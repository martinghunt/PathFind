#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;
use File::Temp;
use File::Spec;
use File::Compare;
no warnings qw{qw};

BEGIN { unshift( @INC, './lib' ) }
use Path::Find::Exception;

BEGIN {
    use Test::Most;
	use Test::Output;
	use Test::Exception;
}

use_ok('Path::Find::CommandLine::QC');

my $script_name = 'qcfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);


for my $type (qw/study lane file library sample species/) {
    @args = ( '--test', '-t', $type);
    $obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
    throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', "correct error thrown, no id given, type=$type";
}

@args = ( '--test', '-t', 'species', '-i', 'Shigella' );
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
$exp_out = read_file('t/data/qcfind/shigella.default.out');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


my @ids = ("1234_5#6", "name/of/file.txt", "name/of/file with spaces.txt");
my @expected = ("1234_5_6", "file.txt", "file_with_spaces.txt");
for my $i (0 .. $#ids) {
    @args = ( '--test', '-t', 'species', '-i', $ids[$i]);
    $obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
    is($obj->_outname, $expected[$i], "_outname made OK for ID $ids[$i]");
}


@ids = ("1234_5#6", "name/of/file.txt", "name/of/file with spaces.txt");
@expected = (
    "$cwd/1234_5_6.kraken_summary.csv",
    "$cwd/file.txt.kraken_summary.csv",
    "$cwd/file_with_spaces.txt.kraken_summary.csv"
);
for my $i (0 .. $#ids) {
    @args = ( '--test', '-t', 'species', '-i', $ids[$i]);
    $obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
    is($obj->_summary_file, $expected[$i], "_kraken_summary made OK for ID $ids[$i]");
}


@args = ( '--test', '-t', 'species', '-i', 'ID');
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
is($obj->_summary_file, "$cwd/ID.kraken_summary.csv", "_summary_file built OK with default");


@args = ( '--test', '-t', 'species', '-i', 'ID', '-s', 'summary.csv');
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
is($obj->_summary_file, "$cwd/summary.csv", "_summary_file built OK with -s summary.csv");


@args = ( '--test', '-t', 'species', '-i', 'ID', '-l');
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
is($obj->_symlink_dir, "$cwd/qcfind_ID", "_symlink_dir built OK with default");


@args = ( '--test', '-t', 'species', '-i', 'ID', '-l', 'symlink_dir');
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
is($obj->_symlink_dir, "$cwd/symlink_dir", "_symlink_dir built OK with -s symlink_dir");


@args = ( '--test', '-t', 'species', '-i', 'ID', '-a');
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
is($obj->_archive_name, "$cwd/qcfind_ID", "_archive_name built OK with default");


@args = ( '--test', '-t', 'species', '-i', 'ID', '-a', 'test');
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
is($obj->_archive_name, "$cwd/test", "_archive_name built OK with -a test");


@args = ( '--test', '-t', 'species', '-i', 'Shigella');
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
$exp_out = read_file('t/data/qcfind/shigella.make_summary.default.out');
$arg_str = join(" ", @args);
$obj->_get_lanes();
my $tmpdir = "$tmp/symlinks";
$obj->_symlink_or_archive($tmpdir, ".kraken.report", 0);
ok(check_links($tmpdir, $exp_out), 'correct files symlinked');
remove_tree($tmpdir);


my $tmp_csv = "$tmp/qcfind_test.csv";
@args = ( '--test', '-t', 'species', '-i', 'Shigella', '-level', 'P', '-s', $tmp_csv );
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
$exp_out = read_file('t/data/qcfind/shigella.make_summary.-s.qcfind_test.csv.out');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
ok( -e $tmp_csv, 'csv file exists');
ok(compare('t/data/qcfind/shigella.summary.default.csv', $tmp_csv) == 0, "csv file contents OK '$arg_str'");
unlink $tmp_csv;


