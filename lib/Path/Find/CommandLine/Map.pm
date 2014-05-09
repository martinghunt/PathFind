package Path::Find::CommandLine::Map;

# ABSTRACT: Given a lane id, a study id or a study name, it will return the paths to the requested files

=head1 NAME

Path::Find::CommandLine::Map

=head1 SYNOPSIS

	use Path::Find::CommandLine::Map;
	my $pipeline = Path::Find::CommandLine::Map->new(
		script_name => 'mapfind',
		args        => \@ARGV
	)->run;

where \@ARGV follows the following parameters:
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

use Moose;

use Cwd;
use Cwd 'abs_path';
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules"
  ;    #Change accordingly once we have a stable checkout
use lib "/software/pathogen/internal/prod/lib";
use lib "../lib";
use Getopt::Long qw(GetOptionsFromArray);

use File::Basename;
use Path::Find;
use Path::Find::Lanes;
use Path::Find::Filter;
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
        'test'         => \$test
    );

    $self->type($type)         if ( defined $type );
    $self->id($id)             if ( defined $id );
    $self->archive($archive)   if ( defined $archive );
    $self->help($help)         if ( defined $help );
    $self->verbose($verbose)   if ( defined $verbose );
    $self->stats($stats)       if ( defined $stats );
    $self->filetype($filetype) if ( defined $filetype );
    $self->ref($ref)           if ( defined $ref );
    $self->date($date)         if ( defined $date );
    $self->mapper($mapper)     if ( defined $mapper );
    $self->qc($qc)             if ( defined $qc );
    $self->_environment('test') if ( defined $test );

    if ( defined $symlink ){
        if ($symlink eq ''){
            $self->symlink($symlink);
        }
        else{
            $self->symlink(abs_path($symlink));
        }
    }
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

    my $logfile = $self->_environment eq 'test' ? '/nfs/pathnfs05/log/pathfindlog/test/mapfind.log' : '/nfs/pathnfs05/log/pathfindlog/mapfind.log';
    eval {
        Path::Find::Log->new(
            logfile => $logfile,
            args    => $self->args
        )->commandline();
    };

    Path::Find::Exception::InvalidInput->throw( error => "The archive and symlink options cannot be used together\n")
      if ( defined $archive && defined $symlink );

    # set file type extension regular expressions
    my %type_extensions = ( bam     => '*markdup.bam', 
                            alt_bam => '*raw.sorted.bam');

    my $lane_filter;
    my $found = 0;

    $filetype = 'bam' if(!defined $filetype);

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
            processed_flag => 4
        );
        my @lanes = @{ $find_lanes->lanes };

        unless (@lanes) {
            $dbh->disconnect();
            next;
        }

        # filter lanes
        my $verbose_info = 0;
        if ( $verbose || $date || $ref || $mapper ){
            $filetype = "bam";
            $verbose_info = 1;
        }

	$lane_filter = Path::Find::Filter->new(
	    lanes           => \@lanes,
            filetype        => 'bam',
            root            => $root,
            pathtrack       => $pathtrack,
            type_extensions => \%type_extensions,
            qc              => $qc,
            reference       => $ref,
            mapper          => $mapper,
            date            => $date,
            verbose         => $verbose_info,
	    search_depth    => 1
	);
	my @matching_markdup = $lane_filter->filter;
	
	$lane_filter = Path::Find::Filter->new(
            lanes           => \@lanes,
            filetype        => 'alt_bam',
            root            => $root,
            pathtrack       => $pathtrack,
            type_extensions => \%type_extensions,
            qc              => $qc,
            reference       => $ref,
            mapper          => $mapper,
            date            => $date,
            verbose         => $verbose_info,
	    search_depth    => 1
	);
	my @matching_raw = $lane_filter->filter;

	my @matching_lanes = $self->remove_dups( [@matching_markdup, @matching_raw]);

        unless (@matching_lanes) {
            $dbh->disconnect();
            next;
        }

        my $sorted_ml = Path::Find::Sort->new(lanes => \@matching_lanes)->sort_lanes;
        @matching_lanes = @{ $sorted_ml };

        # generate stats
        my $stats_output;
        if ( defined $stats || defined $archive ) {
            eval('use Path::Find::Stats::Generator');
            $stats_output = Path::Find::Stats::Generator->new(
                lane_hashes => \@matching_lanes,
                vrtrack     => $pathtrack
            )->mapfind;
            if(defined $stats){
                my $stats_name = $self->stats_name;
                open(STATS, ">", $stats_name) or Path::Find::Exception::InvalidDestination->throw( error => "Can't write statistics to archive. Error code: $?\n");
                print STATS $stats_output;
                close STATS;
            }
        }

        # Set up to symlink/archive. Check whether default filetype should be used
        my $use_default = 0;
        $use_default = 1 if ( !defined $filetype );
        if ( $lane_filter->found && ( defined $symlink || defined $archive ) ) {
            my $name = $self->set_linker_name;
            my %link_names = $self->link_rename_hash( \@matching_lanes );

            my $ind;
            $ind = "bai" if ($filetype eq "bam");
            eval('use Path::Find::Linker');
            my $linker = Path::Find::Linker->new(
                lanes            => \@matching_lanes,
                name             => $name,
                use_default_type => $use_default,
				script_name      => $self->script_name,
                rename_links     => \%link_names,
                index_files      => $ind,
                stats            => $stats_output
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
            return 1;
        }
    }

    unless ($found) {
        Path::Find::Exception::NoMatches->throw( error => "Could not find lanes or files for input data \n");
    }
}

sub stats_name {
    my ($self) = @_;
    my $stats = $self->stats;
    my $id = $self->id;

    if ( $stats eq '' ){
        my $s;
        if( $id =~ /\// ){
            my @dirs = split('/', $id);
            $s = pop(@dirs);
        }
        else{
            $s = $id;
        }
        $stats = "$s.mapping_stats.csv";
    }
    $stats =~ s/[^\w\.\/]+/_/g;
    return $stats;
}

sub link_rename_hash {
    my ($self, $mlanes) = @_;
    my @matching_lanes = @{ $mlanes };

    my %link_names;
    foreach my $mf (@matching_lanes) {
        my $lane = $mf->{path};
        my @parts = split('/', $lane);
        my $f = pop(@parts);
        my $l = pop(@parts);
        $link_names{$lane} = "$l.$f";
    }
    return %link_names;
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

sub remove_dups {
    my( $self, $l) = @_;
    my @lanes = @{ $l };

    my %exts;
    foreach my $lane ( @lanes ){
	my($filename, $directories, $suffix) = fileparse($lane->{path}, ('.markdup.bam', '.raw.sorted.bam'));
	my $halfpath = $directories . $filename;
	$exts{$halfpath} = $suffix if ( !$exts{$halfpath} || $suffix eq '.markdup.bam' );
    }

    my @nodups;
    foreach my $k ( keys \%exts ){
	my $fp = $k . $exts{$k};
	foreach my $lane (@lanes){
	    if($fp eq $lane->{path}){
		push(@nodups, $lane);
		last;
	    }
	}
    }
    return @nodups;
}

sub usage_text {
    my ($self) = @_;
    my $script_name = $self->script_name;
    return <<USAGE;
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
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
