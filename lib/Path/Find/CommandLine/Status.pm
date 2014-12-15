package Path::Find::CommandLine::Status;

# ABSTRACT: Prints out the status of each lane and which pipelines its gone through

=head1 NAME

Path::Find::CommandLine::Status

=head1 SYNOPSIS

	use Path::Find::CommandLine::Status;
	
	my $pipeline = Path::Find::CommandLine::Status->new(
		script_name => 'accessionfind',
		args        => \@ARGV
	)->run;
	
where \@ARGV follows the following parameters:

t|type      <study|lane|file|sample|species>
i|id        <study id|study name|lane name|file of lane names|lane accession|sample accession>
h|help      <display help message>

=head1 METHODS

=head1 CONTACT

pathdevg@sanger.ac.uk

=cut

use Moose;

use lib "/software/pathogen/internal/pathdev/vr-codebase/modules";
use lib "../lib";
use lib './lib';

use Getopt::Long qw(GetOptionsFromArray);

use Path::Find;
use Path::Find::Lanes;
use Path::Find::Log;
use Path::Find::Exception;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'type'        => ( is => 'rw', isa => 'Str',      required => 0 );
has 'id'          => ( is => 'rw', isa => 'Str',      required => 0 );
has 'help' => ( is => 'rw', isa => 'Bool', required => 0 );
has '_environment' => ( is => 'rw', isa => 'Str',      required => 0, default => 'prod' );

sub BUILD {
    my ($self) = @_;


    my ( $type, $id, $help, $test );

    my @args = @{ $self->args };

    GetOptionsFromArray(
        \@args,
        't|type=s'    => \$type,
        'i|id=s'      => \$id,
        'h|help'      => \$help,
        'test'        => \$test,
    ) or Path::Find::Exception::InvalidInput->throw( error => "");

    $self->type($type)           if ( defined $type );
    $self->id($id)               if ( defined $id );
    $self->help($help)           if ( defined $help );
    $self->_environment('test')  if ( defined $test );
}

sub check_inputs{
    my $self = shift; 
    return(
        $self->type
          && ( $self->type eq 'study'
            || $self->type eq 'lane'
            || $self->type eq 'file'
            || $self->type eq 'library'
            || $self->type eq 'sample'
            || $self->type eq 'species'
            || $self->type eq 'database' )
          && $self->id
          && !$self->help
    );
}

sub run {
    my ($self)   = @_;

    $self->check_inputs or Path::Find::Exception::InvalidInput->throw( error => $self->usage_text);

    my $type     = $self->type;
    my $id       = $self->id;

    Path::Find::Exception::FileDoesNotExist->throw( error => "File $id does not exist.\n") if( $type eq 'file' && !-e $id );

    my $logfile = $self->_environment eq 'test' ? '/nfs/pathnfs05/log/pathfindlog/test/irodsfind.log' : '/nfs/pathnfs05/log/pathfindlog/irodsfind.log';
    eval {
        Path::Find::Log->new(
            logfile => $logfile,
            args    => $self->args
        )->commandline();
    };

    # Get databases
    my $find = Path::Find->new( environment => $self->_environment );
    my @pathogen_databases = $find->pathogen_databases;
    my $lanes_found        = 0;

    for my $database (@pathogen_databases) {
        my ( $pathtrack, $dbh, $root ) = $find->get_db_info($database);

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

          my $lane_filter;
          # filter lanes
          $lane_filter = Path::Find::Filter->new(
              lanes           => \@lanes,
              root            => $root,
              pathtrack       => $pathtrack,
          );
          my @matching_lanes = $lane_filter->filter;

          unless (@matching_lanes) {
              $dbh->disconnect();
              next;
          }
          my $sorted_ml = Path::Find::Sort->new(lanes => \@matching_lanes)->sort_lanes;
          @matching_lanes = @{ $sorted_ml };

        my @header = ('Name','Imported','QC','Mapped','Archived','BAM Improved','SNP called','RNASeq','Assembled','Annotated');
        print join("\t",@header)."\n";
        for my $lane (@matching_lanes) {
            my $lane_status = Path::Find::LaneStatus->new(lane => $lane->{lane}, path => $lane->{path});
            my @row = (
              $lane->{lane}->name,
              $lane_status->imported,
              $lane_status->qc,           
              $lane_status->mapped,           
              $lane_status->stored,           
              $lane_status->improved,         
              $lane_status->snp_called,       
              $lane_status->rna_seq_expression,
              $lane_status->assembled,        
              $lane_status->annotated,        
              );
            print join("\t",@row)."\n";
        }
        $lanes_found = scalar @lanes;
        return 1 if $lanes_found;    # Stop looking if lanes found.
    }

    # No lanes found
    Path::Find::Exception::NoMatches->throw( error => "No lanes found for search of '$type' with '$id'\n")
      unless $lanes_found;
}


sub usage_text {
    my ($self) = @_;
    my $scriptname = $self->script_name;
    return <<USAGE;
Find out which pipelines have been run

Usage: $scriptname -t <type> -i <id> [options]   
	 t|type      <study|lane|file|library|sample|species>
	 i|id        <study id|study name|lane name|file of lane names|lane accession|sample accession>
	 h|help      <this message>
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
