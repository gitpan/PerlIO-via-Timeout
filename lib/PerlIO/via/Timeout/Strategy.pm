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
  $PerlIO::via::Timeout::Strategy::VERSION = '0.20';
}

# ABSTRACT: base class for a L<PerlIO::via::Timeout> strategies

require 5.008;
use strict;
use warnings;
use Carp;


sub new {
    my $class = shift;
    @_ % 2 and croak "parameters should be key value pairs";
    my $self = bless { read_timeout => 0, write_timeout => 0, timeout_enabled => 1, @_ }, $class;
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


sub timeout_enabled {
    @_ > 1 and $_[0]{timeout_enabled} = !!$_[1];
    $_[0]{timeout_enabled};
}


sub enable_timeout { $_[0]->timeout_enabled(1) }


sub disable_timeout { $_[0]->timeout_enabled(0) }

sub READ { croak "READ is not implemented by this strategy" }

sub WRITE { croak "WRITE is not implemented by this strategy" }

1;


__END__
=pod

=head1 NAME

PerlIO::via::Timeout::Strategy - base class for a L<PerlIO::via::Timeout> strategies

=head1 VERSION

version 0.20

=head1 DESCRIPTION

This package implements the virtual class from which all timeout strategies are
supposed to inherit from.

=head1 METHODS

=head2 read_timeout

Getter / setter of the read timeout value.

=head2 write_timeout

Getter / setter of the write timeout value.

=head2 timeout_enabled

Getter / setter of the timeout enabled flag.

=head2 enable_timeout

equivalent to setting timeout_enabled to 1

=head2 disable_timeout

equivalent to setting timeout_enabled to 0

=head1 CONSTRUCTOR

=head2 new

  my $strategy = PerlIO::via::Timeout::Strategy::Alarm->new(write_timeout => 2)

Creates a new timeout strategy. Takes in argument a hash, which keys can be:

=over

=item read_timeout

the read timeout in second. Float >= 0. Defaults to 0

=item write_timeout

the write timeout in second. Float >= 0. Defaults to 0

=item timeout_enabled

sets/unset timeout. Boolean. Defaults to 1

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

