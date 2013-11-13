# ABSTRACT: Simple wrapper module for VRTrack and DBI. Used for connecting to pathogen tracking databases.

=head1 NAME
Path::Find

=head1 SYNOPSIS
@databases = Path::Find->pathogen_databases;
$database  = shift @databases;
my ( $pathtrack, $dbh, $root ) = Path::Find->get_db_info($database);
=cut

package Path::Find;
use strict;
use DBI;
use VRTrack::VRTrack;

# Database connection details
my %CONNECT = ('host' => 'mcs6',
               'port' => 3347,
               'user' => 'pathpipe_ro',
               'password' => undef);

# Location of database root directories.
my $DB_ROOT = '/lustre/scratch108/pathogen/pathpipe/';
my %DB_SUB  = ('pathogen_virus_track'    => 'viruses',
               'pathogen_prok_track'     => 'prokaryotes',
               'pathogen_euk_track'      => 'eukaryotes',
               'pathogen_helminth_track' => 'helminths',
               'pathogen_rnd_track'      => 'rnd');

# Hierarchy template for pathogen database directories
my $TEMPLATE = "genus:species-subspecies:TRACKING:projectssid:sample:technology:library:lane";

=begin nd

  Method: pathogen_databases
    
  Description:
    Returns list of pathogen databases. Schema is verified by VRTrackFactory.

  Arguments:
    None

  Example:
    my @databases = Path::Find->pathogen_databases;

  Returns:
    Array of database names.

=cut

sub pathogen_databases
{
    my ($class) = @_;

    my @db_list_all = grep(s/^DBI:mysql://, DBI->data_sources("mysql", \%CONNECT));

    my @db_list = (); # tracking and external databases
    push @db_list, grep (/^pathogen_.+_track$/,   @db_list_all); # pathogens_..._track
    push @db_list, grep (/^pathogen_.+_external$/,@db_list_all); # pathogens_..._external

    my @db_list_out = (); # databases with files on disk
    for my $database (@db_list)
    {
        my $root_dir = Path::Find->hierarchy_root_dir($database);
        push @db_list_out, $database  if defined $root_dir;
    }

    return @db_list_out;
}

=begin nd

  Method: hierarchy_root_dir
    
  Description:
    Returns the root directory for a tracking database.

  Arguments:
    Arg [1] - database name

  Example:
    my $root_dir = Path::Find->hierarchy_root_dir($database);

  Returns:
    Database root directory or undef if directory doesn't exist.

=cut

sub hierarchy_root_dir
{
    my ($class, $database) = @_;

    my $sub_dir = exists $DB_SUB{$database} ? $DB_SUB{$database}:$database;
    my $root_dir = $DB_ROOT.$sub_dir.'/seq-pipelines'; 
    return -d $root_dir ? $root_dir : undef;
}

sub lookup_tracking_name_from_database
{
   my ($class, $database) = @_;
   exists $DB_SUB{$database} ? $DB_SUB{$database}:$database;
}

=begin nd

  Method: hierarchy_template
    
  Description:
    Returns hierarchy template for pathogen tracking database.

  Arguments:
    None

  Example:
    my $hierarchy_template = Path::Find->hierarchy_template;

  Returns:
    String value.

=cut

sub hierarchy_template
{
    my ($class) = @_;
    return $TEMPLATE;
}

=begin nd

  Method: instantiate_vrtrack
    
  Description:
    Instantiates a VRTrack object for a pathogen database. Returns undef on error.

  Arguments:
    Arg [1] - database name

  Example:
    my $vrtrack = Path::Find->instantiate_vrtrack($database)

  Returns:
    A VRTrack object.

=cut

sub vrtrack
{
    my ($class, $database) = @_;

    return undef unless defined Path::Find->hierarchy_root_dir($database);

    my %connect = %CONNECT;
    $connect{database} = $database;
    my $vrtrack = VRTrack::VRTrack->new(\%connect);

    return $vrtrack;
}

=begin nd

  Method: instantiate_dbi($database)

    
  Description:
    Instantiates a DBI object for a pathogen database. Returns undef on error.

  Arguments:
    Arg [1] - database name

  Example:
    my $dbi = Path::Find->instantiate_dbi($database)

  Returns:
    A DBI object.

=cut

sub dbi
{
    my ($class, $database) = @_;

    return undef unless defined Path::Find->hierarchy_root_dir($database);

    my $dbi_connect = "DBI:mysql:dbname=".$database.";host=".$CONNECT{host}.";port=".$CONNECT{port};
    my $dbi = DBI->connect($dbi_connect, $CONNECT{user}) or return undef;

    return $dbi;
}

sub get_db_info{
	my ($self, $db) = @_;
	
	my $vr = $self->vrtrack($db) or die "Failed to create VRTrack object for '$db'\n";
	my $dbh = $self->dbi($db) or die "Failed to create DBI object for '$db'\n";
	my $root = $self->hierarchy_root_dir($db) or die "Failed to find root directory for '$db'\n";
	
	return ($vr, $dbh, $root);
}

1;
