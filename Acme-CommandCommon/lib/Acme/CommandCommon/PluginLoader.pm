package Acme::CommandCommon::PluginLoader;
 
use strict;
use vars qw($VERSION $FORCE_SEARCH_ALL_PATHS);
use Acme::CommandCommon::PluginLoader::Object;

use v5.16.0;
use if $] > 5.017, 'deprecate';

# Version of this software
our $VERSION = '5.2';
$FORCE_SEARCH_ALL_PATHS = 0;

=pod

=head1 NAME

Acme::CommandCommon::PluginLoader - (A fork of Module::Pluggable 5.2)

=head2 DESCRIPTION

This is a DIRECT COPY of https://metacpan.org/release/Module-Pluggable/source/lib/Module/Pluggable.pm

It is only used exclusively for Acme::CommandCommon and is therefore not documented,
the reason for copying this module is to guarantee compatability going forwards.

If you are interested in using a pluginloader, please see the original version 
of this module at: https://metacpan.org/pod/Module::Pluggable

Some minor alterations may be present for purely vanity reasons (spacing etc)

=head2 LICENSE

This module is available under the Perl 5 license.

=head3 COPYRIGHT

Copyright 2006 Simon Wistow

=head2 AUTHOR

The original author of this module was https://metacpan.org/author/SIMONW

The present author of this fork is Paul G Webster https://metacpan.org/author/DAEMON

This fork is entirely under the management and development of Paul G Webster.

=cut

sub import {
    my $class        = shift;
    my %opts         = @_;

    my ($pkg, $file) = caller;
    # the default name for the method is 'plugins'
    my $sub          = $opts{'sub_name'}  || 'plugins';
    # get our package
    my ($package)    = $opts{'package'} || $pkg;
    $opts{filename}  = $file;
    $opts{package}   = $package;
    $opts{force_search_all_paths} = $FORCE_SEARCH_ALL_PATHS unless exists $opts{force_search_all_paths};

    my $finder       = Acme::CommandCommon::PluginLoader::Object->new(%opts);
    my $subroutine   = sub { my $self = shift; return $finder->plugins(@_) };

    my $searchsub = sub {
        my $self = shift;
        my ($action,@paths) = @_;

        $finder->{'search_path'} = ["${package}::Plugin"] if ($action eq 'add' and not $finder->{'search_path'} );
        push @{$finder->{'search_path'}}, @paths      if ($action eq 'add');
        $finder->{'search_path'}       = \@paths      if ($action eq 'new');
        return $finder->{'search_path'};
    };

    my $onlysub = sub {
        my ($self, $only) = @_;

        if (defined $only) {
            $finder->{'only'} = $only;
        };

        return $finder->{'only'};
    };

    my $exceptsub = sub {
        my ($self, $except) = @_;

        if (defined $except) {
            $finder->{'except'} = $except;
        };

        return $finder->{'except'};
    };

    no strict 'refs';
    no warnings qw(redefine prototype);

    *{"$package\::$sub"}        = $subroutine;
    *{"$package\::search_path"} = $searchsub;
    *{"$package\::only"}        = $onlysub;
    *{"$package\::except"}      = $exceptsub;
}

1;