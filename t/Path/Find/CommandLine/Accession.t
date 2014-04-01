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

use_ok('Path::Find::CommandLine::Accession');

my $script_name = 'accessionfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 2
@args = ( '--test', '-i', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 3
@args = ( '--test', '-i', 'valid_value', '-f', '-s', '-o', "$tmp/test.3.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 4
@args = ( '--test', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 5
@args = ( '--test', '-t', 'study' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 6
@args = ( '--test', '-t', 'study', '-f', '-s', '-o', "$tmp/test.6.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 7
@args = ( '--test', '-t', 'study', '-i', '3' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/7.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 8
@args = ( '--test', '-t', 'study', '-i', '3', '-o', "$tmp/test.8.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/8.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 9
@args = ( '--test', '-t', 'study', '-i', '3', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/9.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 10
@args = ( '--test', '-t', 'study', '-i', '3', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/10.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/10.out'),
	read_file("accessionfind.out"),
	'FTP file correct'
);
unlink('accessionfind.out');

# test 11
@args = ( '--test', '-t', 'study', '-i', '3', '-s', '-o', "$tmp/test.11.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/11.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/11.out'),
	read_file("$tmp/test.11.out"),
	'FTP file correct'
);

# test 12
@args = ( '--test', '-t', 'study', '-i', '3', '-s', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 13
@args = ( '--test', '-t', 'study', '-i', '3', '-f' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/13.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/13.out'),
	read_file("accessionfind.out"),
	'FTP file correct'
);
unlink('accessionfind.out');

# test 14
@args = ( '--test', '-t', 'study', '-i', '3', '-f', '-o', "$tmp/test.14.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/14.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/14.out'),
	read_file("$tmp/test.14.out"),
	'FTP file correct'
);

# test 15
@args = ( '--test', '-t', 'study', '-i', '3', '-f', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 16
@args = ( '--test', '-t', 'study', '-i', '3', '-f', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/16.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/16.out'),
	read_file("accessionfind.out"),
	'FTP file correct'
);
unlink('accessionfind.out');

# test 17
@args = ( '--test', '-t', 'study', '-i', '3', '-f', '-s', '-o', "$tmp/test.17.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/17.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/17.out'),
	read_file("$tmp/test.17.out"),
	'FTP file correct'
);

# test 18
@args = ( '--test', '-t', 'study', '-i', '3', '-f', '-s', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 19
@args = ( '--test', '-t', 'study', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 20
@args = ( '--test', '-t', 'study', '-i', 'invalid_value', '-f', '-s', '-o', "$tmp/test.##.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 21
@args = ( '--test', '-t', 'lane' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 22
@args = ( '--test', '-t', 'lane', '-f', '-s', '-o', "$tmp/test.##.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 23
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/23.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 24
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4', '-o', "$tmp/test.24.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/24.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 25
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/25.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 26
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/26.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/26.out'),
	read_file("accessionfind.out"),
	'FTP file correct'
);
unlink('accessionfind.out');

# test 27
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4', '-s', '-o', "$tmp/test.27.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/27.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/27.out'),
	read_file("$tmp/test.27.out"),
	'FTP file correct'
);

# test 28
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4', '-s', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 29
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4', '-f' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/29.out'),
	read_file("accessionfind.out"),
	'FTP file correct'
);
unlink('accessionfind.out');

# test 30
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4', '-f', '-o', "$tmp/test.30.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/30.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/30.out'),
	read_file("$tmp/test.30.out"),
	'FTP file correct'
);

# test 31
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4', '-f', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 32
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4', '-f', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/32.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/32.out'),
	read_file("accessionfind.out"),
	'FTP file correct'
);
unlink('accessionfind.out');

# test 33
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4', '-f', '-s', '-o', "$tmp/test.33.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/33.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/33.out'),
	read_file("$tmp/test.33.out"),
	'FTP file correct'
);

# test 34
@args = ( '--test', '-t', 'lane', '-i', '5477_6#4', '-f', '-s', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 35
@args = ( '--test', '-t', 'lane', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 36
@args = ( '--test', '-t', 'lane', '-i', 'invalid_value', '-f', '-s', '-o', "$tmp/test.36.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 37
@args = ( '--test', '-t', 'file' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 38
@args = ( '--test', '-t', 'file', '-f', '-s', '-o', "$tmp/test.38.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 39
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/39.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 40
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt', '-o', "$tmp/test.40.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/40.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 41
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/41.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 42
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/42.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/42.out'),
	read_file("accessionfind.out"),          
	'FTP file correct'
);
unlink('accessionfind.out');

# test 43
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt', '-s', '-o', "$tmp/test.43.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/43.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/43.out'),
	read_file("$tmp/test.43.out"),          
	'FTP file correct'
);

# test 44
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt', '-s', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 45
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt', '-f' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/45.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/45.out'),
	read_file("accessionfind.out"),
	'FTP file correct'
);
unlink('accessionfind.out');

# test 46
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt', '-f', '-o', "$tmp/test.46.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/46.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/46.out'),
	read_file("$tmp/test.46.out"),
	'FTP file correct'
);

# test 47
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt', '-f', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 48
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt', '-f', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/48.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/48.out'),
	read_file("accessionfind.out"),
	'FTP file correct'
);
unlink('accessionfind.out');

