package App::PerlWatcher::UI::Gtk2::Application;

use 5.12.0;
use strict;
use warnings;

use AnyEvent;
use App::PerlWatcher::Engine;
use App::PerlWatcher::Level qw/:levels/;
use App::PerlWatcher::UI::Gtk2::StatusesModel;
use App::PerlWatcher::UI::Gtk2::StatusesTreeView;
use App::PerlWatcher::UI::Gtk2::SummaryLevelSwitcher;
use App::PerlWatcher::UI::Gtk2::Utils qw/get_level_icon/;
use Devel::Comments;
use Gtk2;
use Gtk2::TrayIcon;
use POSIX qw(strftime);
use Scalar::Util qw/weaken/;

use base qw/App::PerlWatcher::Frontend/;

sub new {
    my ( $class, $engine ) = @_;
    my $self = $class->SUPER::new($engine);
    
    Gtk2->init;
    my $icon      = Gtk2::TrayIcon->new("test");
    my $event_box = Gtk2::EventBox->new;

    my $icon_widget = Gtk2::Image->new;
    $event_box->add($icon_widget);
    $icon->add($event_box);

    $self -> {_icon                 } = $icon;
    $self -> {_icon_widget          } = $icon_widget;
    $self -> {_timers               } = [];
    $self -> {_summary_level        } = LEVEL_NOTICE;
    $self -> {_focus_tracked_widgets} = [];          

    $self->_consruct_gui;
    $self->_construct_menu;
    
    $icon->signal_connect( "button-press-event" => sub {
            # button-press-event
            my ($widget, $event) = @_;
            if ( $event->button == 1 ) { # left
                my ($x, $y) = $event->root_coords;
                $self -> _present($x, $y);
                return 1;
            }
            elsif ( $event->button == 3 ) { # right
                #$self->_mark_as_read;
               $self->{_tray_menu}->popup(undef,undef,undef,undef,0,0);
               $self->{_tray_menu}->show_all;
               return 1;
            }
            return 0;
    });

    $self->_set_label("just started", LEVEL_ANY, 0);
    return $self;
}

sub update {
    my ( $self, $status ) = @_;
    my $visible = $self->{_window}->get('visible');
    my $model = $self->{_tree_store};
    $model->update($status, $visible, sub {
            my $path = shift;
            $self->{_treeview}->expand_row($path, 1);
    });
    #$self->{_treeview}->expand_all;
    $self->_trigger_undertaker if ( $visible );
    $self->_update_summary;
}
                                  
sub show {
    my $self = shift;
    $self->{_icon}->show_all();
}

sub _update_summary {
    my $self = shift;
    my $summary_level = $self->{_summary_level};
    my $summary = $self->{_tree_store}->summary($summary_level);
    my $has_updated =  @{ $summary->{updated} };
    my $sorted_statuses = $self->engine->sort_statuses($summary->{updated});
    my $tip = join "\n", map { $_->description->() } @$sorted_statuses;
    my $notification_level = "notificaiton level: $summary_level"; 
    $tip = sprintf("%s %s (%s)",
                "PerlWatcher",
                $App::PerlWatcher::Engine::VERSION // "dev", 
                $notification_level)
        . ($tip ? "\n\n" . $tip : "");
    $self->_set_label($tip, $summary->{max_level}, $has_updated);
}

sub _set_label {
    my ( $self, $tip, $level, $is_new ) = @_;
    my $icon = get_level_icon($level, $is_new);
    $self->{_icon_widget}->set_tooltip_markup($tip);
    $self->{_icon_widget}->set(pixbuf => $icon);
}

