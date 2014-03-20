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
}

use_ok('Path::Find::CommandLine::Path');

my $script_name = 'pathfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args =  ();
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 2
@args = ( "--test", "-h", "yes" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 3
@args = ( "--test", "-a", "empty_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 4
@args = ( "--test", "-f", "fastq" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 5
@args = ( "--test", "-f", "fastq", "-a", "empty_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 6
@args = ( "--test", "-f", "bam", "-a", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 7
@args = ( "--test", "-f", "bam", "-a", "invalid_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 8
@args = ( "--test", "-i", "valid_value" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 9
@args = ( "--test", "-i", "invalid_value", "-f", "fastq" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 10
@args = ( "--test", "-t", "species" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 11
@args = ( "--test", "-t", "species", "-f", "fastq" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 12
@args = ( "--test", "-t", "species", "-f", "bam" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 13
@args = ( "--test", "-t", "species", "-i", "invalid_value" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown'; 

# test 14
@args = ( "--test", "-t", "species", "-i", "shigella" );
$exp_out = read_file('t/data/pathfind/14.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 15
@args = ( "--test", "-t", "species", "-i", "shigella", "-s", "$tmp/test.15.stats" );
$exp_out = read_file('t/data/pathfind/15.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

is(
	read_file('t/data/pathfind/15.stats'),
	read_file("$tmp/test.15.stats"),
	'stats file correct'
);

# # test 16
# @args = ( "--test", "-t", "species", "-i", "shigella", "-qc", "passed" );
# $obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown'; 

# # test 17
# @args = ( "--test", "-t", "species", "-i", "shigella", "-qc", "failed" );
# $obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown'; 

# # test 18
# @args = ( "--test", "-t", "species", "-i", "shigella", "-qc", "pending" );
# $exp_out = read_file('t/data/pathfind/18.txt');
# $obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# $arg_str = join(" ", @args);
# stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 19
@args = ( "--test", "-t", "species", "-i", "shigella", "-a" );
$exp_out = read_file('t/data/pathfind/19.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "pathfind_shigella.tar.gz", 'archive exists');
ok(check_links('pathfind_shigella.tar.gz', $exp_out, 1), 'correct files present');

# test 20
@args = ( "--test", "-t", "species", "-i", "shigella", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/20.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 21
@args = ( "--test", "-t", "species", "-i", "shigella", "-l" );
$exp_out = read_file('t/data/pathfind/21.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "pathfind_shigella", 'archive exists');
ok(check_links('pathfind_shigella', $exp_out, 1), 'correct files present');


# test 22
@args = ( "--test", "-t", "species", "-i", "shigella", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/22.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 23
@args = ( "--test", "-t", "species", "-i", "shigella", "-f", "fastq" );
$exp_out = read_file('t/data/pathfind/23.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 24
@args = ( "--test", "-t", "species", "-i", "shigella", "-f", "fastq", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/24.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 25
@args = ( "--test", "-t", "species", "-i", "shigella", "-f", "fastq", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/25.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 26
@args = ( "--test", "-t", "species", "-i", "shigella", "-f", "fastq", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/26.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 27
@args = ( "--test", "-t", "species", "-i", "shigella", "-f", "fastq", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/27.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 28
@args = ( "--test", "-t", "species", "-i", "strep", "-f", "bam" );
$exp_out = read_file('t/data/pathfind/28.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 29
@args = ( "--test", "-t", "species", "-i", "strep", "-f", "bam", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 30
@args = ( "--test", "-t", "species", "-i", "strep", "-f", "bam", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/30.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 31
@args = ( "--test", "-t", "species", "-i", "strep", "-f", "bam", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/31.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 32
@args = ( "--test", "-t", "species", "-i", "strep", "-f", "bam", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/32.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 33
@args = ( "--test", "-t", "file" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 34
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt" );
$exp_out = read_file('t/data/pathfind/34.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 35
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-s", "yes" );
$exp_out = read_file('t/data/pathfind/35.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check  stats file
is(
	read_file('t/data/pathfind/35.stats'),
	read_file("$tmp/test.35.stats"),
	'stats file correct'
);

# test 36
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-qc", "passed" );
$exp_out = read_file('t/data/pathfind/36.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 37
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-qc", "failed" );
$exp_out = read_file('t/data/pathfind/37.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 38
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-qc", "pending" );
$exp_out = read_file('t/data/pathfind/38.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 39
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/39.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 40
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/40.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 41
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/41.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 42
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/42.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 43
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-f", "fastq" );
$exp_out = read_file('t/data/pathfind/43.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 44
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-f", "fastq", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/44.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 45
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-f", "fastq", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/45.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 46
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-f", "fastq", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/46.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 47
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-f", "fastq", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/47.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 48
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-f", "bam" );
$exp_out = read_file('t/data/pathfind/48.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 49
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-f", "bam", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/49.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 50
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-f", "bam", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/50.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 51
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-f", "bam", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/51.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 52
@args = ( "--test", "-t", "file", "-i", "t/data/pathfind/path_lanes.txt", "-f", "bam", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/52.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 53
@args = ( "--test", "-t", "file", "-i", "invalid_value" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown'; 

# test 54
@args = ( "--test", "-t", "file", "-i", "invalid_value in file" );
$exp_out = read_file('t/data/pathfind/54.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 55
@args = ( "--test", "-t", "lane", "-f", "fastq", "-a", "empty_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 56
@args = ( "--test", "-t", "lane", "-f", "bam" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 57
@args = ( "--test", "-t", "lane", "-i", "valid_value" );
$exp_out = read_file('t/data/pathfind/57.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 58
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-s", "stats" );
$exp_out = read_file('t/data/pathfind/58.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# check  stats file
is(
	read_file('t/data/pathfind/58.stats'),
	read_file("$tmp/test.58.stats"),
	'stats file correct'
);

# test 59
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-qc", "passed" );
$exp_out = read_file('t/data/pathfind/59.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 60
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-qc", "failed" );
$exp_out = read_file('t/data/pathfind/60.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 61
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-qc", "pending" );
$exp_out = read_file('t/data/pathfind/61.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 62
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/62.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 63
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/63.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 64
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/64.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 65
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/65.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 66
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-f", "fastq" );
$exp_out = read_file('t/data/pathfind/66.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 67
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-f", "fastq", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/67.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 68
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-f", "fastq", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/68.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 69
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-f", "fastq", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/69.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 70
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-f", "fastq", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/70.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 71
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-f", "bam" );
$exp_out = read_file('t/data/pathfind/71.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 72
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-f", "bam", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/72.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 73
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-f", "bam", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/73.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 74
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-f", "bam", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/74.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 75
@args = ( "--test", "-t", "lane", "-i", "valid_value", "-f", "bam", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/75.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 76
@args = ( "--test", "-t", "lane", "-i", "invalid_value" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown'; 

# test 77
@args = ( "--test", "-t", "study" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 78
@args = ( "--test", "-t", "study", "-f", "bam", "-l", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 79
@args = ( "--test", "-t", "study", "-i", "valid_value" );
$exp_out = read_file('t/data/pathfind/79.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 80
@args = ( "--test", "-t", "study", "-i", "valid_value", "-s", "yes" );
$exp_out = read_file('t/data/pathfind/80.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check  stats file
is(
	read_file('t/data/pathfind/15.stats'),
	read_file("$tmp/test.15.stats"),
	'stats file correct'
);

# test 81
@args = ( "--test", "-t", "study", "-i", "valid_value", "-qc", "passed" );
$exp_out = read_file('t/data/pathfind/81.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 82
@args = ( "--test", "-t", "study", "-i", "valid_value", "-qc", "failed" );
$exp_out = read_file('t/data/pathfind/82.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 83
@args = ( "--test", "-t", "study", "-i", "valid_value", "-qc", "pending" );
$exp_out = read_file('t/data/pathfind/83.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 84
@args = ( "--test", "-t", "study", "-i", "valid_value", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/84.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 85
@args = ( "--test", "-t", "study", "-i", "valid_value", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/85.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 86
@args = ( "--test", "-t", "study", "-i", "valid_value", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/86.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 87
@args = ( "--test", "-t", "study", "-i", "valid_value", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/87.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 88
@args = ( "--test", "-t", "study", "-i", "valid_value", "-f", "fastq" );
$exp_out = read_file('t/data/pathfind/88.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 89
@args = ( "--test", "-t", "study", "-i", "valid_value", "-f", "fastq", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/89.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 90
@args = ( "--test", "-t", "study", "-i", "valid_value", "-f", "fastq", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/90.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 91
@args = ( "--test", "-t", "study", "-i", "valid_value", "-f", "fastq", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/91.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 92
@args = ( "--test", "-t", "study", "-i", "valid_value", "-f", "fastq", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/92.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 93
@args = ( "--test", "-t", "study", "-i", "valid_value", "-f", "bam" );
$exp_out = read_file('t/data/pathfind/93.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 94
@args = ( "--test", "-t", "study", "-i", "valid_value", "-f", "bam", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/94.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 95
@args = ( "--test", "-t", "study", "-i", "valid_value", "-f", "bam", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/95.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 96
@args = ( "--test", "-t", "study", "-i", "valid_value", "-f", "bam", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/96.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 97
@args = ( "--test", "-t", "study", "-i", "valid_value", "-f", "bam", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/97.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 98
@args = ( "--test", "-t", "study", "-i", "invalid_value" );
$exp_out = read_file('t/data/pathfind/98.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 99
@args = ( "--test", "-t", "species", "-f", "fastq", "-l", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 100
@args = ( "--test", "-t", "species", "-f", "bam" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 101
@args = ( "--test", "-t", "species", "-i", "shigella" );
$exp_out = read_file('t/data/pathfind/101.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 102
@args = ( "--test", "-t", "species", "-i", "shigella", "-s", "yes" );
$exp_out = read_file('t/data/pathfind/102.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check  stats file
is(
	read_file('t/data/pathfind/102.stats'),
	read_file("$tmp/test.102.stats"),
	'stats file correct'
);

# test 103
@args = ( "--test", "-t", "species", "-i", "shigella", "-qc", "passed" );
$exp_out = read_file('t/data/pathfind/103.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 104
@args = ( "--test", "-t", "species", "-i", "shigella", "-qc", "failed" );
$exp_out = read_file('t/data/pathfind/104.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 105
@args = ( "--test", "-t", "species", "-i", "shigella", "-qc", "pending" );
$exp_out = read_file('t/data/pathfind/105.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 106
@args = ( "--test", "-t", "species", "-i", "shigella", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/106.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 107
@args = ( "--test", "-t", "species", "-i", "shigella", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/107.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 108
@args = ( "--test", "-t", "species", "-i", "shigella", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/108.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 109
@args = ( "--test", "-t", "species", "-i", "shigella", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/109.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 110
@args = ( "--test", "-t", "species", "-i", "shigella", "-f", "fastq" );
$exp_out = read_file('t/data/pathfind/110.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 111
@args = ( "--test", "-t", "species", "-i", "shigella", "-f", "fastq", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/111.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 112
@args = ( "--test", "-t", "species", "-i", "shigella", "-f", "fastq", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/112.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 113
@args = ( "--test", "-t", "species", "-i", "shigella", "-f", "fastq", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/113.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 114
@args = ( "--test", "-t", "species", "-i", "shigella", "-f", "fastq", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/114.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 115
@args = ( "--test", "-t", "species", "-i", "strep", "-f", "bam" );
$exp_out = read_file('t/data/pathfind/115.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 116
@args = ( "--test", "-t", "species", "-i", "strep", "-f", "bam", "-a", "empty_dest" );
$exp_out = read_file('t/data/pathfind/116.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out, 1), 'correct files present');

# test 117
@args = ( "--test", "-t", "species", "-i", "strep", "-f", "bam", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/117.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 118
@args = ( "--test", "-t", "species", "-i", "strep", "-f", "bam", "-l", "empty_dest" );
$exp_out = read_file('t/data/pathfind/118.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out, 1), 'correct files symlinked' );

# test 119
@args = ( "--test", "-t", "species", "-i", "strep", "-f", "bam", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/119.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 120
@args = ( "--test", "-t", "species", "-i", "invalid_value" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown'; 

# test 121
@args = ( "--test", "-t", "invalid_value" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 122
@args = ( "--test", "-t", "species", "-i", "strep", "-f", "bam", "-l", "empty_dest", "-a", "empty_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

remove_tree($tmp);
done_testing();

sub check_links {
	my ($n, $fl, $cwd) = @_;

	my $owd = getcwd();
	chdir($tmp) unless($cwd);

	my $dir = $n;
	if($n =~ /\.tar\.gz/){
		system("tar xvfz $n");
		$dir =~ s/\.tar\.gz//;
	}

	my $result = 1;
	foreach my $f (split( "\n", $fl )){
		my @d = split("/", $f);
		my $e = pop @d;
		$result = 0 unless( -e "$dir/$e" );
	}
	chdir($owd) unless($cwd);
	return $result;
}