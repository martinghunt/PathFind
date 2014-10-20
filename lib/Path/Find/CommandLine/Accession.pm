package Path::Find::CommandLine::Accession;

# ABSTRACT: Finds accession information for given lanes/studies

=head1 NAME

Path::Find::CommandLine::Accession

=head1 SYNOPSIS

	use Path::Find::CommandLine::Accession;
	
	my $pipeline = Path::Find::CommandLine::Accession->new(
		script_name => 'accessionfind',
		args        => \@ARGV
	)->run;
	
where \@ARGV follows the following parameters:

t|type      <study|lane|file|sample|species>
i|id        <study id|study name|lane name|file of lane names|lane accession|sample accession>
f|fastq     <generate ftp addresses for fastq file download from ENA>
s|submitted <generate ftp addresses for submitted file download. Format varies>
o|outfile   <file to write output to. If not given, defaults to accessionfind.out>
h|help      <display help message>

=head1 METHODS

=head1 CONTACT

pathdevg@sanger.ac.uk

=cut

use Moose;

use lib "/software/pathogen/internal/pathdev/vr-codebase/modules"
  ;    #Change accordingly once we have a stable checkout
use lib "../lib";
use lib './lib';

use Getopt::Long qw(GetOptionsFromArray);
use WWW::Mechanize;

use Path::Find;
use Path::Find::Lanes;
use Path::Find::Log;
use Path::Find::Exception;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'type'        => ( is => 'rw', isa => 'Str',      required => 0 );
has 'id'          => ( is => 'rw', isa => 'Str',      required => 0 );
has 'help'        => ( is => 'rw', isa => 'Str',      required => 0 );
has 'external'    => ( is => 'rw', isa => 'Str',      required => 0 );
has 'submitted'   => ( is => 'rw', isa => 'Str',      required => 0 );
has 'outfile' =>
  ( is => 'rw', isa => 'Str', required => 0, default => 'accessionfind.out' );
has 'help' => ( is => 'rw', isa => 'Bool', required => 0 );
has '_environment' => ( is => 'rw', isa => 'Str',      required => 0, default => 'prod' );

sub BUILD {
    my ($self) = @_;

    $ENV{'http_proxy'} = 'http://webcache.sanger.ac.uk:3128/';

    my ( $type, $id, $help, $external, $submitted, $outfile, $test );

    my @args = @{ $self->args };

    GetOptionsFromArray(
        \@args,
        't|type=s'    => \$type,
        'i|id=s'      => \$id,
        'h|help'      => \$help,
        'f|fastq'     => \$external,
        's|submitted' => \$submitted,
        'o|outfile=s' => \$outfile,
        'test'        => \$test,
    ) or Path::Find::Exception::InvalidInput->throw( error => "");

    $self->type($type)           if ( defined $type );
    $self->id($id)               if ( defined $id );
    $self->help($help)           if ( defined $help );
    $self->external($external)   if ( defined $external );
    $self->submitted($submitted) if ( defined $submitted );
    $self->outfile($outfile)     if ( defined $outfile );
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

	my $external = $self->external;
	my $submitted = $self->submitted;
    my $outfile   = $self->outfile;

    Path::Find::Exception::FileDoesNotExist->throw( error => "File $id does not exist.\n") if( $type eq 'file' && !-e $id );

    my $logfile = $self->_environment eq 'test' ? '/nfs/pathnfs05/log/pathfindlog/test/accessionfind.log' : '/nfs/pathnfs05/log/pathfindlog/accessionfind.log';
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

        for my $lane (@lanes) {

            # get sample and lane accessions
            my $sample = $self->get_sample_from_lane( $pathtrack, $lane );
            my $sample_name = $sample->name            if defined $sample;
            my $sample_acc  = $sample->individual->acc if defined $sample;
            my $lane_acc    = $lane->acc;
            $sample_name = 'not found' unless defined $sample_name;
            $sample_acc  = 'not found' unless defined $sample_acc;
            $lane_acc    = 'not found' unless defined $lane_acc;

            # print sample and lane accessions
            print join( "\t",
                ( $sample_name, $sample_acc, $lane->name, $lane_acc ) )
              . "\n";

            # output url
            if ( ( $lane->acc ) && ($external) ) {
                $self->print_ftp_url( "dl", $lane->acc, $outfile );
            }
            if ( ( $lane->acc ) && ($submitted) ) {
                $self->print_ftp_url( "sub", $lane->acc, $outfile );
            }
        }
        $lanes_found = scalar @lanes;
        return 1 if $lanes_found;    # Stop looking if lanes found.
    }

    # No lanes found
    Path::Find::Exception::NoMatches->throw( error => "No lanes found for search of '$type' with '$id'\n")
      unless $lanes_found;
}

sub print_ftp_url {
    my ( $self, $url_type, $acc, $outfile ) = @_;
    
    # check outfile location
    system("touch $outfile") == 0 or Path::Find::Exception::FileDoesNotExist->throw("Cannot write to $outfile\n");

    open( OUT, ">> $outfile" );
    my $url;
    if ( $url_type eq "sub" ) {
        $url = "http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=$acc&result=read_run&fields=submitted_ftp";
    }
    else {
        $url = "http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=$acc&result=read_run&fields=fastq_ftp";
    }
    my $mech = WWW::Mechanize->new;
    $mech->get($url);
    my $down = $mech->content( format => 'text' );
    my @lines = split( /\n/, $down );
    foreach my $x ( 1 .. $#lines ) {
        my @fields = split( /;/, $lines[$x] );
        foreach my $f (@fields){ print OUT "ftp://$f\n"; }
    }
    close OUT;
}

sub get_sample_from_lane {
    my ( $self, $vrtrack, $lane ) = @_;
    my ( $library, $sample );

    $library = VRTrack::Library->new( $vrtrack, $lane->library_id );
    $sample = VRTrack::Sample->new( $vrtrack, $library->sample_id )
      if defined $library;

    return $sample;
}

sub usage_text {
    my ($self) = @_;
    my $scriptname = $self->script_name;
    return <<USAGE;
Usage: $scriptname -t <type> -i <id> [options]   
	 t|type      <study|lane|file|library|sample|species>
	 i|id        <study id|study name|lane name|file of lane names|lane accession|sample accession>
	 f|fastq     <generate ftp addresses for fastq file download from ENA>
	 s|submitted <generate ftp addresses for submitted file download. Format varies>
	 o|outfile   <file to write FTP output to. If not given, defaults to accessionfind.out>
	 h|help      <this message>
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
