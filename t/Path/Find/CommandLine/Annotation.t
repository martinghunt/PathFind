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
        use Test::Files;
}

use_ok('Path::Find::CommandLine::Annotation');

my $script_name = 'annotationfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/1.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 2
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-f', 'gff');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/2.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 3
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-f', 'faa' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/3.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 4
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-f', 'ffn',);
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/4.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 5
@args = ( '--test', '-t', 'file', '-i', 't/data/annotationfind/annotation_lanes.txt');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/5.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 6
@args = ( '--test', '-t', 'file', '-i', 't/data/annotationfind/annotation_lanes.txt', '-f', 'gff');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/6.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 7
@args = ( '--test', '-t', 'file', '-i', 't/data/annotationfind/annotation_lanes.txt', '-f', 'faa');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/7.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 8
@args = ( '--test', '-t', 'file', '-i', 't/data/annotationfind/annotation_lanes.txt', '-f', 'ffn', '-p', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/8.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 9
@args = ( '--test', '-t', 'lane', '-i', '5477_6#2' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/9.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 10
@args = ( '--test', '-t', 'lane', '-i', '5477_6#2', '-f', 'gff' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/10.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 11
@args = ( '--test', '-t', 'lane', '-i', '5477_6#2', '-f', 'faa');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/11.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 12
@args = ( '--test', '-t', 'lane', '-i', '5477_6#2', '-f', 'ffn' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/12.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 13
@args = ( '--test', '-t', 'study', '-i', 'Test Study 2');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/13.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 14
@args = ( '--test', '-t', 'study', '-i', 'Test Study 2', '-f', 'gff' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/14.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 15
@args = ( '--test', '-t', 'study', '-i', 'Test Study 2', '-f', 'faa');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/15.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 16
@args = ( '--test', '-t', 'study', '-i', 'Test Study 2', '-f', 'ffn');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/16.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 17
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-f', 'gff', '-l');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/17.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "annotationfind_Shigella_flexneri", 'symlink dir exists' );
ok( check_links("annotationfind_Shigella_flexneri", $exp_out, 1), 'correct files symlinked' );

# test 18
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-f', 'gff', '-l',  "$tmp/valid_dest");
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/18.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links("$tmp/valid_dest", $exp_out, 1), 'correct files symlinked' );

# test 19
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-f', 'gff', '-a');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/19.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok( -e "annotationfind_Shigella_flexneri.tar.gz", 'archive exists' );
ok( check_links("annotationfind_Shigella_flexneri.tar.gz", $exp_out, 1), 'correct files archived' );

# test 20
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-f', 'gff', '-a', "$tmp/valid_dest" );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/20.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok( -e "$tmp/valid_dest.tar.gz", 'archive exists' );
ok( check_links("valid_dest.tar.gz", $exp_out), 'correct files archived' );

# test 21
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-f', 'gff', '-l', '-a');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 22
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-g');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 23
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-g', 'yfgF_1' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/23.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "output.yfgF_1.fa", 'output file exists' );
compare_ok("output.yfgF_1.fa", "t/data/annotationfind/annotation_aa.txt", "files are identical");

# test 24
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-g', 'yfgF_1', '-n' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/24.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "output.yfgF_1.fa", 'output file exists' );
compare_ok("output.yfgF_1.fa", "t/data/annotationfind/annotation_nuc.txt", "files are identical");

# test 25
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-g', 'yfgF_1', '-o' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 26
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-g', 'yfgF_1', '-o', 'valid_out' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/26.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "valid_out.yfgF_1.fa", 'output file exists' );
compare_ok("valid_out.yfgF_1.fa", "t/data/annotationfind/annotation_aa.txt", "files are identical");


# test 27
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'invalid_value', '-p' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/27.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 28
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-g', 'invalid_value', '-p', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/28.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 29
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 30
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/30.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 31
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-o', 'invalid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/31.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 32
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-n' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/32.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 33
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-n', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/33.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 34
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-n', '-o', 'invalid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/34.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 35
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/35.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 36
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/36.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 37
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p', '-o', 'invalid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/37.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 38
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p', '-n' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/38.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 39
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p', '-n', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/39.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 40
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-p', '-n', '-o', 'invalid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/40.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 41
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/41.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 42
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/42.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 43
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-o', 'invalid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/43.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 44
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-n' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/44.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 45
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-n', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/45.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 46
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-n', '-o', 'invalid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/46.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 47
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-p' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/47.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 48
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-p', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/48.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 49
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-p', '-n' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/49.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 50
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'valid_value', '-p', '-n', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/50.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 51
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/51.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 52
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/52.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 53
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value', '-n' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/53.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 54
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value', '-n', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/54.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 55
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value', '-p' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/55.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 56
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-g', 'invalid_value', '-p', '-o', 'valid_value' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/56.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


remove_tree($tmp);
done_testing();


sub check_links {
	my ($n, $fl, $cwd) = @_;

	my $tar = $n =~ /\.tar\.gz/ ? 1 : 0;
	my $owd = getcwd();
	chdir($tmp) unless($cwd);

	my $dir = $n;
	if($tar){
		system("tar xvfz $n");
		$dir =~ s/\.tar\.gz//;
	}

	my @exp_files = exp_files($fl);
	my $result = 1;
	foreach my $f (@exp_files){
		$result = 0 unless( -e "$dir/$f" );
	}
	chdir($owd) unless($cwd);

	# remove stuff
	unlink($n) if( $tar );
	remove_tree( $dir );

	return $result;
}

sub exp_files {
	my $fl = shift;
	
	my $default_type = "*.fastq.gz";
	my @ef;

	foreach my $f (split( "\n", $fl )){
		my @d = split("/", $f);
		my $e = pop @d;
		if( $e =~ /\./ ){
			push(@ef, $e);
		}
		else{
			my @all = glob("$f/$default_type");
			foreach my $a ( @all ){
				my @dirs = split('/', $a);
				my $fn = pop @dirs;
				push( @ef, $fn );
			}
		}
	}
	return @ef;
}
