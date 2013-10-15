#!/usr/bin/env perl
use strict;
use warnings;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Path::Find::Linker');
}

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my ( @lanes, $linker_obj );

@lanes = (
    { lane => '../../data/test1.fastq' },
    { lane => '../../data/test2.fastq' },
    { lane => '../../data/test3.fastq' }
);

ok(
    $linker_obj = Path::Find::Linker->new(
        lanes => \@lanes,
        name  => '$destination_directory/link_test'
    ),
    'creating linker object'
);

#test symlink creation
ok( $linker_obj->sym_links, 'testing sym linking' );
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
ok( -e "$destination_directory/link_test.gz" );

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
    '../../data/test1.fastq' => 't1.fastq',
    '../../data/test2.fastq' => 't2.fastq',
    '../../data/test3.fastq' => 't3.fastq'
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


done_testing();
