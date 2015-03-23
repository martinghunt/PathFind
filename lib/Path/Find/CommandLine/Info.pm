package Path::Find::CommandLine::Info;

# ABSTRACT: Given a lane id, this script returns basic information on the sample from the sequencescape warehouse.

=head1 NAME

Path::Find::CommandLine::Info 

=head1 SYNOPSIS

	use Path::Find::CommandLine::Info;
	my $pipeline = Path::Find::CommandLine::Info->new(
		script_name => 'infofind',
		args        => \@ARGV
	)->run;

where \@ARGV follows the following parameters:
-t|type            <study|lane|file|sample|species>
-i|id              <study id|study name|lane name|file of lane names>
-h|help            <print this message>

=head1 METHODS

=head1 CONTACT

path-help@sanger.ac.uk

=cut

use Moose;

use Cwd;
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules";
use lib "../lib";
use lib './lib';

use Getopt::Long qw(GetOptionsFromArray);
use DBI;
use Text::CSV;

use Path::Find;
use Path::Find::Lanes;
use Path::Find::Log;
use Path::Find::Sort;
use Path::Find::Exception;

has 'args'         => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'  => ( is => 'ro', isa => 'Str',      required => 1 );
has 'type'         => ( is => 'rw', isa => 'Str',      required => 0 );
has 'id'           => ( is => 'rw', isa => 'Str',      required => 0 );
has 'file_id_type' => ( is => 'rw', isa => 'Str',      required => 0, default => 'lane' );
has 'output'       => ( is => 'rw', isa => 'Str',      required => 0 );
has 'help'         => ( is => 'rw', isa => 'Str',      required => 0 );
has '_environment' => ( is => 'rw', isa => 'Str',      required => 0, default => 'prod' );

sub BUILD {
    my ($self) = @_;

    my ( $type, $id, $file_id_type, $output, $help, $test );

    my @args = @{ $self->args };
    GetOptionsFromArray(
        \@args,
        't|type=s'       => \$type,
        'i|id=s'         => \$id,
        'file_id_type=s' => \$file_id_type,
        'o|output=s'     => \$output,
        'h|help'         => \$help,
        'test'           => \$test,
    );

    $self->type($type)     if ( defined $type );
    $self->id($id)         if ( defined $id );
    $self->output($output) if ( defined $output );
    $self->help($help)     if ( defined $help );
    $self->_environment('test') if ( defined $test );
    $self->file_id_type($file_id_type) if ( defined $file_id_type );
}

sub check_inputs{
    my ($self) = @_;
    return(
             $self->type
          && $self->id
          && $self->id ne ''
          && !$self->help
          && ( $self->type eq 'study'
            || $self->type eq 'lane'
            || $self->type eq 'file'
            || $self->type eq 'library'
            || $self->type eq 'sample'
            || $self->type eq 'species'
            || $self->type eq 'database' )
          && ( $self->file_id_type eq 'lane' || $self->file_id_type eq 'sample' )
          && ( !defined($self->output) || ( defined($self->output) && $self->output ne '' ) )
    );
}

sub run {
    my ($self) = @_;

    $self->check_inputs or Path::Find::Exception::InvalidInput->throw( error => $self->usage_text);

    # assign variables
    my $type   = $self->type;
    my $id     = $self->id;
    my $output = $self->output;

    Path::Find::Exception::FileDoesNotExist->throw( error => "File $id does not exist.\n") if( $type eq 'file' && !-e $id );

    my $logfile = $self->_environment eq 'test' ? '/nfs/pathnfs05/log/pathfindlog/test/infofind.log' : '/nfs/pathnfs05/log/pathfindlog/infofind.log';
    eval {
        Path::Find::Log->new(
            logfile => $logfile,
            args    => $self->args
        )->commandline();
    };

    # Connect to warehouse database
    my $warehouse_dbh = DBI->connect(
        "DBI:mysql:host=mcs7:port=3379;database=seqw-db",
        "warehouse_ro", undef, { 'RaiseError' => 1, 'PrintError' => 0 } )
      or Path::Find::Exception::ConnectionFail->throw( error => "Failed to create connect to warehouse.\n");

    # Get pathogen databases
    my $find = Path::Find->new( environment => $self->_environment );
    my @pathogen_databases = $find->pathogen_databases;
    my $hierarchy_template = $find->hierarchy_template;

    my ( $pathtrack, $dbh, $root );
    my $found = 0;    #assume nothing found

    # Find lanes in pathogen tracking databases
    my @full_info;
    for my $database (@pathogen_databases) {
        # Connect to database and get info
        ( $pathtrack, $dbh, $root ) = $find->get_db_info($database);

        my $find_lanes = Path::Find::Lanes->new(
            search_type    => $type,
            search_id      => $id,
            file_id_type   => $self->file_id_type,
            pathtrack      => $pathtrack,
            dbh            => $dbh,
            processed_flag => 0
        );
        my @unsorted_lanes = @{ $find_lanes->lanes };

        unless (@unsorted_lanes) {
            $dbh->disconnect();
            next;
        }

	   my $sorted = Path::Find::Sort->new(lanes => \@unsorted_lanes)->sort_lanes;
	   my @lanes = @{ $sorted };        

        # Prepare sample data output
        for my $lane (@lanes) {

            # get sample object
            my %lane_hierarchy = $pathtrack->lane_hierarchy_objects($lane);
            my $sample         = $lane_hierarchy{'sample'};

            # Get sample data from warehouse
            my @sample_data = $warehouse_dbh->selectrow_array(
qq[select supplier_name, public_name, strain from current_samples where internal_id = ]
                  . $sample->ssid() );

            # set null to NA
            for (@sample_data) {
                $_ = defined $_ ? $_ : 'NA';
            }

            # results to screen and csv file
            push( @full_info, [ $lane->name(), $sample->name(), @sample_data ] );
            

        }
        $dbh->disconnect();

        $found = 1 if ( @lanes );
        last if($database ne 'pathogen_pacbio_track');
    }

    unless ($found) {
        Path::Find::Exception::NoMatches->throw( error => "Could not find lanes or files for input data \n");
    }

    # print output
    # to screen
    printf "%-15s %-25s %-25s %-25s %-20s\n", ( 'Lane', 'Sample', 'Supplier Name', 'Public Name', 'Strain' );
    for my $i ( @full_info ){
        printf "%-15s %-25s %-25s %-25s %-20s\n", @{$i};
    }

    # to file
    # open csv file and print column headers
    if ( defined $output ) {
        $output .= '.csv' unless ( $output =~ m/\.csv$/ );
        my $csv_out = Text::CSV->new(
                { binary => 1, always_quote => 1, eol => "\r\n" } 
        );
        open( my $csv_fh, ">$output" ) or Path::Find::Exception::FileDoesNotExist->throw( error => "Cannot open output file '$output'\n");
        $csv_out->print( $csv_fh, [ 'Lane', 'Sample', 'Supplier Name', 'Public Name', 'Strain' ] );
        for my $i ( @full_info ){
            $csv_out->print( $csv_fh, $i );
        }
        close($csv_fh);
    }

    $warehouse_dbh->disconnect();
    return 1;
}

sub usage_text {
    my ($self) = @_;
    my $script_name = $self->script_name;
    return <<USAGE;
Usage: $script_name
     -t|type            <study|lane|file|library|sample|species>
     -i|id              <study id|study name|lane name|file of lane names>
     --file_id_type     <lane|sample> define ID types contained in file. default = lane
     -o|output          <output results to CSV file>
     -h|help            <print this message>

Given a study, lane or a file containing a list of lanes, this script will return the name, 
supplier name, public name and strain of the sample.

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
