#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok 'POE::Component::ResourcePool::Resource::TryList';

use POE::Component::ResourcePool::Resource::Collection;

my $first  = POE::Component::ResourcePool::Resource::Collection->new( values => [ 1 .. 3 ] );

my $second = POE::Component::ResourcePool::Resource::Collection->new( values => [ qw(foo bar gorch) ] );

my $both = POE::Component::ResourcePool::Resource::TryList->new( resources => [ $first, $second ] );

my @got = $both->try_allocating( undef, undef, 2 );

is_deeply( \@got, [ $first, 1, 2 ], "try" );

is_deeply( [ $both->finalize_allocation( undef, undef, @got ) ], [ [ 1, 2 ] ], "finalize" );

@got = $both->try_allocating( undef, undef, 2 );

is_deeply( \@got, [ $second, qw(foo bar) ], "try" );

is_deeply( [ $both->finalize_allocation( undef, undef, @got ) ], [ [ qw(foo bar) ] ], "finalize" );

@got = $both->try_allocating( undef, undef, 1 );

is_deeply( \@got, [ $first, 3 ], "try" );
