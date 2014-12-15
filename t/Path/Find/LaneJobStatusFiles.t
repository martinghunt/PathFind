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
    use_ok('Path::Find::LaneJobStatusFiles');
}


ok(my $obj = Path::Find::LaneJobStatusFiles->new(directory => 't/data/lane_job_status'), 'valid directory');
is($obj->pipeline_status->{stored}->time_stamp, '05-07-2014', 'stored time of last run');
is($obj->pipeline_status->{stored}->current_status, 'running', 'stored running status');
is($obj->pipeline_status->{assembled}->time_stamp, '11-21-2014', 'assembled time of last run');
is($obj->pipeline_status->{assembled}->current_status, 'failed', 'assembled running status');


ok($obj = Path::Find::LaneJobStatusFiles->new(directory => 't/data/tradisfind'), 'invalid directory');
is_deeply($obj->pipeline_status, {}, 'nothing parsed in invalid directory');

done_testing();
