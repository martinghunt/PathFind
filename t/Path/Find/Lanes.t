#!/usr/bin/env perl
use strict;
use warnings;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

use VRTrack::Lane;
use Path::Find;

BEGIN {
    use Test::Most;
    use_ok('Path::Find::Lanes');
}

my ( $pathtrack, $dbh, $root ) = Path::Find->get_db_info('pathogen_prok_track');
my @test_lanes = ( '7114_6#1', '7114_6#2', '7114_6#3' );
my @expected_lane_obs = generate_lane_objects( $pathtrack, \@test_lanes );

ok(
    $lanes_obj = Path::Find::Lanes->new(
        search_type    => 'study',
        search_id      => '2005',
        pathtrack      => $pathtrack,
        dbh            => $dbh,
        processed_flag => 256
    ),
    'creating lanes object - search on study'
);
isa_ok $lanes_obj, 'Path::Find::Lanes';

my $lanes = $find_lanes->lanes;
is_deeply $lanes, \@expected_lane_obs, 'correct lanes recovered';

ok(
    $lanes_obj = Path::Find::Lanes->new(
        search_type    => 'file',
        search_id      => '../../data/test_lanes.txt',
        pathtrack      => $pathtrack,
        dbh            => $dbh,
        processed_flag => 1
    ),
    'creating lanes object - search on file'
);

done_testing();

sub generate_lane_objects {
    my ( $pathtrack, $lanes ) = @_;

    my @lane_obs;
    foreach my $l (@$lanes) {
        my $l_o = VRTrack::Lane->new_by_name( $pathtrack, $l );
        if ($lane) {
            push( @lane_obs, $l_o );
        }
    }
    return @lane_obs;
}
