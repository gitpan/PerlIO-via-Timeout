#
# This file is part of PerlIO-via-Timeout
#
# This software is copyright (c) 2013 by Damien "dams" Krotkine.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package PerlIO::via::Timeout::Strategy::Select;
{
  $PerlIO::via::Timeout::Strategy::Select::VERSION = '0.18';
}

# ABSTRACT: a L<PerlIO::via::Timeout> strategy that uses C<select>

require 5.008;
use strict;
use warnings;
use Carp;
use Errno qw(EINTR ETIMEDOUT);

use parent qw(PerlIO::via::Timeout::Strategy::NoTimeout);



sub READ {
    my ($self, undef, $len, $fh, $fd) = @_;

    $self->timeout_enabled
      or return shift->SUPER::READ(@_);

    my $read_timeout = $self->read_timeout
      or return shift->SUPER::READ(@_);

    my $offset = 0;
    while () {
        if ( $len && ! can_read_write($fh, $fd, $read_timeout, 0)) {
            $! = ETIMEDOUT unless $!;
            return 0;
        }
        my $r = sysread($fh, $_[1], $len, $offset);
        if (defined $r) {
            last unless $r;
            $len -= $r;
            $offset += $r;
        }
        elsif ($! != EINTR) {
            return 0;
        }
    }
    return $offset;
}

sub WRITE {
    my ($self, undef, $fh, $fd) = @_;

    $self->timeout_enabled
      or return shift->SUPER::WRITE(@_);

    my $write_timeout = $self->write_timeout
      or return shift->SUPER::WRITE(@_);

    my $len = length $_[1];
    my $offset = 0;
    while () {
        if ( $len && ! can_read_write($fh, $fd, $write_timeout, 1)) {
            $! = ETIMEDOUT unless $!;
            return -1;
        }
        my $r = syswrite($fh, $_[1], $len, $offset);
        if (defined $r) {
            $len -= $r;
            $offset += $r;
            last unless $len;
        }
        elsif ($! != EINTR) {
            return -1;
        }
    }
    return $offset;
}

sub can_read_write {
    my ($fh, $fd, $timeout, $type) = @_;
    # $type: 0 = read, 1 = write
    my $initial = time;
    my $pending = $timeout;
    my $nfound;

    vec(my $fdset = '', $fd, 1) = 1;

    while () {
        if ($type) {
            # write
            $nfound = select(undef, $fdset, undef, $pending);
        } else {
            # read
            $nfound = select($fdset, undef, undef, $pending);
        }
        if ($nfound == -1) {
            $! == EINTR
              or croak(qq/select(2): '$!'/);
            redo if !$timeout || ($pending = $timeout - (time -
            $initial)) > 0;
            $nfound = 0;
        }
        last;
    }
    $! = 0;
    return $nfound;
}


1;

__END__
=pod

=head1 NAME

PerlIO::via::Timeout::Strategy::Select - a L<PerlIO::via::Timeout> strategy that uses C<select>

=head1 VERSION

version 0.18

=head1 SYNOPSIS

  use PerlIO::via::Timeout qw(timeout_strategy);
  binmode($fh, ':via(Timeout)');
  timeout_strategy($fh, 'Select', read_timeout => 0.5);

=head1 DESCRIPTION

This class implements a timeout strategy to be used by L<PerlIO::via::Timeout>.

Timeout is implemented using the C<select> core function.

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

