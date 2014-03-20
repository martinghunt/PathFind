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
#use lib "/software/pathogen/internal/prod/lib";
use lib "../lib";
use File::Basename;

use Path::Find;
use Path::Find::Lanes;
use Path::Find::Filter;
use Path::Find::Linker;
use Path::Find::Stats::Generator;
use Path::Find::Log;
use Path::Find::Sort;
use Path::Find::Exception;

has 'args'         => ( is => 'ro', isa => 'ArrayRef',   required => 1 );
has 'script_name'  => ( is => 'ro', isa => 'Str',        required => 1 );
has 'type'         => ( is => 'rw', isa => 'Str',        required => 0 );
has 'id'           => ( is => 'rw', isa => 'Str',        required => 0 );
has 'symlink'      => ( is => 'rw', isa => 'Str',        required => 0 );
has 'archive'      => ( is => 'rw', isa => 'Str',        required => 0 );
has 'help'         => ( is => 'rw', isa => 'Str',        required => 0 );
has 'verbose'      => ( is => 'rw', isa => 'Str',        required => 0 );
has 'stats'        => ( is => 'rw', isa => 'Str',        required => 0 );
has 'filetype'     => ( is => 'rw', isa => 'Str',        required => 0 );
has 'ref'          => ( is => 'rw', isa => 'Str',        required => 0 );
has 'date'         => ( is => 'rw', isa => 'Str',        required => 0 );
has 'mapper'       => ( is => 'rw', isa => 'Str',        required => 0 );
has 'pseudogenome' => ( is => 'rw', isa => 'Str',        required => 0 );
has 'qc'           => ( is => 'rw', isa => 'Str',        required => 0 );
has '_ref_path'    => ( is => 'rw', isa => 'Maybe[Str]', required => 0, lazy_build => 1 );
has '_environment' => ( is => 'rw', isa => 'Str',      required => 0, default => 'prod' );

sub _build__ref_path {
    my ($self) = @_;
    return my $check_ref = $self->find_reference($self->ref);
}

sub BUILD {
    my ($self) = @_;

    my (
        $type,    $id,           $symlink,  $archive, $help,
        $verbose, $stats,        $filetype, $ref,     $date,
        $mapper,  $pseudogenome, $qc, $test
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
        'p|pseudo:s'    => \$pseudogenome,
        'q|qc=s'        => \$qc,
        'test'         => \$test,
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
    $self->_environment('test')        if ( defined $test );
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
          && ( !$self->filetype || $self->filetype eq 'vcf' || $self->filetype eq 'pseudogenome' )
    );
}

sub run {
    my ($self) = @_;
    $self->check_inputs or Path::Find::Exception::InvalidInput->throw( error => $self->usage_text);

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

    Path::Find::Exception::FileDoesNotExist->throw( error => "File $id does not exist.\n") if( $type eq 'file' && !-e $id );

    my $logfile = $self->_environment eq 'test' ? '/nfs/pathnfs05/log/pathfindlog/test/snpfind.log' : '/nfs/pathnfs05/log/pathfindlog/snpfind.log';
    eval {
        Path::Find::Log->new(
            logfile => $logfile,
            args    => $self->args
        )->commandline();
    };

    Path::Find::Exception::InvalidInput->throw( error => "The archive and symlink options cannot be used together\n")
      if ( defined $archive && defined $symlink );

    Path::Find::Exception::InvalidInput->throw( error => "Please specify a reference to base the pseudogenome on\n")
      if ( defined $pseudogenome && $pseudogenome ne 'none' && !defined $ref );


    # set file type extension regular expressions
    my %type_extensions = (
        vcf          => '*.snp/mpileup.unfilt.vcf.gz',
        pseudogenome => '*.snp/pseudo_genome.fasta'
    );

    my ( $lane_filter, $vb );
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
        my $verbose_info = 0;
        if ( $verbose || $date || $ref || $mapper ){
            $filetype = "vcf" if (!defined $filetype);
            $verbose_info = 1;
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
            verbose         => $verbose_info
        );
        my @matching_lanes = $lane_filter->filter;

        my $sorted_ml = Path::Find::Sort->new(lanes => \@matching_lanes)->sort_lanes;
        @matching_lanes = @{ $sorted_ml };

        # Set up to symlink/archive. Check whether default filetype should be used
        if ( @matching_lanes && ( defined $symlink || defined $archive ) ) {
            my $name = $self->set_linker_name;
            my %link_names = $self->link_rename_hash( \@matching_lanes );

            my $index_files;
            $index_files = "tbi" if( $filetype eq 'vcf' );

            my $linker = Path::Find::Linker->new(
                lanes            => \@matching_lanes,
                name             => $name,
                use_default_type => 0,
				script_name      => $self->script_name,
                rename_links     => \%link_names,
                index_files      => $index_files
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
            $self->create_pseudogenome( \@matching_lanes ) if ( defined $pseudogenome );
        }

        $dbh->disconnect();

        #no need to look in the next database if relevant data has been found
        return 1 if ($found);
		
    }

    unless ($found) {
        Path::Find::Exception::NoMatches->throw( error => "Could not find lanes or files for input data \n");
    }
}

