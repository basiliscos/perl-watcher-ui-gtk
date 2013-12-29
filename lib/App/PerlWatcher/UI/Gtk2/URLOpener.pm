package App::PerlWatcher::UI::Gtk2::URLOpener;
# ABSTRACT: The class is responsible for opening urls after a shord idle.

use 5.12.0;
use strict;
use warnings;

use AnyEvent;
use Devel::Comments;
use List::MoreUtils qw/any/;
use Moo;
use Scalar::Util qw/weaken/;

=head1 DESCRIPTION

The more detailed description of PerlWatcher application can be found here:
L<https://github.com/basiliscos/perl-watcher>.

=cut

=attr openables

The list of objects been opened in browser

=cut

has 'openables'  => ( is => 'rw', default => sub{ []; } );

=attr timer

AE timer object, which will open all openables on timeout

=cut

has 'timer' => (is => 'rw', clearer => 1);

=attr delay

The timeout which should pass after delayed_open is been invoked
to open all openables.

=cut

has 'delay' => (is => 'rw', required => 1);

=attr callback

Callback is been invoked when timer triggers. It's arguments
is the array ref openables.

=cut

has 'callback' => (is => 'rw', required => 1);


=attr tick_step

The tick step for invocation of tick_callback

=cut

has 'tick_step' => (is => 'rw', default => sub{ 0.1 });

=attr tick_callback

Callback is been invoked, during delay before actual opening
links. The value is the fraction of time passed left before
open links. When fraction is 1, that means the moment of opening
them.

=cut

has 'tick_callback' => (is => 'rw', default => sub{ sub{} });

=method delayed_open

Puts the openable into queue and resets the timer. When
timer triggers all openables are open and erased from list

=cut

sub delayed_open {
    my ($self, $openable) = @_;
    my $openables = $self->openables;
    push @$openables, $openable
        unless( any {$_ == $openable} @$openables);

    weaken $self;
    my $start = AE::now;
    my $delay = $self->delay;
    my $end   = $start+$delay;
    my $timer = AE::timer 0, $self->tick_step, sub {
        my $now = AE::now;
        if ($now >= $end) {
            $self->tick_callback->(1.0, $openables);
            $_->open_url for( @$openables );
            $self->openables([]);
            $self->callback->($openables);
            $self->clear_timer;
        } else {
            my $fraction = ($now-$start)/$delay;
            $self->tick_callback->($fraction, $openables);
        }
    };
    $self->timer($timer);
}

1;
