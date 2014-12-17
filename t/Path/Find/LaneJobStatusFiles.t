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
ok($obj->pipeline_status->{stored}->time_stamp =~ /\d\d-\d\d-\d\d\d\d/, 'stored time of last run');
is($obj->pipeline_status->{stored}->current_status, 'running', 'stored running status');
ok($obj->pipeline_status->{assembled}->time_stamp =~ /\d\d-\d\d-\d\d\d\d/, 'assembled time of last run');
is($obj->pipeline_status->{assembled}->current_status, 'failed', 'assembled running status');


ok($obj = Path::Find::LaneJobStatusFiles->new(directory => 't/data/tradisfind'), 'invalid directory');
is_deeply($obj->pipeline_status, {}, 'nothing parsed in invalid directory');

done_testing();
