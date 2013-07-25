#!/usr/bin/env perl

use 5.12.0;
use strict;
use warnings;

use Test::More;

use_ok 'App::PerlWatcher::ui::Gtk2::Application';
use_ok 'App::PerlWatcher::ui::Gtk2::EngineBackend';
use_ok 'App::PerlWatcher::ui::Gtk2::StatusesModel';
use_ok 'App::PerlWatcher::ui::Gtk2::StatusesTreeView';
use_ok 'App::PerlWatcher::ui::Gtk2::SummaryLevelSwitcher';
use_ok 'App::PerlWatcher::ui::Gtk2::Utils';

done_testing();

