#!/usr/bin/env perl
use strict;
use warnings;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
}

use_ok('Path::Find::Linker');

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 0 );
my $destination_directory = $destination_directory_obj->dirname();

my ( @lanes, $linker_obj );

@lanes = (
    { path => 't/data/links' }
);

ok(
    $linker_obj = Path::Find::Linker->new(
        lanes => \@lanes,
        name  => "$destination_directory/link_test",
		_default_type => '/*.fastq',
		use_default_type => 1
    ),
    'creating linker object'
);

#test symlink creation
ok( $linker_obj->sym_links, 'testing sym linking' );

print "LS of $destination_directory/link_test:\n";
system("ls $destination_directory/link_test");

ok( -e "$destination_directory/link_test/test1.fastq",
    'checking link existence' );
ok( -e "$destination_directory/link_test/test2.fastq",
    'checking link existence' );
ok( -e "$destination_directory/link_test/test3.fastq",
    'checking link existence' );
#clean up
unlink glob "$destination_directory/link_test/test*";
rmdir "$destination_directory/link_test";

#test archive creation
ok( $linker_obj->archive, 'testing archive creation' );
ok( -e "$destination_directory/link_test.tar.gz" );

system("gunzip $destination_directory/link_test.gz");
ok( -e "$destination_directory/link_test/test1.fastq",
    'checking file existence' );
ok( -e "$destination_directory/link_test/test2.fastq",
    'checking file existence' );
ok( -e "$destination_directory/link_test/test3.fastq",
    'checking file existence' );
#clean up
unlink glob "$destination_directory/link_test/test*";
rmdir "$destination_directory/link_test";

#test link renaming
my %link_names = (
    't/data/links/test1.fastq' => 't1.fastq',
    't/data/links/test2.fastq' => 't2.fastq',
    't/data/links/test3.fastq' => 't3.fastq'
);
ok(
    $linker_obj = Path::Find::Linker->new(
        lanes        => \@lanes,
        name         => '$destination_directory/link_rename_test',
        rename_links => \%link_names
    ),
    'creating linker object'
);

#test renamed symlink creation
ok( $linker_obj->sym_links, 'testing renamed sym linking' );
ok( -e "$destination_directory/link_rename_test/t1.fastq",
    'checking link existence' );
ok( -e "$destination_directory/link_rename_test/t2.fastq",
    'checking link existence' );
ok( -e "$destination_directory/link_rename_test/t3.fastq",
    'checking link existence' );
#clean up
unlink glob "$destination_directory/link_rename_test/t*";
rmdir "$destination_directory/link_rename_test";

#test archive creation
ok( $linker_obj->archive, 'testing renamed archive creation' );
ok( -e "$destination_directory/link_rename_test.gz" );

system("gunzip $destination_directory/link_rename_test.gz");
ok( -e "$destination_directory/link_rename_test/t1.fastq",
    'checking file existence' );
ok( -e "$destination_directory/link_rename_test/t2.fastq",
    'checking file existence' );
ok( -e "$destination_directory/link_rename_test/t3.fastq",
    'checking file existence' );
#clean up
unlink glob "$destination_directory/link_rename_test/t*";
rmdir "$destination_directory/link_rename_test";

File::Temp::cleanup();
done_testing();
