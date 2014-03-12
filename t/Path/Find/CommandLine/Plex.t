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

use_ok('Path::Find::CommandLine::Plex');

my $script_name = 'plexfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 2
@args = ( '--test', '-tag', 'yes' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 3
@args = ( '--test', '-i', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 4
@args = ( '--test', '-i', 'valid_value', '-tag', 'yes' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 5
@args = ( '--test', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 6
@args = ( '--test', '-i', 'invalid_value', '-tag', 'yes' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 7
@args = ( '--test', '-t', 'study' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 8
@args = ( '--test', '-t', 'study', '-tag', 'yes' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 9
@args = ( '--test', '-t', 'study', '-i', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
$exp_out = read_file('t/data/plexfind/9.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 10
@args = ( '--test', '-t', 'study', '-i', 'valid_value', '-tag', 'yes' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 11
@args = ( '--test', '-t', 'study', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 12
@args = ( '--test', '-t', 'study', '-i', 'invalid_value', '-tag', 'yes' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 13
@args = ( '--test', '-t', 'lane' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 14
@args = ( '--test', '-t', 'lane', '-tag', 'yes' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 15
@args = ( '--test', '-t', 'lane', '-i', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
$exp_out = read_file('t/data/plexfind/15.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 16
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-tag', 'yes' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
$exp_out = read_file('t/data/plexfind/16.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 17
@args = ( '--test', '-t', 'lane', '-i', 'invalid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 18
@args = ( '--test', '-t', 'lane', '-i', 'invalid_value', '-tag', 'yes' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 19
@args = ( '--test', '-t', 'lane', '-i', 'valid_value', '-h', 'yes' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 20
@args = ( '--test', '-t', 'invalid_value', '-i', 'valid_value' );
$obj = Path::Find::CommandLine::Path::Find::CommandLine::Plex->new(args => \@args, script_name => 'plexfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

remove_tree($tmp);
done_testing();