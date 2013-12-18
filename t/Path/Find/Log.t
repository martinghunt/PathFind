#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp;
use File::Path qw(make_path);
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift(@INC, '/software/pathogen/internal/pathdev/vr-codebase/modules') }

BEGIN {
    use Test::Most;
}

use_ok('Path::Find::Log');

# set tempdir
my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $temp_directory     = $temp_directory_obj->dirname();

# set fake command line args
my @argv;

# create object and log file
my $log_file_01 = $temp_directory.'/log_01.csv';
ok(( my $log_obj_01 = Path::Find::Log->new(logfile => $log_file_01, args => \@argv) ), 'created object' );
ok( $log_obj_01->commandline(), 'write line to log file');
ok( -e $log_file_01, 'log file created');
ok( -s $log_file_01, 'log file written');
ok( $log_obj_01->commandline(), 'write second line to log file');

# writes to /dev/null
ok(( Path::Find::Log->new(logfile => '/dev/null', args => \@argv)->commandline() ), 'writes to /dev/null');

# doesn't write to unwritable file
my $unwritable_file = $temp_directory.'/unwritable.log';
open(my $fh,'>',$unwritable_file);
close($fh);
chmod 0444, $unwritable_file;
ok(!( Path::Find::Log->new(logfile => $unwritable_file, args => \@argv)->commandline() ),'fails to write to unwritable log file (silent)');
chmod 0666, $unwritable_file;

# check progname and user
my $user = getpwuid( $< );
my $prog = $0;
ok(( $log_obj_01->_username eq $user), 'user name correct');
ok(( $log_obj_01->_progname eq $prog), 'prog name correct');

# check date and time format
my $row  = $log_obj_01->_row;
my $time = $$row[0];
ok($time =~ m/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}Z$/, 'timestamp format correct');

# check output for lane query
@argv = ('-ty','lane','-id','1234_5#6'); # fake command line (lane)
my $log_obj_02 = Path::Find::Log->new(logfile => '/dev/null', args => \@argv);
ok( $log_obj_02->_args_string eq ' -ty lane -id 1234_5#6', 'lane args correct');

# check output for species query
@argv = ('-ty','species','-id','Tyrannosaurus rex'); # fake command line (species)
my $log_obj_03 = Path::Find::Log->new(logfile => '/dev/null', args => \@argv);
ok( $log_obj_03->_args_string eq qq[ -ty species -id 'Tyrannosaurus rex'], 'species args correct');

# check output for study query 
@argv = ('-ty','study','-id',"Tyrannosaurus rex, 'Susan'."); # fake command line (study)
my $log_obj_04 = Path::Find::Log->new(logfile => '/dev/null', args => \@argv);
ok( $log_obj_04->_args_string eq qq[ -ty study -id "Tyrannosaurus rex, 'Susan'."], 'study args correct');

done_testing();