sub _construct_window {
    my $self   = shift;
    my $window = Gtk2::Window->new;

    my $default_size =
      $self->engine->config->{frontend}->{gtk}->{window_size}
      // [ 500, 300 ];

    $window->set_default_size(@$default_size);
    $window->set_title('Title');

    #$window -> set_decorated(0);
    #$window -> set_opacity(0); # not works yet
    $window->set_skip_taskbar_hint(1);
    $window->set_type_hint('tooltip');
    $window->signal_connect( delete_event => \&Gtk2::Widget::hide_on_delete );
    $window->signal_connect('focus-out-event' => sub {
            # focus out
            my $idle_w; $idle_w = AnyEvent->timer(after => 0.5, cb => sub {
                    my $has_tracked_widgets = @{$self->{_focus_tracked_widgets}};
                    my $child_window_focus = 0;
                    $child_window_focus &&= $_->considered_active
                        for(@{$self->{_focus_tracked_widgets}});
                    my $do_hide = ($has_tracked_widgets && $child_window_focus);
                    ### $do_hide
                    if($do_hide) {
                        $window->hide;
                        $self->{_timers} = []; # kill all timers
                        $self->last_seen(time);
                    }
                    undef $idle_w;
             });
            0;
    });

    return $window;
}

sub _consruct_gui {
    my $self = shift;
    my $window = $self->_construct_window;

    my $vbox = Gtk2::VBox->new( 0, 3 );
    $window->add($vbox);

    my $hbox = Gtk2::HBox->new( 0, 5 );
    $vbox->pack_start( $hbox, 0, 0, 0 );
    
    my $summary_level_switcher = App::PerlWatcher::UI::Gtk2::SummaryLevelSwitcher
        ->new($self, sub { $self->{_summary_level} = shift } );
    push @{ $self->{_focus_tracked_widgets}}, $summary_level_switcher;
        
    #my $icon_widget = Gtk2::Label->new('Action');
    #$hbox->pack_start( $icon_widget, 0, 0, 5 );
    
    $hbox->pack_start( $summary_level_switcher, 0, 0, 5 );
    
    my $reset_button = Gtk2::Button->new_with_label('Mark as read');
    $reset_button->signal_connect( 'clicked' => sub {
            $self->_mark_as_read;
    });    
    $hbox->pack_end( $reset_button, 1, 1, 0 );

    my $tree_store = App::PerlWatcher::UI::Gtk2::StatusesModel
        ->new($self);
    my $treeview   = App::PerlWatcher::UI::Gtk2::StatusesTreeView
        ->new($tree_store, $self);
    $vbox->pack_start( $treeview, 1, 1, 0 );                       
    
    $vbox->show_all;

    $self->{_custom_widget} = $vbox;
    $self->{_window}        = $window;
    $self->{_tree_store}    = $tree_store;
    $self->{_treeview}      = $treeview;
}

sub _construct_menu {
    my $self = shift;
    weaken $self;
    
    my $tray_menu = Gtk2::Menu->new();
    
    my $menu_read = Gtk2::MenuItem->new('mark all as read');
    $menu_read->signal_connect('activate' => sub {
            $self->_mark_as_read;
    });
    $tray_menu->append($menu_read);
    
    $tray_menu->append(Gtk2::SeparatorMenuItem->new());
    
    my $menu_item_quit = Gtk2::MenuItem->new('quit');
    $menu_item_quit->signal_connect('activate' => sub {
            $self->_quit;
    });
    $tray_menu->append($menu_item_quit);
    
    $self->{_tray_menu} = $tray_menu;
}

sub _present {
    my ( $self, $x, $y ) = @_;
    my $window = $self->{_window}; 
    #if ( !$window->get('visible') ) {
        $window->hide_all;
        $window->move( $x, $y );
        $window->show_all;
        $window->present;
        $self->_trigger_undertaker;
    #}
}

sub _trigger_undertaker {
    my $self = shift;
    my $idle = 
        $self->engine->config->{frontend}->{gtk}->{uninteresting_after} // 5;
    my $timer = AnyEvent->timer (
        after => $idle,
        cb    => sub {
            $self->_mark_as_read;
        },
    );                                       
    push @{ $self->{_timers} }, $timer;
}

sub _mark_as_read {
    my $self = shift;
    $self->{_timers} = [];
    $self->{_tree_store}->stash_outdated(time);
    $self->_update_summary;
}

sub _quit {
    my $self = shift;
    $self->engine->stop;
}

1;
