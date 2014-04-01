#!/usr/bin/env perl
use strict;
use warnings;
use File::Slurp;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

use VRTrack::Lane;
use Path::Find;

BEGIN {
    use Test::Most;
}

use_ok('Path::Find::Lanes');

my ( $pathtrack, $dbh, $root ) = Path::Find->new->get_db_info('pathogen_prok_track');
my ( $lanes, $lanes_obj );

# test lanes by study
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

$lanes = $lanes_obj->lanes;

my @test_lanes1 = ( '7114_6#1', '7114_6#2', '7114_6#3' );
my @expected_lanes1 = generate_lane_objects( $pathtrack, \@test_lanes1 );

is_deeply $lanes, \@expected_lanes1, 'correct lanes recovered';

# test lanes from file
ok(
    $lanes_obj = Path::Find::Lanes->new(
        search_type    => 'file',
        search_id      => 't/data/Lanes/test_lanes.txt',
        pathtrack      => $pathtrack,
        dbh            => $dbh,
        processed_flag => 1
    ),
    'creating lanes object - search on file'
);
isa_ok $lanes_obj, 'Path::Find::Lanes';

$lanes = $lanes_obj->lanes;

open( FILE, "<", "t/data/Lanes/test_lanes.txt" );
my @test_lanes2 = <FILE>;
chomp @test_lanes2;
my @expected_lanes2 = generate_lane_objects( $pathtrack, \@test_lanes2 );

is_deeply $lanes, \@expected_lanes2, 'correct lanes recovered';

# test lanes from lane ID
ok(
    $lanes_obj = Path::Find::Lanes->new(
        search_type    => 'lane',
        search_id      => '8086_1',
        pathtrack      => $pathtrack,
        dbh            => $dbh,
        processed_flag => 4
    ),
    'creating lanes object - search on lane ID'
);
isa_ok $lanes_obj, 'Path::Find::Lanes';

$lanes = $lanes_obj->lanes;

my @test_lanes3 = (
    '8086_1#1', '8086_1#2', '8086_1#3', '8086_1#4',
    '8086_1#5', '8086_1#6', '8086_1#7', '8086_1#8'
);
my @expected_lanes3 = generate_lane_objects( $pathtrack, \@test_lanes3 );

is_deeply $lanes, \@expected_lanes3, 'correct lanes recovered';

# test lanes from species
ok(
    $lanes_obj = Path::Find::Lanes->new(
        search_type    => 'species',
        search_id      => 'Blautia producta',
        pathtrack      => $pathtrack,
        dbh            => $dbh,
        processed_flag => 1
    ),
    'creating lanes object - search on species name'
);
isa_ok $lanes_obj, 'Path::Find::Lanes';

$lanes = $lanes_obj->lanes;

my @test_lanes4 = (
    '5749_8#1', '5749_8#2', '5749_8#3', '8080_1#72'
);
my @expected_lanes4 = generate_lane_objects( $pathtrack, \@test_lanes4 );
is_deeply $lanes, \@expected_lanes4, 'correct lanes recovered';

done_testing();

sub generate_lane_objects {
    my ( $pathtrack, $lanes ) = @_;

    my @lane_obs;
    foreach my $l (@$lanes) {
        my $l_o = VRTrack::Lane->new_by_name( $pathtrack, $l );
        if ($l_o) {
            push( @lane_obs, $l_o );
        }
    }
    return @lane_obs;
}
