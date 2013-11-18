package Path::Find::CommandLine::SNP;

#ABSTRACT: Given a lane id, a study id or a study name, it will return the paths to the SNP data

=head1 NAME

Path::Find::CommandLine::SNP

=head1 SYNOPSIS

	use Path::Find::CommandLine::SNP;
	my $pipeline = Path::Find::CommandLine::SNP->new(
		script_name => 'snpfind',
		args        => \@ARGV
	)->run;

where \@ARGV contains the following parameters:
-t|type      <study|lane|file|sample|species>
 -i|id        <study id|study name|lane name|file of lane names>
 -f|filetype  <vcf|pseudogenome>
 -q|qc        <pass|failed|pending>
 -l|symlink   <create a symlink to the data>
 -a|arvhive   <archive the data>
 -v|verbose   <display reference, mapper and date>
 -s|stats     <output file for summary of mapping results in CSV format>
 -r|reference <filter results based on reference>
 -m|mapper    <filter results based on mapper>
 -d|date      <show only results produced after a given date>
 -p|pseudo    <generate a pseudogenome based on the given reference>
 -h|help      <print help message>

=head1 CONTACT

path-help@sanger.ac.uk

=head1 METHODS

=cut

use strict;
use warnings;
no warnings 'uninitialized';
use Moose;

use Data::Dumper;
use Cwd;
use File::chdir;
use File::Temp;
use File::Copy qw(move);
use Getopt::Long qw(GetOptionsFromArray);
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules";    #Change accordingly once we have a stable checkout
use lib "/software/pathogen/internal/prod/lib";
use lib "../lib";

use Path::Find;
use Path::Find::Lanes;
use Path::Find::Filter;
use Path::Find::Linker;
use Path::Find::Stats::Generator;
use Path::Find::Log;

has 'args'         => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'  => ( is => 'ro', isa => 'Str',      required => 1 );
has 'type'         => ( is => 'rw', isa => 'Str',      required => 0 );
has 'id'           => ( is => 'rw', isa => 'Str',      required => 0 );
has 'symlink'      => ( is => 'rw', isa => 'Str',      required => 0 );
has 'archive'      => ( is => 'rw', isa => 'Str',      required => 0 );
has 'help'         => ( is => 'rw', isa => 'Str',      required => 0 );
has 'verbose'      => ( is => 'rw', isa => 'Str',      required => 0 );
has 'stats'        => ( is => 'rw', isa => 'Str',      required => 0 );
has 'filetype'     => ( is => 'rw', isa => 'Str',      required => 0 );
has 'ref'          => ( is => 'rw', isa => 'Str',      required => 0 );
has 'date'         => ( is => 'rw', isa => 'Str',      required => 0 );
has 'mapper'       => ( is => 'rw', isa => 'Str',      required => 0 );
has 'pseudogenome' => ( is => 'rw', isa => 'Str',      required => 0 );
has 'qc'           => ( is => 'rw', isa => 'Str',      required => 0 );

sub BUILD {
    my ($self) = @_;

    my (
        $type,    $id,           $symlink,  $archive, $help,
        $verbose, $stats,        $filetype, $ref,     $date,
        $mapper,  $pseudogenome, $qc
    );

    my @args = @{ $self->args };
    GetOptionsFromArray(
        \@args,
        't|type=s'      => \$type,
        'i|id=s'        => \$id,
        'h|help'        => \$help,
        'f|filetype=s'  => \$filetype,
        'l|symlink:s'   => \$symlink,
        'a|archive:s'   => \$archive,
        's|stats:s'     => \$stats,
        'v|verbose'     => \$verbose,
        'r|reference=s' => \$ref,
        'd|date=s'      => \$date,
        'm|mapper=s'    => \$mapper,
        'p|pseudo=s'    => \$pseudogenome,
        'q|qc=s'        => \$qc
    );

    $self->type($type)                 if ( defined $type );
    $self->id($id)                     if ( defined $id );
    $self->symlink($symlink)           if ( defined $symlink );
    $self->archive($archive)           if ( defined $archive );
    $self->help($help)                 if ( defined $help );
    $self->verbose($verbose)           if ( defined $verbose );
    $self->stats($stats)               if ( defined $stats );
    $self->filetype($filetype)         if ( defined $filetype );
    $self->ref($ref)                   if ( defined $ref );
    $self->date($date)                 if ( defined $date );
    $self->mapper($mapper)             if ( defined $mapper );
    $self->pseudogenome($pseudogenome) if ( defined $pseudogenome );
    $self->qc($qc)                     if ( defined $qc );

    (
             $type
          && $id
          && $id ne ''
          && ( $type eq 'study'
            || $type eq 'lane'
            || $type eq 'sample'
            || $type eq 'file'
            || $type eq 'species'
            || $type eq 'database' )
          && ( !$filetype || $filetype eq 'vcf' || $filetype eq 'pseudogenome' )
    ) or die $self->usage_text;
}

