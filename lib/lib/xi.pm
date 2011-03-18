package lib::xi;
use 5.008_001;
use strict;
use warnings;

our $VERSION = '0.01';

use Carp        ();
use Config      ();
use File::Which ();
use File::Spec  ();

our $CPANM_PATH = File::Which::which('cpanm')
    || die '[lib::ex] cpanm is not available';

use constant _VERBOSE => ! ! $ENV{PERL_LIBXI_VERBOSE};

sub new {
    my($class, %args) = @_;
    return bless \%args, $class;
}

# must be fully-qualified; othewise implied ::INC.
sub lib::xi::INC {
    my($self, $file) = @_;

    my @args = (@{ $self->{cpanm_opts} }, $file);
    print STDERR "[lib::xi] cpanm @args\n" if _VERBOSE;
    system $^X, $CPANM_PATH, @args;

    foreach my $lib (@{ $self->{libs} }) {
        if(open my $inh, '<', "$lib/$file") {
            $INC{$file} = "$lib/$file";
            return $inh;
        }
    }

    Carp::croak("[lib::xi] Try to install $file via `cpanm @args` but failed");
}

sub import {
    my($class, @cpanm_opts) = @_;

    my $install_dir;

    if(@cpanm_opts && $cpanm_opts[0] !~ /^-/) {
        $install_dir = File::Spec->rel2abs(shift @cpanm_opts);
    }

    my @libs;

    if($install_dir) {
        @libs = (
            "$install_dir/lib/perl5",
            "$install_dir/lib/perl5/$Config::Config{archname}",
        );
        push @INC, @libs;
        print STDERR "[lib::xi] add [@libs] to \@INC\n" if _VERBOSE;

        unshift @cpanm_opts, '-l', $install_dir;
    }

    push @INC, $class->new(
        install_dir => $install_dir,
        libs        => \@libs,
        cpanm_opts  => \@cpanm_opts,
    );
    return;
}
1;
__END__

=head1 NAME

lib::xi - Perl extention to do something

=head1 VERSION

This document describes lib::xi version 0.01.

=head1 SYNOPSIS

    # to install missing libaries
    $ perl -Mlib::xi script.pl

    # to install missing libaries to extlib/ (with cpanm -l extlib)
    $ perl -Mlib::xi=extlib script.pl

    # with cpanm options
    $ perl -Mlib::xi=-L,extlib,-q script.pl

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<Dist::Maker::Template::Default>

=head1 AUTHOR

Fuji, Goro (gfx) E<lt>gfuji@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011, Fuji, Goro (gfx). All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
