#
# This file is part of PerlIO-via-Timeout
#
# This software is copyright (c) 2013 by Damien "dams" Krotkine.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package PerlIO::via::Timeout::Strategy;
{
  $PerlIO::via::Timeout::Strategy::VERSION = '0.10';
} # hide from CPAN

# ABSTRACT: base class for a L<PerlIO::via::Timeout> strategies

require 5.008;
use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    @_ % 2 and croak "parameters should be key value pairs";
    my $self = bless { read_timeout => 0, write_timeout => 0, @_ }, $class;
    $self->_check_attributes;
    $self;
}

sub _check_attributes {
    grep { $_[0]->{$_} < 0 } qw(read_timeout write_timeout)
      and croak "if defined, 'read_timeout' and 'write_timeout' attributes should be >= 0";
}

sub read_timeout {
    @_ > 1 and $_[0]{read_timeout} = $_[1], $_[0]->_check_attributes;
    $_[0]{read_timeout};
}

sub write_timeout {
    @_ > 1 and $_[0]{write_timeout} = $_[1], $_[0]->_check_attributes;
    $_[0]{write_timeout};    
}

sub READ { croak "READ is not implemented by this strategy" }

sub WRITE { croak "WRITE is not implemented by this strategy" }

1;

__END__
=pod

=head1 NAME

PerlIO::via::Timeout::Strategy - base class for a L<PerlIO::via::Timeout> strategies

=head1 VERSION

version 0.10

=head1 AUTHOR

Damien "dams" Krotkine

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Damien "dams" Krotkine.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

