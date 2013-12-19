#!/usr/bin/env perl
use Moose;
use Carp;
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
}

use_ok('Path::Find::CommandLine::SNP');

my $script_name = 'snpfind';

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my (@args, $arg_str, $snp_stdout, $exp_out, $snp_obj);

# test basic output
@args = ("-t", "lane", "-id", "10593_1#41");
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2332/2332STDY5573209/SLX/7995746/10593_1#41\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
isa_ok $snp_obj, 'Path::Find::CommandLine::SNP';
$arg_str = join(" ", @args);
stdout_is { $snp_obj->run } $exp_out, "Correct results for '$arg_str'";

# test file type & file parse
@args = qw(-t file -i t/data/snp_lanes.txt -f vcf);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/522/A16329/SLX/A16329_153823/4821_3#1/443255.pe.markdup.snp/mpileup.unfilt.vcf.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Vibrio/cholerae/TRACKING/352/A363_Vc/SLX/A363_Vc_5274327/8036_3#15/174114.pe.markdup.snp/mpileup.unfilt.vcf.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2332/2332STDY5539185/SLX/7734077/10316_1#85/559303.pe.markdup.snp/mpileup.unfilt.vcf.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2332/2332STDY5539185/SLX/7734077/10316_1#85/606177.pe.markdup.snp/mpileup.unfilt.vcf.gz\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $snp_obj->run } $exp_out, "Correct results for '$arg_str'";

# test symlink
@args = ("-t", "study", "-i", "2005", "-f", "vcf", "-l", "$destination_directory/symlink_test");
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_vit_exp/SLX/Lc_vit_exp_3980720/7114_6#1/116135.pe.markdup.snp/mpileup.unfilt.vcf.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_vit_sta/SLX/Lc_vit_sta_3980721/7114_6#2/116138.pe.markdup.snp/mpileup.unfilt.vcf.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_viv_cae/SLX/Lc_viv_cae_3980722/7114_6#3/116141.pe.markdup.snp/mpileup.unfilt.vcf.gz\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $snp_obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -d "$destination_directory/symlink_test", 'symlink directory exists' );
system("ls $destination_directory/symlink_test");
ok( -e "$destination_directory/symlink_test/7114_6#1.116135.mpileup.unfilt.vcf.gz", 'symlinked file exists');
ok( -e "$destination_directory/symlink_test/7114_6#1.116135.mpileup.unfilt.vcf.gz.tbi", 'symlinked index exists');
ok( -e "$destination_directory/symlink_test/7114_6#2.116138.mpileup.unfilt.vcf.gz", 'symlinked file exists');
ok( -e "$destination_directory/symlink_test/7114_6#2.116138.mpileup.unfilt.vcf.gz.tbi", 'symlinked index exists');
ok( -e "$destination_directory/symlink_test/7114_6#3.116141.mpileup.unfilt.vcf.gz", 'symlinked file exists');
ok( -e "$destination_directory/symlink_test/7114_6#3.116141.mpileup.unfilt.vcf.gz.tbi", 'symlinked index exists');
remove_tree('symlink_test');

# test archive
@args = ("-t", "study", "-i", "2005", "-a", "$destination_directory/archive_test");
$snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $snp_obj->run } $exp_out, "Correct results for '$arg_str'";

ok( -e "$destination_directory/archive_test.tar.gz", 'archive exists');
system("cd $destination_directory; tar xvfz archive_test.tar.gz");
ok( -d "$destination_directory/archive_test", 'decompressed archive directory exists' );
ok( -e "$destination_directory/archive_test/7114_6#1.116135.mpileup.unfilt.vcf.gz", 'archived file exists');
ok( -e "$destination_directory/archive_test/7114_6#1.116135.mpileup.unfilt.vcf.gz.tbi", 'archived index file exists');
ok( -e "$destination_directory/archive_test/7114_6#2.116138.mpileup.unfilt.vcf.gz", 'archived file exists');
ok( -e "$destination_directory/archive_test/7114_6#2.116138.mpileup.unfilt.vcf.gz.tbi", 'archived index file exists');
ok( -e "$destination_directory/archive_test/7114_6#3.116141.mpileup.unfilt.vcf.gz", 'archived file exists');
ok( -e "$destination_directory/archive_test/7114_6#3.116141.mpileup.unfilt.vcf.gz.tbi", 'archived index file exists');
remove_tree("$destination_directory/archive_test");
unlink("$destination_directory/archive_test.tar.gz");

