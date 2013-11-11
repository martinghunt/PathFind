#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;
use File::Temp;

no warnings qw{qw};

sub run_object {
	my $ro = shift;
	$ro->run;
}

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
	use Test::Output;
}

use_ok('Path::Find::CommandLine::Annotation');

my $script_name = 'annotationfind';
my $cwd = getcwd();

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $ann_obj);

# test basic output
@args = qw(-t lane -i 11064_1#67);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Chlamydia/trachomatis/TRACKING/162/162STDY5591713/SLX/8283265/11064_1#67/velvet_assembly/annotation\n";

$ann_obj = Path::Find::CommandLine::Annotation->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $ann_obj->run } $exp_out, "Correct results for '$arg_str'";

# test file type & file parse
@args = qw(-t file -i t/data/annotation_lanes.txt -f gff);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Staphylococcus/aureus/TRACKING/1943/1943STDY5484090/SLX/6898333/9716_4#9/velvet_assembly/annotation/9716_4#9.gff
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Staphylococcus/aureus/TRACKING/2282/GN_19103_6281/SLX/GN_19103_6281_7244322/9802_1#66/velvet_assembly/annotation/9802_1#66.gff
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Staphylococcus/aureus/TRACKING/2282/GN_ss_86/SLX/GN_ss_86_7280619/9852_1#81/velvet_assembly/annotation/9852_1#81.gff\n";

$ann_obj = Path::Find::CommandLine::Annotation->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $ann_obj->run } $exp_out, "Correct results for '$arg_str'";

# test symlink
@args = ("-t", "study", "-i", "2583", "-f", "faa", "-l", "$destination_directory/symlink_test");
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/unidentified/TRACKING/2583/SK116C1P/SLX/SK116C1P_7067788/9653_7#1/velvet_assembly/annotation/9653_7#1.faa
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/unidentified/TRACKING/2583/SK116C2P/SLX/SK116C2P_7067789/9653_7#2/velvet_assembly/annotation/9653_7#2.faa\n";

$ann_obj = Path::Find::CommandLine::Annotation->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $ann_obj->run } $exp_out, "Correct results for '$arg_str'";
ok( -d "$destination_directory/symlink_test", 'symlink directory exists' );
ok( -e "$destination_directory/symlink_test/9653_7#1.faa", 'symlink exists');
ok( -e "$destination_directory/symlink_test/9653_7#2.faa", 'symlink exists');
remove_tree('symlink_test');

# test archive
@args = ("-t", "study", "-i", "2489", "-f", "ffn", "-a", "$destination_directory/archive_test");
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mus/musculus/TRACKING/2489/BMDM_I_3/SLX/BMDM_I_3_6884105/9555_5#15/velvet_assembly/annotation/9555_5#15.ffn
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mus/musculus/TRACKING/2489/BMDM_I_3/SLX/BMDM_I_3_6884105/9555_6#15/velvet_assembly/annotation/9555_6#15.ffn
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mus/musculus/TRACKING/2489/BMDM_I_3/SLX/BMDM_I_3_6884105/9555_7#15/velvet_assembly/annotation/9555_7#15.ffn
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Mus/musculus/TRACKING/2489/BMDM_I_3/SLX/BMDM_I_3_6884105/9555_8#15/velvet_assembly/annotation/9555_8#15.ffn\n";

$ann_obj = Path::Find::CommandLine::Annotation->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $ann_obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$destination_directory/archive_test.tar.gz", 'archive exists');
system("cd $destination_directory; tar xvfz archive_test.tar.gz");
ok( -d "$destination_directory/archive_test", 'decompressed archive directory exists' );
ok( -e "$destination_directory/archive_test/9555_5#15.ffn", 'ffn file exists');
ok( -e "$destination_directory/archive_test/9555_6#15.ffn", 'ffn file exists');
ok( -e "$destination_directory/archive_test/9555_7#15.ffn", 'ffn file exists');
ok( -e "$destination_directory/archive_test/9555_8#15.ffn", 'ffn file exists');
remove_tree("$destination_directory/archive_test");
unlink("$destination_directory/archive_test.tar.gz");

# test stats file
@args = ("-t", "file", "-i", "t/data/annotation_lanes.txt", "-s", "$destination_directory/annotationfind_test.stats");
$ann_obj = Path::Find::CommandLine::Annotation->new(args => \@args, script_name => $script_name);
$ann_obj->run;
ok( -e "$destination_directory/annotationfind_test.stats", 'stats file exists');
is(
	read_file("$destination_directory/annotationfind_test.stats"),
	read_file("t/data/annotationfind_stats.exp"),
	'stats are correct'
);

done_testing();