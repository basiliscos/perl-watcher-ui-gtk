package App::PerlWatcher::UI::Gtk2::Widgets::CellRendererActivatablePixbuf;
# ABSTRACT: CellRenderer with triggers some action on clicking on some image in cell

use 5.12.0;
use strict;
use warnings;

use Gtk2;

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
    if($cell->get('pixbuf')){
        $cell->signal_emit("activated", $path);
        return 1;
    }
    return 0;
}

1;
