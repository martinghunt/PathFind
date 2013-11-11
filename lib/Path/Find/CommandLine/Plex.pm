package Path::Find::CommandLine::Plex;

# ABSTRACT: Prints the sample and tag information for a specified study or lane

=head1 NAME

Path::Find::CommandLine::Plex

=head1 SYNOPSIS

	use Path::Find::CommandLine::Plex;
	my $pipeline = Path::Find::CommandLine::Plex->new(
		script_name => 'plexfind',
		args        => \@ARGV
	)->run;

where \@ARGV uses the following parameters:
-t|type  <study|lane>
-i|id    <study id|study name|lane id>
-tag     <tag>
-h|help  <print this message>

=head1 CONTACT

jm15@sanger.ac.uk, nds@sanger.ac.uk

=head1 METHODS

=cut

use strict;
use warnings;
no warnings 'uninitialized';
use Moose;

use lib "/software/pathogen/internal/pathdev/vr-codebase/modules"
  ;    #Change accordingly once we have a stable checkout
use lib "/software/pathogen/internal/prod/lib";
use lib "../lib";

#use Getopt::Long qw(:config no_ignore_case bundling);
use Getopt::Long qw(GetOptionsFromArray);
use Carp;
use DBI;
use VRTrack::VRTrack;
use VRTrack::Lane;
use VertRes::Utils::VRTrackFactory;
use Path::Find::Log;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'type'        => ( is => 'rw', isa => 'Str',      required => 0 );
has 'id'          => ( is => 'rw', isa => 'Str',      required => 0 );
has 'tag'         => ( is => 'rw', isa => 'Str',      required => 0 );
has 'help'        => ( is => 'rw', isa => 'Str',      required => 0 );

sub BUILD {
    my ($self) = @_;

    my ( $type, $id, $tag, $help );

    my @args = @{ $self->args };
    GetOptionsFromArray(
        \@args,
        't|type=s' => \$type,
        'i|id=s'   => \$id,
        'tag=s'    => \$tag,
        'h|help'   => \$help,
    );

    $self->type($type) if ( defined $type );
    $self->id($id)     if ( defined $id );
    $self->tag($tag)   if ( defined $tag );
    $self->help($help) if ( defined $help );

    (
        $type
          && ( $type eq 'study'
            || $type eq 'lane' )
          && $id
    ) or die $self->usage_text;
}

