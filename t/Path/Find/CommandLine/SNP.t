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
$args = "-t lane -id ***";
$exp_out = "***\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");

# test file type & file parse
$args = "-t file -i *** -f ***";
$exp_out = "***\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");

# test symlink
$args = "-t study -i *** -l $destination_directory/symlink_test";
$exp_out = "***\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");
ok( -d "$destination_directory/symlink_test", 'symlink directory exists' );
ok( -e "$destination_directory/symlink_test/***", 'symlink exists');

# test archive
$args = "-t study -i *** -a $destination_directory/archive_test";
$exp_out = "***\n";

$snp_obj = Path::Find::CommandLine::SNP->new(args => $args, script_name => $script_name);
stdout_is($snp_obj->run, $exp_out, "Correct results for '$args'");

ok( -e "$destination_directory/archive_test.tar.gz", 'archive exists');
system('tar xvfz archive_test.tar.gz');
ok( -d "$destination_directory/archive_test", 'decompressed archive directory exists' );
ok( -e "$destination_directory/archive_test/***", 'archived file exists');

done_testing();

