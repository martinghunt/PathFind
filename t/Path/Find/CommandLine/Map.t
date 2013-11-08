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

my (@args, $arg_str, $exp_out, $map_obj);

# test basic output
@args = qw(-t lane -id 10018_1#18);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Actinobacillus/pleuropneumoniae/TRACKING/607/APP_N5_OP1/SLX/APP_N5_OP1_7492543/10018_1#18\n";

$map_obj = Path::Find::CommandLine::Map->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is({$map_obj->run}, $exp_out, "Correct results for '$arg_str'");

# test file type & file parse
@args = qw(-t file -i t/data/map_lanes.txt -f bam);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica/TRACKING/697/CAN0185/SLX/CAN0185_5140165/7978_7#14/392948.pe.markdup.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica/TRACKING/697/CAN0185/SLX/CAN0185_5140165/7978_7#14/490636.pe.markdup.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Klebsiella/pneumoniae/TRACKING/2512/2512STDY5462705/SLX/6898003/9776_6#32/474610.pe.markdup.bam\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Klebsiella/pneumoniae/TRACKING/2512/2512STDY5462705/SLX/6898003/9776_6#32/582798.pe.markdup.bam\n";

$map_obj = Path::Find::CommandLine::Map->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is({$map_obj->run}, $exp_out, "Correct results for '$arg_str'");

# test symlink
@args = qw(-t study -i 2005 -l $destination_directory/symlink_test);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_vit_exp/SLX/Lc_vit_exp_3980720/7114_6#1\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_vit_sta/SLX/Lc_vit_sta_3980721/7114_6#2\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Lactobacillus/casei/TRACKING/2005/Lc_viv_cae/SLX/Lc_viv_cae_3980722/7114_6#3\n";

$map_obj = Path::Find::CommandLine::Map->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is({$map_obj->run}, $exp_out, "Correct results for '$arg_str'");
ok( -d "$destination_directory/symlink_test", 'symlink directory exists' );
ok( -e "$destination_directory/symlink_test/116135.pe.markdup.bam", 'symlink exists');
ok( -e "$destination_directory/symlink_test/116138.pe.markdup.bam", 'symlink exists');
ok( -e "$destination_directory/symlink_test/116141.pe.markdup.bam", 'symlink exists');

# test archive
@args = qw(-t study -i 2510 -a $destination_directory/archive_test);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2510/2510STDY5462330/SLX/6742020/9472_4#78\n";

$map_obj = Path::Find::CommandLine::Map->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is({$map_obj->run}, $exp_out, "Correct results for '$arg_str'");

ok( -e "$destination_directory/archive_test.tar.gz", 'archive exists');
system('tar xvfz archive_test.tar.gz');
ok( -d "$destination_directory/archive_test", 'decompressed archive directory exists' );
ok( -e "$destination_directory/archive_test/659132.pe.markdup.bam", 'archived file exists');

# test verbose output
@args = qw(-t file -i t/data/map_verbose_lanes.txt -v);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Campylobacter/jejuni/TRACKING/2310/57_33_cj/SLX/57_33_cj_5765944/8489_8#89\tCampylobacter_jejuni_subsp_jejuni_M1_v1\tbwa\t22-04-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Klebsiella/pneumoniae/TRACKING/2585/202M1D0/SLX/202M1D0_7080284/9659_1#2\tKlebsiella_pneumoniae_subsp_pneumoniae_Ecl8_v1.1\tbwa\t27-06-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2332/2332STDY5490471/SLX/7346728/9953_5#58\tSalmonella_enterica_subsp_enterica_serovar_Typhi_str_CT18_v1\tsmalt\t15-08-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2332/2332STDY5490472/SLX/7346740/9953_5#59\tSalmonella_enterica_subsp_enterica_serovar_Typhi_str_CT18_v1\tsmalt\t15-08-2013\n";

$map_obj = Path::Find::CommandLine::Map->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is({$map_obj->run}, $exp_out, "Correct results for '$arg_str'");

# test d mapper filter
@args = qw(-t file -i t/data/map_verbose_lanes.txt -v -m bwa);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Campylobacter/jejuni/TRACKING/2310/57_33_cj/SLX/57_33_cj_5765944/8489_8#89\tCampylobacter_jejuni_subsp_jejuni_M1_v1\tbwa\t22-04-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Klebsiella/pneumoniae/TRACKING/2585/202M1D0/SLX/202M1D0_7080284/9659_1#2\tKlebsiella_pneumoniae_subsp_pneumoniae_Ecl8_v1.1\tbwa\t27-06-2013\n";

$map_obj = Path::Find::CommandLine::Map->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is({$map_obj->run}, $exp_out, "Correct results for '$arg_str'");

# test date filter
@args = qw(-t file -i t/data/map_verbose_lanes.txt -v -d 01-08-2013);
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2332/2332STDY5490471/SLX/7346728/9953_5#58\tSalmonella_enterica_subsp_enterica_serovar_Typhi_str_CT18_v1\tsmalt\t15-08-2013\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Salmonella/enterica_subsp_enterica_serovar_Typhi/TRACKING/2332/2332STDY5490472/SLX/7346740/9953_5#59\tSalmonella_enterica_subsp_enterica_serovar_Typhi_str_CT18_v1\tsmalt\t15-08-2013\n";

$map_obj = Path::Find::CommandLine::Map->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is({$map_obj->run}, $exp_out, "Correct results for '$arg_str'");

# test reference filter
@args = qw(-t file -i t/data/map_verbose_lanes.txt -v -r Salmonella_enterica_subsp_enterica_serovar_Typhi_str_CT18_v1);

$map_obj = Path::Find::CommandLine::Map->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is({$map_obj->run}, $exp_out, "Correct results for '$arg_str'");

# test stats file
@args = qw(-t file -i t/data/map_lanes.txt -s $destination_directory/mapfind_test.stats);
ok( -e "$destination_directory/mapfind_test.stats", 'stats file exists');
is(
	read_file("$destination_directory/mapfind_test.stats"),
	read_file("t/data/mapfind_stats.exp"),
	'stats are correct'
);



done_testing();