File::Temp::cleanup();

# test verbose output
@args = qw(-t file -i t/data/snp_verbose_lanes.txt -v);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Vibrio/cholerae/TRACKING/352/F15KTH7/SLX/F15KTH7_3152222/6714_5#15/665855.pe.markdup.snp/mpileup.unfilt.vcf.gz\tVibrio_cholerae_O1_biovar_eltor_str_N16961_v1\tsmalt\t18-10-2013
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Vibrio/cholerae/TRACKING/352/F15KTH7/SLX/F15KTH7_3152222/6714_5#15/670240.pe.markdup.snp/mpileup.unfilt.vcf.gz\tVibrio_cholerae_O1_biovar_eltor_str_N16961_v2\tsmalt\t22-10-2013
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Vibrio/cholerae/TRACKING/352/F15KTH7/SLX/F15KTH7_3152222/6714_5#15/690687.pe.markdup.snp/mpileup.unfilt.vcf.gz\tVibrio_cholerae_O1_biovar_eltor_str_N16961_v2\tsmalt\t28-11-2013
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU16_3/SLX/HKU16_3_4002741/7138_8#3/454622.pe.markdup.snp/mpileup.unfilt.vcf.gz\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU30_1/SLX/HKU30_1_4002742/7138_8#4/454625.pe.markdup.snp/mpileup.unfilt.vcf.gz\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Wolbachia/endosymbiont_of_Drosophila_simulans/TRACKING/651/wAu_070612/SLX/wAu_070612_5552870/8163_8#94/652831.pe.markdup.snp/mpileup.unfilt.vcf.gz\tSalmonella_enterica_subsp_enterica_serovar_Paratyphi_A_str_AKU_12601_v1\tsmalt\t01-10-2013\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $snp_obj->run } $exp_out, "Correct results for '$arg_str'";

# test d mapper filter
@args = qw(-t file -i t/data/snp_verbose_lanes.txt -v -m bwa);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU16_3/SLX/HKU16_3_4002741/7138_8#3/454622.pe.markdup.snp/mpileup.unfilt.vcf.gz\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU30_1/SLX/HKU30_1_4002742/7138_8#4/454625.pe.markdup.snp/mpileup.unfilt.vcf.gz\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $snp_obj->run } $exp_out, "Correct results for '$arg_str'";

# test date filter
@args = qw(-t file -i t/data/snp_verbose_lanes.txt -v -d 01-08-2013);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Vibrio/cholerae/TRACKING/352/F15KTH7/SLX/F15KTH7_3152222/6714_5#15/665855.pe.markdup.snp/mpileup.unfilt.vcf.gz\tVibrio_cholerae_O1_biovar_eltor_str_N16961_v1\tsmalt\t18-10-2013
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Vibrio/cholerae/TRACKING/352/F15KTH7/SLX/F15KTH7_3152222/6714_5#15/670240.pe.markdup.snp/mpileup.unfilt.vcf.gz\tVibrio_cholerae_O1_biovar_eltor_str_N16961_v2\tsmalt\t22-10-2013
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Vibrio/cholerae/TRACKING/352/F15KTH7/SLX/F15KTH7_3152222/6714_5#15/690687.pe.markdup.snp/mpileup.unfilt.vcf.gz\tVibrio_cholerae_O1_biovar_eltor_str_N16961_v2\tsmalt\t28-11-2013
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Wolbachia/endosymbiont_of_Drosophila_simulans/TRACKING/651/wAu_070612/SLX/wAu_070612_5552870/8163_8#94/652831.pe.markdup.snp/mpileup.unfilt.vcf.gz\tSalmonella_enterica_subsp_enterica_serovar_Paratyphi_A_str_AKU_12601_v1\tsmalt\t01-10-2013\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $snp_obj->run } $exp_out, "Correct results for '$arg_str'";

