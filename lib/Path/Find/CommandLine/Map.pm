package Path::Find::CommandLine::Map;

=head1 NAME

mapfind

=head1 SYNOPSIS

mapfind -t study -id "My study name"
mapfind -t lane -id 1234_5#6

=head1 DESCRIPTION

Given a lane id, a study id or a study name, it will return the paths to the mapped bam files.

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
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules"
  ;    #Change accordingly once we have a stable checkout
use lib "/software/pathogen/internal/prod/lib";
use lib "../lib";
use Getopt::Long qw(GetOptionsFromArray);

use Path::Find;
use Path::Find::Lanes;
use Path::Find::Filter;
use Path::Find::Linker;
use Path::Find::Stats::Generator;
use Path::Find::Log;

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

sub BUILD {
    my ($self) = @_;

    my (
        $type,  $id,       $symlink, $archive, $help,   $verbose,
        $stats, $filetype, $ref,     $date,    $mapper, $qc
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
        'q|qc=s'        => \$qc
    );

    $self->type($type)         if ( defined $type );
    $self->id($id)             if ( defined $id );
    $self->symlink($symlink)   if ( defined $symlink );
    $self->archive($archive)   if ( defined $archive );
    $self->help($help)         if ( defined $help );
    $self->verbose($verbose)   if ( defined $verbose );
    $self->stats($stats)       if ( defined $stats );
    $self->filetype($filetype) if ( defined $filetype );
    $self->ref($ref)           if ( defined $ref );
    $self->date($date)         if ( defined $date );
    $self->mapper($mapper)     if ( defined $mapper );
    $self->qc($qc)             if ( defined $qc );

    (
        $type && $id && $id ne '' && ( $type eq 'study'
            || $type eq 'lane'
            || $type eq 'sample'
            || $type eq 'file'
            || $type eq 'species'
            || $type eq 'database' )
    ) or die $self->usage_text;
}

sub run {
    my ($self) = @_;

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

    eval {
        Path::Find::Log->new(
            logfile => '/nfs/pathnfs05/log/pathfindlog/mapfind.log',
            args    => $self->args
        )->commandline();
    };

    die "The archive and symlink options cannot be used together\n"
      if ( defined $archive && defined $symlink );

    # set file type extension regular expressions
    my %type_extensions = ( bam => '*markdup.bam', );

    my $lane_filter;
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
            processed_flag => 4
        );
        my @lanes = @{ $find_lanes->lanes };

        unless (@lanes) {
            $dbh->disconnect();
            next;
        }

        # filter lanes
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
            verbose         => $verbose
        );
        my @matching_lanes = $lane_filter->filter;

        unless (@matching_lanes) {
            $dbh->disconnect();
            next;
        }

      # Set up to symlink/archive. Check whether default filetype should be used
        my $use_default = 0;
        $use_default = 1 if ( !defined $filetype );
        if ( $lane_filter->found && ( defined $symlink || defined $archive ) ) {
            my $name;
            if ( defined $symlink ) {
                $name = $symlink;
            }
            elsif ( defined $archive ) {
                $name = $archive;
            }
            $name = "mapfind_$id" if ( $name eq '' );

            my $linker = Path::Find::Linker->new(
                lanes            => \@matching_lanes,
                name             => $name,
                use_default_type => $use_default
            );

            $linker->sym_links if ( defined $symlink );
            $linker->archive   if ( defined $archive );
        }

        if (@matching_lanes) {
            $found = 1;
            if ($verbose) {
                foreach my $ml (@matching_lanes) {
                    my $l = $ml->{path};
                    my $r = $ml->{ref};
                    my $m = $ml->{mapper};
                    my $d = $ml->{date};
                    print "$l\t$r\t$m\t$d\n";
                }
            }
            else {
                foreach my $ml (@matching_lanes) {
                    my $l = $ml->{path};
                    print "$l\n";
                }
            }
        }

        $dbh->disconnect();

        #no need to look in the next database if relevant data has been found
        if ($found) {

            if ( defined $stats ) {
                $stats = "$id.csv" if ( $stats eq '' );
                $stats =~ s/\s+/_/g;
                Path::Find::Stats::Generator->new(
                    lane_hashes => \@matching_lanes,
                    output      => $stats,
                    vrtrack     => $pathtrack
                )->mapfind;
            }
            exit;
        }
    }

    unless ($found) {

        print "Could not find lanes or files for input data \n";

    }
}

sub usage_text {
    my ($self) = @_;
    my $script_name = $self->script_name;
    print <<USAGE;
Usage: $script_name
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
     -h|help      <print this message>

***********
Given a study, lane or a file containing a list of lanes, this script will output the path (on pathogen disk) to the mapped bam files with the specified study or lane. 
Using the option -l|symlink will create a symlink to the queried data in the given directory (this will be created if it does not already exist). 
Similarly, using the -a|archive option will create an archive of the results with the given filename. 
The -s|stats option will produce a CSV file summarising the mapping statistics for the resulting lanes.
In symlink, archive and stats cases, if no name is provided, the name will default to the given ID.

Using the option -r|reference will limit the results to a lanes mapped against a specific reference (eg 'H1N1','3D7').
The -m|mapper option will limit results to lanes mapped using the specified mapper (eg smalt, bowtie2 )
The -d|date option will limit results to lanes processed after a given date. The date format should be dd-mm-yyyy (eg 01-01-2010)
***********
# produce an archive named 1234.tar.gz with all matching lanes
$0 -t study -i 1234 -a 
# produce an archive named myarchive.tar.gz with all matching lanes
$0 -t study -i 1234 -a myarchive
# create symlinks to data created after Dec 25th 2011 in the directory symlink_dir
$0 -t study -i 1234 -l symlink_dir -d 25-12-2011
# show verbose information for lanes mapped with smalt
$0 -t study -i 1234 -m smalt -v
USAGE
    exit;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
