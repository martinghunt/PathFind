#!/usr/bin/env perl
use strict;
use warnings;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

use VRTrack::Lane;

BEGIN {
    use Test::Most;
    use_ok('Path::Find::Lanes');
}




done_testing();

sub generate_lane_objects {
	my ($pathtrack, $lanes) = @_;
	
	my @lane_obs;
	foreach my $l (@$lanes){
		my $l_o = VRTrack::Lane->new_by_name($pathtrack, $l);
		if($lane){
			push(@lane_obs, $l_o);
		}
	}
	return @lane_obs;
}