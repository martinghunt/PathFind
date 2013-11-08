#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
	use Test::Output;
    use_ok('Path::Find::CommandLine::PanGenome');
}
my $script_name = 'Path::Find::CommandLine::PanGenome';
my $cwd = getcwd();

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my ($args, $exp_out, $pang_obj);

# test file parse
$args = "-t file -i t/data/annotation_lanes.txt";
$exp_out = "***";
#$pang_obj = Path::Find::CommandLine::PanGenome->new(args => $args, script_name => $script_name);
#stdout_is($pang_obj->run, $exp_out, "Correct results for '$args'");


done_testing();

