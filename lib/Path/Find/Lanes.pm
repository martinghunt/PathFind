package Path::Find::Lanes;

# ABSTRACT: Logic to find lanes from the tracking database

=head1 SYNOPSIS

Logic to find lanes from the tracking database

   use Path::Find::Lanes;
   my $obj = Path::Find::Lanes->new(
     search_type => 'lane',
     search_id => '1234_5',
     pathtrack => $self->pathtrack,
     dbh => $dbh
   );
   
   $obj->lanes;
   
=method lanes

Returns an array of matching VRTrack::Lane objects

=cut

use Moose;
use VRTrack::Lane;
use VRTrack::Individual;

has 'search_type'    => ( is => 'ro', isa => 'Str', required => 1 );
has 'search_id'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'processed_flag' => ( is => 'ro', isa => 'Int', required => 1 );

has 'pathtrack' => ( is => 'rw', required => 1 );
has 'dbh'       => ( is => 'rw', required => 1 );

has 'lanes' =>
  ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_lanes' );

sub _lookup_by_lane {
    my ($self) = @_;
    my @lanes;

    my $search_id_suffix = '%';
    if ( $self->search_id =~ /\#/ ) {
        $search_id_suffix = '';
    }

    my $lane_names =
      $self->dbh->selectall_arrayref(
            'select lane.name from latest_lane as lane where'
          . ' ( lane.name like "'
          . $self->search_id
          . $search_id_suffix . '"'
          . ' OR lane.acc like "'
          . $self->search_id . '" )'
          . ' AND lane.processed & '
          . $self->processed_flag . ' = '
          . $self->processed_flag
          . ' order by lane.name asc' );
    for my $lane_name (@$lane_names) {
        my $lane =
          VRTrack::Lane->new_by_name( $self->pathtrack, @$lane_name[0] );
        if ($lane) {
            push( @lanes, $lane );
        }
    }

    return \@lanes;
}

sub _lookup_by_sample {
    my ($self) = @_;
    my @lanes;

    my $lane_names = $self->dbh->selectall_arrayref(
        'select lane.name from individual as individual
        inner join latest_sample as sample on sample.individual_id = individual.individual_id
        inner join latest_library as library on library.sample_id = sample.sample_id
        inner join latest_lane as lane on lane.library_id = library.library_id
        where'
          . '( individual.acc like "'
          . $self->search_id . '"'
          . ' OR sample.name like "'
          . $self->search_id . '" )'
          . ' AND lane.processed & '
          . $self->processed_flag . ' = '
          . $self->processed_flag
          . ' order by lane.name asc'
    );
    for my $lane_name (@$lane_names) {
        my $lane =
          VRTrack::Lane->new_by_name( $self->pathtrack, @$lane_name[0] );
        if ($lane) {
            push( @lanes, $lane );
        }
    }

    return \@lanes;
}

