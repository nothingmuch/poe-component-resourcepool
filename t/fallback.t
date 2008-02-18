#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok 'POE::Component::ResourcePool::Resource::TryList';

use POE::Component::ResourcePool::Resource::Collection;

my $first  = POE::Component::ResourcePool::Resource::Collection->new( values => [ 1 .. 3 ] );

my $second = POE::Component::ResourcePool::Resource::Collection->new( values => [ qw(foo bar gorch) ] );

my $both = POE::Component::ResourcePool::Resource::TryList->new( resources => [ $first, $second ] );

ok( $both->could_allocate( undef, undef, 2 ), "could allocate" );

my @one = $both->try_allocating( undef, undef, 2 );

is_deeply( \@one, [ $first, 1, 2 ], "try" );

is_deeply( [ $both->finalize_allocation( undef, undef, @one ) ], [ [ 1, 2 ] ], "finalize" );

my @two = $both->try_allocating( undef, undef, 2 );

is_deeply( \@two, [ $second, qw(foo bar) ], "try" );

is_deeply( [ $both->finalize_allocation( undef, undef, @two ) ], [ [ qw(foo bar) ] ], "finalize" );

is_deeply( [ $both->try_allocating( undef, undef, 1 ) ], [ $first, 3 ], "try" );

is_deeply( [ $both->try_allocating( undef, undef, 2 ) ], [ ], "failed" );

$both->free_allocation( undef, undef, @two );

is_deeply( [ $both->try_allocating( undef, undef, 2 ) ], [ $second, qw(gorch foo) ], "freed" );

$both->free_allocation( undef, undef, @one );

is_deeply( [ $both->try_allocating( undef, undef, 2 ) ], [ $first, 3, 1 ], "freed" );
