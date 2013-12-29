package App::PerlWatcher::UI::Gtk2::URLOpener;
{
  $App::PerlWatcher::UI::Gtk2::URLOpener::VERSION = '0.10';
}
# ABSTRACT: The class is responsible for opening urls after a shord idle.

use 5.12.0;
use strict;
use warnings;

use AnyEvent;
use Devel::Comments;
use List::MoreUtils qw/any/;
use Moo;
use Scalar::Util qw/weaken/;



has 'openables'  => ( is => 'rw', default => sub{ []; } );


has 'timer' => (is => 'rw', clearer => 1);


has 'delay' => (is => 'rw', required => 1);


has 'callback' => (is => 'rw', required => 1);



has 'tick_step' => (is => 'rw', default => sub{ 0.1 });


has 'tick_callback' => (is => 'rw', default => sub{ sub{} });


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

__END__

=pod

=encoding UTF-8

=head1 NAME

App::PerlWatcher::UI::Gtk2::URLOpener - The class is responsible for opening urls after a shord idle.

=head1 VERSION

version 0.10

=head1 DESCRIPTION

The more detailed description of PerlWatcher application can be found here:
L<https://github.com/basiliscos/perl-watcher>.

=head1 ATTRIBUTES

=head2 openables

The list of objects been opened in browser

=head2 timer

AE timer object, which will open all openables on timeout

=head2 delay

The timeout which should pass after delayed_open is been invoked
to open all openables.

=head2 callback

Callback is been invoked when timer triggers. It's arguments
is the array ref openables.

=head2 tick_step

The tick step for invocation of tick_callback

=head2 tick_callback

Callback is been invoked, during delay before actual opening
links. The value is the fraction of time passed left before
open links. When fraction is 1, that means the moment of opening
them.

=head1 METHODS

=head2 delayed_open

Puts the openable into queue and resets the timer. When
timer triggers all openables are open and erased from list

=head1 AUTHOR

Ivan Baidakou <dmol@gmx.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Ivan Baidakou.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
