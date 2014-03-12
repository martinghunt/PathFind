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

use_ok('Path::Find::CommandLine::Map');

my $script_name = 'mapfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/1.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 2
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/2.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 3
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 4
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/4.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 5
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/5.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 6
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-d', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 7
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 8
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-d', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 9
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/9.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 10
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/10.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 11
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 12
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'valid_value', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/12.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 13
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'valid_value', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/13.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 14
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'valid_value', '-d', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 15
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'valid_value', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 16
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'valid_value', '-d', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 17
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 18
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 19
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'invalid_value', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 20
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-r', 'invalid_value', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 21
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/21.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 22
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/22.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 23
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 24
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/24.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 25
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/25.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 26
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-d', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 27
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 28
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-d', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 29
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 30
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/30.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 31
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 32
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'valid_value', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/32.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 33
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'valid_value', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/33.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 34
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'valid_value', '-d', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 35
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'valid_value', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 36
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'valid_value', '-d', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 37
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 38
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 39
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'invalid_value', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 40
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-v', '-r', 'invalid_value', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 41
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-s', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/41.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 42
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-s', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/42.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 43
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'bam', '-s', '-r', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Map->new(args => \@args, script_name => 'mapfind');
$exp_out = read_file('t/data/mapfind/43.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


remove_tree($tmp);
done_testing();