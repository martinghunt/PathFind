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
    use_ok('Path::Find::CommandLine::Tradis');
}
my $script_name = 'Path::Find::CommandLine::Tradis';
my $cwd = getcwd();

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $tradis_obj);

# test basic output
@args = qw(-t lane -id 4354_3#6);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/451/CALF3_51_55_IN/SLX/CALF3_51_55_IN_112184/4354_3#6\n";

$tradis_obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is($tradis_obj->run, $exp_out, "Correct results for '$arg_str'");

# test file type & file parse
@args = qw(-t file -i t/data/tradis_lanes.txt -f bam);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/451/CALF1_11_15_IN/SLX/CALF1_11_15_IN_112182/4354_7#5/545055.se.markdup.bam.corrected.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/PMHKU30_1/SLX/PMHKU30_1_4049668/7138_6#15/454631.pe.markdup.bam.corrected.bam\n";

$tradis_obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is($tradis_obj->run, $exp_out, "Correct results for '$arg_str'");

# test symlink
@args = qw(-t study -i 2561 -l $destination_directory/symlink_test);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Citrobacter/rodentium/TRACKING/2561/1_CR_TraDIS/SLX/1_CR_TraDIS_6982967/9521_1#1\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Pseudomonas/aeruginosa/TRACKING/2561/Gm_input_1/SLX/Gm_input_1_6982965/9521_1#14\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Pseudomonas/aeruginosa/TRACKING/2561/Gm_input_2/SLX/Gm_input_2_6982966/9521_1#15\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Citrobacter/rodentium/TRACKING/2561/2_CR_TraDIS/SLX/2_CR_TraDIS_6982970/9521_1#2\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Citrobacter/rodentium/TRACKING/2561/2_CR_TraDIS/SLX/2_CR_TraDIS_6982968/9521_1#3\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Citrobacter/rodentium/TRACKING/2561/1_CR_TraDIS/SLX/1_CR_TraDIS_6982969/9521_1#5\n";

$tradis_obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is($tradis_obj->run, $exp_out, "Correct results for '$arg_str'");

ok( -d "$destination_directory/symlink_test", 'symlink directory exists' );
ok( -e "$destination_directory/symlink_test/520105.se.markdup.bam.insertion.csv", 'symlink exists');
ok( -e "$destination_directory/symlink_test/520108.se.markdup.bam.insertion.csv", 'symlink exists');
ok( -e "$destination_directory/symlink_test/520111.se.markdup.bam.insertion.csv", 'symlink exists');
ok( -e "$destination_directory/symlink_test/520153.se.markdup.bam.insertion.csv", 'symlink exists');
ok( -e "$destination_directory/symlink_test/526338.se.markdup.bam.insertion.csv", 'symlink exists');
ok( -e "$destination_directory/symlink_test/557408.se.markdup.bam.insertion.csv", 'symlink exists');

# test archive
@args = qw(-t study -i 2561 -a $destination_directory/archive_test);

$tradis_obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is($tradis_obj->run, $exp_out, "Correct results for '$arg_str'");

ok( -e "$destination_directory/archive_test.tar.gz", 'archive exists');
system('tar xvfz archive_test.tar.gz');
ok( -d "$destination_directory/archive_test", 'decompressed archive directory exists' );
ok( -e "$destination_directory/archive_test/520105.se.markdup.bam.insertion.csv", 'archived file exists');
ok( -e "$destination_directory/archive_test/520108.se.markdup.bam.insertion.csv", 'archived file exists');
ok( -e "$destination_directory/archive_test/520111.se.markdup.bam.insertion.csv", 'archived file exists');
ok( -e "$destination_directory/archive_test/520153.se.markdup.bam.insertion.csv", 'archived file exists');
ok( -e "$destination_directory/archive_test/526338.se.markdup.bam.insertion.csv", 'archived file exists');
ok( -e "$destination_directory/archive_test/557408.se.markdup.bam.insertion.csv", 'archived file exists');

# test verbose
@args = qw(-t file -i t/data/tradis_verbose_lanes.txt -v);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/suis/TRACKING/607/A_M_6_IN_2/SLX/A_M_6_IN_2_5647193/8211_1#4/539502.se.markdup.bam.corrected.bam\tStreptococcus_suis_P1_7_v1\tsmalt\t13-07-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Clostridium/difficile/TRACKING/2027/R20291_S1/SLX/R20291_S1_5765227/8405_4#7/377155.pe.markdup.bam.corrected.bam\tClostridium_difficile_630_v1\tbwa\t23-05-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Clostridium/difficile/TRACKING/2027/R20291_S1/SLX/R20291_S1_5765227/8405_4#7/445618.pe.markdup.bam.corrected.bam\tClostridium_difficile_630_v1\tbwa\t23-05-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Clostridium/difficile/TRACKING/2027/R20291_S2/SLX/R20291_S2_5765228/8405_4#8/377152.pe.markdup.bam.corrected.bam\tClostridium_difficile_630_v1\tbwa\t23-05-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Clostridium/difficile/TRACKING/2027/R20291_S2/SLX/R20291_S2_5765228/8405_4#8/445621.pe.markdup.bam.corrected.bam\tClostridium_difficile_630_v1\tbwa\t23-05-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2342/5_STyphi_Rif_2/SLX/5_STyphi_Rif_2_6098734/8788_8#24/557441.se.markdup.bam.corrected.bam\tSalmonella_enterica_subsp_enterica_serovar_Typhi_Ty2_v1\tsmalt\t29-07-2013\n";

$tradis_obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is($tradis_obj->run, $exp_out, "Correct results for '$arg_str'");

# test mapper filter
@args = qw(-t file -i t/data/tradis_verbose_lanes.txt -v -m smalt);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/suis/TRACKING/607/A_M_6_IN_2/SLX/A_M_6_IN_2_5647193/8211_1#4/539502.se.markdup.bam.corrected.bam\tStreptococcus_suis_P1_7_v1\tsmalt\t13-07-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2342/5_STyphi_Rif_2/SLX/5_STyphi_Rif_2_6098734/8788_8#24/557441.se.markdup.bam.corrected.bam\tSalmonella_enterica_subsp_enterica_serovar_Typhi_Ty2_v1\tsmalt\t29-07-2013\n";

$tradis_obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is($tradis_obj->run, $exp_out, "Correct results for '$arg_str'");

# test date filter
@args = qw(-t file -i t/data/tradis_verbose_lanes.txt -v -d 01-07-2013);

$tradis_obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is($tradis_obj->run, $exp_out, "Correct results for '$arg_str'");

# test reference filter
@args = qw(-t file -i t/data/tradis_verbose_lanes.txt -v -r Streptococcus_suis_P1_7_v1);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/suis/TRACKING/607/A_M_6_IN_2/SLX/A_M_6_IN_2_5647193/8211_1#4/539502.se.markdup.bam.corrected.bam\tStreptococcus_suis_P1_7_v1\tsmalt\t13-07-2013\n";

$tradis_obj = Path::Find::CommandLine::Tradis->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is($tradis_obj->run, $exp_out, "Correct results for '$arg_str'");

# test stats file

done_testing();