sub run {
    my ($self) = @_;

    # assign variables
    my $type         = $self->type;
    my $id           = $self->id;
    my $symlink      = $self->symlink;
    my $archive      = $self->archive;
    my $verbose      = $self->verbose;
    my $stats        = $self->stats;
    my $filetype     = $self->filetype;
    my $ref          = $self->ref;
    my $date         = $self->date;
    my $mapper       = $self->mapper;
    my $pseudogenome = $self->pseudogenome;
    my $qc           = $self->qc;

    eval {
        Path::Find::Log->new(
            logfile => '/nfs/pathnfs05/log/pathfindlog/snpfind.log',
            args    => $self->args
        )->commandline();
    };

    die "The archive and symlink options cannot be used together\n"
      if ( defined $archive && defined $symlink );

    #die "Please specify a reference to base the pseudogenome on\n"
    #  if ( defined $pseudogenome && !defined $ref );

    # set file type extension regular expressions
    my %type_extensions = (
        vcf          => '*.snp/mpileup.unfilt.vcf.gz',
        pseudogenome => '*.snp/pseudo_genome.fasta'
    );

    my ( $lane_filter, $vb );
    my $found = 0;

    # Get databases and loop through them
    my @pathogen_databases = Path::Find->pathogen_databases;
    for my $database (@pathogen_databases) {

        # Connect to database and get info
        my ( $pathtrack, $dbh, $root ) = Path::Find->get_db_info($database);

        my $find_lanes = Path::Find::Lanes->new(
            search_type    => $type,
            search_id      => $id,
            pathtrack      => $pathtrack,
            dbh            => $dbh,
            processed_flag => 256
        );
        my @lanes = @{ $find_lanes->lanes };

        unless (@lanes) {
            $dbh->disconnect();
            next;
        }

        # filter lanes
        if ( defined $pseudogenome ) {
            $filetype = "pseudogenome";
        }
        elsif ( ( defined $symlink || defined $archive ) && !defined $filetype )
        {
            $filetype = "vcf";
        }
        $lane_filter = Path::Find::Filter->new(
            lanes           => \@lanes,
            filetype        => $filetype,
            root            => $root,
            pathtrack       => $pathtrack,
            type_extensions => \%type_extensions,
            reference       => $ref,
            mapper          => $mapper,
            date            => $date,
            verbose         => $verbose
        );
        my @matching_lanes = $lane_filter->filter;

        # Set up to symlink/archive. Check whether default filetype should be used
        if ( @matching_lanes && ( defined $symlink || defined $archive ) ) {
            my $name;
            if ( defined $symlink ) {
                $name = $symlink;
            }
            elsif ( defined $archive ) {
                $name = $archive;
            }
            $name = "snpfind_$id" if ( $name eq '' );

            my %link_names = $self->link_rename_hash( \@matching_lanes );

            my $linker = Path::Find::Linker->new(
                lanes            => \@matching_lanes,
                name             => $name,
                use_default_type => 0,
				script_name      => $self->script_name,
                rename_links     => \%link_names
            );

            $linker->sym_links if ( defined $symlink );
            $linker->archive   if ( defined $archive );
        }

        $self->create_pseudogenome( \@matching_lanes )
          if ( defined $pseudogenome && @matching_lanes );

        if (@matching_lanes) {
            $found = 1;
            if ($verbose) {
                foreach
                  my $ml ( sort { $a->{path} cmp $b->{path} } @matching_lanes )
                {
                    my $l = $ml->{path};
                    my $r = $ml->{ref};
                    my $m = $ml->{mapper};
                    my $d = $ml->{date};
                    print "$l\t$r\t$m\t$d\n";
                }
            }
            else {
                foreach
                  my $ml ( sort { $a->{path} cmp $b->{path} } @matching_lanes )
                {
                    my $l = $ml->{path};
                    print "$l\n";
                }
            }
        }

        $dbh->disconnect();

        #no need to look in the next database if relevant data has been found
        return 1 if ($found);
		
    }

    unless ($found) {

        print "Could not find lanes or files for input data \n";

    }
}

