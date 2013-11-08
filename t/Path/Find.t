#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './lib') }
BEGIN {
    use Test::Most tests => 9;
}

use_ok('Path::Find');

# Check hierarchy template
is Path::Find->hierarchy_template, 'genus:species-subspecies:TRACKING:projectssid:sample:technology:library:lane', 'hierarchy ok';

my $db_file = '/lustre/scratch108/'; # Database filesystem
my $db_root = $db_file.'pathogen/pathpipe/'; # Database root directory
my $database_A = 'pathogen_prok_track'; # existing database
my $location_A = $db_root.'prokaryotes/seq-pipelines';
my $database_B = 'pathogen_trex_track'; # unknown database

# Skip testing if database filesystem not mounted.
unless( -d $db_file)
{
    done_testing();
    exit;
} 

# Find existing database
my ($vrtrack_A, $dbi_A, $root_A) = Path::Find->get_db_info($database_A);

isa_ok $vrtrack_A, 'VRTrack::VRTrack';
isa_ok $dbi_A, 'DBI::db';
is $root_A, $location_A, 'found known directory ok';

# Fail to find non-existing database
my ($vrtrack_B, $dbi_B, $root_B) = Path::Find->get_db_info($database_B);

is $vrtrack_B, undef, 'vrtrack fails for unknown ok';
is $dbi_B, undef, 'dbi fails for unknown ok';
is $root_B, undef, 'root fails for unknown ok';

# Check pathogen databases list
my $databases = scalar Path::Find->pathogen_databases;
my $db_list_ok = $databases ? 1:0;
is $db_list_ok, 1, "$databases pathogen databases listed";

done_testing();
exit;