# test reference filter
@args = qw(-t file -i t/data/snp_verbose_lanes.txt -v -r Streptococcus_pyogenes_BC2_HKU16_v0.1);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU16_3/SLX/HKU16_3_4002741/7138_8#3/454622.pe.markdup.snp/mpileup.unfilt.vcf.gz\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/2027/HKU30_1/SLX/HKU30_1_4002742/7138_8#4/454625.pe.markdup.snp/mpileup.unfilt.vcf.gz\tStreptococcus_pyogenes_BC2_HKU16_v0.1\tbwa\t12-04-2013\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $snp_obj->run } $exp_out, "Correct results for '$arg_str'";

# test reference filter without -v option
@args = qw(-t file -i t/data/verbose_test.lanes -r Streptococcus_pneumoniae_str_110.58_v0.4);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pneumoniae/TRACKING/2245/2245STDY5609344/SLX/8529277/11511_8#88/703681.pe.markdup.snp/mpileup.unfilt.vcf.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pneumoniae/TRACKING/2245/2245STDY5609347/SLX/8529194/11511_8#89/703774.pe.markdup.snp/mpileup.unfilt.vcf.gz
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pneumoniae/TRACKING/2245/2245STDY5609348/SLX/8529206/11511_8#90/704062.pe.markdup.snp/mpileup.unfilt.vcf.gz\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $snp_obj->run } $exp_out, "Correct results for '$arg_str'";

# test pseudogenome creation
@args = ('-t', 'lane', '-i', '10464_1#1', '-r', 'Salmonella_enterica_subsp_enterica_serovar_Typhimurium_str_LT2_v1', '-p');
$snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
$snp_obj->run;
ok( -e '10464_1_1_Salmonella_enterica_subsp_enterica_serovar_Typhimurium_str_LT2_v1_concatenated.aln', 'pseudogenome created' );
is(
	read_file('10464_1_1_Salmonella_enterica_subsp_enterica_serovar_Typhimurium_str_LT2_v1_concatenated.aln'),
	read_file('t/data/pseudogenome_exp.aln'),
	'pseudogenome is correct'
);
unlink('10464_1_1_Salmonella_enterica_subsp_enterica_serovar_Typhimurium_str_LT2_v1_concatenated.aln');

# # test pseudogenome with ambiguous reference
# @args = ('-t', 'lane', '-i', '10464_1#1', '-r', 'Dublin', '-p' );
# $snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
# my $exp_err = "Creating pseudogenome in 10464_1_1_Dublin_concatenated.aln
# Ambiguous reference. Did you mean:
# Salmonella_enterica_subsp_enterica_serovar_Dublin_str_BA207_v0.1
# Salmonella_enterica_subsp_enterica_serovar_Dublin_str_SC50_v0.1
# Could not find reference: Dublin. Pseudogenome creation aborted.\n";
# stderr_is { $snp_obj->run } $exp_err, "Correct message for ambiguous reference";

# test pseudogenome without reference
@args = ('-t', 'lane', '-i', '10464_1#1', '-p', 'none' );
$snp_obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => $script_name);
$snp_obj->run;
ok( -e '10464_1_1_concatenated.aln', 'pseudogenome created');
is(
	read_file('10464_1_1_concatenated.aln'),
	read_file('t/data/pseudogenome_no_ref.aln'),
	'pseudogenome without reference seq correct'
);
unlink('10464_1_1_concatenated.aln');

done_testing();