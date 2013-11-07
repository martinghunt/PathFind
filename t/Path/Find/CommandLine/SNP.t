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
    use_ok('Path::Find::CommandLine::SNP');
}
my $script_name = 'Path::Find::CommandLine::SNP';
my $cwd = getcwd();

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my ($args, $exp_out, $snp_obj);

# test basic output
$args = "-t lane -id 10593_1#41";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2332/2332STDY5573209/SLX/7995746/10593_1#41\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");

# test file type & file parse
$args = "-t file -i t/data/snp_lanes.txt -f vcf";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2332/2332STDY5539185/SLX/7734077/10316_1#85/559303.pe.markdup.snp/mpileup.unfilt.vcf.gz\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2332/2332STDY5539185/SLX/7734077/10316_1#85/606177.pe.markdup.snp/mpileup.unfilt.vcf.gz\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/522/A16329/SLX/A16329_153823/4821_3#1/443255.pe.markdup.snp/mpileup.unfilt.vcf.gz\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Vibrio/cholerae/TRACKING/352/A363_Vc/SLX/A363_Vc_5274327/8036_3#15/174114.pe.markdup.snp/mpileup.unfilt.vcf.gz\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");

# test symlink
$args = "-t study -i 2005 -l $destination_directory/symlink_test";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_vit_exp/SLX/Lc_vit_exp_3980720/7114_6#1/116135.pe.markdup.snp/mpileup.unfilt.vcf.gz\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_vit_sta/SLX/Lc_vit_sta_3980721/7114_6#2/116138.pe.markdup.snp/mpileup.unfilt.vcf.gz\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_viv_cae/SLX/Lc_viv_cae_3980722/7114_6#3/116141.pe.markdup.snp/mpileup.unfilt.vcf.gz\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");
ok( -d "$destination_directory/symlink_test", 'symlink directory exists' );
ok( -e "$destination_directory/symlink_test/116135.mpileup.unfilt.vcf.gz", 'symlink exists');
ok( -e "$destination_directory/symlink_test/116138.mpileup.unfilt.vcf.gz", 'symlink exists');
ok( -e "$destination_directory/symlink_test/116141.mpileup.unfilt.vcf.gz", 'symlink exists');

# test archive
$args = "-t study -i 2005 -a $destination_directory/archive_test";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");

ok( -e "$destination_directory/archive_test.tar.gz", 'archive exists');
system('tar xvfz archive_test.tar.gz');
ok( -d "$destination_directory/archive_test", 'decompressed archive directory exists' );
ok( -e "$destination_directory/archive_test/116135.mpileup.unfilt.vcf.gz", 'archived file exists');
ok( -e "$destination_directory/archive_test/116138.mpileup.unfilt.vcf.gz", 'archived file exists');
ok( -e "$destination_directory/archive_test/116141.mpileup.unfilt.vcf.gz", 'archived file exists');

# test verbose output
$args = "-t file -i t/data/snp_verbose_lanes.txt -v";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU16_3/SLX/HKU16_3_4002741/7138_8#3\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU30_1/SLX/HKU30_1_4002742/7138_8#4\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Wolbachia/endosymbiont_of_Drosophila_simulans/TRACKING/651/wAu_070612/SLX/wAu_070612_5552870/8163_8#94\tSalmonella_enterica_subsp_enterica_serovar_Paratyphi_A_str_AKU_12601_v1\tsmalt\t01-10-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Vibrio/cholerae/TRACKING/352/F15KTH7/SLX/F15KTH7_3152222/6714_5#15\tVibrio_cholerae_O1_biovar_eltor_str_N16961_v1\tsmalt\t18-10-2013\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");

# test d mapper filter
$args = "-t file -i t/data/snp_verbose_lanes.txt -v -m bwa";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU16_3/SLX/HKU16_3_4002741/7138_8#3\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU30_1/SLX/HKU30_1_4002742/7138_8#4\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");

# test date filter
$args = "-t file -i t/data/snp_verbose_lanes.txt -v -d 01-08-2013";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Wolbachia/endosymbiont_of_Drosophila_simulans/TRACKING/651/wAu_070612/SLX/wAu_070612_5552870/8163_8#94\tSalmonella_enterica_subsp_enterica_serovar_Paratyphi_A_str_AKU_12601_v1\tsmalt\t01-10-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Vibrio/cholerae/TRACKING/352/F15KTH7/SLX/F15KTH7_3152222/6714_5#15\tVibrio_cholerae_O1_biovar_eltor_str_N16961_v1\tsmalt\t18-10-2013\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");

# test reference filter
$args = "-t file -i t/data/snp_verbose_lanes.txt -v -r Streptococcus_pyogenes_BC2_HKU16_v0.1";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU16_3/SLX/HKU16_3_4002741/7138_8#3\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU30_1/SLX/HKU30_1_4002742/7138_8#4\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");

done_testing();

