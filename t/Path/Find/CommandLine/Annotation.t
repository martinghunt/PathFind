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

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 0 );
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
@args = ( '--test', '-t', 'file', '-i', 't/data/annotationfind/annotation_lanes.txt', '-f', 'ffn', '-o', 'valid_value' );
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
unlink("output.yfgF_1.fa");

# test 24
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-g', 'yfgF_1', '-n' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/24.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "output.yfgF_1.fa", 'output file exists' );
compare_ok("output.yfgF_1.fa", "t/data/annotationfind/annotation_nuc.txt", "files are identical");
unlink("output.yfgF_1.fa");

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
unlink("valid_out.yfgF_1.fa");

# test 27
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-p' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 28
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-p', 'cytochrome C' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "output.cytochromeC.fa", 'output file exists' );
compare_ok("output.cytochromeC.fa", "t/data/annotationfind/annotation_cc.fa", "files are identical");
unlink("output.cytochromeC.fa");

# test 29
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-g', 'yfgF_1', '-p', 'cytochrome C');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "output.yfgF_1.fa", 'output file exists' );
compare_ok("output.yfgF_1.fa", "t/data/annotationfind/annotation_aa.txt", "files are identical");
unlink("output.yfgF_1.fa");

# test 30
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-g', 'yfgF_1', '-p', 'cytochrome C', '-n');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/30.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "output.yfgF_1.fa", 'output file exists' );
compare_ok("output.yfgF_1.fa", "t/data/annotationfind/annotation_nuc.txt", "files are identical");
unlink("output.yfgF_1.fa");

# test 31
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-o', 'valid', '-n',  '-g', 'yfgF_1', '-p', 'cytochrome C');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/31.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "valid.yfgF_1.fa", 'output file exists' );
compare_ok("valid.yfgF_1.fa", "t/data/annotationfind/annotation_nuc.txt", "files are identical");
unlink("valid.yfgF_1.fa");

# test 32
@args = ('--test', '-t', 'species', '-i', 'Shigella flexneri', '-g', 'yfgF_1', '-a' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 33
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-g', 'yfgF_1', '-a' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 34
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-f', 'faa','-g', 'yfgF_1' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 35
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-f', 'ffn','-g', 'yfgF_1' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 36
@args = ( '--test', '-t' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 37
@args = ( '--test', '-t', 'species', '-i' );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 38
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-f');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 39
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-s');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/39.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "Shigella_flexneri.annotation_stats.csv", 'output file exists' );
compare_ok("Shigella_flexneri.annotation_stats.csv", "t/data/annotationfind/annotation_stats_species.exp", "files are identical");
unlink('Shigella_flexneri.annotation_stats.csv');

# test 40
@args = ( '--test', '-t', 'species', '-i', 'Shigella flexneri', '-s', 'statsfile');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/40.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "statsfile", 'output file exists' );
compare_ok("statsfile", "t/data/annotationfind/annotation_stats_species.exp", "files are identical");
unlink("statsfile");

# test 41
@args = ( '--test', '-t', 'file', '-i', 't/data/annotationfind/annotation_lanes.txt', '-s');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/41.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "annotation_lanes.txt.annotation_stats.csv", 'output file exists' );
compare_ok("annotation_lanes.txt.annotation_stats.csv", "t/data/annotationfind/annotation_stats_file.exp", "files are identical");
unlink("annotation_lanes.txt.annotation_stats.csv");

# test 42
@args = ( '--test', '-t', 'file', '-i', 't/data/annotationfind/annotation_lanes.txt', '-s', 'filestatsfile.csv');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/42.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "filestatsfile.csv", 'output file exists' );
compare_ok("filestatsfile.csv", "t/data/annotationfind/annotation_stats_file.exp", "files are identical");
unlink("filestatsfile.csv");

# test 43
@args = ( '--test', '-t', 'lane', '-i', '5477_6#2', '-s');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/43.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "5477_6_2.annotation_stats.csv", 'output file exists' );
compare_ok("5477_6_2.annotation_stats.csv", "t/data/annotationfind/annotation_stats_lane.exp", "files are identical");
unlink("5477_6_2.annotation_stats.csv");

# test 44
@args = ( '--test', '-t', 'lane', '-i', '5477_6#2', '-s', 'lanestatsfile.csv');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/44.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "lanestatsfile.csv", 'output file exists' );
compare_ok("lanestatsfile.csv", "t/data/annotationfind/annotation_stats_lane.exp", "files are identical");
unlink("lanestatsfile.csv");

# test 45
@args = ( '--test', '-t', 'study', '-i', 'Test Study 2', '-s');
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/45.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "Test_Study_2.annotation_stats.csv", 'output file exists' );
compare_ok("Test_Study_2.annotation_stats.csv", "t/data/annotationfind/annotation_stats_study.exp", "files are identical");
unlink("Test_Study_2.annotation_stats.csv");

# test 46
@args = ( '--test', '-t', 'study', '-i', 'Test Study 2', '-s', "$tmp/studystatsfile.csv", '-a', "$tmp/test_archive" );
$obj =Path::Find::CommandLine::Annotation->new(args => \@args, script_name => 'annotationfind');
$exp_out = read_file('t/data/annotationfind/46.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check file
ok( -e "$tmp/studystatsfile.csv", 'output file exists' );
#compare_ok("studystatsfile.csv", "t/data/annotationfind/annotation_stats_study.exp", "files are identical");
is(
	read_file("$tmp/studystatsfile.csv"),
	read_file('t/data/annotationfind/annotation_stats_study.exp'),
	'file contents correct'
);
unlink("studystatsfile.csv");

# check stats inside archive
ok( -e "$tmp/test_archive.tar.gz", 'archive exists');
my $owd = getcwd();
chdir($tmp);
system("tar xvfz test_archive.tar.gz");
chdir($owd);
ok( -e "$tmp/test_archive/stats.csv", 'stats file exists' );
compare_ok("$tmp/test_archive/stats.csv", "t/data/annotationfind/annotation_stats_study.exp", "archived stats correct");

remove_tree($tmp);
done_testing();


sub check_links {
	my ($n, $fl, $cwd) = @_;

	my @exp_files = exp_files($fl);

	my $tar = $n =~ /\.tar\.gz/ ? 1 : 0;
	my $owd = getcwd();
	chdir($tmp) unless($cwd);

	my $dir = $n;
	if($tar){
		system("tar xvfz $n");
		$dir =~ s/\.tar\.gz//;
		push(@exp_files, 'stats.csv');
	}

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