sub _lookup_by_study {
    my ($self) = @_;
    my @lanes;

    my $lane_names = $self->dbh->selectall_arrayref(
        'select lane.name from latest_project as project
      inner join latest_sample as sample on sample.project_id = project.project_id
      inner join latest_library as library on library.sample_id = sample.sample_id
      inner join latest_lane as lane on lane.library_id = library.library_id
      where (project.ssid = "'
          . $self->search_id
          . '" OR  project.name like "'
          . $self->search_id
          . '") AND lane.processed & '
          . $self->processed_flag . ' = '
          . $self->processed_flag
          . ' order by lane.name asc'
    );
    for my $lane_name (@$lane_names) {
        my $lane =
          VRTrack::Lane->new_by_name( $self->pathtrack, @$lane_name[0] );
        if ($lane) {
            push( @lanes, $lane );
        }
    }

    return \@lanes;
}

sub _lookup_by_species {
    my ($self) = @_;
    my @lanes;

    my $lane_names = $self->dbh->selectall_arrayref(
        'select lane.name from species as species
        inner join individual as individual on individual.species_id = species.species_id
        inner join latest_sample as sample on sample.individual_id = individual.individual_id
        inner join latest_library as library on library.sample_id = sample.sample_id
        inner join latest_lane as lane on lane.library_id = library.library_id
      where species.name like "'
          . $self->search_id
          . '%" AND lane.processed & '
          . $self->processed_flag . ' = '
          . $self->processed_flag
          . ' order by lane.name asc'
    );
    for my $lane_name (@$lane_names) {
        my $lane =
          VRTrack::Lane->new_by_name( $self->pathtrack, @$lane_name[0] );
        if ($lane) {
            push( @lanes, $lane );
        }
    }

    return \@lanes;
}

# xxxfind -t database -i pathogen_abc_track
sub _lookup_by_database {
    my ($self) = @_;
    my @lanes;

    my @current_database_name_row =
      $self->dbh->selectrow_array('select DATABASE();');
    if ( $current_database_name_row[0] ne $self->search_id ) {
        return \@lanes;
    }

    my $lane_names = $self->dbh->selectall_arrayref(
        'select lane.name from latest_lane as lane
      where lane.processed & '
          . $self->processed_flag . ' = '
          . $self->processed_flag
          . ' order by lane.name asc'
    );
    for my $lane_name (@$lane_names) {
        my $lane =
          VRTrack::Lane->new_by_name( $self->pathtrack, @$lane_name[0] );
        if ($lane) {
            push( @lanes, $lane );
        }
    }

    return \@lanes;
}

sub _lookup_by_file {
    my ($self) = @_;
    my @lanes;

    my %lanenames;
    open( my $fh, $self->search_id )
      || die "Error: Could not open file '" . $self->search_id . "'\n";
    foreach my $lane_id (<$fh>) {
        chomp $lane_id;
        next if $lane_id eq '';
        $lanenames{$lane_id} = 1;
    }
    close $fh;

    my @all_lane_names = keys %lanenames;
    for ( my $i = 0 ; $i < @all_lane_names ; $i++ ) {
        unless ( $all_lane_names[$i] =~ /\#/ ) {
            $all_lane_names[$i] .= '%';
        }

    }

    my $lane_name_search_query =
      join( '" OR lane.name like "', @all_lane_names );
    $lane_name_search_query =
      ' (lane.name like "' . $lane_name_search_query . '") ';

    my $lane_acc_search_query =
      join( '" OR lane.acc like "', ( keys %lanenames ) );
    $lane_acc_search_query =
      ' (lane.acc like "' . $lane_acc_search_query . '") ';

    my $lane_names =
      $self->dbh->selectall_arrayref(
            'select lane.name from latest_lane as lane where ' . '( '
          . $lane_name_search_query . ' OR '
          . $lane_acc_search_query . ' )'
          . ' AND lane.processed & '
          . $self->processed_flag . ' = '
          . $self->processed_flag
          . ' order by lane.name asc' );
    for my $lane_name (@$lane_names) {
        my $lane =
          VRTrack::Lane->new_by_name( $self->pathtrack, @$lane_name[0] );
        if ($lane) {
            push( @lanes, $lane );
        }
    }

    return \@lanes;
}

sub _build_lanes {
    my ($self) = @_;
    my @lanes = [];

    if ( $self->search_type eq 'lane' ) {
        return $self->_lookup_by_lane;
    }
    elsif ( $self->search_type eq 'sample' ) {
        return $self->_lookup_by_sample;
    }
    elsif ( $self->search_type eq 'database' ) {
        return $self->_lookup_by_database;
    }
    elsif ( $self->search_type eq 'study' ) {
        return $self->_lookup_by_study;
    }
    elsif ( $self->search_type eq 'file' ) {
        return $self->_lookup_by_file;
    }
    elsif ( $self->search_type eq 'species' ) {
        return $self->_lookup_by_species;
    }

    return \@lanes;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
