package Path::Find::CommandLine::QC;
use Data::Dumper;

# ABSRACT: Given a lane id, this script returns the location on disk of the requested QC files

=head1 NAME

Path::Find::CommandLine::QC

=head1 SYNOPSIS

use Path::Find::CommandLine::QC;
my $pipeline = Path::Find::CommandLine::QC->new(
    script_name => 'qcfind',
    args => \@ARGV
)->run;

where \@ARGV follows the following parameters:

-t|type     <study|lane|file|sample|species>
-i|id       <study id|study name|lane name|file of lane names>
-l|symlink  <create a symlink to the data>
-a|archive  <create archive of the data>
-s|summary  <create a summary CSV file>
-level      <D|P|C|O|F|G|S|T> the taxon level when running metagm_summarise_kraken_reports
-counts     <report read counts instead of %s in summary file>
-assigned_directly <report reads assigned directly totaxon>
-transpose  <transpose summary file>
-h|help     <print help message>

=head1 METHODS

=head1 CONTACT

path-help@sanger.ac.uk

=cut

use Moose;
use Cwd;
use Cwd 'abs_path';
use File::Basename;
use File::Path 'remove_tree';

#Change accordingly once we have a stable checkout
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules";
use lib "../lib";
use lib "./lib";

use Getopt::Long qw(GetOptionsFromArray);

use Bio::Metagenomics::External::KrakenSummary;
use Path::Find;
use Path::Find::Lanes;
use Path::Find::Filter;
use Path::Find::Linker;
use Path::Find::Log;
use Path::Find::Sort;
use Path::Find::Exception;

has 'args'              => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'       => ( is => 'ro', isa => 'Str', required => 1 );
has 'type'              => ( is => 'rw', isa => 'Str', required => 0 );
has 'id'                => ( is => 'rw', isa => 'Str', required => 0 );
has 'file_id_type'      => ( is => 'rw', isa => 'Str', required => 0, default => 'lane' );
has 'symlink'           => ( is => 'rw', isa => 'Str', required => 0 );
has 'archive'           => ( is => 'rw', isa => 'Str', required => 0 );
has 'summary'           => ( is => 'rw', isa => 'Str', required => 0 );
has 'level'             => ( is => 'rw', isa => 'Str', required => 0, default => 'S' );
has 'counts'            => ( is => 'rw', isa => 'Bool', required => 0 );
has 'assigned_directly' => ( is => 'rw', isa => 'Bool', required => 0 );
has 'min_cutoff'        => ( is => 'rw', isa => 'Num', required => 0, default => 0 );
has 'transpose'         => ( is => 'rw', isa => 'Bool', required => 0 );
has 'help'              => ( is => 'rw', isa => 'Bool', required => 0 );
has '_environment'      => ( is => 'rw', isa => 'Str', required => 0, default => 'prod' );
has '_outname'          => ( is => 'rw', isa => 'Str', required => 0, builder => '_build_outname', lazy => 1 );
has '_lanes'            => ( is => 'rw', isa => 'ArrayRef', required => 0);
has '_summary_file'     => ( is => 'rw', isa => 'Str', required => 0, builder => '_build_summary_file', lazy => 1);
has '_symlink_dir'      => (is => 'rw', isa => 'Str', required => 0, builder => '_build_symlink_dir', lazy => 1);
has '_archive_name'      => (is => 'rw', isa => 'Str', required => 0, builder => '_build_archive_name', lazy => 1);


sub _build_outname {
    my ($self) = @_;
    my $name;
    $name = $self->id =~ /\// ? (split('/', $self->id))[-1] : $self->id;
    $name =~ s/[^\w\.\/]+/_/g;
    return $name;
}


sub _build_summary_file {
    my ($self) = @_;
    if (defined $self->summary and $self->summary ne '') {
        return abs_path($self->summary);
    }
    else {
        return abs_path($self->_outname . '.kraken_summary.csv');
    }
}


sub _build_symlink_dir {
    my ($self) = @_;
    if (defined $self->symlink and $self->symlink ne '') {
        return abs_path($self->symlink);
    }
    else {
        return abs_path($self->script_name . '_' . $self->_outname);
    }
}


sub _build_archive_name {
    my ($self) = @_;
    if (defined $self->archive and $self->archive ne '') {
        return abs_path($self->archive);
    }
    else {
        return abs_path($self->script_name . '_' . $self->_outname);
    }
}


