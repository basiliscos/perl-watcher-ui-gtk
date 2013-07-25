package App::PerlWatcher::ui::Gtk2::EngineBackend;
{
  $App::PerlWatcher::ui::Gtk2::EngineBackend::VERSION = '0.03';
}

use 5.12.0;
use strict;
use warnings;

use Gtk2;

sub new{
    my $class = shift;
    my $self = {};
    return bless $self => $class;
}

sub start_loop {
    Gtk2->main;
}

sub stop_loop {
    Gtk2->main_quit;
}

1;
