#!/usr/bin/env perl
use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use Test::MockObject;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, '../lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Path::Find::LaneStatus');
    
}


set_mocked_lane_data(0);
ok( my $obj = Path::Find::LaneStatus->new( lane => VRTrack::Lane->new() ), 'Create valid object with no flags set' );
is( $obj->imported(),             '-'  , 'no flags set Imported not done' );
is( $obj->qc(),                 '-'  , 'no flags set qc not done' );
is( $obj->mapped(),             '-'  , 'no flags set mapped not done' );
is( $obj->stored(),             '-'  , 'no flags set stored not done' );
is( $obj->improved(),           '-'  , 'no flags set improved not done' );
is( $obj->snp_called(),         '-'  , 'no flags set snp_called not done' );
is( $obj->rna_seq_expression(), '-'  , 'no flags set rna_seq_expression not done' );
is( $obj->assembled(),          '-'  , 'no flags set assembled not done' );
is( $obj->annotated(),          '-'  , 'no flags set annotated not done' );

set_mocked_lane_data(4095);
ok( $obj = Path::Find::LaneStatus->new( lane => VRTrack::Lane->new() ), 'Create valid object with all flags set' );
is( $obj->imported(),             'Done', 'all flags set -  Imported Done' );
is( $obj->qc(),                 'Done', 'all flags set -  qc Done' );
is( $obj->mapped(),             'Done', 'all flags set -  mapped Done' );
is( $obj->stored(),             'Done', 'all flags set -  stored Done' );
is( $obj->improved(),           'Done', 'all flags set -  improved Done' );
is( $obj->snp_called(),         'Done', 'all flags set -  snp_called Done' );
is( $obj->rna_seq_expression(), 'Done', 'all flags set -  rna_seq_expression Done' );
is( $obj->assembled(),          'Done', 'all flags set -  assembled Done' );
is( $obj->annotated(),          'Done', 'all flags set -  annotated Done' );

set_mocked_lane_data(2693);
ok( $obj = Path::Find::LaneStatus->new( lane => VRTrack::Lane->new() ), 'Create valid object with every second flag set' );
is( $obj->imported(),             'Done', 'every second flag set -  Imported Done' );
is( $obj->qc(),                 '-'   , 'every second flag set -  qc not Done' );
is( $obj->mapped(),             'Done', 'every second flag set -  mapped Done' );
is( $obj->stored(),             '-'   , 'every second flag set -  stored not Done' );
is( $obj->improved(),           'Done', 'every second flag set -  improved  Done' );
is( $obj->snp_called(),         '-'   , 'every second flag set -  snp_called not Done' );
is( $obj->rna_seq_expression(), 'Done', 'every second flag set -  rna_seq_expression  Done' );
is( $obj->assembled(),          '-'  ,  'every second flag set -  assembled not Done' );
is( $obj->annotated(),          'Done', 'every second flag set -  annotated  Done' );



done_testing();

sub set_mocked_lane_data {
    my ($processed) = @_;
    my $vlane = Test::MockObject->new();
    $vlane->fake_module( 'VRTrack::Lane', test => sub { 1 } );
    $vlane->fake_new('VRTrack::Lane');
    $vlane->set_isa('VRTrack::Lane');
    $vlane->mock( 'processed', sub { $processed } );
}

