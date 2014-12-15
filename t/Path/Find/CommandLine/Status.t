#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;
use File::Temp;
no warnings qw{qw};

BEGIN { unshift( @INC, './lib' ) }
use Path::Find::Exception;

BEGIN {
	use Test::Most;
	use Test::Output;
	use Test::Exception;
	use Test::Files;
}

use_ok('Path::Find::CommandLine::Status');

my $script_name = 'statusfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( "--test", "-t", "species", "-i", "shigella");
$exp_out = read_file('t/data/statusfind/1.txt');
$obj = Path::Find::CommandLine::Status->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 2
@args = ( "--test", "-t", "file", "-i", "t/data/statusfind/status_lanes.txt" );
$exp_out = read_file('t/data/statusfind/2.txt');
$obj = Path::Find::CommandLine::Status->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 3
@args = ( "--test", "-t", "lane", "-i", "5477_6#1" );
$exp_out = read_file('t/data/statusfind/3.txt');
$obj = Path::Find::CommandLine::Status->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 65
@args = ( "--test", "-t", "study", "-i", "3" );
$exp_out = read_file('t/data/statusfind/4.txt');
$obj = Path::Find::CommandLine::Status->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


remove_tree($tmp);
done_testing();
