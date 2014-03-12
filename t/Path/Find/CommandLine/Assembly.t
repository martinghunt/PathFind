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

use_ok('Path::Find::CommandLine::Assembly');

my $script_name = 'assemblyfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test', '-t', 'species', '-f', 'contigs' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 2
@args = ( '--test', '-t', 'species', '-f', 'scaffold' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 3
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/3.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 4
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/4.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 5
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-a', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/5.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 6
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-l', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/6.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 7
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/7.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 8
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/8.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 9
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/9.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 10
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-a', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/10.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 11
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-l', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/11.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 12
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/12.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 13
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'contigs' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/13.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 14
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'contigs', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/14.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 15
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'contigs', '-a', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/15.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 16
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'contigs', '-l', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/16.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 17
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'contigs', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/17.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 18
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'scaffold' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/18.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 19
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'scaffold', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/19.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 20
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'scaffold', '-a', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/20.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 21
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'scaffold', '-l', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/21.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 22
@args = ( '--test', '-t', 'file', '-i', 'valid_value', '-f', 'scaffold', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/22.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 23
@args = ( '--test', '-t', 'lane', '-f', 'contigs', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 24
@args = ( '--test', '-t', 'lane', '-f', 'scaffold' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 25
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', 'contigs' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/25.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 26
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', 'contigs', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/26.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 27
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', 'contigs', '-a', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/27.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 28
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', 'contigs', '-l', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/28.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 29
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', 'contigs', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 30
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', 'scaffold' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/30.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 31
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', 'scaffold', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/31.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 32
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', 'scaffold', '-a', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/32.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 33
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', 'scaffold', '-l', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/33.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 34
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-f', 'scaffold', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/34.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 35
@args = ( '--test', '-t', 'study', '-f', 'scaffold', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 36
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', 'contigs' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/36.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 37
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', 'contigs', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/37.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 38
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', 'contigs', '-a', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/38.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 39
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', 'contigs', '-l', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/39.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 40
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', 'contigs', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/40.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 41
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', 'scaffold' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/41.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 42
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', 'scaffold', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/42.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 43
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', 'scaffold', '-a', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/43.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 44
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', 'scaffold', '-l', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/44.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 45
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-f', 'scaffold', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/45.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 46
@args = ( '--test', '-t', 'species', '-f', 'contigs', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 47
@args = ( '--test', '-t', 'species', '-f', 'scaffold' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 48
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/48.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 49
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/49.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 50
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-a', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/50.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 51
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-l', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/51.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 52
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'contigs', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/52.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 53
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/53.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 54
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/54.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 55
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-a', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/55.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');


# test 56
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-l', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/56.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 57
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-l', "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
$exp_out = read_file('t/data/assemblyfind/57.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check symlinks
ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );


# test 58
@args = ( '--test', '-t', 'species', '-i', 'valid_value', '-f', 'scaffold', '-l', 'empty_dest', '-a', 'empty_dest' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Assembly->new(args => \@args, script_name => 'assemblyfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

remove_tree($tmp);
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