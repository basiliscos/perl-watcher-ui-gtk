#!/usr/bin/env perl

use 5.12.0;
use strict;
use warnings;

use Carp;
use Devel::Comments;
use Hash::Merge qw( merge );
use FindBin;

BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use App::PerlWatcher::Bootstrap qw/get_home_file config engine_config/;
use App::PerlWatcher::Engine;
use App::PerlWatcher::ui::Gtk2::Application;

{
    package X;
    
    use AnyEvent;
    use App::PerlWatcher::Engine;
    use App::PerlWatcher::Level qw/:levels/;
    use App::PerlWatcher::ui::Gtk2::Utils qw/level_to_symbol/;
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
    
        my $label = Gtk2::Label->new("test");
        $event_box->add($label);
        $icon->add($event_box);
    
        $self -> {_icon      } = $icon;
        $self -> {_label     } = $label;
        $self -> {_timers    } = [];
        $self -> {_summary_level} = LEVEL_NOTICE;
        
        $self -> {_focus_tracked_widgets} = [];          
    
        $self->_consruct_gui;
        
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
        my $summary = $self->{_tree_store}->summary($self->{_summary_level});
        # $summary
        my $symbol = level_to_symbol($summary->{max_level});
        $symbol = @{ $summary->{updated} } ? "<b>$symbol</b>" : $symbol;
        my $sorted_statuses = $self->engine->sort_statuses($summary->{updated});
        $symbol = "[$symbol]";
        my $tip = join "\n", map {
                sprintf("[%s] %s", level_to_symbol($_->level), $_->description->())
            } @$sorted_statuses;
        $tip = sprintf("%s %s","PerlWatcher",$App::PerlWatcher::Engine::VERSION // "dev")
            . ($tip ? "\n\n" . $tip : "");
        $self->_set_label($symbol, $tip);
    }
    
    sub _set_label {
        my ( $self, $text, $tip ) = @_;
        $self->{_label}->set_markup($text);
        $self->{_label}->set_tooltip_markup($tip);
    }
    
    sub _construct_window {
        my $self   = shift;
        my $window = Gtk2::Window->new;
    
        my $default_size =[ 500, 300 ];
    
        $window->set_default_size(@$default_size);
        $window->set_title('Title');
    
        #$window -> set_decorated(0);
        #$window -> set_opacity(0); # not works yet
        $window->set_skip_taskbar_hint(1);
        $window->set_type_hint('tooltip');
        $window->signal_connect('focus-out-event' => sub {
                ### focus out
                my $idle_w; $idle_w = AnyEvent->timer(after => 0.5, cb => sub {
                        my $child_window_focus = @{$self->{_focus_tracked_widgets}};
                        $child_window_focus &&= $_->considered_active
                            for(@{$self->{_focus_tracked_widgets}});
                        my $do_hide = !$child_window_focus;
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
    
            my $button = Gtk2::Button->new ('Quit');
            $button->signal_connect (clicked => sub { Gtk2->main_quit });
            $window->add ($button);    
        $self->{_window}        = $window;
    }
    
    sub _present {
        my ( $self, $x, $y ) = @_;
        my $window = $self->{_window}; 
        #if ( !$window->get('visible') ) {
            $window->hide_all;
            $window->move( $x, $y );
            $window->show_all;
            $window->present;
        #}
    }
    
}

my $config = {
    backend => 'Gtk2',
    defaults    => {
        timeout     => 1,
        behaviour   => {
            ok  => { 
                1 => 'notice', 
                2 => 'info' 
            },
            fail => { 1 => 'alert' }
        },
    },
    watchers => [
    ],
};

my $backend = 'Gtk2';
my $engine = App::PerlWatcher::Engine->new($config, $backend);
my $app = X->new($engine);

$engine->frontend( $app );

$app->show;
$engine->start;

1;

