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

use_ok('Path::Find::CommandLine::Plex');

my $script_name = 'Path::Find::CommandLine::Plex';
my $cwd = getcwd();

my $destination_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $plex_obj);

# test basic output
@args = qw(-t lane -i 11233_1);
$exp_out = "C2_Bp, 11233_1, 28, pass, pending 
D50_Bt, 11233_1, 29, pass, pending 
Gabon_Bp, 11233_1, 30, pass, pending \n";

$plex_obj = Path::Find::CommandLine::Plex->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $plex_obj->run } $exp_out, "Correct results for '$arg_str'";

# test file parse and file type
@args = qw(-t study -i 1707);
$exp_out = "46082A21, 5749_8, 5, pass, passed 
46082E21, 5749_8, 6, pass, passed 
straina, 5749_8, 4, pass, passed 
2950, 5749_8, 2, pass, passed 
TL266, 5749_8, 1, pass, passed 
3507, 5749_8, 3, pass, passed \n";

$plex_obj = Path::Find::CommandLine::Plex->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $plex_obj->run } $exp_out, "Correct results for '$arg_str'";

done_testing();