package App::PerlWatcher::UI::Gtk2::SummaryLevelSwitcher;

use 5.12.0;
use strict;
use warnings;

use Devel::Comments;
use Gtk2;


use App::PerlWatcher::Level qw/:levels/;
use App::PerlWatcher::UI::Gtk2::Utils qw/get_level_icon/;

use base 'Gtk2::ComboBox';

sub new {
    my ($class, $app, $cb) = @_;
    #my $self = Gtk2::ComboBox->new_text;
    my $self = Gtk2::ComboBox->new;
    bless $self, $class;
    
    my $model = $self->_create_levels_model;
    $self->_create_renderers;
    
    $self->{_app    } = $app;
    $self->set_model($model);
    
    # $self->signal_connect(changed => sub {
            # my $label = $self->get_active_text;
            # my $value = $model{$label};
            # $cb->($value);
    # });
    return $self;    
}

sub _create_levels_model {
    my $self = shift;
    my $model = Gtk2::ListStore->new(qw/Glib::Scalar/);
    my @all_levels = @App::PerlWatcher::Level::ALL_LEVELS;
    $model->set($model->append, 0, $_) for(@all_levels);
    return $model;
}

sub _create_renderers {
    my $self = shift;
    $self->_create_icon_renderer;
    $self->_create_label_renderer;
}

sub _create_icon_renderer {
    my $self = shift;
    my $renderer_icon = Gtk2::CellRendererPixbuf->new;
    $self->pack_start($renderer_icon, 0);
    $self->set_cell_data_func(
        $renderer_icon, sub {
            my ( $column, $cell, $model, $iter, $func_data ) = @_;
            my $level = $model->get_value( $iter, 0 );
            my $pixbuff = get_level_icon($level, 0);
            $cell->set( pixbuf => $pixbuff)
        }
    );
}

sub _create_label_renderer {
    my $self = shift;
    my $renderer_label = Gtk2::CellRendererText->new;
    $self->pack_start($renderer_label, 0);
    $self->set_cell_data_func(
        $renderer_label, sub {
            my ( $column, $cell, $model, $iter, $func_data ) = @_;
            my $level = $model->get_value( $iter, 0 );
            $cell->set(text => "$level" );
        }
    );
}

sub considered_active {
    return shift->get('popup-shown');
}

1;