sub BUILD {
    my ($self) = @_;

    my $args;
    my $script_name;
    my $type;
    my $id;
    my $file_id_type;
    my $symlink;
    my $archive;
    my $summary;
    my $level;
    my $counts;
    my $min_cutoff;
    my $assigned_directly;
    my $transpose;
    my $help;
    my $test;

    my @args = @{ $self->args };
    GetOptionsFromArray(
        \@args,
        't|type=s'             => \$type,
        'i|id=s'               => \$id,
        'file_id_type=s'       => \$file_id_type,
        'l|symlink:s'          => \$symlink,
        'a|archive:s'          => \$archive,
        's|summary:s'          => \$summary,
        'level:s'              => \$level,
        'counts'               => \$counts,
        'min_cutoff=f'           => \$min_cutoff,
        'assigned_directly'    => \$assigned_directly,
        'transpose'            => \$transpose,
        'h|help'               => \$help,
        'test'                 => \$test,
    );

    $self->type($type)         if ( defined $type );
    $self->id($id)             if ( defined $id );
    $self->file_id_type($file_id_type) if ( defined $file_id_type );
    $self->symlink($symlink)   if ( defined $symlink );
    $self->archive($archive)   if ( defined $archive );
    $self->help($help)         if ( defined $help );
    $self->summary($summary)   if ( defined $summary );
    $self->level($level)       if ( defined $level );
    $self->counts($counts)     if ( defined $counts );
    $self->min_cutoff($min_cutoff) if ( defined $min_cutoff);
    $self->assigned_directly($assigned_directly) if ( defined $assigned_directly );
    $self->transpose($transpose) if ( defined $transpose );
    $self->_environment('test')  if ( defined $test );
}


sub check_inputs {
    my ($self) = @_;
    return  (
            $self->type
        &&  $self->level
        &&  $self->id
        &&  $self->id ne ''
        &&  !$self->help
        && ( $self->file_id_type eq 'lane' || $self->file_id_type eq 'sample' )
        &&  ( $self->type eq 'study'
           ||  $self->type eq 'lane'
           ||  $self->type eq 'file'
           ||  $self->type eq 'sample'
           ||  $self->type eq 'library'
           ||  $self->type eq 'species'
           ||  $self->type eq 'database' )
    );
}


sub run {
    my ($self) = @_;
    $self->check_inputs or Path::Find::Exception::InvalidInput->throw( error => $self->usage_text);

    my $logfile = $self->_environment eq 'test' ? '/nfs/pathnfs05/log/pathfindlog/test/qcfind.log' : '/nfs/pathnfs05/log/pathfindlog/qcfind.log';
    eval {
        Path::Find::Log->new(
        logfile => $logfile,
        args => $self->args
        )->commandline();
    };

    $self->_get_lanes();

    unless (scalar @{$self->_lanes} ) {
        Path::Find::Exception::NoMatches->throw( error => "Could not find lanes or files for input data\n");
    }

    foreach my $lane (@{$self->_lanes}) {
        print $lane->{path} . "\n";
    }

    if (defined $self->symlink) {
        $self->_symlink_or_archive($self->_symlink_dir, ".kraken.report", 0);
    }

    if (defined $self->summary) {
        $self->_make_kraken_summary();
    }

    if (defined $self->archive) {
        $self->_symlink_or_archive($self->_archive_name, ".kraken.report", 1);
    } 
}


sub _get_lanes {
    my ($self) = @_;
    my @matching_lanes;
    my $find = Path::Find->new( environment => $self->_environment );
    my @pathogen_databases = $find->pathogen_databases;

    for my $database (@pathogen_databases) {
        # Connect to database and get info
        my ( $pathtrack, $dbh, $root ) = $find->get_db_info($database);

        # find matching lanes - must have been QC'd
        my $find_lanes = Path::Find::Lanes->new(
                search_type    => $self->type,
                search_id      => $self->id,
                file_id_type   => $self->file_id_type,
                pathtrack      => $pathtrack,
                dbh            => $dbh,
                processed_flag => 2,
                );
        my @lanes = @{ $find_lanes->lanes };
        unless (@lanes) {
            $dbh->disconnect();
            next;
        }

        # filter lanes - we want kraken.report files
        my %type_extensions = (kraken => 'kraken.report');
        my $lane_filter = Path::Find::Filter->new(
                lanes => \@lanes,
                root => $root,
                pathtrack => $pathtrack,
                type_extensions => \%type_extensions,
                filetype => 'kraken',
                search_depth => 1
                );
        @matching_lanes = $lane_filter->filter;
        my $sorted_ml = Path::Find::Sort->new(lanes => \@matching_lanes)->sort_lanes;
        @matching_lanes = @{ $sorted_ml };

        unless (@matching_lanes) {
            $dbh->disconnect();
            next;
        }
        $dbh->disconnect();
        last;
    }

    $self->_lanes(\@matching_lanes);
}


