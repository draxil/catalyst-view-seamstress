#!/usr/bin/perl

# check that the changes to stop this view leaking worked (and stay working!)

use strict;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;

eval('require Devel::Leak' );

if ( $@ ) {
    plan 'skip_all' => 'No Devel Leak' ;
}
else {
    plan 'tests' => 1;
}

use Catalyst::Test 'TestApp';
my $handle;

my $count = Devel::Leak::NoteSV( $handle );

get( 'index.html' );


my $count2 = Devel::Leak::CheckSV( $handle );

# If this isn't working then...
ok( $count2 > $count, 'Leak is seeing us allocate resources' );

my $count = Devel::Leak::NoteSV( $handle );

# Make 100 requests for index.html!
get( 'index.html' ) for( 1..100 );

my $count3 = Devel::Leak::CheckSV( $handle );

# OK Check that we're still looking good object count wise:
ok( $count3 <= $count2, 'Making 100 requests didn\'t inflate the object count' );

print "$count $count2 $count3\n";
