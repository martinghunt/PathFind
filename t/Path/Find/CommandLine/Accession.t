#!/usr/bin/env perl
use Moose;
use Cwd;
use File::Temp;
no warnings qw{qw};

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
	use Test::Output;
}

use_ok('Path::Find::CommandLine::Accession');

my $script_name = 'accessionfind';
my $cwd = getcwd();

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $acc_obj);

# test basic output
@args = qw(-t lane -id 5463_3#1);
$exp_out = "B0402_2\tERS005123\t5463_3#1\tERR361821\n";

$acc_obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $acc_obj->run } $exp_out, "Correct results for '$arg_str'";

# test file parse
@args = qw(-t file -i t/data/accession_lanes.txt);
$exp_out = "2047STDY5552273\tERS311560\t10660_2#13\tERR363472
2047STDY5552104\tERS311393\t10665_2#81\tnot found
2047STDY5552201\tERS311489\t10665_2#90\tnot found\n";
$acc_obj = Path::Find::CommandLine::Accession->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $acc_obj->run } $exp_out, "Correct results for '$arg_str'";

done_testing();