package Path::Find::CommandLine::Assembly;

=head1 NAME

assemblyfind

=head1 SYNOPSIS

assemblyfind -t lane -i 1234

=head1 DESCRIPTION

Given a lane id, this script returns the location on disk of the relevant fastq files

=head1 CONTACT

path-help@sanger.ac.uk

=head1 METHODS

=cut

use strict;
use warnings;
no warnings 'uninitialized';
use Moose;

use Cwd;
use Data::Dumper;

#Change accordingly once we have a stable checkout
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules";

use lib "/software/pathogen/internal/prod/lib";
use lib "../lib";

use Getopt::Long qw(GetOptionsFromArray);

use Bio::MLST::Databases;
use File::Temp;
use File::chdir;
use File::Copy qw(move);

use Path::Find;
use Path::Find::Lanes;
use Path::Find::Filter;
use Path::Find::Linker;
use Path::Find::Log;
use Path::Find::Stats::Generator;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'type'        => ( is => 'rw', isa => 'Str',      required => 0 );
has 'id'          => ( is => 'rw', isa => 'Str',      required => 0 );
has 'symlink'     => ( is => 'rw', isa => 'Str',      required => 0 );
has 'output'      => ( is => 'rw', isa => 'Str',      required => 0 );
has 'stats'       => ( is => 'rw', isa => 'Str',      required => 0 );
has 'filetype'    => ( is => 'rw', isa => 'Str',      required => 0 );
has 'archive'     => ( is => 'rw', isa => 'Str',      required => 0 );
has 'help'        => ( is => 'rw', isa => 'Str',      required => 0 );

sub BUILD {
    my ($self) = @_;

    my ( $type, $id, $symlink, $output, $stats, $filetype, $archive, $help );

    GetOptionsFromArray(
        $self->args,
        't|type=s'     => \$type,
        'i|id=s'       => \$id,
        'h|help'       => \$help,
        'f|filetype=s' => \$filetype,
        'l|symlink:s'  => \$symlink,
        'a|archive:s'  => \$archive,
        's|stats:s'    => \$stats,
    );

    $self->type($type)         if ( defined $type );
    $self->id($id)             if ( defined $id );
    $self->symlink($symlink)   if ( defined $symlink );
    $self->output($output)     if ( defined $output );
    $self->stats($stats)       if ( defined $stats );
    $self->filetype($filetype) if ( defined $filetype );
    $self->archive($archive)   if ( defined $archive );
    $self->help($help)         if ( defined $help );

    (
             $type
          && $id
          && $id ne ''
          && ( $type eq 'study'
            || $type eq 'lane'
            || $type eq 'file'
            || $type eq 'sample'
            || $type eq 'species'
            || $type eq 'database' )
          && (
            !$filetype
            || (
                $filetype
                && (   $filetype eq 'contigs'
                    || $filetype eq 'scaffold' )
            )
          )
          && ( !defined($archive)
            || $archive eq ''
            || ( $archive && !( $stats || $symlink || $output ) ) )
    ) or die $self->usage_text;
}

sub run {
    my ($self) = @_;
    my ( $qc, $found, $destination, $tmpdirectory_name, $archive_name,
        $all_stats, $archive_path, $archive_suffix );

    # assign variables
    my $type     = $self->type;
    my $id       = $self->id;
    my $symlink  = $self->symlink;
    my $output   = $self->output;
    my $stats    = $self->stats;
    my $filetype = $self->filetype;
    my $archive  = $self->archive;

    eval {
        Path::Find::Log->new(
            logfile => '/nfs/pathnfs05/log/pathfindlog/assemblyfind.log',
            args    => $self->args
        )->commandline();
    };

    # Get databases
    my @pathogen_databases = Path::Find->pathogen_databases;

    # Set assembly subdirectories
    my @sub_directories;
    if ($filetype) {
        @sub_directories = (
            '/velvet_assembly', '/velvet_assembly_with_reference',
            '/spades_assembly'
        );
    }
    else {
        $filetype        = 'scaffold';
        @sub_directories = (
            '/velvet_assembly', '/velvet_assembly_with_reference',
            '/spades_assembly'
        );
    }

    # set file type extension wildcard
    my %type_extensions = (
        contigs  => 'unscaffolded_contigs.fa',
        scaffold => 'contigs.fa',
    );

    my $lane_filter;

    for my $database (@pathogen_databases) {

        # Connect to database and get info
        my ( $pathtrack, $dbh, $root ) = Path::Find->get_db_info($database);

        my $find_lanes = Path::Find::Lanes->new(
            search_type    => $type,
            search_id      => $id,
            pathtrack      => $pathtrack,
            dbh            => $dbh,
            processed_flag => 1024
        );
        my @lanes = @{ $find_lanes->lanes };

        unless (@lanes) {
            $dbh->disconnect();
            next;
        }

        # check directories exist, find & filter by file type
        if ( ( defined $symlink || defined $archive ) && !defined $filetype ) {
            $filetype = "contigs";
        }
        my @req_stats;
        @req_stats = ( 'contigs.fa.stats', 'contigs.mapped.sorted.bam.bc' )
          if ( defined $stats );
        $lane_filter = Path::Find::Filter->new(
            lanes           => \@lanes,
            filetype        => $filetype,
            type_extensions => \%type_extensions,
            root            => $root,
            pathtrack       => $pathtrack,
            subdirectories  => \@sub_directories,
            stats           => \@req_stats
        );
        my @matching_lanes = $lane_filter->filter;

      # symlink or archive
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
            $name = "assemblyfind_$id" if ( $name eq '' );

            my %link_names = link_rename_hash( \@matching_lanes );

            my $linker = Path::Find::Linker->new(
                lanes            => \@matching_lanes,
                name             => $name,
                use_default_type => $use_default,
                rename_links     => \%link_names
            );

            $linker->sym_links if ( defined $symlink );
            $linker->archive   if ( defined $archive );
        }

        # print out the paths
        foreach my $ml (@matching_lanes) {
            my $l = $ml->{path};
            print "$l\n";
        }

        $dbh->disconnect();

        #no need to look in the next database if relevant data has been found
        if ( $lane_filter->found ) {
            if ( defined $stats ) {
                $stats = "$id.assembly_stats.csv" if ( $stats eq '' );
                $stats =~ s/\s+/_/g;
                Path::Find::Stats::Generator->new(
                    lane_hashes => \@matching_lanes,
                    output      => $stats,
                    vrtrack     => $pathtrack
                )->assemblyfind;

            }
            exit;
        }
    }

    unless ( $lane_filter->found ) {

        print "Could not find lanes or files for input data\n";

    }
}