sub create_pseudogenome {
    my ($self, $mlanes)       = @_;
    my @matching_lanes = @{$mlanes};
    my $ref            = $self->pseudogenome;

    my $pg_filename = $self->pseudogenome_filename();

    # first add reference as one sequence
    unless ( $ref eq 'none' ) {
        my $ref_path = $self->find_reference($ref);
        system("echo \">$ref\" >> $pg_filename");
        system("grep -v \">\" $ref_path >> $pg_filename");
    }

    # next, add all found sequences
    foreach my $ml (@matching_lanes) {
        my $ml_path = $ml->{path};
        system("cat $ml_path >> $pg_filename");
    }
    return 1;
}

sub pseudogenome_filename {
    my ($self) = @_;
    my $pseudo_genome_filename = "concatenated";
    my $ref                    = $self->pseudogenome;
    my $id                     = $self->id;

    unless ( $ref eq 'none' ) {
        $pseudo_genome_filename = $ref . "_" . $pseudo_genome_filename;
    }

    $pseudo_genome_filename = $id . "_" . $pseudo_genome_filename;
    $pseudo_genome_filename =~ s![\W]!_!gi;
    $pseudo_genome_filename .= '.aln';
    `touch $pseudo_genome_filename`;
    return $pseudo_genome_filename;
}

sub link_rename_hash {
    my ($self, $mlanes) = @_;
    my @matching_lanes = @{ $mlanes };

    my %link_names;
    foreach my $mf (@matching_lanes) {
        my $lane = $mf->{path};
        $lane =~ /(\d+)[^\/]+\/([^\/]+)$/;
        $link_names{$lane} = "$1.$2";
    }
    return %link_names;
}

sub find_reference {
	my ($self) = @_;
    my $passed_in_reference = shift;
    return undef unless ( defined($passed_in_reference) );
    my $index_file = '/lustre/scratch108/pathogen/pathpipe/refs/refs.index';

    open( my $fh, $index_file ) or die 'Couldnt open index file';
    while (<$fh>) {
        chomp;
        my $line         = $_;
        my $search_query = $passed_in_reference . '.fa$';
        if ( $line =~ m/$search_query/i ) {
            my @ref_details = split( /\t/, $line );
            if ( -e $ref_details[1] ) {
                return $ref_details[1];
            }
        }
    }
    return undef;
}

sub usage_text {
    my ($self) = @_;
    my $script_name = $self->script_name;
    print <<USAGE;
Usage: $script_name
     -t|type      <study|lane|file|sample|species>
     -i|id        <study id|study name|lane name|file of lane names>
     -f|filetype  <vcf|pseudogenome>
     -q|qc        <pass|failed|pending>
     -l|symlink   <create a symlink to the data>
     -a|arvhive   <archive the data>
     -v|verbose   <display reference, mapper and date>
     -s|stats     <output file for summary of mapping results in CSV format>
     -r|reference <filter results based on reference>
     -m|mapper    <filter results based on mapper>
     -d|date      <show only results produced after a given date>
     -p|pseudo    <generate a pseudogenome based on this reference. Pass 'none' to exclude reference from pseudogenome>
     -h|help      <print this message>

Given a study, lane or a file containing a list of lanes, this script will output the path (on pathogen disk) to the VCF files with the specified study or lane. Using the option -qc (passed|failed|pending) will limit the 
results to data of the specified qc status. Using the option -symlink will create a symlink to the queried data in the current 
directory, alternativley an output directory can be specified in which the symlinks will be created.
Using the option -archive will create an archive (.tar.gz) containing the VCF and index files.

The -p option will generate a pseudogenome based on the reference passed via this option. If you wish to omit the reference from the multifasta file, pass 'none' as the reference. Examples:
# generate a pseudogenome, but exclude the reference
snpfind -t file -i my_lanes.txt -p none
# generate a pseudogenome based on Salmonella enterica Typhi Ty2
snpfind -t file -i my_lanes.txt -p Salmonella_enterica_subsp_enterica_serovar_Typhi_Ty2_v1

USAGE
    exit;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
