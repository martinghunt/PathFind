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
}

use_ok('Path::Find::CommandLine::Ref');

my $script_name = 'reffind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

my $help_text = read_file("t/data/reffind/help.txt");
# test 1
@args = ( "-f", "fa" );
$exp_out = $help_text;
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);

eval { $obj->run };
print STDERR "\$\@: $@\n";
like($@, $exp_out, "dies with help text");

#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


## test 2
#@args = ( "-i", "valid_value", "-f", "gff", "-a", "invalid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 3
#@args = ( "-i", "valid_value", "-f", "embl", "-l", "valid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 4
#@args = ( "-i", "invalid_value", "-f", "annotation", "-a", "valid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 5
#@args = ( "-t", "species", "-f", "fa", "-l", "invalid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 6
#@args = ( "-t", "species", "-f", "gff" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 7
#@args = ( "-t", "species", "-f", "embl", "-a", "invalid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 8
#@args = ( "-t", "species", "-f", "annotation", "-l", "valid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 9
#@args = ( "-t", "species", "-i", "pseudo", "-f", "fa" );
#$exp_out = read_file("t/data/reffind/9.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 10
#@args = ( "-t", "species", "-i", "pseudo", "-f", "fa", "-a", "valid_dest" );
#$exp_out = read_file("t/data/reffind/10.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive
#
#
#
## test 11
#@args = ( "-t", "species", "-i", "pseudo", "-f", "fa", "-a", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/11.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive  error message
#
#
#
## test 12
#@args = ( "-t", "species", "-i", "pseudo", "-f", "fa", "-l", "valid_dest" );
#$exp_out = read_file("t/data/reffind/12.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir
#
#
#
## test 13
#@args = ( "-t", "species", "-i", "pseudo", "-f", "fa", "-l", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/13.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir error message
#
#
#
## test 14
#@args = ( "-t", "species", "-i", "pseudo", "-f", "gff" );
#$exp_out = read_file("t/data/reffind/14.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 15
#@args = ( "-t", "species", "-i", "pseudo", "-f", "gff", "-a", "valid_dest" );
#$exp_out = read_file("t/data/reffind/15.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive
#
#
#
## test 16
#@args = ( "-t", "species", "-i", "pseudo", "-f", "gff", "-a", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/16.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive  error message
#
#
#
## test 17
#@args = ( "-t", "species", "-i", "pseudo", "-f", "gff", "-l", "valid_dest" );
#$exp_out = read_file("t/data/reffind/17.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir
#
#
#
## test 18
#@args = ( "-t", "species", "-i", "pseudo", "-f", "gff", "-l", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/18.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir error message
#
#
#
## test 19
#@args = ( "-t", "species", "-i", "pseudo", "-f", "embl" );
#$exp_out = read_file("t/data/reffind/19.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 20
#@args = ( "-t", "species", "-i", "pseudo", "-f", "embl", "-a", "valid_dest" );
#$exp_out = read_file("t/data/reffind/20.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive
#
#
#
## test 21
#@args = ( "-t", "species", "-i", "pseudo", "-f", "embl", "-a", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/21.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive  error message
#
#
#
## test 22
#@args = ( "-t", "species", "-i", "pseudo", "-f", "embl", "-l", "valid_dest" );
#$exp_out = read_file("t/data/reffind/22.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir
#
#
#
## test 23
#@args = ( "-t", "species", "-i", "pseudo", "-f", "embl", "-l", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/23.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir error message
#
#
#
## test 24
#@args = ( "-t", "species", "-i", "pseudo", "-f", "annotation" );
#$exp_out = read_file("t/data/reffind/24.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 25
#@args = ( "-t", "species", "-i", "pseudo", "-f", "annotation", "-a", "valid_dest" );
#$exp_out = read_file("t/data/reffind/25.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive
#
#
#
## test 26
#@args = ( "-t", "species", "-i", "pseudo", "-f", "annotation", "-a", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/26.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive  error message
#
#
#
## test 27
#@args = ( "-t", "species", "-i", "pseudo", "-f", "annotation", "-l", "valid_dest" );
#$exp_out = read_file("t/data/reffind/27.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir
#
#
#
## test 28
#@args = ( "-t", "species", "-i", "pseudo", "-f", "annotation", "-l", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/28.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir error message
#
#
#
## test 29
#@args = ( "-t", "species", "-i", "invalid_value", "-f", "fa", "-l", "valid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 30
#@args = ( "-t", "species", "-i", "invalid_value", "-f", "gff", "-a", "valid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 31
#@args = ( "-t", "species", "-i", "invalid_value", "-f", "embl" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 32
#@args = ( "-t", "species", "-i", "invalid_value", "-f", "annotation", "-l", "valid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 33
#@args = ( "-t", "file", "-f", "fa", "-l", "invalid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 34
#@args = ( "-t", "file", "-f", "gff" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 35
#@args = ( "-t", "file", "-f", "embl", "-a", "invalid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 36
#@args = ( "-t", "file", "-f", "annotation", "-l", "valid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 37
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "fa" );
#$exp_out = read_file("t/data/reffind/37.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 38
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "fa", "-a", "valid_dest" );
#$exp_out = read_file("t/data/reffind/38.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive
#
#
#
## test 39
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "fa", "-a", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/39.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive  error message
#
#
#
## test 40
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "fa", "-l", "valid_dest" );
#$exp_out = read_file("t/data/reffind/40.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir
#
#
#
## test 41
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "fa", "-l", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/41.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir error message
#
#
#
## test 42
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "gff" );
#$exp_out = read_file("t/data/reffind/42.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 43
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "gff", "-a", "valid_dest" );
#$exp_out = read_file("t/data/reffind/43.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive
#
#
#
## test 44
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "gff", "-a", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/44.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive  error message
#
#
#
## test 45
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "gff", "-l", "valid_dest" );
#$exp_out = read_file("t/data/reffind/45.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir
#
#
#
## test 46
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "gff", "-l", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/46.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir error message
#
#
#
## test 47
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl" );
#$exp_out = read_file("t/data/reffind/47.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 48
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl", "-a", "valid_dest" );
#$exp_out = read_file("t/data/reffind/48.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive
#
#
#
## test 49
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl", "-a", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/49.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive  error message
#
#
#
## test 50
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl", "-l", "valid_dest" );
#$exp_out = read_file("t/data/reffind/50.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir
#
#
#
## test 51
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl", "-l", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/51.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir error message
#
#
#
## test 52
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "annotation" );
#$exp_out = read_file("t/data/reffind/52.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 53
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "annotation", "-a", "valid_dest" );
#$exp_out = read_file("t/data/reffind/53.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive
#
#
#
## test 54
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "annotation", "-a", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/54.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  archive  error message
#
#
#
## test 55
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "annotation", "-l", "valid_dest" );
#$exp_out = read_file("t/data/reffind/55.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir
#
#
#
## test 56
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "annotation", "-l", "invalid_dest" );
#$exp_out = read_file("t/data/reffind/56.txt");
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
## check  symlink dir error message
#
#
#
## test 57
#@args = ( "-t", "file", "-i", "invalid_value", "-f", "fa", "-l", "valid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 58
#@args = ( "-t", "file", "-i", "invalid_value", "-f", "gff", "-a", "valid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 59
#@args = ( "-t", "file", "-i", "invalid_value", "-f", "embl" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 60
#@args = ( "-t", "file", "-i", "invalid_value", "-f", "annotation", "-l", "valid_dest" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 61
#@args = ( "-t", "species", "-i", "pseudo", "-f", "gff", "-l", "valid_dest", "-h" );
#$exp_out = $help_text;
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
#
#
## test 62
#@args = ( "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl", "-l", "valid_dest", "-a", "valid_dest" );
#$exp_out = "The archive and symlink options cannot be used together";
#$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


done_testing();
