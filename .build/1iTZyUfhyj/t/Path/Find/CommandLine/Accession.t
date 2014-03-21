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
@args = ( '--test', '-i', 'valid_value', '-f', '-s', '-o', 'valid_value' );
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
@args = ( '--test', '-t', 'study', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 7
@args = ( '--test', '-t', 'study', '-i', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/7.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 8
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/8.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 9
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/9.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 10
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/10.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 11
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/11.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 12
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-s', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/12.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 13
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/13.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 14
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/14.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 15
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/15.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 16
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/16.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 17
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/17.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 18
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', '-s', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/18.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 19
@args = ( '--test', '-t', 'study', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 20
@args = ( '--test', '-t', 'study', '-i', 'invalid_value', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 21
@args = ( '--test', '-t', 'lane' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 22
@args = ( '--test', '-t', 'lane', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 23
@args = ( '--test', '-t', 'lane', '-i', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/23.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 24
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/24.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 25
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/25.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 26
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/26.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 27
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/27.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 28
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-s', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/28.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 29
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 30
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/30.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 31
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/31.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 32
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/32.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 33
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/33.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 34
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', '-s', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/34.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 35
@args = ( '--test', '-t', 'lane', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 36
@args = ( '--test', '-t', 'lane', '-i', 'invalid_value', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 37
@args = ( '--test', '-t', 'file' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 38
@args = ( '--test', '-t', 'file', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 39
@args = ( '--test', '-t', 'file', '-i', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/39.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 40
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/40.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 41
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/41.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 42
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/42.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 43
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/43.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 44
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-s', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/44.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 45
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/45.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 46
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/46.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 47
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/47.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 48
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/48.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 49
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/49.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 50
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', '-s', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/50.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 51
@args = ( '--test', '-t', 'file', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 52
@args = ( '--test', '-t', 'file', '-i', 'invalid_value', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown';

# test 53
@args = ( '--test', '-t', 'sample' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 54
@args = ( '--test', '-t', 'sample', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 55
@args = ( '--test', '-t', 'sample', '-i', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/55.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 56
@args = ( '--test', '-t', 'sample', '-i', 'valid_value', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/56.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 57
@args = ( '--test', '-t', 'sample', '-i', 'valid_value', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/57.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 58
@args = ( '--test', '-t', 'sample', '-i', 'valid_value', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/58.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 59
@args = ( '--test', '-t', 'sample', '-i', 'valid_value', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/59.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 60
@args = ( '--test', '-t', 'sample', '-i', 'valid_value', '-s', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/60.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 61
@args = ( '--test', '-t', 'sample', '-i', 'valid_value', '-f' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/61.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 62
@args = ( '--test', '-t', 'sample', '-i', 'valid_value', '-f', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/62.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 63
@args = ( '--test', '-t', 'sample', '-i', 'valid_value', '-f', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/63.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 64
@args = ( '--test', '-t', 'sample', '-i', 'valid_value', '-f', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/64.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 65
@args = ( '--test', '-t', 'sample', '-i', 'valid_value', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/65.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 66
@args = ( '--test', '-t', 'sample', '-i', 'valid_value', '-f', '-s', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/66.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 67
@args = ( '--test', '-t', 'sample', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 68
@args = ( '--test', '-t', 'sample', '-i', 'invalid_value', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 69
@args = ( '--test', '-t', 'species' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 70
@args = ( '--test', '-t', 'species', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 71
@args = ( '--test', '-t', 'species', '-i', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/71.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 72
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/72.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 73
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/73.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 74
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/74.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 75
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/75.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 76
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-s', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/76.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 77
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/77.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 78
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/78.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 79
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/79.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 80
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', '-s' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/80.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 81
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/81.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 82
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', '-s', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
$exp_out = read_file('t/data/accessionfind/82.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 83
@args = ( '--test', '-t', 'species', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 84
@args = ( '--test', '-t', 'species', '-i', 'invalid_value', '-f', '-s', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 85
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-h' );
$obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => 'accessionfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

remove_tree($tmp);
done_testing();
