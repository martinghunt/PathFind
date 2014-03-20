package Path::Find::CommandLine::Annotation;

# ABSTRACT: Given a lane id, a study id or a study name, it will print the paths to the annotation data

=head1 NAME

Path::Find::CommandLine::Annotation

=head1 SYNOPSIS

	use Path::Find::CommandLine::Annotation;
	my $pipeline = Path::Find::CommandLine::Annotation->new(
		script_name => 'annotationfind',
		args        => \@ARGV
	)->run;
	
where \@ARGV follows the following parameters:
-t|type            <study|lane|file|sample|species>
-i|id              <study id|study name|lane name|file of lane names>
-l|symlink         <create a symlink to the data>
-f|filetype        <gff|faa|ffn>
-g|gene            <name of gene>
-p|search_products <when searching for genes also search products>
-o|output          <name of output fasta file of genes>
-n|nucleotides     <output nucleotide sequence instead of amino acids in fasta file>
-a|archive		   <name of archive>
-h|help            <print help message>


=head1 METHODS

=head1 CONTACT

path-help@sanger.ac.uk

=cut

use strict;
use warnings;
no warnings 'uninitialized';
use Moose;

#use Cwd;
use Cwd qw(abs_path getcwd);

use lib "/software/pathogen/internal/pathdev/vr-codebase/modules"
  ;    #Change accordingly once we have a stable checkout
#use lib "/software/pathogen/internal/prod/lib";
use lib "../lib";

#use File::Temp;
#use File::Copy qw(move);
use Getopt::Long qw(GetOptionsFromArray);
use Bio::AutomatedAnnotation::ParseGenesFromGFFs;

use Data::Dumper;

use Path::Find;
use Path::Find::Lanes;
use Path::Find::Filter;
use Path::Find::Linker;
use Path::Find::Stats::Generator;
use Path::Find::Log;
use Path::Find::Sort;
use Path::Find::Exception;

has 'args'            => ( is => 'ro', isa => 'ArrayRef',        required => 1 );
has 'script_name'     => ( is => 'ro', isa => 'Str',             required => 1 );
has 'type'            => ( is => 'rw', isa => 'Str',             required => 0 );
has 'id'              => ( is => 'rw', isa => 'Str',             required => 0 );
has 'symlink'         => ( is => 'rw', isa => 'Str',             required => 0 );
has 'help'            => ( is => 'rw', isa => 'Str',             required => 0 );
has 'filetype'        => ( is => 'rw', isa => 'Str',             required => 0 );
has 'output'          => ( is => 'rw', isa => 'Maybe[Str]',      required => 0 );
has 'gene'            => ( is => 'rw', isa => 'Str',             required => 0 );
has 'search_products' => ( is => 'rw', isa => 'Str',             required => 0 );
has 'nucleotides'     => ( is => 'rw', isa => 'Str',             required => 0 );
has 'archive'         => ( is => 'rw', isa => 'Str',             required => 0 );
has 'stats'           => ( is => 'rw', isa => 'Str',             required => 0 );
has '_environment' => ( is => 'rw', isa => 'Str',      required => 0, default => 'prod' );

sub BUILD {
    my ($self) = @_;

    my (
        $type,        $id,      $symlink, $help,
        $filetype,    $output,  $gene,    $search_products,
        $nucleotides, $archive, $stats, $test
    );

    my @args = @{ $self->args };
    GetOptionsFromArray(
        \@args,
        't|type=s'          => \$type,
        'i|id=s'            => \$id,
        'h|help'            => \$help,
        'f|filetype=s'      => \$filetype,
        'l|symlink:s'       => \$symlink,
        'a|archive:s'       => \$archive,
        'g|gene=s'          => \$gene,
        'p|search_products' => \$search_products,
        'n|nucleotides'     => \$nucleotides,
        'o|output=s'        => \$output,
        's|stats:s'         => \$stats,
        'test'              => \$test,
    );

    $self->type($type)                       if ( defined $type );
    $self->id($id)                           if ( defined $id );
    $self->symlink($symlink)                 if ( defined $symlink );
    $self->help($help)                       if ( defined $help );
    $self->filetype($filetype)               if ( defined $filetype );
    $self->output($output)                   if ( defined $output );
    $self->gene($gene)                       if ( defined $gene );
    $self->search_products($search_products) if ( defined $search_products );
    $self->nucleotides($nucleotides)         if ( defined $nucleotides );
    $self->archive($archive)                 if ( defined $archive );
    $self->stats($stats)                     if ( defined $stats );
    $self->_environment('test')              if ( defined $test );
}

sub check_inputs{
    my $self = shift;
    return (
             $self->type
          && $self->id
          && $self->id ne ''
          && !$self->help

          && ( $self->type eq 'study'
            || $self->type eq 'lane'
            || $self->type eq 'file'
            || $self->type eq 'sample'
            || $self->type eq 'species'
            || $self->type eq 'database' )
      )
      && (
        !$self->filetype
        || (
            $self->filetype
            && (   $self->filetype eq 'gff'
                || $self->filetype eq 'faa'
                || $self->filetype eq 'ffn' )
        )
      );
}