sub _make_kraken_summary {
    my $self = shift;
    my $summary_file = $self->_summary_file;

    # make tmp dir of links to reports so summary file nicer to read
    my $temp_directory_obj = File::Temp->newdir("tmp.qcfind.XXXXXXXX",  CLEANUP => 1);
    my $tmpdir = $temp_directory_obj->dirname();
    $self->_symlink_or_archive($tmpdir, "", 0);
    my @reports = map { $_->{lane}{name} } @{$self->_lanes};
    my $cwd = getcwd;
    chdir $tmpdir; 
    my $obj = Bio::Metagenomics::External::KrakenSummary->new(
        report_files => \@reports,
        outfile => $summary_file,
        taxon_level => $self->level,
        counts => $self->counts,
        assigned_directly => $self->assigned_directly,
        transpose => $self->transpose,
        min_cutoff => $self->min_cutoff,
    );
    $obj->run();
    chdir $cwd;
}


sub _symlink_or_archive {
    my ($self, $dirname, $suffix, $archive) = @_;
    return unless defined $dirname;
    my %files_to_copy;
    my $temp_directory_obj = File::Temp->newdir("tmp.qcfind.XXXXXXXX",  CLEANUP => 1);
    if ($archive) {
        my $tmpdir = $temp_directory_obj->dirname();
        my $original_summary_file = $self->_summary_file;
        $self->_summary_file(abs_path("$tmpdir/summary.csv"));
        $files_to_copy{$self->_summary_file} = 'kraken_summary.csv';
        $self->_make_kraken_summary;
        $self->_summary_file($original_summary_file);
    }
    my %link_names = map { $_->{path} => $_->{lane}{name} . $suffix } @{$self->_lanes};
    my $linker = Path::Find::Linker->new(
        lanes            => $self->_lanes,
        name             => $dirname,
        rename_links     => \%link_names,
        copy_files       => \%files_to_copy,
    );

    if ($archive) {
        $linker->archive;
    }
    else {
        $linker->sym_links;
    }
}


sub usage_text {
    my ($self) = @_;
    my $script_name = $self->script_name;
    return <<USAGE;
Usage: $script_name
     -t|type             <study|lane|file|library|sample|species>
     -i|id               <study id|study name|lane name|file of lane names>
     --file_id_type     <lane|sample> define ID types contained in file. default = lane
     -l|symlink          <create a symlink to the data>
     -a|archive          <create archive of the data>
     -s|summary          <create a summary CSV file>
     -level              <D|P|C|O|F|G|S|T>
     -counts             <Use counts in summary instead of percentages>
     -assigned_directly  <Report reads assigned directly to taxon node>
     -transpose          <Transpose the summary file>
     -h|help             <print this message>

***********
Given a study, lane or a file containing a list of lanes or samples, this script will output the path (on pathogen disk) to the data associated with the specified study or lane.
Using the option -l|symlink will create a symlink to the queried data in a default directory created in the current directory, alternatively an output directory can be specified in which the symlinks will be created.
Using the option -a|archive will create an archive (.tar.gz) containing the selected kraken reports and a summary CSV file. The -archive option will automatically name the archive file if a name is not supplied.

Using the options -a|archive or -s|summary will create a summary CSV file from the Kraken output of each sample. The following options then apply:
-level D|P|C|O|F|G|S|T (default: S)
    Taxonomic level to output. Choose from:
      D (Domain), P (Phylum), C (Class), O (Order),
      F (Family), G (Genus), S (Species), T (Strain)

-counts
    Report counts of reads instead of percentages of the total reads in each
    file.

-assigned_directly
    Report reads assigned directly to this taxon, instead of the
    default of reporting reads covered by the clade rooted at this taxon.

-min_cutoff
    Cutoff minimum value in at least one report to include in output.
    Default: no cutoff.

-transpose
    Transpose output to have files in rows and matches in columns.
    Default is to have matches in rows and files in columns
***********

Examples:

# find a Kraken report for a give lane
qcfind -t lane -i 1234_5#6

# make summary CSV file for all samples in the given study
qcfind -t study -i 123 -s summary.csv

# create symlinks to all kraken reports in the given study
qcfind -t study -i "My study" -l 
qcfind -t study -i "My study" -l output_directory

# create a compressed archive of all kraken reports and a summary file
qcfind -t study -i 123 -a
qcfind -t study -i 123 -a study_123_reports.tar.gz
USAGE
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;

