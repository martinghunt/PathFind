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

use_ok('Path::Find::CommandLine::Info');

my $script_name = 'infofind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 2
@args = ( '--test', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 3
@args = ( '--test', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 4
@args = ( '--test', '-i', 'valid_value' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 5
@args = ( '--test', '-i', 'valid_value', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 6
@args = ( '--test', '-i', 'valid_value', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 7
@args = ( '--test', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 8
@args = ( '--test', '-i', 'invalid_value', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 9
@args = ( '--test', '-t', 'study' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 10
@args = ( '--test', '-t', 'study', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 11
@args = ( '--test', '-t', 'study', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 12
@args = ( '--test', '-t', 'study', '-i', '3' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
$exp_out = read_file('t/data/infofind/12.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 13
@args = ( '--test', '-t', 'study', '-i', '3', '-o', "$tmp/test.13" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
$exp_out = read_file('t/data/infofind/13.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check output file
ok( -e "$tmp/test.13.csv", 'symlink dir exists' );
is(
	read_file('t/data/infofind/13.csv'),
	read_file("$tmp/test.13.csv"),
	'file contents correct'
);

# test 14
@args = ( '--test', '-t', 'study', '-i', '3', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 15
@args = ( '--test', '-t', 'study', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 16
@args = ( '--test', '-t', 'study', '-i', 'invalid_value', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 17
@args = ( '--test', '-t', 'lane' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 18
@args = ( '--test', '-t', 'lane', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 19
@args = ( '--test', '-t', 'lane', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 20
@args = ( '--test', '-t', 'lane', '-i', '6578_4#4' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
$exp_out = read_file('t/data/infofind/20.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 21
@args = ( '--test', '-t', 'lane', '-i', '6578_4#4', '-o', "$tmp/test.21" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
$exp_out = read_file('t/data/infofind/21.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check output file
ok( -e "$tmp/test.21.csv", 'symlink dir exists' );
is(
	read_file('t/data/infofind/21.csv'),
	read_file("$tmp/test.21.csv"),
	'file contents correct'
);

# test 22
@args = ( '--test', '-t', 'lane', '-i', '6578_4#4', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 23
@args = ( '--test', '-t', 'lane', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 24
@args = ( '--test', '-t', 'lane', '-i', 'invalid_value', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 25
@args = ( '--test', '-t', 'file' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 26
@args = ( '--test', '-t', 'file', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 27
@args = ( '--test', '-t', 'file', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 28
@args = ( '--test', '-t', 'file', '-i', 't/data/infofind/info_lanes.txt' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
$exp_out = read_file('t/data/infofind/28.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 29
@args = ( '--test', '-t', 'file', '-i', 't/data/infofind/info_lanes.txt', '-o', "$tmp/test.29" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
$exp_out = read_file('t/data/infofind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check output file
ok( -e "$tmp/test.29.csv", 'symlink dir exists' );
is(
	read_file('t/data/infofind/29.csv'),
	read_file("$tmp/test.29.csv"),
	'file contents correct'
);

# test 30
@args = ( '--test', '-t', 'file', '-i', 't/data/infofind/info_lanes.txt', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 31
@args = ( '--test', '-t', 'file', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 32
@args = ( '--test', '-t', 'file', '-i', 'invalid_value', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 33
@args = ( '--test', '-t', 'sample' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 34
@args = ( '--test', '-t', 'sample', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 35
@args = ( '--test', '-t', 'sample', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 36
@args = ( '--test', '-t', 'sample', '-i', 'test1_3' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
$exp_out = read_file('t/data/infofind/36.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 37
@args = ( '--test', '-t', 'sample', '-i', 'test1_3', '-o', "$tmp/test.37" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
$exp_out = read_file('t/data/infofind/37.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check output file
ok( -e "$tmp/test.37.csv", 'symlink dir exists' );
is(
	read_file('t/data/infofind/37.csv'),
	read_file("$tmp/test.37.csv"),
	'file contents correct'
);

# test 38
@args = ( '--test', '-t', 'sample', '-i', 'test1_3', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 39
@args = ( '--test', '-t', 'sample', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 40
@args = ( '--test', '-t', 'sample', '-i', 'invalid_value', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 41
@args = ( '--test', '-t', 'species' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 42
@args = ( '--test', '-t', 'species', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 43
@args = ( '--test', '-t', 'species', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 44
@args = ( '--test', '-t', 'species', '-i', 'strep' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
$exp_out = read_file('t/data/infofind/44.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 45
@args = ( '--test', '-t', 'species', '-i', 'strep', '-o', "$tmp/test.45" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
$exp_out = read_file('t/data/infofind/45.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check output file
ok( -e "$tmp/test.45.csv", 'symlink dir exists' );
is(
	read_file('t/data/infofind/45.csv'),
	read_file("$tmp/test.45.csv"),
	'file contents correct'
);

# test 46
@args = ( '--test', '-t', 'species', '-i', 'strep', '-o', 'not/a/real/destination' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 47
@args = ( '--test', '-t', 'species', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 48
@args = ( '--test', '-t', 'species', '-i', 'invalid_value', '-o', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 49
@args = ( '--test', '-t', 'species', '-i', 'invalid_value', '-o', "$tmp/valid_dest", '-h', 'yes' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 50
@args = ( '--test', '-h', 'yes' );
$obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => 'infofind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

remove_tree($tmp);
done_testing();