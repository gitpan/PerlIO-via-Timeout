#
# This file is part of PerlIO-via-Timeout
#
# This software is copyright (c) 2013 by Damien "dams" Krotkine.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package PerlIO::via::Timeout::Strategy::NoTimeout;
{
  $PerlIO::via::Timeout::Strategy::NoTimeout::VERSION = '0.21';
}

# ABSTRACT: a L<PerlIO::via::Timeout> strategy that don't do any timeout


require 5.008;
use strict;
use warnings;
use Errno qw(EINTR);

use PerlIO::via::Timeout::Strategy;
our @ISA = qw(PerlIO::via::Timeout::Strategy);


sub READ {
    my ($self, undef, $len, $fh, $fd) = @_;
    my $offset = 0;
    while () {
        my $r = sysread($fh, $_[1], $len, $offset);
        if (defined $r) {
            last unless $r;
            $len -= $r;
            $offset += $r;
        }
        elsif ($! != EINTR) {
            # There is a bug in PerlIO::via (possibly in PerlIO ?). We would like
            # to return -1 to signify error, but doing so doesn't work (it usually
            # segfault), it looks like the implementation is not complete. So we
            # return 0.
            return 0;
        }
    }
    return $offset;
}

sub WRITE {
    my ($self, undef, $fh, $fd) = @_;
    my $len = length $_[1];
    my $offset = 0;
    while () {
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

1;

__END__
=pod

=head1 NAME

PerlIO::via::Timeout::Strategy::NoTimeout - a L<PerlIO::via::Timeout> strategy that don't do any timeout

=head1 VERSION

version 0.21

=DESCRIPTION

This class is the default strategy used by L<PerlIO::via::Timeout> if none is
provided. It inherits L<PerlIO::via::Timeout::Strategy>. This strategy does
B<not> apply any timeout on the filehandle.

This strategy is only useful for other strategies to inherit from. It should B<not>
be used directly.

=head1 CONSTRUCTOR

See L<PerlIO::via::Timeout::Strategy>.

=head1 METHODS

See L<PerlIO::via::Timeout::Strategy>.

=head1 AUTHOR

Damien "dams" Krotkine

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Damien "dams" Krotkine.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

