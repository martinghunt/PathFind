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

use_ok('Path::Find::CommandLine::Info');

my $script_name = 'Path::Find::CommandLine::Info';
my $cwd = getcwd();

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();

my (@args, $arg_str, @formatted_out, $exp_out, $info_obj);

# test basic output
@args = qw(-t lane -id 10812_1#86);
@formatted_out = ("Lane\tSample\tSupplier Name\tPublic Name\tStrain",
"10812_1#86\t2682STDY5583393\tMDR1343\tMDR1343\tMDR1343");
$exp_out = "";
foreach my $line (@formatted_out){
	my @fields = split("\t", $line);
	$exp_out .= sprintf "%-15s %-25s %-25s %-25s %-20s\n", @fields;
}

$info_obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $info_obj->run } $exp_out, "Correct results for '$arg_str'";

# test study output
@args = qw(-t study -i 66);
@formatted_out = ("Lane\tSample\tSupplier Name\tPublic Name\tStrain",
"554_1\tPool 2\tNA\tA1338, AKU_12061, B4173, B418, B964, D441 A1338, AKU_12061, B4173, B418, B964, D441\t",
"554_2\tPool 7\tNA\tstr44, str10, str21, E771, B1378, 14/06 str44, str10, str21, E771, B1378, 14/06\t",
"554_3\tPool 6\tNA\t2664, BL1344, BL4579, B7697, 6911, 6912 2664, BL1344, BL4579, B7697, 6911, 6912\t",
"554_5\tPool 5\tNA\t2129, BL8758, BL4595, BL14275, 58/38, 138/69 2129, BL8758, BL4595, BL14275, 58/38, 138/69\t",
"554_6\tPool 4\tNA\tA1345, A2248, B4986, C806, D4075, F846 A1345, A2248, B4986, C806, D4075, F846\t",
"554_7\tPool 3\tNA\tAKU_12601\tAKU_12601",
"554_8\tPool 1\tNA\tB1357, D2383, D1985, B943, C4672 B1357, D2383, D1985, B943, C4672\t");
$exp_out = "";
foreach my $line (@formatted_out){
	print STDERR "$line\n";
	my @fields = split("\t", $line);
	$exp_out .= sprintf "%-15s %-25s %-25s %-25s %-20s\n", @fields;
}

$info_obj = Path::Find::CommandLine::Info->new(args => \@args, script_name => $script_name);
$arg_str = join(" ", @args);
stdout_is { $info_obj->run } $exp_out, "Correct results for '$arg_str'";

done_testing();