sub run {
    my ($self) = @_;

    $self->check_inputs or Path::Find::Exception::InvalidInput->throw( error => $self->usage_text);

    # assign variables
    my $type            = $self->type;
    my $id              = $self->id;
    my $symlink         = $self->symlink;
    my $filetype        = $self->filetype;
    my $output          = $self->output;
    my $gene            = $self->gene;
    my $search_products = $self->search_products;
    my $nucleotides     = $self->nucleotides;
    my $archive         = $self->archive;
    my $stats           = $self->stats;

    Path::Find::Exception::FileDoesNotExist->throw( error => "File $id does not exist.\n") if( $type eq 'file' && !-e $id );

    my $logfile = $self->_environment eq 'test' ? '/nfs/pathnfs05/log/pathfindlog/test/annotationfind.log' : '/nfs/pathnfs05/log/pathfindlog/annotationfind.log';
    eval {
        Path::Find::Log->new(
            logfile => $logfile,
            args    => $self->args
        )->commandline();
    };

    Path::Find::Exception::InvalidInput( error => "The archive and symlink options cannot be used together\n")
      if ( defined $archive && defined $symlink );

    my $lane_filter;
    my $found = 0;

    # set subdirectories to search for annotations in
    my @sub_directories =
      ( '/velvet_assembly/annotation', '/spades_assembly/annotation' );

    # set file type extension wildcard
    my %type_extensions = (
        gff => '*.gff',
        faa => '*.faa',
        ffn => '*.ffn'
    );

    if ($gene || !defined $filetype) {
        $filetype = 'gff';
    }

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
            processed_flag => 2048
        );
        my @lanes = @{ $find_lanes->lanes };

        unless (@lanes) {
            $dbh->disconnect();
            next;
        }

        my @req_stats;
        @req_stats = (
            'contigs.fa.stats', 'contigs.mapped.sorted.bam.bc',
            'annotation/*.gff'
        ) if ( defined $stats );

        # check directories exist, find & filter by file type
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

        my $sorted_ml = Path::Find::Sort->new(lanes => \@matching_lanes)->sort_lanes;
        @matching_lanes = @{ $sorted_ml };

      # symlink or archive
      # Set up to symlink/archive. Check whether default filetype should be used
        my $use_default = 0;
        $use_default = 1 if ( !defined $filetype );
        if ( $lane_filter->found && ( defined $symlink || defined $archive ) ) {
            my $name = $self->set_linker_name;

            my $linker = Path::Find::Linker->new(
                lanes            => \@matching_lanes,
                name             => $name,
                use_default_type => $use_default
            );

            $linker->sym_links if ( defined $symlink );
            $linker->archive   if ( defined $archive );
        }

        # print out the paths
        foreach my $ml (@matching_lanes) {
            my $l = $ml->{path};
            print "$l\n";
        }

        if ( $lane_filter->found && defined($gene) ) {
            my $qualifiers_to_search = ['gene'];
            if ( defined($search_products) ) {
                push( @{$qualifiers_to_search}, 'product' );
                push( @{$qualifiers_to_search}, 'ID' );
            }
            my $amino_acids = 1;
            $amino_acids = 0 if ($nucleotides);

            my @gffs;
            foreach my $file_hash (@matching_lanes){
                push(@gffs, $file_hash->{path});
            }

            my $gene_finder =
              Bio::AutomatedAnnotation::ParseGenesFromGFFs->new(
                gff_files         => \@gffs,
                search_query      => $gene,
                search_qualifiers => $qualifiers_to_search,
                amino_acids       => $amino_acids
              );

            # check output location
            unless( -e $output ){
                print "Cannot access '$output'. Writing output to default file name\n";
                $output = undef;
            }

	    $gene_finder->output_base($output) if(defined($output));
            $gene_finder->create_fasta_file;

            print "Samples containing gene:\t"
              . $gene_finder->files_with_hits() . "\n";
            print "Samples missing gene:\t"
              . $gene_finder->files_without_hits() . "\n";
        }

        $dbh->disconnect();

        #no need to look in the next database if relevant data has been found
        if ( $lane_filter->found ) {
            $found = 1;
            if ( defined $stats ) {
                $stats = "$id.csv" if ( $stats eq '' );
                $stats =~ s/\s+/_/g;
                Path::Find::Stats::Generator->new(
                    lane_hashes => \@matching_lanes,
                    output      => $stats,
                    vrtrack     => $pathtrack
                )->annotationfind;
            }
            return 1;
        }
    }

    unless ( $found ) {
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
    print <<USAGE;
Usage: $script_name
  -t|type            <study|lane|file|sample|species>
  -i|id              <study id|study name|lane name|file of lane names>
  -l|symlink         <create a symlink to the data>
  -f|filetype        <gff|faa|ffn>
  -g|gene            <name of gene>
  -p|search_products <when searching for genes also search products>
  -o|output          <name of output fasta file of genes>
  -n|nucleotides     <output nucleotide sequence instead of amino acids in fasta file>
  -a|archive		 <name of archive>
  -h|help            <print this message>

Given a study or lane this will give you the location of the annotation results. By default it provides the directory, but by specifiying a 'filetype' you can narrow it down to particular 
files within the result set. 
Using the option -l|symlink will create symlinks to the data. Using the option -a|archive will create an archive (.tar.gz) containing the selected annotations. 
The archive and symlink options will automatically create/name the archive file/symlink directory if a name is not supplied.
For an annotation you will have:

gff: The master annotation in GFF3 format, containing both sequences and annotations.
faa: The Protein FASTA file of the translated CDS sequences.
ffn: The Nucleotide FASTA file of the CDS sequences.

# Create a fasta file containing all of the gryA genes for Stap.
annotationfind -t species -i Stap -g gryA

# Output as nucleotide sequences instead of amino acids
annotationfind -t species -i Stap -g gryA -n 

# Create a fasta file containing all 16S for Strep.
annotationfind -t species -i Strep -g "16S ribosomal RNA" -p

# create a compressed archive containing all annotations for a study
annotationfind -t study -i 123 -a 
annotationfind -t study -i 123 -a study_123_annotations

# create symlinks to data in directory 'symlinks_dir'
annotationfind -t lane -i 123_1#23 -l symlinks_dir

USAGE
    #exit;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
