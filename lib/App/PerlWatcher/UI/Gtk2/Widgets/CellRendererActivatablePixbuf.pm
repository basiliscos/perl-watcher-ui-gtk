package App::PerlWatcher::UI::Gtk2::Widgets::CellRendererActivatablePixbuf;
{
  $App::PerlWatcher::UI::Gtk2::Widgets::CellRendererActivatablePixbuf::VERSION = '0.04';
}

use Glib::Object::Subclass
    Gtk2::CellRendererPixbuf::,
    signals => {
        activated => {
            param_types => ['Glib::String'],
        },            
    },
    properties => [];

sub INIT_INSTANCE {
    my $self = shift;
    $self->set(mode => 'activatable');
}

sub ACTIVATE {
    my ($cell, $event, $widget, $path, $background_area, $cell_area, $flags) = @_;
    ### activate
    $cell->signal_emit("activated", $path);
    return 1;
}

1;