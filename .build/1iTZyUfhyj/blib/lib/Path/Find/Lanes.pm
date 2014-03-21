package Path::Find::Lanes;

# ABSTRACT: Logic to find lanes from the tracking database


use Moose;
use VRTrack::Lane;
use VRTrack::Individual;
use Data::Dumper;

use lib "../../";
use Path::Find::Exception;

has 'search_type'    => ( is => 'ro', isa => 'Str', required => 1 );
has 'search_id'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'processed_flag' => ( is => 'ro', isa => 'Int', required => 1 );

has 'pathtrack' => ( is => 'rw', required => 1 );
has 'dbh'       => ( is => 'rw', required => 1 );

has 'lanes' =>
  ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_lanes' );

sub _lookup_by_lane {
    my ($self, $s_id) = @_;
    my $search_id = (defined $s_id) ? $s_id : $self->search_id;
    my @lanes;

    my $search_term = 'select lane.name from latest_lane as lane where'
          . ' ( lane.name = "'
          . $search_id . '"'
          . ' OR lane.name like "'
          . $search_id . '#%"'
          . ' OR lane.acc like "'
          . $search_id . '" )'
          . ' AND lane.processed & '
          . $self->processed_flag . ' = '
          . $self->processed_flag
          . ' order by lane.name asc';

    my $lane_names =
      $self->dbh->selectall_arrayref($search_term);
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

    my $search_id = $self->search_id;
    $search_id =~ s/\W+/_/g;

    my $lane_names = $self->dbh->selectall_arrayref(
        'select lane.name from latest_project as project
      inner join latest_sample as sample on sample.project_id = project.project_id
      inner join latest_library as library on library.sample_id = sample.sample_id
      inner join latest_lane as lane on lane.library_id = library.library_id
      where (project.ssid = "'
          . $search_id
          . '" OR  project.name like "'
          . $search_id
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
  open( my $fh, $self->search_id ) || Path::Find::Exception::FileDoesNotExist->throw( error => "Error: Could not open file '" . $self->search_id . "'\n");
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

  my $lane_name_search_query = join( '" OR lane.name like "', @all_lane_names );
  $lane_name_search_query = ' (lane.name like "' . $lane_name_search_query . '") ';

  my $lane_acc_search_query = join( '" OR lane.acc like "', (keys %lanenames) );
  $lane_acc_search_query = ' (lane.acc like "' . $lane_acc_search_query . '") ';

  my $lane_names =
    $self->dbh->selectall_arrayref( 'select lane.name from latest_lane as lane where '
        . '( ' . $lane_name_search_query
        . ' OR ' . $lane_acc_search_query . ' )'
        . ' AND lane.processed & '
        . $self->processed_flag . ' = '
        . $self->processed_flag
        . ' order by lane.name asc' );
  for my $lane_name (@$lane_names) {
      my $lane = VRTrack::Lane->new_by_name( $self->pathtrack, @$lane_name[0] );
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

__END__

=pod

=encoding UTF-8

=head1 NAME

Path::Find::Lanes - Logic to find lanes from the tracking database

=head1 VERSION

version 1.140790

=head1 SYNOPSIS

Logic to find lanes from the tracking database

   use Path::Find::Lanes;
   my $obj = Path::Find::Lanes->new(
     search_type => 'lane',
     search_id => '1234_5',
	 processed_flag => 1
     pathtrack => $self->pathtrack,
     dbh => $dbh
   );
   
   $obj->lanes;

=head1 METHODS

=head2 lanes

Returns an array of matching VRTrack::Lane objects

=head1 AUTHOR

Carla Cummins <cc21@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
