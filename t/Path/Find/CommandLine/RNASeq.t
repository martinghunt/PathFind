#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;
use File::Temp;
no warnings qw{qw};

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
	use Test::Output;
	use Test::Exception;
	use Test::Files;
}

use_ok('Path::Find::CommandLine::RNASeq');

my $script_name = 'rnaseqfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/1.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 2
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/2.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 3
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 4
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'spreadsheet', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/4.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 5
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-d', '19-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/5.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 6
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-d', '19-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 7
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 8
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'spreadsheet', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 9
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-r', 'Shigella_flexneri_2a_str_301_v2' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/9.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 10
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-r', 'Shigella_flexneri_2a_str_301_v2', '-m', 'bwa' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/10.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 11
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-r', 'Shigella_flexneri_2a_str_301_v2', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 12
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'spreadsheet', '-r', 'Shigella_flexneri_2a_str_301_v2', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/12.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 13
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-r', 'Shigella_flexneri_2a_str_301_v2', '-d', '19-03-2014', '-m', 'bwa' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/13.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 14
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-r', 'Shigella_flexneri_2a_str_301_v2', '-d', '19-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 15
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-r', 'Shigella_flexneri_2a_str_301_v2', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 16
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'spreadsheet', '-r', 'Shigella_flexneri_2a_str_301_v2', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 17
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-r', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 18
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-r', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 19
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-r', 'invalid_value', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 20
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'spreadsheet', '-r', 'invalid_value', '-d', '19-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 21
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-v' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/21.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 22
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-v', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/22.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 23
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-v', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 24
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'spreadsheet', '-v', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/24.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 25
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-v', '-d', '19-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/25.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 26
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-v', '-d', '19-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 27
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-v', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 28
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'spreadsheet', '-v', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 29
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-v', '-r', 'Shigella_flexneri_2a_str_301_v2' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 30
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-v', '-r', 'Shigella_flexneri_2a_str_301_v2', '-m', 'bwa' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/30.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 31
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-v', '-r', 'Shigella_flexneri_2a_str_301_v2', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 32
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'spreadsheet', '-v', '-r', 'Shigella_flexneri_2a_str_301_v2', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/32.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 33
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-v', '-r', 'Shigella_flexneri_2a_str_301_v2', '-d', '19-03-2014', '-m', 'bwa' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/33.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 34
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-v', '-r', 'Shigella_flexneri_2a_str_301_v2', '-d', '19-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 35
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-v', '-r', 'Shigella_flexneri_2a_str_301_v2', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 36
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'spreadsheet', '-v', '-r', 'Shigella_flexneri_2a_str_301_v2', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 37
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-v', '-r', 'invalid_value' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 38
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-v', '-r', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 39
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-v', '-r', 'invalid_value', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 40
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'spreadsheet', '-v', '-r', 'invalid_value', '-d', '19-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 41
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-s', "$tmp/test.41.stats", '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/41.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check  stats file
is(
	read_file('t/data/rnaseqfind/41.stats'),
	read_file("$tmp/test.41.stats"),
	'stats file correct'
);

# test 42
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-s', "$tmp/test.42.stats", '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/42.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 43
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-s', "$tmp/test.43.stats", '-r', 'Shigella_flexneri_2a_str_301_v2' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/43.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 44
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-s', "$tmp/test.44.stats", '-qc', 'passed', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/44.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 45
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'coverage', '-s', "$tmp/test.45.stats", '-qc', 'failed', '-m', 'smalt' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/45.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 46
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-s', "$tmp/test.46.stats", '-qc', 'pending', '-r', 'Shigella_flexneri_2a_str_301_v2' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/46.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 47
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'intergenic', '-s', "$tmp/test.47.stats", '-qc', 'pending', '-r', 'Shigella_flexneri_2a_str_301_v2', '-h' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 48
@args = ( '--test', '-t', 'file', '-i', 't/data/rnaseqfind/rnaseq_lanes.txt', '-f', 'bam', '-a', "$tmp/test_stats", '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::RNASeq->new(args => \@args, script_name => 'rnaseqfind');
$exp_out = read_file('t/data/rnaseqfind/41.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check stats inside archive
ok( -e "$tmp/test_stats.tar.gz", 'archive exists');
my $owd = getcwd();
chdir($tmp);
system("tar xvfz test_stats.tar.gz");
chdir($owd);
ok( -e "$tmp/test_stats/stats.csv", 'stats file exists' );
compare_ok("$tmp/test_stats/stats.csv", "t/data/rnaseqfind/41.stats", "archived stats correct");

remove_tree($tmp);
done_testing();
