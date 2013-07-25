package App::PerlWatcher::ui::Gtk2::Utils;
{
  $App::PerlWatcher::ui::Gtk2::Utils::VERSION = '0.03';
}

use 5.12.0;
use strict;
use warnings;

use Carp;
use Devel::Comments;
use App::PerlWatcher::Level qw/:levels/;

use parent qw/Exporter/;

our @EXPORT_OK = qw/level_to_symbol/;

our %_SYMBOLS_FOR = (
    'unknown'   => '?',
    'notice'    => 'n',
    'info'      => 'i',
    'warn'      => 'w',
    'alert'     => 'A',
    'ignore'    => '-',
);

sub level_to_symbol {
    my $level = shift;
    return $_SYMBOLS_FOR{$level};
}

