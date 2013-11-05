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
    use_ok('Path::Find::CommandLine::Assembly');
}
my $script_name = 'Path::Find::CommandLine::Assembly';
my $cwd = getcwd();

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my ($args, $exp_out, $ass_obj);

# test basic output
$args = "-t lane -id 5364_8#1";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pyogenes/TRACKING/655/NS53GAS/SLX/NS53GAS_1351267/5364_8#1/velvet_assembly/contigs.fa\n";

$ass_obj = Path::Find::CommandLine::Assembly->new(args => $args, script_name => $script_name);
stdout_is($ass_obj->run, $exp_out, "Correct results for '$args'");

# test file type & file parse
$args = "-t file -i t/data/assembly_lanes.txt -f contigs";
$exp_out = "//lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Streptococcus/pneumoniae/TRACKING/466/ILBStrepP15424631/SLX/6714257/9517_4#15/velvet_assembly/contigs.fa\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Staphylococcus/aureus/TRACKING/2662/2662STDY5553572/SLX/8094217/10770_3#64/velvet_assembly/contigs.fa\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Escherichia/coli/TRACKING/2133/epc0012/SLX/epc0012_4818015/7853_6#12/velvet_assembly/contigs.fa\n";

$ass_obj = Path::Find::CommandLine::Assembly->new(args => $args, script_name => $script_name);
stdout_is($ass_obj->run, $exp_out, "Correct results for '$args'");

# test symlink
$args = "-t study -i 2583 -l $destination_directory/symlink_test";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/u/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/unidentified/TRACKING/2583/SK116C1P/SLX/SK116C1P_7067788/9653_7#1/velvet_assembly/contigs.fa\n
/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/unidentified/TRACKING/2583/SK116C2P/SLX/SK116C2P_7067789/9653_7#2/velvet_assembly/contigs.fa\n";

$ass_obj = Path::Find::CommandLine::Assembly->new(args => $args, script_name => $script_name);
stdout_is($ass_obj->run, $exp_out, "Correct results for '$args'");
ok( -d "$destination_directory/symlink_test", 'symlink directory exists' );
ok( -e "$destination_directory/symlink_test/9653_7#1.contigs_velvet.fa", 'symlink exists');
ok( -e "$destination_directory/symlink_test/9653_7#2.contigs_velvet.fa", 'symlink exists');

# test archive
$args = "-t study -i 2727 -a $destination_directory/archive_test";
$exp_out = "/lustre/scratch108/pathogen/pathpipe/prokaryotes/seq-pipelines/Burkholderia/gladioli/TRACKING/2727/BCC0238_A/SLX/BCC0238_A_7908989/10532_1#75/velvet_assembly/contigs.fa\n";

$ass_obj = Path::Find::CommandLine::Assembly->new(args => $args, script_name => $script_name);
stdout_is($ass_obj->run, $exp_out, "Correct results for '$args'");

ok( -e "$destination_directory/archive_test.tar.gz", 'archive exists');
system('tar xvfz archive_test.tar.gz');
ok( -d "$destination_directory/archive_test", 'decompressed archive directory exists' );
ok( -e "$destination_directory/archive_test/10532_1#75.contigs_velvet.fa", 'archived file exists');

done_testing();

