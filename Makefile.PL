
use strict;
use warnings;

use 5.012;

use ExtUtils::MakeMaker 6.72;

use File::ShareDir::Install;
install_share dist => "share";


my %WriteMakefileArgs = (
  "ABSTRACT" => "Gtk2 frontend for perl watcher",
  "AUTHOR" => "Ivan Baidakou <dmol\@gmx.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.72",
    "File::ShareDir::Install" => "0.03"
  },
  "DISTNAME" => "App-PerlWatcher-UI-Gtk2",
  "EXE_FILES" => [
    "bin/perl-watcher-gtk",
    "bin/perl-watcher-gtk"
  ],
  "LICENSE" => "perl",
  "NAME" => "App::PerlWatcher::UI::Gtk2",
  "PREREQ_PM" => {
    "AnyEvent" => "7.04",
    "App::PerlWatcher::Engine" => "0.18",
    "Devel::Comments" => "v1.1.4",
    "File::ShareDir::ProjectDistDir" => "v0.4.4",
    "Gtk2" => "1.247",
    "Gtk2::TrayIcon" => "0.06",
    "Hash::Merge" => "0.200",
    "Image::Base::Gtk2::Gdk::Pixbuf" => 11,
    "Keybinder" => "0.02",
    "List::MoreUtils" => "0.33",
    "Moo" => "1.003000",
    "Scalar::Util" => "1.25",
    "aliased" => "0.31"
  },
  "TEST_REQUIRES" => {
    "File::Spec" => 0,
    "File::Temp" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Test::More" => "0.98"
  },
  "VERSION" => "0.10",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "AnyEvent" => "7.04",
  "App::PerlWatcher::Engine" => "0.18",
  "Devel::Comments" => "v1.1.4",
  "File::ShareDir::ProjectDistDir" => "v0.4.4",
  "File::Spec" => 0,
  "File::Temp" => 0,
  "Gtk2" => "1.247",
  "Gtk2::TrayIcon" => "0.06",
  "Hash::Merge" => "0.200",
  "IO::Handle" => 0,
  "IPC::Open3" => 0,
  "Image::Base::Gtk2::Gdk::Pixbuf" => 11,
  "Keybinder" => "0.02",
  "List::MoreUtils" => "0.33",
  "Moo" => "1.003000",
  "Scalar::Util" => "1.25",
  "Test::More" => "0.98",
  "aliased" => "0.31"
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);

{
package
MY;
use File::ShareDir::Install qw(postamble);
}