# test 49
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt', '-f', '-s', '-o', "$tmp/test.49.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/49.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/49.out'),
	read_file("$tmp/test.49.out"),
	'FTP file correct'
);

# test 50
@args = ( '--test', '-t', 'file', '-i', 't/data/accessionfind/acc_lanes.txt', '-f', '-s', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 51
@args = ( '--test', '-t', 'file', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 52
@args = ( '--test', '-t', 'file', '-i', 'invalid_value', '-f', '-s', '-o', "$tmp/test.##.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 53
@args = ( '--test', '-t', 'sample' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 54
@args = ( '--test', '-t', 'sample', '-f', '-s', '-o', "$tmp/test.54.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 55
@args = ( '--test', '-t', 'sample', '-i', 'test2_1' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/55.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 56
@args = ( '--test', '-t', 'sample', '-i', 'test2_1', '-o', "$tmp/test.56.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/56.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 57
@args = ( '--test', '-t', 'sample', '-i', 'test2_1', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/57.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 58
@args = ( '--test', '-t', 'sample', '-i', 'test2_1', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/58.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
    read_file('t/data/accessionfind/58.out'),
    read_file("accessionfind.out"),
    'FTP file correct'
);
unlink('accessionfind.out');

# test 59
@args = ( '--test', '-t', 'sample', '-i', 'test2_1', '-s', '-o', "$tmp/test.59.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/59.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
    read_file('t/data/accessionfind/59.out'),
    read_file("$tmp/test.59.out"),
    'FTP file correct'
);

# test 60
@args = ( '--test', '-t', 'sample', '-i', 'test2_1', '-s', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 61
@args = ( '--test', '-t', 'sample', '-i', 'test2_1', '-f' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/61.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
    read_file('t/data/accessionfind/61.out'),
    read_file("accessionfind.out"),
    'FTP file correct'
);
unlink('accessionfind.out');

# test 62
@args = ( '--test', '-t', 'sample', '-i', 'test2_1', '-f', '-o', "$tmp/test.62.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/62.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
    read_file('t/data/accessionfind/62.out'),
    read_file("$tmp/test.62.out"),
    'FTP file correct'
);

# test 63
@args = ( '--test', '-t', 'sample', '-i', 'test2_1', '-f', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 64
@args = ( '--test', '-t', 'sample', '-i', 'test2_1', '-f', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/64.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
    read_file('t/data/accessionfind/64.out'),
    read_file("accessionfind.out"),
    'FTP file correct'
);
unlink('accessionfind.out');

# test 65
@args = ( '--test', '-t', 'sample', '-i', 'test2_1', '-f', '-s', '-o', "$tmp/test.65.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/65.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
    read_file('t/data/accessionfind/65.out'),
    read_file("$tmp/test.65.out"),
    'FTP file correct'
);

# test 66
@args = ( '--test', '-t', 'sample', '-i', 'test2_1', '-f', '-s', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 67
@args = ( '--test', '-t', 'sample', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 68
@args = ( '--test', '-t', 'sample', '-i', 'invalid_value', '-f', '-s', '-o', "$tmp/test.##.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 69
@args = ( '--test', '-t', 'species' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 70
@args = ( '--test', '-t', 'species', '-f', '-s', '-o', "$tmp/test.70.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 71
@args = ( '--test', '-t', 'species', '-i', 'shigella' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/71.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 72
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-o', "$tmp/test.72.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/72.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 73
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/73.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 74
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/74.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/74.out'),
	read_file("accessionfind.out"),
	'FTP file correct'
);
unlink('accessionfind.out');

# test 75
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-s', '-o', "$tmp/test.75.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/75.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/75.out'),
	read_file("$tmp/test.75.out"),
	'FTP file correct'
);

# test 76
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-s', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 77
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-f' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/77.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/77.out'),
	read_file("accessionfind.out"),
	'FTP file correct'
);
unlink('accessionfind.out');

# test 78
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-f', '-o', "$tmp/test.78.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/78.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/78.out'),
	read_file("$tmp/test.78.out"),
	'FTP file correct'
);

# test 79
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-f', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 80
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-f', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/80.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/80.out'),
	read_file("accessionfind.out"),
	'FTP file correct'
);
unlink('accessionfind.out');

# test 81
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-f', '-s', '-o', "$tmp/test.81.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/81.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check FTP file
is(
	read_file('t/data/accessionfind/81.out'),
	read_file("$tmp/test.81.out"),
	'FTP file correct'
);

# test 82
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-f', '-s', '-o', "not/really/a/file.txt" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 83
@args = ( '--test', '-t', 'species', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 84
@args = ( '--test', '-t', 'species', '-i', 'invalid_value', '-f', '-s', '-o', "$tmp/test.##.out" );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 85
@args = ( '--test', '-t', 'species', '-i', 'shigella', '-h' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

remove_tree($tmp);
done_testing();
