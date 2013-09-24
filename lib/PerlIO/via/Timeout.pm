#
# This file is part of PerlIO-via-Timeout
#
# This software is copyright (c) 2013 by Damien "dams" Krotkine.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package PerlIO::via::Timeout;
{
  $PerlIO::via::Timeout::VERSION = '0.14';
}

# ABSTRACT: a PerlIO layer that adds read & write timeout to a handle

require 5.008;
use strict;
use warnings;
use Carp;
use Errno qw(EBADF);
use Scalar::Util qw(reftype blessed);

use PerlIO::via::Timeout::Strategy::NoTimeout;

use Exporter 'import'; # gives you Exporter's import() method directly
our @EXPORT_OK = qw(timeout_strategy);


# used to associate strategies to file descriptors
my %strategy;

sub _get_fd {
    # params: FH
    my $fd = fileno($_[0] or return);
    defined $fd && $fd >= 0
      or $! = EBADF, return;
    $fd;
}

sub PUSHED {
    # params CLASS, MODE, FH
    defined (my $fd = _get_fd $_[2] ) or return -1;
    bless { }, $_[0];
}

sub POPPED {
# params: SELF [, FH ]
    defined (my $fd = _get_fd $_[1]) or return;
    delete $strategy{$fd}
}

sub CLOSE {
    # params: SELF, FH
    defined (my $fd = _get_fd $_[1]) or return;
    delete $strategy{$fd};
    close $_[1];
}

sub READ {
    # params: SELF, BUF, LEN, FH
    my $self = shift;
    defined (my $fd = _get_fd $_[2]) or return 0;
    ($strategy{$fd} ||= PerlIO::via::Timeout::Strategy::NoTimeout->new())->READ(@_, $fd);
}

sub WRITE {
    # params: SELF, BUF, FH
    my $self = shift;
    defined (my $fd = _get_fd $_[1]) or return -1;
    ($strategy{$fd} ||= PerlIO::via::Timeout::Strategy::NoTimeout->new())->WRITE(@_, $fd);
}


sub timeout_strategy {
    # params: FH [, STRATEGY, PARAMS]
    @_ and reftype $_[0] || '' eq 'GLOB' or croak 'timeout(FH [, STRATEGY, PARAMS... ])';
    defined (my $fd = _get_fd $_[0]) or croak 'bad file descriptor for handle';
    if (@_ > 1) {
        shift;
        my $strategy = shift;
        if (blessed $strategy) {
            $strategy{$fd} = $strategy;
            $strategy{$fd}{_fd} = $fd;
        } else {
            $strategy =~ s/^\+//
              or $strategy = 'PerlIO::via::Timeout::Strategy::' . $strategy;
            my $file = $strategy;
            $file =~ s!::|'!/!g;
            $file .= '.pm';
            require $file;
            $strategy{$fd} = $strategy->new(_fd => $fd, @_);
        }
    }
    return $strategy{$fd} ||= PerlIO::via::Timeout::Strategy::NoTimeout->new();
}

1;


__END__
=pod

=head1 NAME

PerlIO::via::Timeout - a PerlIO layer that adds read & write timeout to a handle

=head1 VERSION

version 0.14

=head1 SYNOPSIS

  use PerlIO::via::Timeout qw(timeout_strategy);
  open my $fh, '<:via(Timeout)', 'foo.html';

  # creates a new timeout strategy with 0.5 second timeout, using select as
  # timeout system
  timeout_strategy($fh, 'Select', read_timeout => 0.5);

  my $line = <$fh>;
  if ($line == undef && $! eq 'Operation timed out') { ... }

=head1 DESCRIPTION

This package implements a PerlIO layer, that adds read / write timeout. This
can be useful to avoid blocking while accessing a filehandle, and fail after
some time.

=head1 FUNCTIONS

=head2 timeout_strategy

  # creates a L<PerlIO::via::Timeout::Strategy::Select strategy> with 0.5
  # read_timeout and set it to $fh
  timeout_strategy($fh, 'Select', read_timeout => 0.5);

  # same but give an alarm strategy instance directly
  my $strategy = PerlIO::via::Timeout::Strategy::Alarm->new(write_timeout => 2)
  timeout_strategy($fh, $strategy);

  # used as a getter, returns the current strategy
  my $strategy = timeout_strategy($fh);

=head1 AVAILABLE STRATEGIES

=over

=item L<PerlIO::via::Timeout::Strategy::Select>

=item L<PerlIO::via::Timeout::Strategy::Alarm>

=back

=head1 SEE ALSO

=over

=item L<PerlIO::via>

=back

=head1 THANKS TO

=over

=item Vincent Pit

=item Christian Hansen

=item Leon Timmmermans

=back

=head1 AUTHOR

Damien "dams" Krotkine

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Damien "dams" Krotkine.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

