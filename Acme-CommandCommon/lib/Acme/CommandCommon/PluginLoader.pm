package Acme::CommandCommon::PluginLoader;
 
use strict;
use vars qw($VERSION $FORCE_SEARCH_ALL_PATHS);
use Acme::CommandCommon::PluginLoader::Object;

use if $] > 5.017, 'deprecate';

# Version of this software
our $VERSION = '5.2';
$FORCE_SEARCH_ALL_PATHS = 0;

=pod
 
=head1 NAME

Acme::CommandCommon::PluginLoader - (A version frozen copy of Module::Pluggable 5.2)

=head2 README - LICENSE

This is a DIRECT COPY of https://metacpan.org/source/SIMONW/Module-Pluggable-5.2/lib/Module/Pluggable/Object.pm
Which has been renamed to stop module name collisions, due to the nature of 
CommandCommon in that it requires explicit versioning and requires as little
moving parts as possible, I decided that the best thing to do in regards to
the plugin loader was to use one I knew worked and leave this notice in it
along with its LICENSE, I could find no LICENSE file the only reference to
any license is found in the POD and reads:

    COPYING

    Copyright, 2006 Simon Wistow

    Distributed under the same terms as Perl itself.

So I have included that as well as this notice.

=head2 LICENSE

I have no idea what to write here.

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
 
              $finder->{'search_path'} = ["${package}::Plugin"] if ($action eq 'add'  and not   $finder->{'search_path'} );
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