@args = ( '--test', '-t', 'species', '-i', 'Shigella', '-level', 'P', '-s', $tmp_csv, '-transpose' );
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
$exp_out = read_file('t/data/qcfind/shigella.make_summary.-s.qcfind_test.-transpose.csv.out');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
ok( -e $tmp_csv, 'csv file exists');
ok(compare('t/data/qcfind/shigella.summary.-transpose.csv', $tmp_csv) == 0, "csv file contents OK '$arg_str'");
unlink $tmp_csv;


@args = ( '--test', '-t', 'species', '-i', 'Shigella', '-s', $tmp_csv, '-level', 'D' );
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
$exp_out = read_file('t/data/qcfind/shigella.make_summary.-s.qcfind_test.-level_D.csv.out');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
ok( -e $tmp_csv, 'csv file exists');
ok(compare('t/data/qcfind/shigella.summary.-level_D.csv', $tmp_csv) == 0, "csv file contents OK '$arg_str'");
unlink $tmp_csv;


@args = ( '--test', '-t', 'species', '-i', 'Shigella', '-level', 'P', '-s', $tmp_csv, '-counts');
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
$exp_out = read_file('t/data/qcfind/shigella.make_summary.-s.qcfind_test.-counts.csv.out');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
ok( -e $tmp_csv, 'csv file exists');
ok(compare('t/data/qcfind/shigella.summary.-counts.csv', $tmp_csv) == 0, "csv file contents OK '$arg_str'");
unlink $tmp_csv;


@args = ( '--test', '-t', 'species', '-i', 'Shigella', '-level', 'P', '-s', $tmp_csv, '-min_cutoff', '20');
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
$exp_out = read_file('t/data/qcfind/shigella.make_summary.-s.qcfind_test.-min_cutoff.20.csv.out');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
ok( -e $tmp_csv, 'csv file exists');
ok(compare('t/data/qcfind/shigella.make_summary.-min_cutoff.20.csv', $tmp_csv) == 0, "csv file contents OK '$arg_str'");
unlink $tmp_csv;


@args = ( '--test', '-t', 'species', '-i', 'Shigella', '-level', 'P', '-s', $tmp_csv, '-assigned_directly');
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
$exp_out = read_file('t/data/qcfind/shigella.make_summary.-s.qcfind_test.-assigned_directly.csv.out');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";
ok( -e $tmp_csv, 'csv file exists');
ok(compare('t/data/qcfind/shigella.summary.-assigned_directly.csv', $tmp_csv) == 0, "csv file contents OK '$arg_str'");
unlink $tmp_csv;


$tmpdir = "qcfind_archive";
@args = ( '--test', '-t', 'species', '-i', 'Shigella', '-a', $tmpdir);
$exp_out = read_file('t/data/qcfind/shigella.archive.default.out');
$arg_str = join(" ", @args);
$obj = Path::Find::CommandLine::QC->new(args => \@args, script_name => 'qcfind');
$obj->run();
ok(check_archive("$tmpdir.tar.gz", $exp_out), "archive OK for '$arg_str'");


system("rm -r qcfind_*");
done_testing();


sub check_links {
    my $dir = shift;
    my $links_filecontents = shift;
    my @expected_links = split(/\n/, $links_filecontents);

    for my $abs_path (@expected_links) {
        my @dirs = File::Spec->splitdir($abs_path);
        my $filename = $dirs[-1];
        my $lane = $dirs[-2];
        return 0 unless (-e File::Spec->catfile($dir, "$lane.kraken.report"));
    }
    return 1;
}


sub check_archive {
    my $archive = shift;
    my $expected_links = shift;
    my $dir;
    if ($archive =~ /^(.*)\.tar\.gz$/) {
        $dir = $1;
    }
    else {
        return 0;
    }
    system("tar -zxf $archive") and return 0;
    return 0 unless (-e "$dir/kraken_summary.csv");
    return check_links($dir, $expected_links);
}
