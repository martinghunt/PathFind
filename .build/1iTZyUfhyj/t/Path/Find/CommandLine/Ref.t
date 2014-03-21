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

use_ok('Path::Find::CommandLine::Ref');

my $script_name = 'reffind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( "--test", "-f", "fa" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', "correct error thrown; test #1";

## test 2
@args = ( "--test", "-i", "valid_value", "-f", "gff", "-a", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #2';

# test 3
@args = ( "--test", "-i", "valid_value", "-f", "embl", "-l", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #3';

# test 4
@args = ( "--test", "-i", "invalid_value", "-f", "annotation", "-a", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #4';

# test 5
@args = ( "--test", "-t", "species", "-f", "fa", "-l", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #5';

# test 6
@args = ( "--test", "-t", "species", "-f", "gff" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #6';

# test 7
@args = ( "--test", "-t", "species", "-f", "embl", "-a", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #7';

# test 8
@args = ( "--test", "-t", "species", "-f", "annotation", "-l", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #8';

# test 9
@args = ( "--test", "-t", "species", "-i", "etec", "-f", "fa" );
$exp_out = read_file("t/data/reffind/9.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 10
@args = ( "--test", "-t", "species", "-i", "etec", "-f", "fa", "-a", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/10.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check archive
ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 11
@args = ( "--test", "-t", "species", "-i", "etec", "-f", "fa", "-a", "/not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #11';

# test 12
@args = ( "--test", "-t", "species", "-i", "etec", "-f", "fa", "-l", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/12.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 13
@args = ( "--test", "-t", "species", "-i", "etec", "-f", "fa", "-l", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #13';

# test 14
@args = ( "--test", "-t", "species", "-i", "kleb", "-f", "gff" );
$exp_out = read_file("t/data/reffind/14.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 15
@args = ( "--test", "-t", "species", "-i", "kleb", "-f", "gff", "-a", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/15.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 16
@args = ( "--test", "-t", "species", "-i", "kleb", "-f", "gff", "-a", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #16';

# test 17
@args = ( "--test", "-t", "species", "-i", "kleb", "-f", "gff", "-l", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/17.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 18
@args = ( "--test", "-t", "species", "-i", "kleb", "-f", "gff", "-l", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #18';

# test 19
@args = ( "--test", "-t", "species", "-i", "leish", "-f", "embl" );
$exp_out = read_file("t/data/reffind/19.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 20
@args = ( "--test", "-t", "species", "-i", "leish", "-f", "embl", "-a", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/20.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 21
@args = ( "--test", "-t", "species", "-i", "leish", "-f", "embl", "-a", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #21';

# test 22
@args = ( "--test", "-t", "species", "-i", "leish", "-f", "embl", "-l", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/22.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 23
@args = ( "--test", "-t", "species", "-i", "leish", "-f", "embl", "-l", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #23';

# test 24
@args = ( "--test", "-t", "species", "-i", "clost", "-f", "annotation" );
$exp_out = read_file("t/data/reffind/24.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 25
@args = ( "--test", "-t", "species", "-i", "clost", "-f", "annotation", "-a", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/25.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 26
@args = ( "--test", "-t", "species", "-i", "clost", "-f", "annotation", "-a", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #26';

# test 27
@args = ( "--test", "-t", "species", "-i", "clost", "-f", "annotation", "-l", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/27.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 28
@args = ( "--test", "-t", "species", "-i", "clost", "-f", "annotation", "-l", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #28';

# test 29
@args = ( "--test", "-t", "species", "-i", "invalid_value", "-f", "fa", "-l", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown; test #29';

# test 30
@args = ( "--test", "-t", "species", "-i", "invalid_value", "-f", "gff", "-a", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown; test #30';

# test 31
@args = ( "--test", "-t", "species", "-i", "invalid_value", "-f", "embl" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown; test #31';

# test 32
@args = ( "--test", "-t", "species", "-i", "invalid_value", "-f", "annotation", "-l", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown; test #32';

# test 33
@args = ( "--test", "-t", "file", "-f", "fa", "-l", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #33';

# test 34
@args = ( "--test", "-t", "file", "-f", "gff" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #34';

# test 35
@args = ( "--test", "-t", "file", "-f", "embl", "-a", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #35';

# test 36
@args = ( "--test", "-t", "file", "-f", "annotation", "-l", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #36';

# test 37
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "fa" );
$exp_out = read_file("t/data/reffind/37.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 38
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "fa", "-a", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/38.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 39
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "fa", "-a", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #39';

# test 40
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "fa", "-l", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/40.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 41
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "fa", "-l", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #41';

# test 42
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "gff" );
$exp_out = read_file("t/data/reffind/42.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 43
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "gff", "-a", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/43.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 44
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "gff", "-a", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #44';

# test 45
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "gff", "-l", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/45.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 46
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "gff", "-l", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #46';

# test 47
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl" );
$exp_out = read_file("t/data/reffind/47.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 48
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl", "-a", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/48.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 49
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl", "-a", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #49';

# test 50
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl", "-l", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/50.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 51
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl", "-l", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #51';

# test 52
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "annotation" );
$exp_out = read_file("t/data/reffind/52.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 53
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "annotation", "-a", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/53.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok(-e "$tmp/valid_dest.tar.gz", 'archive exists');
ok(check_links('valid_dest.tar.gz', $exp_out), 'correct files present');

# test 54
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "annotation", "-a", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #54';

# test 55
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "annotation", "-l", "$tmp/valid_dest" );
$exp_out = read_file("t/data/reffind/55.txt");
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$tmp/valid_dest", 'symlink dir exists' );
ok( check_links('valid_dest', $exp_out), 'correct files symlinked' );

# test 56
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "annotation", "-l", "not/a/real/dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidDestination', 'correct error thrown; test #56';

# test 57
@args = ( "--test", "-t", "file", "-i", "invalid_value", "-f", "fa", "-l", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown; test #57';

# test 58
@args = ( "--test", "-t", "file", "-i", "invalid_value", "-f", "gff", "-a", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown; test #58';

# test 59
@args = ( "--test", "-t", "file", "-i", "invalid_value", "-f", "embl" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown; test #59';

# test 60
@args = ( "--test", "-t", "file", "-i", "invalid_value", "-f", "annotation", "-l", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::FileDoesNotExist', 'correct error thrown; test #60';

# test 61
@args = ( "--test", "-t", "species", "-i", "kleb", "-f", "gff", "-l", "$tmp/valid_dest", "-h" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown; test #61';

# test 62
@args = ( "--test", "-t", "file", "-i", "t/data/reffind/ref_lanes.txt", "-f", "embl", "-l", "$tmp/valid_dest", "-a", "$tmp/valid_dest" );
$obj = Path::Find::CommandLine::Ref->new(args => \@args, script_name => $script_name);
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown when symlink and archive used together';


File::Temp::cleanup();
done_testing();

sub check_links {
	my ($n, $fl) = @_;

	my $owd = getcwd();
	chdir($tmp);

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
	chdir($owd);

	if(!$result){
		print STDERR "DIR: $dir\n";
		system("ls $dir");
	}

	return $result;
}