sub link_rename_hash {
    my ($mlanes) = @_;
    my @matching_lanes = @{$mlanes};

    my %suffixes = (
        'velvet_assembly'                => '_velvet.fa',
        'velvet_assembly_with_reference' => '_columbus.fa',
        'spades_assembly'                => '_spades.fa',
        'scaffolding_results'            => '_scaffolded.fa'
    );

    my %link_names;
    foreach my $mf (@matching_lanes) {
        my $lane      = $mf->{path};
        my @dirs      = split( "/", $lane );
        my $filename  = pop @dirs;
        my $subdir    = pop @dirs;
        my $lane_name = pop @dirs;
        my $suffix    = $suffixes{$subdir};

        $filename =~ s/\.fa/$suffix/;
        my $sf = $link_names{$lane} = "$lane_name.$filename";
    }

    return %link_names;
}

# Sort routine for multiplexed lane names (eg 1234_5#6)
# Run, Lane and Tag are sorted in ascending order.
# Reverts to alphabetic sort if cannot sort numerically
sub lanesort {
    my @a = split( /\_|\#/, $a->name() );
    my @b = split( /\_|\#/, $b->name() );

    for my $i ( 0 .. 2 ) {
        return ( $a->name cmp $b->name )
          if ( $a[$i] =~ /\D+/ || $b[$i] =~ /\D+/ );
    }

    $a[0] <=> $b[0] || $a[1] <=> $b[1] || $a[2] <=> $b[2];
}

sub usage_text {
    my ($self) = @_;
    my $script_name = $self->script_name;
    print <<USAGE;
Usage: $script_name
     -t|type            <study|lane|file|sample|species>
     -id                <study id|study name|lane name|file of lane names>
     -qc                <passed|failed|pending>
     -symlink           <create a symlink to the data>
     -o|output          <output dir for sym links>
     -s|stats           <create a CSV file containing assembly stats>
     -a|archive         <name of archive>
     -stage             <auto|all|user|velvet|columbus|scaffold>
     -h|help            <print this message>

Given a study, lane or a file containing a list of lanes, this script will output the path (on pathogen disk) to the data associated with the specified study or lane. 
Using the option -symlink will create a symlink to the queried data in the current directory, alternativley an output directory can be specified in which the symlinks will be created.
Using the option -archive will create an archive (.tar.gz) containing the selected assemblies and a CSV file. The -archive option will automatically name the archive file if a name is not supplied.
Assemblies created by the assemble_lanes script can be found using the -stage option: 'all' will find all assemblies on disk, 'user' will find assemblies created by assemble_lanes and 'velvet','columbus' or 'scaffold' will find the assembly from the given stage of the assemble_lanes pipeline
The default value for -stage is 'auto' which will find assemblies produced by the automated pipeline.

# create symlinks to all the final assemblies in the given study
assemblyfind -t study -id "My study" -symlink

# find an assembly for a given lane
assemblyfind -t lane -id 1234_5#6 

# create a CSV file of assembly statistics for all assemblies in the given study
assemblyfind -t study -id 123 -s

# create a compressed archive containing all assemblies for a study and a CSV file of assembly statistics
assemblyfind -t study -id 123 -archive 
assemblyfind -t study -id 123 -archive study_123_assemblies.tgz

# find all assemblies
assemblyfind -t lane -id 1234_5#6 -stage all

USAGE
    exit;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

