package Path::Find::CommandLine::RNASeq;

# ABSTRACT: Given a lane id, a study id or a study name, it will return the paths to the rna seq data

=head1 NAME

Path::Find::CommandLine::RNASeq

=head1 SYNOPSIS

	use Path::Find::CommandLine::RNASeq;
	my $pipeline = Path::Find::CommandLine::RNASeq->new(
		script_name => 'rnaseqfind',
		args        => \@ARGV
	)->run;

where \@ARGV uses the following parameters:
-t|type      <study|lane|file|sample|species>
 -i|id        <study id|study name|lane name|file of lane names>
 -f|filetype  <bam>
 -q|qc        <pass|failed|pending>
 -l|symlink   <create a symlink to the data>
 -a|arvhive   <archive the data>
 -v|verbose   <display reference, mapper and date>
 -s|stats     <output file for summary of mapping results in CSV format>
 -r|reference <filter results based on reference>
 -m|mapper    <filter results based on mapper>
 -d|date      <show only results produced after a given date>
 -h|help      <print help message>

=head1 CONTACT

path-help@sanger.ac.uk

=head1 METHODS

=cut

use strict;
use warnings;
no warnings 'uninitialized';
use Moose;

use Cwd;
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules"
  ;    #Change accordingly once we have a stable checkout
#use lib "/software/pathogen/internal/prod/lib";
use lib "../lib";
use Getopt::Long qw(GetOptionsFromArray);

use Data::Dumper;

use Path::Find;
use Path::Find::Lanes;
use Path::Find::Filter;
use Path::Find::Linker;
use Path::Find::Stats::Generator;
use Path::Find::Log;
use Path::Find::Sort;
use Path::Find::Exception;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'type'        => ( is => 'rw', isa => 'Str',      required => 0 );
has 'id'          => ( is => 'rw', isa => 'Str',      required => 0 );
has 'symlink'     => ( is => 'rw', isa => 'Str',      required => 0 );
has 'archive'     => ( is => 'rw', isa => 'Str',      required => 0 );
has 'help'        => ( is => 'rw', isa => 'Str',      required => 0 );
has 'verbose'     => ( is => 'rw', isa => 'Str',      required => 0 );
has 'stats'       => ( is => 'rw', isa => 'Str',      required => 0 );
has 'filetype'    => ( is => 'rw', isa => 'Str',      required => 0 );
has 'ref'         => ( is => 'rw', isa => 'Str',      required => 0 );
has 'date'        => ( is => 'rw', isa => 'Str',      required => 0 );
has 'mapper'      => ( is => 'rw', isa => 'Str',      required => 0 );
has 'qc'          => ( is => 'rw', isa => 'Str',      required => 0 );
has '_environment' => ( is => 'rw', isa => 'Str',      required => 0, default => 'prod' );

sub BUILD {
    my ($self) = @_;

    my (
        $type,  $id,       $symlink, $archive, $help,   $verbose,
        $stats, $filetype, $ref,     $date,    $mapper, $qc, $test
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
        'q|qc=s'        => \$qc,
        'test'          => \$test
    );

    $self->type($type)          if ( defined $type );
    $self->id($id)              if ( defined $id );
    $self->symlink($symlink)    if ( defined $symlink );
    $self->archive($archive)    if ( defined $archive );
    $self->help($help)          if ( defined $help );
    $self->verbose($verbose)    if ( defined $verbose );
    $self->stats($stats)        if ( defined $stats );
    $self->filetype($filetype)  if ( defined $filetype );
    $self->ref($ref)            if ( defined $ref );
    $self->date($date)          if ( defined $date );
    $self->mapper($mapper)      if ( defined $mapper );
    $self->qc($qc)              if ( defined $qc );
    $self->_environment('test') if ( defined $test );
}

