package App::PerlWatcher::ui::Gtk2::Utils;

use 5.12.0;
use strict;
use warnings;

use Carp;
use Devel::Comments;
use File::ShareDir::ProjectDistDir ':all';
use Gtk2;
use Memoize;

use App::PerlWatcher::Level qw/:levels/;

use parent qw/Exporter/;

our @EXPORT_OK = qw/get_level_icon/;

memoize('get_level_icon');
sub get_level_icon {
    my ($level, $unseen) = @_;
    my $postfix = $unseen ? "_new" : "";
    my $filename = dist_file(__PACKAGE__, "assets/icons/${level}${postfix}.png");
    ### $filename
    return unless -r $filename;
    my @icon_size = Gtk2::IconSize->lookup('menu');
    my $pixbuff = Gtk2::Gdk::Pixbuf->new_from_file_at_scale($filename, @icon_size, 1);
    return $pixbuff;
}
