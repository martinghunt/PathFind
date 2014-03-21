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

use_ok('Path::Find::CommandLine::Annotation');

my $script_name = 'annotationfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/1.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 2
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/2.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 3
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/3.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 4
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-n' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/4.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 5
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-n', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/5.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 6
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-n', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/6.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 7
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/7.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 8
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-p', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/8.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 9
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-p', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/9.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 10
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-p', '-n' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/10.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 11
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-p', '-n', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/11.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 12
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-p', '-n', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/12.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 13
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/13.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 14
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'valid_value', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/14.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 15
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'valid_value', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/15.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 16
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'valid_value', '-n' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/16.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 17
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'valid_value', '-n', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/17.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 18
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'valid_value', '-n', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/18.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 19
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'valid_value', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/19.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 20
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'valid_value', '-p', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/20.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 21
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'valid_value', '-p', '-n' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/21.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 22
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'valid_value', '-p', '-n', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/22.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 23
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/23.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 24
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'invalid_value', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/24.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 25
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'invalid_value', '-n' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/25.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 26
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'invalid_value', '-n', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/26.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 27
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'invalid_value', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/27.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 28
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'invalid_value', '-p', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/28.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 29
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 30
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/30.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 31
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/31.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 32
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-n' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/32.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 33
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-n', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/33.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 34
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-n', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/34.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 35
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/35.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 36
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/36.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 37
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/37.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 38
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p', '-n' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/38.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 39
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p', '-n', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/39.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 40
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p', '-n', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/40.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 41
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/41.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 42
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/42.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 43
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/43.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 44
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-n' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/44.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 45
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-n', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/45.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 46
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-n', '-o', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/46.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 47
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/47.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 48
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-p', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/48.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 49
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-p', '-n' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/49.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 50
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-p', '-n', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/50.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 51
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/51.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 52
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/52.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 53
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value', '-n' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/53.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 54
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value', '-n', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/54.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 55
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value', '-p' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/55.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 56
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value', '-p', '-o', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/56.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


remove_tree($tmp);
done_testing();