sub create_pseudogenome {
    my ($self, $mlanes)       = @_;
    my @matching_lanes = @{$mlanes};
    my $ref            = $self->pseudogenome eq 'none' ? $self->pseudogenome : $self->ref;

    print "Using reference: $ref\n";

    my $pg_filename = $self->pseudogenome_filename();
    print STDERR "Creating pseudogenome in $pg_filename\n";

    # first add reference as one sequence
    unless ( $ref eq 'none' ) {
        my $ref_path = $self->_ref_path;
        unless( defined $ref_path ){
            unlink($pg_filename);
            print STDERR "Could not find reference: $ref. Pseudogenome creation aborted.\n";
            return 1;
        }

        `rm $pg_filename` if ( -e $pg_filename );
        `touch $pg_filename`;

        my $cmd = "echo \">$ref\" >> $pg_filename";
        system($cmd);
        $cmd = "grep -v \">\" $ref_path >> $pg_filename";
        system($cmd);
		
		# add newline to ref
		open(PG, ">>", $pg_filename);
		print PG "\n";
		close(PG);
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
    my $ref                    = $self->pseudogenome eq 'none' ? $self->pseudogenome : $self->ref;
    my $id                     = $self->id;

    unless ( $ref eq 'none' ) {
        $pseudo_genome_filename = $ref . "_" . $pseudo_genome_filename;
    }

    unless(-e $id){
        $pseudo_genome_filename = $id . "_" . $pseudo_genome_filename;
    }
    else{
        my($filename, $directories, $suffix) = fileparse($id, qr/\.[^.]*/);
        $pseudo_genome_filename = $filename . "_" . $pseudo_genome_filename;
    }
    $pseudo_genome_filename =~ s![\W]!_!gi;
    $pseudo_genome_filename .= '.aln';
    return $pseudo_genome_filename;
}

sub link_rename_hash {
    my ($self, $mlanes) = @_;
    my @matching_lanes = @{ $mlanes };

    my %link_names;
    foreach my $mf (@matching_lanes) {
        my $lane = $mf->{path};
        $lane =~ /(\d+)[^\/]+\/([^\/]+)$/;
        my $lane_n = $mf->{lane}->{name};
        $link_names{$lane} = "$lane_n.$1.$2";
    }
    return %link_names;
}

sub find_reference {
    my ($self, $ref) = @_; 
    chomp $ref;
    my $reffind_args = "-t species -i $ref -f fa";
    my @refs = `reffind $reffind_args`;

    chomp @refs;

    if (scalar @refs > 1){
        my @ref_names;
        foreach my $r (@refs){
            return $r if ($ref eq $r);
            $r =~ /([^\/]+)\.fa$/;
            push(@ref_names, $1);
        }
        print STDERR "Ambiguous reference. Did you mean:\n" . join("\n", @ref_names) . "\n"; 
        return undef;
    }
    my $ref_path = $refs[0];
    return $ref_path if( -e $ref_path );
    return undef;
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

The -p option will generate a pseudogenome based on the reference passed via the -r option. If you wish to omit the reference from the multifasta file, pass 'none' after the -p option. Examples:
# generate a pseudogenome, but exclude the reference
snpfind -t file -i my_lanes.txt -p none
# generate a pseudogenome based on Salmonella enterica Typhi Ty2
snpfind -t file -i my_lanes.txt -p -r Salmonella_enterica_subsp_enterica_serovar_Typhi_Ty2_v1

USAGE
    exit;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
