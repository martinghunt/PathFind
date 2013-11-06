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
    use_ok('Path::Find::CommandLine::Map');
}
my $script_name = 'Path::Find::CommandLine::Map';
my $cwd = getcwd();

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my ($args, $exp_out, $map_obj);

# test basic output
$args = "-t lane -id 10018_1#18";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Actinobacillus/pleuropneumoniae/TRACKING/607/APP_N5_OP1/SLX/APP_N5_OP1_7492543/10018_1#18\n";

$map_obj = Path::Find::CommandLine::Map->new(args => $args, script_name => $script_name);
stdout_is($map_obj->run, $exp_out, "Correct results for '$args'");

# test file type & file parse
$args = "-t file -i t/data/map_lanes.txt -f bam";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica/TRACKING/697/CAN0185/SLX/CAN0185_5140165/7978_7#14/392948.pe.markdup.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica/TRACKING/697/CAN0185/SLX/CAN0185_5140165/7978_7#14/490636.pe.markdup.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Klebsiella/pneumoniae/TRACKING/2512/2512STDY5462705/SLX/6898003/9776_6#32/474610.pe.markdup.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Klebsiella/pneumoniae/TRACKING/2512/2512STDY5462705/SLX/6898003/9776_6#32/582798.pe.markdup.bam\n";

$map_obj = Path::Find::CommandLine::Map->new(args => $args, script_name => $script_name);
stdout_is($map_obj->run, $exp_out, "Correct results for '$args'");

# test symlink
$args = "-t study -i 2005 -l $destination_directory/symlink_test";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_vit_exp/SLX/Lc_vit_exp_3980720/7114_6#1\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_vit_sta/SLX/Lc_vit_sta_3980721/7114_6#2\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_viv_cae/SLX/Lc_viv_cae_3980722/7114_6#3\n";

$map_obj = Path::Find::CommandLine::Map->new(args => $args, script_name => $script_name);
stdout_is($map_obj->run, $exp_out, "Correct results for '$args'");
ok( -d "$destination_directory/symlink_test", 'symlink directory exists' );
ok( -e "$destination_directory/symlink_test/116135.pe.markdup.bam", 'symlink exists');
ok( -e "$destination_directory/symlink_test/116138.pe.markdup.bam", 'symlink exists');
ok( -e "$destination_directory/symlink_test/116141.pe.markdup.bam", 'symlink exists');

# test archive
$args = "-t study -i 2510 -a $destination_directory/archive_test";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2510/2510STDY5462330/SLX/6742020/9472_4#78\n";

$map_obj = Path::Find::CommandLine::Map->new(args => $args, script_name => $script_name);
stdout_is($map_obj->run, $exp_out, "Correct results for '$args'");

ok( -e "$destination_directory/archive_test.tar.gz", 'archive exists');
system('tar xvfz archive_test.tar.gz');
ok( -d "$destination_directory/archive_test", 'decompressed archive directory exists' );
ok( -e "$destination_directory/archive_test/659132.pe.markdup.bam", 'archived file exists');

# test verbose output
$args = "-t study -i 2234 -v";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCTRL1/SLX/TyCTRL1_5521546/8086_1#1\tSalmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1\tsmalt\t11-07-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCTRL2/SLX/TyCTRL2_5521547/8086_1#2\tSalmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1\tsmalt\t25-06-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCPI1/SLX/TyCPI1_5521548/8086_1#3\tSalmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1\tsmalt\t25-06-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCIP2/SLX/TyCIP2_5521549/8086_1#4\tSalmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1\tsmalt\t11-07-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCTRL1_3/SLX/TyCTRL1_3_5521550/8086_1#5\tSalmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1\tsmalt\t25-06-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCTRL2_3/SLX/TyCTRL2_3_5521551/8086_1#6\tSalmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1\tsmalt\t25-06-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCPI1_3/SLX/TyCPI1_3_5521552/8086_1#7\tSalmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1\tsmalt\t25-06-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCIP2_3/SLX/TyCIP2_3_5521553/8086_1#8\tSalmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1\tsmalt\t25-06-2013\n";

$map_obj = Path::Find::CommandLine::Map->new(args => $args, script_name => $script_name);
stdout_is($map_obj->run, $exp_out, "Correct results for '$args'");

# test date filtering
$args = "-t study -i 2234 -v -d 01-07-2013";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCTRL1/SLX/TyCTRL1_5521546/8086_1#1\tSalmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1\tsmalt\t11-07-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhimurium/TRACKING/2234/TyCIP2/SLX/TyCIP2_5521549/8086_1#4\tSalmonella_enterica_subsp_enterica_serovar_Typhimurium_SL1344_v1\tsmalt\t11-07-2013\n";

$map_obj = Path::Find::CommandLine::Map->new(args => $args, script_name => $script_name);
stdout_is($map_obj->run, $exp_out, "Correct results for '$args'");

# test mapper filtering

# test reference filtering

# test stats


done_testing();

