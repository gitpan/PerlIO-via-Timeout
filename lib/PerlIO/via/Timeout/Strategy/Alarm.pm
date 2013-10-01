#
# This file is part of PerlIO-via-Timeout
#
# This software is copyright (c) 2013 by Damien "dams" Krotkine.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package PerlIO::via::Timeout::Strategy::Alarm;
{
  $PerlIO::via::Timeout::Strategy::Alarm::VERSION = '0.17';
}

# ABSTRACT: a L<PerlIO::via::Timeout> strategy that uses L<Time::Out> (based on alarm)

require 5.008;
use strict;
use warnings;
use Carp;
use Errno qw(ETIMEDOUT);

use parent qw(PerlIO::via::Timeout::Strategy::NoTimeout);

use Time::Out qw(timeout);



sub new {
    $^O eq 'MSWin32'
      and croak "This Strategy is not supported on 'MSWin32'";
    return shift->SUPER::new(@_);
}

sub READ {
    my ($self, undef, $len, $fh, $fd) = @_;

    $self->timeout_enabled
      or return shift->SUPER::READ(@_);

    my $read_timeout = $self->read_timeout
      or return shift->SUPER::READ(@_);

    my $rv;
    # We have to do some convolution so that READ's second argument is still an
    # alias on the buffer variable
    if ( ! timeout $read_timeout, \@_ => sub { $rv = shift(@{$_[0]})->SUPER::READ(@{$_[0]}); 1 } ) {
        $@ eq 'timeout'
          or croak $@;
        $! = ETIMEDOUT;
        return 0
    }
    return $rv;
}

sub WRITE {
    my ($self, undef, $fh, $fd) = @_;

    $self->timeout_enabled
      or return shift->SUPER::WRITE(@_);

    my $write_timeout = $self->write_timeout
      or return shift->SUPER::WRITE(@_);

    my $rv;
    if ( ! timeout $write_timeout, @_ => sub { $rv = shift->SUPER::WRITE(@_); 1 } ) {
        $@ eq 'timeout'
          or croak $@;
        $! = ETIMEDOUT;
        return 0
    }
    return $rv;
}



1;

__END__
=pod

=head1 NAME

PerlIO::via::Timeout::Strategy::Alarm - a L<PerlIO::via::Timeout> strategy that uses L<Time::Out> (based on alarm)

=head1 VERSION

version 0.17

=head1 SYNOPSIS

  use Time::HiRes;
  use PerlIO::via::Timeout qw(timeout_strategy);
  binmode($fh, ':via(Timeout)');
  timeout_strategy($fh, 'Alarm', read_timeout => 0.5);

=head1 DESCRIPTION

This class implements a timeout strategy to be used by L<PerlIO::via::Timeout>.

Timeout is implemented using the L<Time::Out>, which uses the C<alarm> core
function, but with a safe harness.

=head1 METHODS

=head2 new

Constructor of the strategy. Takes as arguments a list of key / values :

=over

=item read_timeout

The read timeout in second. Can be a float

=item write_timeout

The write timeout in second. Can be a float

=item timeout_enabled

Boolean. Defaults to 1

=back

=head1 UNDER THE SECOND TIMEOUTS

Warning, if you need timeout at a precision finer than the second, you need to use L<Time::HiRes>.

=head1 COMPATIBILITY

Doesn't work on Windows

=head1 SEE ALSO

=over

=item L<PerlIO::via::Timeout>

=back

=head1 AUTHOR

Damien "dams" Krotkine

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Damien "dams" Krotkine.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