sub check_inputs{
    my $self = shift;
    return(
        $self->type 
        && $self->id 
        && $self->id ne '' 
        && !$self->help
        && ( $self->type eq 'study'
            || $self->type eq 'lane'
            || $self->type eq 'sample'
            || $self->type eq 'file'
            || $self->type eq 'species'
            || $self->type eq 'database' )
    );
}

sub run {
    my ($self) = @_;
    $self->check_inputs or Path::Find::Exception::InvalidInput->throw( error => $self->usage_text);

    # assign variables
    my $type     = $self->type;
    my $id       = $self->id;
    my $symlink  = $self->symlink;
    my $archive  = $self->archive;
    my $verbose  = $self->verbose;
    my $stats    = $self->stats;
    my $filetype = $self->filetype;
    my $ref      = $self->ref;
    my $date     = $self->date;
    my $mapper   = $self->mapper;
    my $qc       = $self->qc;

    Path::Find::Exception::FileDoesNotExist->throw( error => "File $id does not exist.\n") if( $type eq 'file' && !-e $id );

    my $logfile = $self->_environment eq 'test' ? '/nfs/pathnfs05/log/pathfindlog/test/rnaseqfind.log' : '/nfs/pathnfs05/log/pathfindlog/rnaseqfind.log';
    eval {
        Path::Find::Log->new(
            logfile => $logfile,
            args    => $self->args
        )->commandline();
    };

    Path::Find::Exception::InvalidInput->throw( error => "The archive and symlink options cannot be used together\n")
      if ( defined $archive && defined $symlink );

    my %type_extensions = (
        coverage    => '*coverageplot.gz',
        intergenic  => '*tab.gz',
        bam         => '*corrected.bam',
        spreadsheet => '*expression.csv',
    );

    my $lane_filter;
    my $found = 0;

    # Get databases and loop through them
    my $find = Path::Find->new( environment => $self->_environment );
    my @pathogen_databases = $find->pathogen_databases;
    for my $database (@pathogen_databases) {

        # Connect to database and get info
        my ( $pathtrack, $dbh, $root ) = $find->get_db_info($database);

        my $find_lanes = Path::Find::Lanes->new(
            search_type    => $type,
            search_id      => $id,
            pathtrack      => $pathtrack,
            dbh            => $dbh,
            processed_flag => 512
        );
        my @lanes = @{ $find_lanes->lanes };

        unless (@lanes) {
            $dbh->disconnect();
            next;
        }

        my @req_stats;
        @req_stats = ('*corrected.bam') if ( defined $stats );

        # filter lanes
        my $verbose_info = 0;
        if ( $verbose || $date || $ref || $mapper ){
            $filetype = "bam" unless(defined $filetype);
            $verbose_info = 1;
        }
        $lane_filter = Path::Find::Filter->new(
            lanes           => \@lanes,
            filetype        => $filetype,
            root            => $root,
            pathtrack       => $pathtrack,
            type_extensions => \%type_extensions,
            qc              => $qc,
            reference       => $ref,
            mapper          => $mapper,
            date            => $date,
            verbose         => $verbose_info,
            stats           => \@req_stats
        );
        my @matching_lanes = $lane_filter->filter;

        unless (@matching_lanes) {
            $dbh->disconnect();
            next;
        }

        my $sorted_ml = Path::Find::Sort->new(lanes => \@matching_lanes)->sort_lanes;
        @matching_lanes = @{ $sorted_ml };

      # Set up to symlink/archive. Check whether default filetype should be used
        my $use_default = 0;
        $use_default = 1 if ( !defined $filetype );
        if ( $lane_filter->found && ( defined $symlink || defined $archive ) ) {
            my $name = $self->set_linker_name;

            my $linker = Path::Find::Linker->new(
                lanes            => \@matching_lanes,
                name             => $name,
                use_default_type => $use_default,
				script_name      => $self->script_name
            );

            $linker->sym_links if ( defined $symlink );
            $linker->archive   if ( defined $archive );
        }

        if (@matching_lanes) {
            $found = 1;
            if ($verbose) {
                foreach my $ml ( @matching_lanes )
                {
                    my $l = $ml->{path};
                    my $r = $ml->{ref};
                    my $m = $ml->{mapper};
                    my $d = $ml->{date};
                    print "$l\t$r\t$m\t$d\n";
                }
            }
            else {
                foreach my $ml ( @matching_lanes )
                {
                    my $l = $ml->{path};
                    print "$l\n";
                }
            }
        }

        $dbh->disconnect();

        if ($found) {
            if ( defined $stats ) {

                # add required mapstats ID to lane hash
                foreach my $li ( 0 .. $#matching_lanes ) {
                    my ($s) = @{ $matching_lanes[$li]->{stats} };
                    $s =~ /\/(\d+)[^\/]+corrected.bam$/;
                    $matching_lanes[$li]->{mapstat_id} = $1;
                }

                $stats = "$id.csv" if ( $stats eq '' );
                $stats =~ s/\s+/_/g;
                Path::Find::Stats::Generator->new(
                    lane_hashes => \@matching_lanes,
                    output      => $stats,
                    vrtrack     => $pathtrack
                )->rnaseqfind;
            }
            return 1;
        }
    }

    unless ($found) {
        Path::Find::Exception::NoMatches->throw( error => "Could not find lanes or files for input data \n");
    }
}

