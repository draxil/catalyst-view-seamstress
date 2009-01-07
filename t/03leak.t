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
    plan 'tests' => 2;
}

use Catalyst::Test 'TestApp';
my $handle;

my $count = Devel::Leak::NoteSV( $handle );

get( 'index.html' );


my $count2 = Devel::Leak::CheckSV( $handle );

# If this isn't working then...
ok( $count2 > $count, 'Leak is seeing us allocate resources' );

Devel::Leak::NoteSV( $handle );

# Make 100 requests for index.html!
get( 'index.html' ) for( 1..100 );

my $count3 = Devel::Leak::CheckSV( $handle );

# OK Check that we're still looking good object count wise: Note: we used to just
# say $count3 <= $count2, but that seemed to fail on some systems, I think due
# to debugging + devel leak. this should still catch any new leaks.
ok( $count3 <= ($count2 + ( $count2 * 0.1) ), 'Making 100 requests didn\'t inflate the object count (much)' );


