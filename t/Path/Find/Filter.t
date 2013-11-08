#!/usr/bin/env perl
use strict;
use warnings;
use Storable;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

use VRTrack::Lane;
use Path::Find;

BEGIN {
    use Test::Most tests => 5;
}

use_ok('Path::Find::Filter');

my ( $pathtrack, $dbh, $root ) = Path::Find->get_db_info('pathogen_prok_track');
my ( $filter, @matching_lanes );

my %type_extensions = (
    fastq => '*.fastq.gz',
    bam   => '*.bam'
);

# test fastq filtering
my @fastq_lanes =
  ( '5749_8#1', '5749_8#2', '5749_8#3', '5749_8#4', '5749_8#5', '5749_8#6' );
my @fastq_obs = generate_lane_objects( $pathtrack, \@fastq_lanes );

$filter = Path::Find::Filter->new(
    lanes           => \@fastq_obs,
    filetype        => 'fastq',
    root            => $root,
    pathtrack       => $pathtrack,
    type_extensions => \%type_extensions
);
@matching_lanes = $filter->filter;

my @expected_fastq = retrieve("../../data/fastq_lanes.store");
is_deeply \@matching_lanes, \@expected_fastq, 'correct fastq files recovered';

#test bam filtering
my @bam_lanes = ( '4880_8#1', '4880_8#2', '4880_8#3', '4880_8#4', '4880_8#5' );
my @bam_obs = generate_lane_objects( $pathtrack, \@bam_lanes );

$filter = Path::Find::Filter->new(
    lanes           => \@bam_obs,
    filetype        => 'bam',
    root            => $root,
    pathtrack       => $pathtrack,
    type_extensions => \%type_extensions
);
@matching_lanes = $filter->filter;

my @expected_bams = retrieve("../../data/bam_lanes.store");
is_deeply \@matching_lanes, \@expected_bams, 'correct bam files recovered';

#test verbose output
my @verbose_lanes = (
    '8086_1#1', '8086_1#2', '8086_1#3', '8086_1#4',
    '8086_1#5', '8086_1#6', '8086_1#7', '8086_1#8'
);
my @verbose_obs = generate_lane_objects( $pathtrack, \@verbose_lanes );

$filter = Path::Find::Filter->new(
    lanes           => \@verbose_obs,
    root            => $root,
    pathtrack       => $pathtrack,
    verbose         => 1
);
@matching_lanes = $filter->filter;

my @expected_verbose = retrieve("../../data/verbose.store");
is_deeply \@matching_lanes, \@expected_verbose, 'correct verbose files recovered';

#filtered on date
$filter->{date} = "01-07-2013";
@matching_lanes = $filter->filter;

my @expected_date = retrieve("../../data/date_filter.store");
is_deeply \@matching_lanes, \@expected_date, 'correctly dated files recovered';

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
