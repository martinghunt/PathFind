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
    use_ok('Path::Find::LaneJobStatusFile');
}


ok(my $obj = Path::Find::LaneJobStatusFile->new(filename => 't/data/lane_job_status/running_job_status'), 'Running job');
is($obj->pipeline_name, 'stored', 'stored pipeline');
is($obj->time_stamp, '05-07-2014', 'time of last run');
is($obj->current_status, 'running', 'running status');


ok($obj = Path::Find::LaneJobStatusFile->new(filename => 't/data/lane_job_status/failed_job_status'), 'failed job');
is($obj->pipeline_name, 'assembled', 'stored pipeline');
is($obj->time_stamp, '11-21-2014', 'time of last run');
is($obj->current_status, 'failed', 'running status');


ok($obj = Path::Find::LaneJobStatusFile->new(filename => 't/data/lane_job_status/invalid_job_status'), 'invalid format');
is($obj->pipeline_name, undef , 'stored pipeline');
is($obj->time_stamp, undef, 'time of last run');
is($obj->current_status, undef, 'running status');

done_testing();