sub set_linker_name {
    my  ($self) = @_;
    my $archive = $self->archive;
    my $symlink = $self->symlink;
    my $id = $self->id;
    my $script_path = $self->script_name;
    $script_path =~ /([^\/]+$)/;
    my $script_name = $1;

    my $name;
    if ( defined $symlink ) {
        $name = $symlink;
    }
    elsif ( defined $archive ) {
        $name = $archive;
    }

    if( $name eq '' ){
        $id =~ /([^\/]+$)/;
        $name = $script_name . "_" . $1;
    }
    my $cwd = getcwd;
    if($name =~ /^\//){
        return $name;
    }
    else{
        return "$cwd/$name";
    }
}

sub usage_text {
    my ($self) = @_;
    my $script_name = $self->script_name;
    return <<USAGE;
Usage: $script_name
     -t|type      <study|lane|file|sample|species>
     -i|id        <study id|study name|lane name|file of lane names>
     -f|filetype  <bam|coverage|intergenic|spreadsheet>
     -q|qc        <pass|failed|pending>
     -l|symlink   <create a symlink to the data>
     -a|arvhive   <archive the data>
     -v|verbose   <display reference, mapper and date>
     -s|stats     <output file for summary of mapping results in CSV format>
     -r|reference <filter results based on reference>
     -m|mapper    <filter results based on mapper>
     -d|date      <show only results produced after a given date>
     -h|help      <print this message>

***********
Given a study or lane this will give you the location of the RNA Seq results. By default it provides the directory, but by specifiying a 'file_type' you can narrow it down to particular 
files within the result set. For a single RNA seq experiment you will have:

- a BAM file with reads corrected according to the protocol
- a spreadsheet with RPKM and read counts for each CDS/polypeptide
- coverage plots for each sequence which can be opened in Artemis
- tab files for each sequence with intergenic regions marked up, which can be opened in Artemis.

Using the option -l|symlink will create a symlink to the queried data in the given directory (this will be created if it does not already exist). 
Similarly, using the -a|archive option will create an archive of the results with the given filename. 
The -s|stats option will produce a CSV file summarising the mapping statistics for the resulting lanes.
In symlink, archive and stats cases, if no name is provided, a default based on the given ID will be used.

Using the option -r|reference will limit the results to a lanes mapped against a specific reference (eg 'H1N1','3D7').
The -m|mapper option will limit results to lanes mapped using the specified mapper (eg smalt, bowtie2 )
The -d|date option will limit results to lanes processed after a given date. The date format should be dd-mm-yyyy (eg 01-01-2010)

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
