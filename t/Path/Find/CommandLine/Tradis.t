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
}

use_ok('Path::Find::CommandLine::Tradis');

my $script_name = 'tradisfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'bam' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/1.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 2
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'coverage', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/2.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 3
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'intergenic', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 4
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'spreadsheet', '-d', '20-03-2014' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/4.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 5
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'bam', '-d', '19-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/5.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 6
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'coverage', '-d', '20-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 7
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'intergenic', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 8
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'spreadsheet', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 9
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'bam', '-r', 'Streptococcus_pneumoniae_INV200_v1' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/9.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 10
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'coverage', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/10.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 11
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'intergenic', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 12
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'spreadsheet', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '18-03-2014' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/12.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 13
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'bam', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '20-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/13.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 14
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'coverage', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '20-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 15
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'intergenic', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 16
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'spreadsheet', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 17
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'bam', '-r', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 18
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'coverage', '-r', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 19
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'intergenic', '-r', 'invalid_value', '-d', '20-03-2014' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 20
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'spreadsheet', '-r', 'invalid_value', '-d', '20-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 21
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'bam', '-v' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/21.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 22
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'coverage', '-v', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/22.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 23
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'intergenic', '-v', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 24
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'spreadsheet', '-v', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/24.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 25
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'bam', '-v', '-d', '20-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/25.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 26
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'coverage', '-v', '-d', '20-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 27
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'intergenic', '-v', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 28
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'spreadsheet', '-v', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 29
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'bam', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 30
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'coverage', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/30.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 31
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'intergenic', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 32
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'spreadsheet', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '20-03-2014' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/32.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 33
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'bam', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '20-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/33.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 34
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'coverage', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '20-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 35
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'intergenic', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 36
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'spreadsheet', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 37
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'bam', '-v', '-r', 'invalid_value' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 38
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'coverage', '-v', '-r', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 39
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'intergenic', '-v', '-r', 'invalid_value', '-d', '20-03-2014' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 40
@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'spreadsheet', '-v', '-r', 'invalid_value', '-d', '20-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 41
#@args = ( '--test', '-t', 'file', '-i', 't/data/tradisfind/tradis_lanes.txt', '-f', 'bam', '-s', '-d', '20-03-2014' );
#$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
#$exp_out = read_file('t/data/tradisfind/41.txt');
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 42
@args = ( '--test', '-t', 'lane', '-i', '5477_6#1' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/42.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 43
@args = ( '--test', '-t', 'study', '-i', '3' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/43.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 44
@args = ( '--test', '-t', 'sample', '-i', 'test2_4' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/44.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 45
@args = ( '--test', '-t', 'species', '-i', 'shigella' );
$obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => 'tradisfind');
$exp_out = read_file('t/data/tradisfind/45.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


remove_tree($tmp);
done_testing();
