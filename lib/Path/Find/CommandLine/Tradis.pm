package Path::Find::CommandLine::Tradis;

#ABSTRACT: Given a lane id, a study id or a study name, it will return the paths to the tradis data

=head1 NAME

Path::Find::CommandLine::Tradis

=head1 SYNOPSIS

	use Path::Find::CommandLine::Tradis;
	my $pipeline = Path::Find::CommandLine::Tradis->new(
		script_name => 'tradisfind',
		args        => \@ARGV
	)->run;

where \@ARGV contains the following parameters:
-t|type      <study|lane|file|sample|species>
-i|id        <study id|study name|lane name>
-l|symlink   <create a symlink to the data>
-a|arvhive   <archive the data>
-f|filetype  <coverage|intergenic|bam|spreadsheet>
-s|stats     <output stats to file>
-v|verbose   <extended details>
-r|reference <select only results mapped to given reference>
-d|date      <select only results produced after given date>
-m|mapper    <select only results produced by given mapper>
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
use lib "/software/pathogen/internal/prod/lib";
use lib "../lib";

use Getopt::Long qw(GetOptionsFromArray);
use File::Basename;

use Path::Find;
use Path::Find::Lanes;
use Path::Find::Filter;
use Path::Find::Linker;
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

sub BUILD {
    my ($self) = @_;

    my (
        $type,  $id,       $symlink, $archive, $help, $verbose,
        $stats, $filetype, $ref,     $date,    $mapper
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
          && (
            !$filetype
            || (
                $filetype
                && (   $filetype eq 'bam'
                    || $filetype eq 'spreadsheet'
                    || $filetype eq 'intergenic'
                    || $filetype eq 'coverage' )
            )
          )
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

    eval {
        Path::Find::Log->new(
            logfile => '/nfs/pathnfs05/log/pathfindlog/tradisfind.log',
            args    => $self->args
        )->commandline();
    };

    die "The archive and symlink options cannot be used together\n"
      if ( defined $archive && defined $symlink );

    # set file type extension regular expressions
    my %type_extensions = (
        coverage    => '*insert_site_plot.gz',
        intergenic  => '*tab.gz',
        bam         => '*corrected.bam',
        spreadsheet => '*insertion.csv',
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
            processed_flag => 512
        );
        my @lanes = @{ $find_lanes->lanes };

        unless (@lanes) {
            $dbh->disconnect();
            next;
        }

        # filter lanes
        $filetype = "bam" if ( $verbose || $date || $ref || $mapper );
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
            $name = "tradisfind_$id" if ( $name eq '' );
			
			my $script_name = $self->script_name;

            my $linker = Path::Find::Linker->new(
                lanes            => \@matching_lanes,
                name             => $name,
                use_default_type => $use_default,
				script_name      => $script_name
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
        return 1 if ($found);
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
  -i|id        <study id|study name|lane name>
  -l|symlink   <create a symlink to the data>
  -a|arvhive   <archive the data>
  -f|filetype  <coverage|intergenic|bam|spreadsheet>
  -s|stats     <output stats to file>
  -v|verbose   <extended details>
  -r|reference <select only results mapped to given reference>
  -d|date      <select only results produced after given date>
  -m|mapper    <select only results produced by given mapper>
  -h|help      <print this message>

Given a study or lane this will give you the location of the Tradis results. By default it provides the directory, but by specifiying a 'file_type' 
you can narrow it down to particular 
files within the result set. For a single Tradis experiment you will have:

a BAM file with reads corrected according to the protocol,
a spreadsheet with statistics about insertions on each gene,
insertion site plots for each sequence which can be opened in Artemis,
tab files for each sequence with intergenic regions marked up, which can be opened in Artemis.

USAGE
    exit;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
