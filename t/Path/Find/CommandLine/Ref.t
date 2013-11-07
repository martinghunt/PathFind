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

# test annotation file retrieval
$args = "-t species -i vibrio -f annotation";
$exp_out = "//lustre/scratch108/pathogen/pathpipe/refs/Vibrio/cholerae_O1_biovar_eltor_str_N16961/annotation/Vibrio_cholerae_O1_biovar_eltor_str_N16961_v1.gff\n
/lustre/scratch108/pathogen/pathpipe/refs/Vibrio/cholerae_O1_biovar_eltor_str_N16961/annotation/Vibrio_cholerae_O1_biovar_eltor_str_N16961_v2.gff\n
/lustre/scratch108/pathogen/pathpipe/refs/Vibrio/cholerae_O395/annotation/Vibrio_cholerae_O395_v1.gff\n";

$ref_obj = Path::Find::CommandLine::Ref->new(args => $args, script_name => $script_name);
stdout_is($ref_obj->run, $exp_out, "Correct results for '$args'");

# test symlink
$args = "-t species -i dublin -f fa -l $destination_directory/symlink_test";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/refs/Salmonella/enterica_subsp_enterica_serovar_Dublin_str_BA207/Salmonella_enterica_subsp_enterica_serovar_Dublin_str_BA207_v0.1.fa
/lustre/scratch108/pathogen/pathpipe/refs/Salmonella/enterica_subsp_enterica_serovar_Dublin_str_SC50/Salmonella_enterica_subsp_enterica_serovar_Dublin_str_SC50_v0.1.fa\n";

$ref_obj = Path::Find::CommandLine::Ref->new(args => $args, script_name => $script_name);
stdout_is($ref_obj->run, $exp_out, "Correct results for '$args'");
ok( -d "$destination_directory/symlink_test", 'symlink directory exists' );
ok( -e "$destination_directory/symlink_test/Salmonella_enterica_subsp_enterica_serovar_Dublin_str_BA207_v0.1.fa", 'symlink exists');
ok( -e "$destination_directory/symlink_test/Salmonella_enterica_subsp_enterica_serovar_Dublin_str_SC50_v0.1.fa", 'symlink exists');

# test archive
$args = "-t study -i dublin -f fa -a $destination_directory/archive_test";

$ref_obj = Path::Find::CommandLine::Ref->new(args => $args, script_name => $script_name);
stdout_is($ref_obj->run, $exp_out, "Correct results for '$args'");

ok( -e "$destination_directory/archive_test.tar.gz", 'archive exists');
system('tar xvfz archive_test.tar.gz');
ok( -d "$destination_directory/archive_test", 'decompressed archive directory exists' );
ok( -e "$destination_directory/archive_test/Salmonella_enterica_subsp_enterica_serovar_Dublin_str_BA207_v0.1.fa", 'archived file exists');
ok( -e "$destination_directory/archive_test/Salmonella_enterica_subsp_enterica_serovar_Dublin_str_SC50_v0.1.fa", 'archived file exists');

done_testing();

