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

use strict;
use warnings;
no warnings 'uninitialized';
use Moose;

use Cwd;
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules";
use lib "/software/pathogen/internal/prod/lib";
use lib "../lib";

use Getopt::Long qw(GetOptionsFromArray);
use DBI;
use Text::CSV;

use Path::Find;
use Path::Find::Lanes;
use Path::Find::Log;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'type'        => ( is => 'rw', isa => 'Str',      required => 0 );
has 'id'          => ( is => 'rw', isa => 'Str',      required => 0 );
has 'output'      => ( is => 'rw', isa => 'Str',      required => 0 );
has 'help'        => ( is => 'rw', isa => 'Str',      required => 0 );

sub BUILD {
    my ($self) = @_;

    my ( $type, $id, $output, $help );

    my @args = @{ $self->args };
    GetOptionsFromArray(
        \@args,
        't|type=s'   => \$type,
        'i|id=s'     => \$id,
        'h|help'     => \$help
    );

    $self->type($type)     if ( defined $type );
    $self->id($id)         if ( defined $id );
    $self->output($output) if ( defined $output );
    $self->help($help)     if ( defined $help );

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
          && ( !defined($output) || ( defined($output) && $output ne '' ) )
    ) or die $self->usage_text;
}

sub run {
    my ($self) = @_;

    # assign variables
    my $type   = $self->type;
    my $id     = $self->id;
    my $output = $self->output;

    die "File $id does not exist.\n" if( $type eq 'file' && !-e $id );

    eval {
        Path::Find::Log->new(
            logfile => '/nfs/pathnfs05/log/pathfindlog/infofind.log',
            args    => $self->args
        )->commandline();
    };

    # Connect to warehouse database
    my $warehouse_dbh = DBI->connect(
        "DBI:mysql:host=mcs7:port=3379;database=sequencescape_warehouse",
        "warehouse_ro", undef, { 'RaiseError' => 1, 'PrintError' => 0 } )
      or die "Failed to create connect to warehouse.\n";

    # CSV output
    my $csv_out;
    my $csv_fh;
    $output .= $output && ( $output =~ m/\.csv$/ ) ? '' : '.csv';

    # Get pathogen databases
    my @pathogen_databases = Path::Find->pathogen_databases;
    my $hierarchy_template = Path::Find->hierarchy_template;

    my ( $pathtrack, $dbh, $root );
    my $found = 0;    #assume nothing found

    # Find lanes in pathogen tracking databases
    for my $database (@pathogen_databases) {

        # Connect to database and get info
        ( $pathtrack, $dbh, $root ) = Path::Find->get_db_info($database);

        my $find_lanes = Path::Find::Lanes->new(
            search_type    => $type,
            search_id      => $id,
            pathtrack      => $pathtrack,
            dbh            => $dbh,
            processed_flag => 0
        );
        my @lanes = @{ $find_lanes->lanes };

        unless (@lanes) {
            $dbh->disconnect();
            next;
        }

        # open csv file and print column headers
        if ( $output && @lanes ) {
            $csv_out =
              Text::CSV->new(
                { binary => 1, always_quote => 1, eol => "\r\n" } );
            open( $csv_fh, ">$output" )
              or die "Cannot open output file '$output'\n";
            $csv_out->print( $csv_fh,
                [ 'Lane', 'Sample', 'Supplier Name', 'Public Name', 'Strain' ]
            );
        }

        # print column headers to screen
        printf "%-15s %-25s %-25s %-25s %-20s\n",
          ( 'Lane', 'Sample', 'Supplier Name', 'Public Name', 'Strain' )
          if @lanes;

        # Output sample data
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
            printf "%-15s %-25s %-25s %-25s %-20s\n",
              ( $lane->name(), $sample->name(), @sample_data );
            $csv_out->print( $csv_fh,
                [ $lane->name(), $sample->name(), @sample_data ] )
              if $output;

        }
        close($csv_fh) if ( $output && @lanes );
        $dbh->disconnect();

        if ( @lanes
          ) #no need to look in the next database if relevant data has been found
        {
            $found = 1;
            last;
        }
    }

    unless ($found) {
        print "Could not find lanes or files for input data \n";
    }

    $warehouse_dbh->disconnect();
    return 1;
}

sub usage_text {
    my ($self) = @_;
    my $script_name = $self->script_name;
    print <<USAGE;
Usage: $script_name
     -t|type            <study|lane|file|sample|species>
     -i|id              <study id|study name|lane name|file of lane names>
     -h|help            <print this message>

Given a study, lane or a file containing a list of lanes, this script will return the name, 
supplier name, public name and strain of the sample.

USAGE
    exit;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