sub run {
    my ($self) = @_;

    # assign variables
    my $type = $self->type;
    my $id   = $self->id;
    my $tag  = $self->tag;

    eval {
        Path::Find::Log->new(
            logfile => '/nfs/pathnfs05/log/pathfindlog/plexfind.log',
            args    => $self->args
        )->commandline();
    };

    my %databases = (
        'viruses'     => 'pathogen_virus_track',
        'prokaryotes' => 'pathogen_prok_track',
        'eukaryotes'  => 'pathogen_euk_track',
        'helminths'   => 'pathogen_helminth_track',
        'rnd'         => 'pathogen_rnd_track'
    );

# Connection details for the read only account and hierarchy template hard-coded here
# but should eventually be put into the pathogen profile
    my %connection_details = (
        host     => "mcs6",
        port     => 3347,
        user     => "pathpipe_ro",
        password => ""
    );

    my $hierarchy_template =
"genus:species-subspecies:TRACKING:projectssid:sample:technology:library:lane";

    my $track;
    my $study_obj;
    my $lane_obj;
	my %data;

    if ( $type eq 'study' ) {
        my $study = $id;
        foreach ( keys %databases ) {
            $connection_details{database} = $databases{$_};
            $track = VRTrack::VRTrack->new( {%connection_details} );
            $study_obj =
                $study =~ m/(\d)/
              ? $track->get_project_by_ssid($study)
              : $track->get_project_by_name($study);
            if ($study_obj) {
                my $samples = $study_obj->samples();
                foreach my $sample (@$samples) {
                    my $name                = $sample->name();
                    my $multiplex_lanes_ref = $self->get_multiplex_lanes($sample);
                    my @multiplex_lanes     = @$multiplex_lanes_ref;
                    if ( @multiplex_lanes > 0 ) {
                        $data{$name} = $multiplex_lanes_ref;
                    }
                }
                if ( scalar %data ) {
                    $self->print_data( \%data );
                }
                else {
                    print "No multiplex data available for study $study \n";
                }
                exit;
            }
        }
    }

    if ( $type eq 'lane' && $tag ) {
        my $lane      = $id;
        my $lane_name = $lane . '#' . $tag;
        foreach ( keys %databases ) {
            $connection_details{database} = $databases{$_};
            $track = VRTrack::VRTrack->new( {%connection_details} );
            my $lne = VRTrack::Lane->new_by_name( $track, $lane_name );
            if ($lne) {
                my $sample      = $self->get_sample($track, $lne);
                my $sample_name = $sample->name();
                my $npg_qc =
                  defined( $lne->npg_qc_status() )
                  ? $lne->npg_qc_status()
                  : "not defined";
                my $qc =
                  defined( $lne->qc_status() )
                  ? $lne->qc_status()
                  : "not defined";
                print "Sample : $sample_name\n";
                print "NPG QC : $npg_qc\n";
                print "QC : $qc\n";
                last;
            }
        }
    }

    if ( $type eq 'lane' ) {
        my $lane = $id;
        foreach ( keys %databases ) {
            $connection_details{database} = $databases{$_};
            $track = VRTrack::VRTrack->new( {%connection_details} );

            # raw database connection
            my $dbi_connect =
                "DBI:mysql:dbname="
              . $connection_details{database}
              . ";host="
              . $connection_details{host}
              . ";port="
              . $connection_details{port};
            my $dbh = DBI->connect( $dbi_connect, $connection_details{user} )
              or die "Can't connect to database: $DBI::errstr\n";

            my $lane_names = $dbh->selectall_arrayref(
                    'select name from latest_lane where name like "'
                  . $lane
                  . '#%"' );
            for my $lane_name (@$lane_names) {
                my $lne = VRTrack::Lane->new_by_name( $track, @$lane_name[0] );
                if ($lne) {
                    my $sample      = $self->get_sample($track, $lne);
                    my $sample_name = $sample->name();
                    my $npg_qc =
                      defined( $lne->npg_qc_status() )
                      ? $lne->npg_qc_status()
                      : "not defined";
                    my $qc =
                      defined( $lne->qc_status() )
                      ? $lne->qc_status()
                      : "not defined";
                    my @multiplex_lanes;
                    push( @multiplex_lanes, @$lane_name[0] . "#$npg_qc#$qc" );
                    $data{$sample_name} = \@multiplex_lanes;
                }
            }
            $dbh->disconnect();
        }
        if ( scalar %data ) {
            $self->print_data( \%data );
        }
        else {
            print "No multiplex data available for lane $lane \n";
        }
    }

	return 1 if(scalar %data);

    print "No info found for the details you provided.\n";

}

sub get_multiplex_lanes {
    my ( $self, $sample ) = @_;
    my @multiplex_lanes;
    my $libraries = $sample->libraries();
    foreach my $library (@$libraries) {
        my $lanes = $library->lanes();
        foreach my $lane (@$lanes) {
            my $lane_name = $lane->name();
            if ( $lane_name =~ m/#/ ) {
                my $npg_qc =
                  defined( $lane->npg_qc_status() )
                  ? $lane->npg_qc_status()
                  : "not defined";
                my $qc =
                  defined( $lane->qc_status() )
                  ? $lane->qc_status()
                  : "not defined";
                push( @multiplex_lanes, "$lane_name#$npg_qc#$qc" );
            }
        }
    }
    return \@multiplex_lanes;
}

sub print_data {
    my ( $self, $data_ref) = @_;
    my %data     = %$data_ref;

    #sort if required
    foreach my $sn ( keys %data ) {
        my $lanes = $data{$sn};
        foreach (@$lanes) {
            my @splits    = split( /#/, $_ );
            my $lane_name = $splits[0];
            my $tag_id    = $splits[1];
            my $npg_qc    = $splits[2];
            my $qc        = $splits[3];
            print "$sn, $lane_name, $tag_id, $npg_qc, $qc \n";
        }
    }
}

sub get_sample {
    my ( $self, $track, $lane ) = @_;
    my $library_id = $lane->library_id();
    my $library    = VRTrack::Library->new( $track, $library_id );
    my $sample_id  = $library->sample_id();
    my $sample     = VRTrack::Sample->new( $track, $sample_id );
    return $sample;
}

sub usage_text {
    my ($self) = @_;
    my $script_name = $self->script_name;
    print <<USAGE;
Usage: $script_name
     -t|type  <study|lane>
     -i|id    <study id|study name|lane id>
     -tag     <tag>
     -h|help  <print this message>

Given a study name or study id this script will return a list of multiplex lanes for the study along with the list of samples in each multiplex lane 
along with their corresponding tag number. Given a lane id the script will return the list of samples in the specified multiplex lane and their corresponding tag number.

USAGE
    exit;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
