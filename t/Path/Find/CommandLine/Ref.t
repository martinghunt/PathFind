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
    use_ok('Path::Find::CommandLine::Ref');
}
my $script_name = 'Path::Find::CommandLine::Ref';
my $cwd = getcwd();

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my ($args, $exp_out, $ref_obj);

# test basic output
$args = "-s cholera";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/refs/Salmonella/enterica_subsp_enterica_serovar_Choleraesuis_str_SC-B67\n
/lustre/scratch108/pathogen/pathpipe/refs/Vibrio/cholerae_O1_biovar_eltor_str_N16961\n
/lustre/scratch108/pathogen/pathpipe/refs/Vibrio/cholerae_O395\n";

$ref_obj = Path::Find::CommandLine::Ref->new(args => $args, script_name => $script_name);
stdout_is($ref_obj->run, $exp_out, "Correct results for '$args'");

# test file parse and file type
$args = "-t file -i t/data/ref_lanes.txt -f fa";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/refs/Shigella/boydii_CDC_3083-94/Shigella_boydii_CDC_3083-94_v1.fa\n
/lustre/scratch108/pathogen/pathpipe/refs/Shigella/boydii_Sb227/Shigella_boydii_Sb227_v1.fa\n
/lustre/scratch108/pathogen/pathpipe/refs/Shigella/sonnei_53G/Shigella_sonnei_53G_v1.fa\n
/lustre/scratch108/pathogen/pathpipe/refs/Shigella/sonnei_Ss046/Shigella_sonnei_Ss046_v1.fa\n";

$ref_obj = Path::Find::CommandLine::Ref->new(args => $args, script_name => $script_name);
stdout_is($ref_obj->run, $exp_out, "Correct results for '$args'");

# test symlink
$args = "-t study -i 2561 -l $destination_directory/symlink_test";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Citrobacter/rodentium/TRACKING/2561/1_CR_TraDIS/SLX/1_CR_TraDIS_6982967/9521_1#1\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Pseudomonas/aeruginosa/TRACKING/2561/Gm_input_1/SLX/Gm_input_1_6982965/9521_1#14\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Pseudomonas/aeruginosa/TRACKING/2561/Gm_input_2/SLX/Gm_input_2_6982966/9521_1#15\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Citrobacter/rodentium/TRACKING/2561/2_CR_TraDIS/SLX/2_CR_TraDIS_6982970/9521_1#2\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Citrobacter/rodentium/TRACKING/2561/2_CR_TraDIS/SLX/2_CR_TraDIS_6982968/9521_1#3\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Citrobacter/rodentium/TRACKING/2561/1_CR_TraDIS/SLX/1_CR_TraDIS_6982969/9521_1#5\n";

$ref_obj = Path::Find::CommandLine::Ref->new(args => $args, script_name => $script_name);
stdout_is($ref_obj->run, $exp_out, "Correct results for '$args'");
ok( -d "$destination_directory/symlink_test", 'symlink directory exists' );
ok( -e "$destination_directory/symlink_test/520105.se.markdup.bam.insertion.csv", 'symlink exists');
ok( -e "$destination_directory/symlink_test/520108.se.markdup.bam.insertion.csv", 'symlink exists');
ok( -e "$destination_directory/symlink_test/520111.se.markdup.bam.insertion.csv", 'symlink exists');
ok( -e "$destination_directory/symlink_test/520153.se.markdup.bam.insertion.csv", 'symlink exists');
ok( -e "$destination_directory/symlink_test/526338.se.markdup.bam.insertion.csv", 'symlink exists');
ok( -e "$destination_directory/symlink_test/557408.se.markdup.bam.insertion.csv", 'symlink exists');

# test archive
$args = "-t study -i 2561 -a $destination_directory/archive_test";

$ref_obj = Path::Find::CommandLine::Ref->new(args => $args, script_name => $script_name);
stdout_is($ref_obj->run, $exp_out, "Correct results for '$args'");

ok( -e "$destination_directory/archive_test.tar.gz", 'archive exists');
system('tar xvfz archive_test.tar.gz');
ok( -d "$destination_directory/archive_test", 'decompressed archive directory exists' );
ok( -e "$destination_directory/archive_test/520105.se.markdup.bam.insertion.csv", 'archived file exists');
ok( -e "$destination_directory/archive_test/520108.se.markdup.bam.insertion.csv", 'archived file exists');
ok( -e "$destination_directory/archive_test/520111.se.markdup.bam.insertion.csv", 'archived file exists');
ok( -e "$destination_directory/archive_test/520153.se.markdup.bam.insertion.csv", 'archived file exists');
ok( -e "$destination_directory/archive_test/526338.se.markdup.bam.insertion.csv", 'archived file exists');
ok( -e "$destination_directory/archive_test/557408.se.markdup.bam.insertion.csv", 'archived file exists');

done_testing();

