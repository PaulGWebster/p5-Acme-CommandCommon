package Acme::CommandCommon::Plugin::V1;

# Internal perl
use v5.30.0;
use feature 'say';

# Internal perl modules (core)
use strict;
use warnings;

# Internal perl modules (core,recommended)
use utf8;
use open qw(:std :utf8);
use experimental qw(signatures);

# External modules - Core
use Carp;
use Try::Tiny;

# External modules - Net
use Socket qw(PF_INET SOCK_STREAM pack_sockaddr_in inet_aton inet_pton);
use IO::Socket qw(AF_INET AF_UNIX);
use IO::Socket::INET;

# Version of this software
our $VERSION = '0.001';

=head1 NAME

Acme::CommandCommon::Plugin::V1 - Version 1 common commands

=head1 SYNOPSIS

=for comment Brief examples of using the module.

    # To call this plugin directly:
    my $v1 = Acme::CommandCommon::Plugin::V1->new();
    my $count = $v1->count_occurrences(
        qr/some_text/,
        'some_text and some_text'
    );
    say "Count: $count"; # 2

    # Or to use the interface like you are meant to :)
    my $common = Acme::CommandCommon->new(1);
    my $count = $common->exec(
        'count_occurrences',
        qr/some_text/,
        'some_text and some_text'
    );
    say "Count: $count"; # 2

=head1 DESCRIPTION

=for comment The module's description.

Version 1 of the CommandCommon functions, can be used directly.

=cut

# Primary code block
sub new {
    my ($class,$args) = @_;

    my $self = bless {
        functions   =>  qw[
            count_occurrences
            split_on_seperator
            test_tcp4_bind
            valid_ipv4
        ],
        version     =>  1,
    }, $class;

    return $self;  
}

=head1 FUNCTIONS

Note that the titles below here like general or network are simply to make it 
easier to find documentation on what you want, the functions are all availible 
in this versions object.

=head2 General

Basic counting, splitting and data manipulation functions.

=head3 type

Return the type of an object, this is just a simple wrapper around ref()
for the sake of clarity.

Via CommandCommon:

    $common->exec('type',$someScalar);

Or directly via this module:

    $v1->type($someScalar);

Expected arguments:

    Arg1: The object.

Return: the type.

=cut

sub type($self,$object) {
    return ref(\$object);
}

=head3 count_occurrences

Count the occurences of a regex or string within a string, takes two mandatory 
arguments.

Via CommandCommon:

    $common->exec('count_occurrences',qr/word/,'word and word');

Or directly via this module:

    $v1->count_occurrences(qr/word/,'word of words in words');

Expected arguments:

    arg1: The match criteria as a qr// or string
    arg2: The data to match against

Will return the number of matches of arg1 in arg2.

=cut

sub count_occurrences($self,$match_criteria,$data) {
    if (!$match_criteria || !$data)  {
        croak "Invalid arguments passed to function";
    }

    my $count = () = $data =~ /$match_criteria/g;

    return $count;
}

=head3 split_on_seperator

Split a string into two components a head and a tail.

Via CommandCommon:

    $common->exec('split_on_seperator','word and word',' and ');

Or directly via this module:

    $v1->count_occurrences('word and word',' and ');

Accepts 1 mandatory argument and 1 optional argument, example:

    Arg1: The string to operate on.
    Arg2: The optional seperator, defaults to ':'.

Will return a list containing 2 items the head and tail.

=cut

sub split_on_seperator($self,$string,$seperator = ':') {
    if (!$string) {
        croak "No value passed to process.";
    }
    my ($head,$tail) = split(/$seperator/,$string,2);
    return ($head,$tail);
}

=head2 Length

Related to the length of various things

=head3 array_length

Count the length of an array, example call:

Via CommandCommon:

    $common->exec('array_length',@array);

Or directly via this module:

    $v1->array_length(@array);

Expected arguments:

    arg1: The array

Will return the number of elements in the target array

=cut

sub array_length($self,@array) {
    return scalar(@array);
}

=head3 arrayref_length

Count the length of an array an arrayref points to

Via CommandCommon:

    $common->exec('arrayref_length',\@array);

Or directly via this module:

    $v1->arrayref_length(\@array);

Expected arguments:

    Arg1: The arrayref

Will return the number of elements in the target array

=cut

sub arrayref_length($self,$arrayref) {
    return scalar(@{$arrayref});
}

=head2 Network related

Speifically for testing the validity of ips or if they are bindable etc.

=head3 test_tcp4_bind

Attempt to bind a port on ipv4/tcp and report if succesful

Via CommandCommon:

    $common->exec('test_tcp4_bind','127.0.0.1',8080);

Or directly via this module:

    $v1->test_tcp4_bind('127.0.0.1',8080);

Expected arguments:

    Arg1: An ip
    Arg2: A port

Returns 0 on success and 1 on error.

=cut 

sub test_tcp4_bind($self,$bind_ip,$bind_port) {
    if ($self->valid_ipv4($bind_ip)) { return 1; }

    my $error_detected = 0;

    my $server = IO::Socket->new(
        Domain      => AF_INET,
        Type        => SOCK_STREAM,
        Proto       => 'tcp',
        LocalHost   => $bind_ip,
        LocalPort   => $bind_port,
        ReusePort   => 1,
        Listen      => 5,
    ) || do { $error_detected = 1 };

    return $error_detected;
}

=head3 valid_ipv4

Check if the provided ip is a valid ipv4 address.

Via CommandCommon:

    $common->exec('test_tcp4_bind','127.0.0.1');

Or directly via this module:

    $v1->valid_ipv4('127.0.0.1');

Accepts 1 mandatory argument of an ipv4 address.

Returns 0 if the address is valid, 1 if it is not.

=cut

sub valid_ipv4($self,$ipv4) {
    my $error_detected = 0;
    try {
        inet_pton(AF_INET, $ipv4);
    }
    catch {
        $error_detected = 1;
    };
    return $error_detected;
}

=head1 AUTHOR

Paul G Webster <daemon@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by Paul G Webster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

1;
