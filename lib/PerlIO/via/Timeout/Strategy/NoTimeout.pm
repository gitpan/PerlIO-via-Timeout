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
  $PerlIO::via::Timeout::Strategy::NoTimeout::VERSION = '0.14';
}

# ABSTRACT: a L<PerlIO::via::Timeout> strategy that don't do any timeout


require 5.008;
use strict;
use warnings;

use PerlIO::via::Timeout::Strategy;
our @ISA = qw(PerlIO::via::Timeout::Strategy);

sub READ {
    my ($self, undef, $len, $fh, $fd) = @_;
    return sysread($fh, $_[1], $len);
}

sub WRITE {
    my ($self, undef, $fh, $fd) = @_;
    return syswrite($fh, $_[1]);
}

1;

__END__
=pod

=head1 NAME

PerlIO::via::Timeout::Strategy::NoTimeout - a L<PerlIO::via::Timeout> strategy that don't do any timeout

=head1 VERSION

version 0.14

=DESCRIPTION

This class is the default strategy used by L<PerlIO::via::Timeout> if none is
provided. This strategy does B<not> apply any timeout on the filehandle.

This strategy is only useful for other strategies to herit from. It should not
be used directly.

=head1 AUTHOR

Damien "dams" Krotkine

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Damien "dams" Krotkine.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

