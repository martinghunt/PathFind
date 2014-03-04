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
#@args =  ();
#$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
#throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 2
@args = ( "-h", "yes" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 3
@args = ( "-a", "empty_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 4
@args = ( "-f", "fastq" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 5
@args = ( "-f", "fastq", "-a", "empty_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 6
@args = ( "-f", "bam", "-a", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 7
@args = ( "-f", "bam", "-a", "invalid_dest" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 8
@args = ( "-i", "valid_value" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 9
@args = ( "-i", "invalid_value", "-f", "fastq" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 10
@args = ( "-t", "species" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 11
@args = ( "-t", "species", "-f", "fastq" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 12
@args = ( "-t", "species", "-f", "bam" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# test 13
@args = ( "-t", "species", "-i", "invalid_value" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown'; 

# test 14
@args = ( "-t", "species", "-i", "sanguinicola" );
$exp_out = read_file('t/data/pathfind/14.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 15
@args = ( "-t", "species", "-i", "sanguinicola", "-s", "$tmp/test.15.stats" );
$exp_out = read_file('t/data/pathfind/15.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

is(
	read_file('t/data/pathfind/15.stats'),
	read_file("$tmp/test.15.stats"),
	'stats file correct'
);

# test 16
@args = ( "-t", "species", "-i", "sanguinicola", "-qc", "passed" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown'; 

# test 17
@args = ( "-t", "species", "-i", "sanguinicola", "-qc", "failed" );
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown'; 

# test 18
@args = ( "-t", "species", "-i", "sanguinicola", "-qc", "pending" );
$exp_out = read_file('t/data/pathfind/18.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 19
@args = ( "-t", "species", "-i", "sanguinicola", "-a" );
$exp_out = read_file('t/data/pathfind/19.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "pathfind_sanguinicola.tar.gz", 'archive exists');
ok(check_links('pathfind_sanguinicola.tar.gz', $exp_out, 1), 'correct files present');

# test 20
@args = ( "-t", "species", "-i", "sanguinicola", "-a", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/20.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 21
@args = ( "-t", "species", "-i", "sanguinicola", "-l" );
$exp_out = read_file('t/data/pathfind/21.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "pathfind_sanguinicola", 'archive exists');
ok(check_links('pathfind_sanguinicola', $exp_out, 1), 'correct files present');


# test 22
@args = ( "-t", "species", "-i", "sanguinicola", "-l", "$tmp/valid_dest" );
$exp_out = read_file('t/data/pathfind/22.txt');
$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 23
@args = ( "-t", "species", "-i", "sanguinicola", "-f", "fastq" );
$exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 24
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "fastq", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 25
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "fastq", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 26
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "fastq", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 27
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "fastq", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 28
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "bam" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 29
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "bam", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 30
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "bam", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 31
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "bam", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 32
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "bam", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 33
# @args = ( "-t", "file" );
# $exp_out = $help_text;

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 34
# @args = ( "-t", "file", "-i", "valid_value" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 35
# @args = ( "-t", "file", "-i", "valid_value", "-s", "yes" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  stats file



# # test 36
# @args = ( "-t", "file", "-i", "valid_value", "-qc", "passed" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 37
# @args = ( "-t", "file", "-i", "valid_value", "-qc", "failed" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 38
# @args = ( "-t", "file", "-i", "valid_value", "-qc", "pending" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 39
# @args = ( "-t", "file", "-i", "valid_value", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 40
# @args = ( "-t", "file", "-i", "valid_value", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 41
# @args = ( "-t", "file", "-i", "valid_value", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 42
# @args = ( "-t", "file", "-i", "valid_value", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 43
# @args = ( "-t", "file", "-i", "valid_value", "-f", "fastq" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 44
# @args = ( "-t", "file", "-i", "valid_value", "-f", "fastq", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 45
# @args = ( "-t", "file", "-i", "valid_value", "-f", "fastq", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 46
# @args = ( "-t", "file", "-i", "valid_value", "-f", "fastq", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 47
# @args = ( "-t", "file", "-i", "valid_value", "-f", "fastq", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 48
# @args = ( "-t", "file", "-i", "valid_value", "-f", "bam" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 49
# @args = ( "-t", "file", "-i", "valid_value", "-f", "bam", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 50
# @args = ( "-t", "file", "-i", "valid_value", "-f", "bam", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 51
# @args = ( "-t", "file", "-i", "valid_value", "-f", "bam", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 52
# @args = ( "-t", "file", "-i", "valid_value", "-f", "bam", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 53
# @args = ( "-t", "file", "-i", "invalid_value" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 54
# @args = ( "-t", "file", "-i", "invalid_value in file" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  omitting invalid value



# # test 55
# @args = ( "-t", "lane", "-f", "fastq", "-a", "empty_dest" );
# $exp_out = $help_text;

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 56
# @args = ( "-t", "lane", "-f", "bam" );
# $exp_out = $help_text;

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 57
# @args = ( "-t", "lane", "-i", "valid_value" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 58
# @args = ( "-t", "lane", "-i", "valid_value", "-s", "stats" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  stats file



# # test 59
# @args = ( "-t", "lane", "-i", "valid_value", "-qc", "passed" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 60
# @args = ( "-t", "lane", "-i", "valid_value", "-qc", "failed" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 61
# @args = ( "-t", "lane", "-i", "valid_value", "-qc", "pending" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 62
# @args = ( "-t", "lane", "-i", "valid_value", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 63
# @args = ( "-t", "lane", "-i", "valid_value", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 64
# @args = ( "-t", "lane", "-i", "valid_value", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 65
# @args = ( "-t", "lane", "-i", "valid_value", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 66
# @args = ( "-t", "lane", "-i", "valid_value", "-f", "fastq" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 67
# @args = ( "-t", "lane", "-i", "valid_value", "-f", "fastq", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 68
# @args = ( "-t", "lane", "-i", "valid_value", "-f", "fastq", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 69
# @args = ( "-t", "lane", "-i", "valid_value", "-f", "fastq", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 70
# @args = ( "-t", "lane", "-i", "valid_value", "-f", "fastq", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 71
# @args = ( "-t", "lane", "-i", "valid_value", "-f", "bam" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 72
# @args = ( "-t", "lane", "-i", "valid_value", "-f", "bam", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 73
# @args = ( "-t", "lane", "-i", "valid_value", "-f", "bam", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 74
# @args = ( "-t", "lane", "-i", "valid_value", "-f", "bam", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 75
# @args = ( "-t", "lane", "-i", "valid_value", "-f", "bam", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 76
# @args = ( "-t", "lane", "-i", "invalid_value" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 77
# @args = ( "-t", "study" );
# $exp_out = $help_text;

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 78
# @args = ( "-t", "study", "-f", "bam", "-l", "$tmp/valid_dest" );
# $exp_out = $help_text;

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 79
# @args = ( "-t", "study", "-i", "valid_value" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 80
# @args = ( "-t", "study", "-i", "valid_value", "-s", "yes" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  stats file



# # test 81
# @args = ( "-t", "study", "-i", "valid_value", "-qc", "passed" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 82
# @args = ( "-t", "study", "-i", "valid_value", "-qc", "failed" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 83
# @args = ( "-t", "study", "-i", "valid_value", "-qc", "pending" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 84
# @args = ( "-t", "study", "-i", "valid_value", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 85
# @args = ( "-t", "study", "-i", "valid_value", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 86
# @args = ( "-t", "study", "-i", "valid_value", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 87
# @args = ( "-t", "study", "-i", "valid_value", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 88
# @args = ( "-t", "study", "-i", "valid_value", "-f", "fastq" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 89
# @args = ( "-t", "study", "-i", "valid_value", "-f", "fastq", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 90
# @args = ( "-t", "study", "-i", "valid_value", "-f", "fastq", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 91
# @args = ( "-t", "study", "-i", "valid_value", "-f", "fastq", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 92
# @args = ( "-t", "study", "-i", "valid_value", "-f", "fastq", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 93
# @args = ( "-t", "study", "-i", "valid_value", "-f", "bam" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 94
# @args = ( "-t", "study", "-i", "valid_value", "-f", "bam", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 95
# @args = ( "-t", "study", "-i", "valid_value", "-f", "bam", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 96
# @args = ( "-t", "study", "-i", "valid_value", "-f", "bam", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 97
# @args = ( "-t", "study", "-i", "valid_value", "-f", "bam", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 98
# @args = ( "-t", "study", "-i", "invalid_value" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 99
# @args = ( "-t", "species", "-f", "fastq", "-l", "$tmp/valid_dest" );
# $exp_out = $help_text;

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 100
# @args = ( "-t", "species", "-f", "bam" );
# $exp_out = $help_text;

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 101
# @args = ( "-t", "species", "-i", "sanguinicola" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 102
# @args = ( "-t", "species", "-i", "sanguinicola", "-s", "yes" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  stats file



# # test 103
# @args = ( "-t", "species", "-i", "sanguinicola", "-qc", "passed" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 104
# @args = ( "-t", "species", "-i", "sanguinicola", "-qc", "failed" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 105
# @args = ( "-t", "species", "-i", "sanguinicola", "-qc", "pending" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 106
# @args = ( "-t", "species", "-i", "sanguinicola", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 107
# @args = ( "-t", "species", "-i", "sanguinicola", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 108
# @args = ( "-t", "species", "-i", "sanguinicola", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 109
# @args = ( "-t", "species", "-i", "sanguinicola", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 110
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "fastq" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 111
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "fastq", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 112
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "fastq", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 113
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "fastq", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 114
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "fastq", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 115
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "bam" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 116
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "bam", "-a", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 117
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "bam", "-a", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  archive



# # test 118
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "bam", "-l", "empty_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 119
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "bam", "-l", "$tmp/valid_dest" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 

# # check  symlinks



# # test 120
# @args = ( "-t", "species", "-i", "invalid_value" );
# $exp_out = 

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 121
# @args = ( "-t", "invalid_value" );
# $exp_out = $help_text;

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


# # test 122
# @args = ( "-t", "species", "-i", "sanguinicola", "-f", "bam", "-l", "empty_dest", "-a", "empty_dest" );
# $exp_out = "The archive and symlink options cannot be used together";

# #$obj = Path::Find::CommandLine::Path->new(args => \@args, script_name => $script_name);
# #$arg_str = join(" ", @args);
# #stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
# #throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown'; 


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