package App::PerlWatcher::ui::Gtk2::SummaryLevelSwitcher;

use 5.12.0;
use strict;
use warnings;

use Devel::Comments;
use Gtk2;


use App::PerlWatcher::Level qw/:levels/;

use base 'Gtk2::ComboBox';

sub new {
    my ($class, $app, $cb) = @_;
    my $self = Gtk2::ComboBox->new_text;
    bless $self, $class;
    
    my @all_levels = @App::PerlWatcher::Level::ALL_LEVELS;
    my %model;
    @model{@all_levels} = @all_levels;
    
    $self->append_text($_) for(@all_levels);
    $self->{_app} = $app;
    
    $self->signal_connect(changed => sub {
            my $label = $self->get_active_text;
            my $value = $model{$label};
            ### $value
            $cb->($value);
    });
    return $self;    
}

sub considered_active {
    return shift->get('popup-shown');
}

1;
