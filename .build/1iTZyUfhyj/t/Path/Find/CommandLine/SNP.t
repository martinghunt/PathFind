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

use_ok('Path::Find::CommandLine::Snp');

my $script_name = 'snpfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/1.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 2
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/2.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 3
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 4
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/4.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 5
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/5.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 6
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-d', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 7
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 8
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-d', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 9
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/9.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 10
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/10.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 11
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 12
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/12.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 13
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/13.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 14
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-d', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 15
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 16
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-d', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 17
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 18
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 19
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'invalid_value', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 20
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'invalid_value', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 21
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/21.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 22
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/22.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 23
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 24
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/24.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 25
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/25.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 26
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-d', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 27
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 28
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-d', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 29
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 30
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/30.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 31
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 32
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'valid_value', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/32.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 33
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'valid_value', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/33.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 34
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'valid_value', '-d', 'valid_value', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 35
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'valid_value', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 36
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'valid_value', '-d', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 37
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 38
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'invalid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 39
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'invalid_value', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 40
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'invalid_value', '-d', 'valid_value', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 41
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-s', '-d', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/41.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 42
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-s', '-m', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/42.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 43
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-s', '-r', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/43.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 44
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'invalid_value', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 45
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 46
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-d', 'valid_value', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 47
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-m', 'valid_value', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 48
$id = "valid_value";
$ref = "valid_value";
@args = ( '--test', '-t', 'file', '-i', $id, '-f', 'pseudogenome', '-v', '-r', $ref, '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/48.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check pseudogenome

is(
    read_file('t/data/snpfind/48.fa'),
    read_file("$tmp/test.48.fa"),
    'pseudogenome correct'
);

# test 49
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-d', 'valid_value', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/49.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check pseudogenome
is(
    read_file('t/data/snpfind/49.fa'),
    read_file("$tmp/test.49.fa"),
    'pseudogenome correct'
);

# test 50
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-m', 'valid_value', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/50.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check pseudogenome
is(
    read_file('t/data/snpfind/50.fa'),
    read_file("$tmp/test.50.fa"),
    'pseudogenome correct'
);

# test 51
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-d', 'valid_value', '-m', 'valid_value', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/51.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check pseudogenome
is(
    read_file('t/data/snpfind/51.fa'),
    read_file("$tmp/test.51.fa"),
    'pseudogenome correct'
);

# test 52
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-r', 'valid_value', '-p', '"none"' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/52.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check pseudogenome
is(
    read_file('t/data/snpfind/52.fa'),
    read_file("$tmp/test.52.fa"),
    'pseudogenome correct'
);

# test 53
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'pseudogenome', '-v', '-r', 'valid_value', '-p', '-h' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Snp->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

remove_tree($tmp);
done_testing();
