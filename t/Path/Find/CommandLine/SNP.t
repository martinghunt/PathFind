#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;
use File::Temp;
no warnings qw{qw};

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
	use Test::Output;
	use Test::Exception;
}

use_ok('Path::Find::CommandLine::SNP');

my $script_name = 'snpfind';
my $cwd = getcwd();

my $temp_directory_obj = File::Temp->newdir(DIR => getcwd, CLEANUP => 1 );
my $tmp = $temp_directory_obj->dirname();

my (@args, $arg_str, $exp_out, $obj);

# test 1
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/1.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 2
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/2.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 3
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 4
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/4.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 5
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-d', '19-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/5.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 6
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-d', '19-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 7
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 8
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 9
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'Streptococcus_pneumoniae_INV200_v1' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/9.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 10
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/10.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 11
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 12
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/12.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 13
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '19-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/13.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 14
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '19-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 15
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 16
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 17
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 18
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 19
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'invalid_value', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 20
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-r', 'invalid_value', '-d', '19-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 21
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-v' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/21.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 22
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-v', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/22.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 23
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-v', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 24
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-v', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/24.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 25
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'vcf', '-v', '-d', '19-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/25.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 26
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-d', '19-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 27
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 28
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 29
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/29.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 30
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/30.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 31
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 32
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/32.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 33
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '19-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/33.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";


# test 34
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '19-03-2014', '-m', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 35
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 36
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 37
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'invalid_value' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 38
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'invalid_value', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 39
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'invalid_value', '-d', '19-03-2014' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 40
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'invalid_value', '-d', '19-03-2014', '-m', 'smalt' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';


# stats not implemented!!
# test 41
#@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-s', '-d', '19-03-2014' );
#$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
#$exp_out = read_file('t/data/snpfind/41.txt');
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 42
#@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-s', '-m', 'smalt' );
#$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
#$exp_out = read_file('t/data/snpfind/42.txt');
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 43
#@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-s', '-r', 'Streptococcus_pneumoniae_INV200_v1' );
#$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
#$exp_out = read_file('t/data/snpfind/43.txt');
#$arg_str = join(" ", @args);
#stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 44
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-r', 'invalid_value', '-p' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# duplicate
# test 45
#@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-p' );
#$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
#throws_ok {$obj->run} 'Path::Find::Exception::NoMatches', 'correct error thrown';

# test 46
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-d', '19-03-2014', '-p' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 47
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-m', 'smalt', '-p' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

# test 48
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-p' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/48.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check pseudogenome
is(
    read_file('t/data/snpfind/48.fa'),
    read_file("snp_lanes_Streptococcus_pneumoniae_INV200_v1_concatenated.aln"),
    'pseudogenome correct'
);
unlink('snp_lanes_Streptococcus_pneumoniae_INV200_v1_concatenated.aln');

# test 49
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '19-03-2014', '-p' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/49.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check pseudogenome
is(
    read_file('t/data/snpfind/49.fa'),
    read_file("snp_lanes_Streptococcus_pneumoniae_INV200_v1_concatenated.aln"),
    'pseudogenome correct'
);
unlink('snp_lanes_Streptococcus_pneumoniae_INV200_v1_concatenated.aln');

# test 50
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-m', 'smalt', '-p' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/50.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check pseudogenome
is(
    read_file('t/data/snpfind/50.fa'),
    read_file("snp_lanes_Streptococcus_pneumoniae_INV200_v1_concatenated.aln"),
    'pseudogenome correct'
);
unlink('snp_lanes_Streptococcus_pneumoniae_INV200_v1_concatenated.aln');

# test 51
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-d', '19-03-2014', '-m', 'smalt', '-p' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/51.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check pseudogenome
is(
    read_file('t/data/snpfind/51.fa'),
    read_file("snp_lanes_Streptococcus_pneumoniae_INV200_v1_concatenated.aln"),
    'pseudogenome correct'
);
unlink('snp_lanes_Streptococcus_pneumoniae_INV200_v1_concatenated.aln');

# test 52
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-p', 'none' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
$exp_out = read_file('t/data/snpfind/52.txt');
$arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# check pseudogenome
is(
    read_file('t/data/snpfind/52.fa'),
    read_file("snp_lanes_concatenated.aln"),
    'pseudogenome correct'
);
unlink('snp_lanes_concatenated.aln');

# test 53
@args = ( '--test', '-t', 'file', '-i', 't/data/snpfind/snp_lanes.txt', '-f', 'pseudogenome', '-v', '-r', 'Streptococcus_pneumoniae_INV200_v1', '-p', '-h' );
$obj = Path::Find::CommandLine::SNP->new(args => \@args, script_name => 'snpfind');
throws_ok {$obj->run} 'Path::Find::Exception::InvalidInput', 'correct error thrown';

remove_tree($tmp);
done_testing();
