package Path::Find::Filter;

# ABSTRACT:

=head1 SYNOPSIS

Logic to filter lanes based on given criteria

   use Path::Find::Filter;
   my $lane_filter = Path::Find::Filter->new(
	   scriptname => 'pathfind',
       lanes     => \@lanes,
       filetype  => $filetype,
       qc        => $qc,
       root      => $root,
       pathtrack => $pathtrack
   );
   my @matching_paths = $lane_filter->filter;
   
=method filter

Returns a list of full paths to lanes that match the given criteria

=cut

use Moose;
use VRTrack::Lane;
use VRTrack::Individual;
use Path::Find;
use Data::Dumper;

has 'lanes' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'hierarchy_template' =>
  ( is => 'rw', required => 0, builder => '_build_hierarchy_template' );
has 'filetype'        => ( is => 'ro', required => 0 );
has 'type_extensions' => ( is => 'rw', required => 0, isa => 'HashRef' );
has 'qc'              => ( is => 'ro', required => 0 );
has 'root'            => ( is => 'ro', required => 1 );
has 'found' =>
  ( is => 'rw', required => 0, default => 0, writer => '_set_found' );
has 'pathtrack' => ( is => 'ro', required => 1 );
has 'subdirectories' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 0,
    default  => sub {
        my @empty = ("");
        return \@empty;
    }
);
has 'reference' => ( is => 'ro', required => 0 );
has 'mapper'    => ( is => 'rw', required => 0 );
has 'date'      => ( is => 'ro', required => 0 );
has 'verbose' => ( is => 'ro', isa => 'Bool', required => 0, default => 0 );

sub _build_hierarchy_template {
    my ($self) = @_;

    return Path::Find->hierarchy_template;
}

sub filter {
    my ($self)   = @_;
    my $filetype = $self->filetype;
    my @lanes    = @{ $self->lanes };
    my $qc       = $self->qc;

    my $ref    = $self->reference;
    my $mapper = $self->mapper;
    my $date   = $self->date;

    my $type_extn = $self->type_extensions->{$filetype} if ($filetype);

    my @matching_paths;
    foreach (@lanes) {
        my $l = $_;

        # check ref, date or mapper matches
        next if ( $ref    && !$self->_reference_matches($l) );
        next if ( $mapper && !$self->_mapper_matches($l) );
        next if ( $date   && !$self->_date_is_later($l) );

        if ( !$qc || ( $qc && $qc eq $l->qc_status() ) ) {
            my @paths = $self->_get_full_path($l);

            foreach my $full_path (@paths) {
                if ($filetype) {
					my $search_path = "$full_path/$type_extn";
                    next
                      unless my $matching_files =
                      $self->find_files( $search_path );
                    for my $m ( @{$matching_files} ) {
                        chomp $m;
                        if ( -e $m ) {
                            $self->_set_found(1);
                            push(@matching_paths, $self->_make_lane_hash( $m, $l ));
                        }
                    }
                }
                else {
                    if ( -e $full_path ) {
                        $self->_set_found(1);
                        push(@matching_paths, $self->_make_lane_hash( $full_path, $l ));
                    }
                }
            }
        }
    }

    return @matching_paths;
}

sub find_files {
    my ( $self, $full_path ) = @_;

	print "ls $full_path";
    my @matches = `ls $full_path`;
	print join("\n", @matches);
    if ( @matches ) {
        return \@matches;
    }
    else {
        return undef;
    }
}

sub _make_lane_hash {
    my ( $self, $path, $lane_obj ) = @_;
    my $vb = $self->verbose;

    if ($vb) {
        return {
            lane   => $path,
            ref    => $self->_reference_name($lane_obj),
            mapper => $self->_get_mapper($lane_obj),
            date   => $self->_date_changed($lane_obj)
        };

    }
    else {
        return { lane => $path };
    }
}

sub _get_full_path {
    my ( $self, $lane ) = @_;
    my $hierarchy_template = $self->hierarchy_template;
    my $root               = $self->root;
    my $pathtrack          = $self->pathtrack;
    my @subdirs            = @{ $self->subdirectories };

    my $lane_path =
      $pathtrack->hierarchy_path_of_lane( $lane, $hierarchy_template );
    my @fps;
    foreach my $subdir (@subdirs) {
        push( @fps, "$root/$lane_path$subdir" );
    }

    return @fps;
}

sub get_verbose_info {
    my ($self) = @_;
    my ( $ref, $mapper, $date );

    my @lanes = @{ $self->lanes };
    my @vb;
    foreach my $l (@lanes) {
        $ref    = $self->_reference_name($l);
        $mapper = $self->_get_mapper($l);
        $date   = $self->_bam_date($l);

        push( @vb, "$l\t$ref\t$mapper\t$date" );
    }
    $self->_set_found(1) if ( \@vb );
    return \@vb;
}

sub _reference_matches {
    my ( $self, $lane ) = @_;
    my $given_ref = $self->reference;

    my $lane_ref = $self->_reference_name($lane);
    if ( $lane_ref eq $given_ref ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _mapper_matches {
    my ( $self, $lane ) = @_;
    my $given_mapper = $self->mapper;

    my $lane_mapper = $self->_get_mapper($lane);
    if ( $lane_mapper eq $given_mapper ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _date_is_later {
    my ( $self, $lane ) = @_;
    my $earliest_date = $self->date;
    my $given_date    = $self->_date_changed($lane);

    my ( $e_dy, $e_mn, $e_yr ) = split( "-", $earliest_date );
    my ( $g_dy, $g_mn, $g_yr ) = split( "-", $given_date );

    my $later = 0;

    $later = 1
      if ( ( $e_yr < $g_yr )
        || ( $e_yr == $g_yr && $e_mn < $g_mn )
        || ( $e_yr == $g_yr && $e_mn == $g_mn && $e_dy < $g_dy ) );

    return $later;
}

sub _reference_name {
    my ( $self, $lane ) = @_;

    my @mapstats = @{ $lane->mappings_excluding_qc };
    return $mapstats[0]->assembly->name;
}

sub _get_mapper {
    my ( $self, $lane ) = @_;

    my @mapstats = @{ $lane->mappings_excluding_qc };
    return $mapstats[0]->mapper->name;
}

sub _date_changed {
    my ( $self, $lane ) = @_;
	
	my $lc = $lane->changed;
    my ( $date, $time ) = split( /\s+/, $lc );
    my @date_elements = split( '-', $date );
    return join( '-', reverse @date_elements );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
