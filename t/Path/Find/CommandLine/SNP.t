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

done_testing();

