#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
	use Test::Output;
    use_ok('Path::Find::CommandLine::RNASeq');
}
my $script_name = 'Path::Find::CommandLine::RNASeq';
my $cwd = getcwd();

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my ($args, $exp_out, $rnaseq_obj);

# test basic output
$args = "-t lane -i 10131_4#34";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Actinobacillus/pleuropneumoniae/TRACKING/607/APP_T1_OP2/SLX/APP_T1_OP2_7492558/10131_4#34\n";

$rnaseq_obj = Path::Find::CommandLine::RNASeq->new(args => $args, script_name => $script_name);
stdout_is($rnaseq_obj->run, $exp_out, "Correct results for '$args'");

# test file type & file parse
$args = "-t file -i t/data/rnaseq_lanes.txt -f bam";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Actinobacillus/pleuropneumoniae/TRACKING/607/APP_N2_OP2/SLX/APP_N2_OP2_7492531/10018_1#9/544432.se.markdup.bam.corrected.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Haemophilus/parasuis/TRACKING/607/2B_in/SLX/2B_in_7822066/10421_1#60/589890.se.markdup.bam.corrected.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Haemophilus/parasuis/TRACKING/607/BDs_2hr/SLX/BDs_2hr_6229107/8896_1#9/544579.se.markdup.bam.corrected.bam\n";

$rnaseq_obj = Path::Find::CommandLine::RNASeq->new(args => $args, script_name => $script_name);
stdout_is($rnaseq_obj->run, $exp_out, "Correct results for '$args'");

# test symlink
$args = "-t study -i 576 -f intergenic -l $destination_directory/symlink_test";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Escherichia/coli/TRACKING/576/O157_Input/SLX/O157_Input_236583/4799_1/539628.se.markdup.bam.corrected.bam.intergenic.AE005174.tab.gz\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Escherichia/coli/TRACKING/576/O157_Output/SLX/O157_Output_236584/4799_2/539631.se.markdup.bam.corrected.bam.intergenic.AE005174.tab.gz\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Escherichia/coli/TRACKING/576/O157_Output/SLX/O157_Output_236584/5246_6/526341.se.markdup.bam.corrected.bam.intergenic.AE005174.tab.gz\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Escherichia/coli/TRACKING/576/O157_Output/SLX/O157_Output_236584/5359_6/522285.se.markdup.bam.corrected.bam.intergenic.AE005174.tab.gz\n";

$rnaseq_obj = Path::Find::CommandLine::RNASeq->new(args => $args, script_name => $script_name);
stdout_is($rnaseq_obj->run, $exp_out, "Correct results for '$args'");
ok( -d "$destination_directory/symlink_test", 'symlink directory exists' );
ok( -e "$destination_directory/symlink_test/539628.se.markdup.bam.corrected.bam.intergenic.AE005174.tab.gz", 'symlink exists');
ok( -e "$destination_directory/symlink_test/539631.se.markdup.bam.corrected.bam.intergenic.AE005174.tab.gz", 'symlink exists');
ok( -e "$destination_directory/symlink_test/526341.se.markdup.bam.corrected.bam.intergenic.AE005174.tab.gz", 'symlink exists');
ok( -e "$destination_directory/symlink_test/522285.se.markdup.bam.corrected.bam.intergenic.AE005174.tab.gz", 'symlink exists');

# test archive
$args = "-t study -i 576 -a $destination_directory/archive_test";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Escherichia/coli/TRACKING/576/O157_Input/SLX/O157_Input_236583/4799_1/539628.se.markdup.bam.corrected.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Escherichia/coli/TRACKING/576/O157_Output/SLX/O157_Output_236584/4799_2/539631.se.markdup.bam.corrected.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Escherichia/coli/TRACKING/576/O157_Output/SLX/O157_Output_236584/5246_6/526341.se.markdup.bam.corrected.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Escherichia/coli/TRACKING/576/O157_Output/SLX/O157_Output_236584/5359_6/522285.se.markdup.bam.corrected.bam\n";

$rnaseq_obj = Path::Find::CommandLine::RNASeq->new(args => $args, script_name => $script_name);
stdout_is($rnaseq_obj->run, $exp_out, "Correct results for '$args'");

ok( -e "$destination_directory/archive_test.tar.gz", 'archive exists');
system('tar xvfz archive_test.tar.gz');
ok( -d "$destination_directory/archive_test", 'decompressed archive directory exists' );
ok( -e "$destination_directory/archive_test/539628.se.markdup.bam.corrected.bam", 'archived file exists');
ok( -e "$destination_directory/archive_test/539631.se.markdup.bam.corrected.bam", 'archived file exists');
ok( -e "$destination_directory/archive_test/526341.se.markdup.bam.corrected.bam", 'archived file exists');
ok( -e "$destination_directory/archive_test/522285.se.markdup.bam.corrected.bam", 'archived file exists');

done_testing();

