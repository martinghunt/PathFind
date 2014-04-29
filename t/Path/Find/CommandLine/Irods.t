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

use_ok('Path::Find::CommandLine::Irods');

my $script_name = 'accessionfind';
my $cwd = getcwd();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test' );
$obj = Path::Find::CommandLine::Irods->new(args => \@args, script_name => 'irodsfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 2
@args = ( '--test', '-t', 'lane', '-i', '22893_A01' );
$obj = Path::Find::CommandLine::Irods->new(args => \@args, script_name => 'irodsfind');
$exp_out = read_file('t/data/irodsfind/2.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 2
@args = ( '--test', '-t', 'species', '-i', 'Mycobacterium tuberculosis' );
$obj = Path::Find::CommandLine::Irods->new(args => \@args, script_name => 'irodsfind');
$exp_out = read_file('t/data/irodsfind/3.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

@args = ( '--test', '-t', 'study', '-i', 'Pacbio_pathogens' );
$obj = Path::Find::CommandLine::Irods->new(args => \@args, script_name => 'irodsfind');
$exp_out = read_file('t/data/irodsfind/4.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


done_testing();
