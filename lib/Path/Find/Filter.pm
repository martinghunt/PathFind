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

# required
has 'lanes' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'root'      => ( is => 'ro', required => 1 );
has 'pathtrack' => ( is => 'ro', required => 1 );
# end required

#optional
has 'hierarchy_template' =>
  ( is => 'rw', builder => '_build_hierarchy_template', required => 0 );
has 'filetype'        => ( is => 'ro', required => 0 );
has 'type_extensions' => ( is => 'rw', isa      => 'HashRef', required => 0 );
has 'qc'              => ( is => 'ro', required => 0 );
has 'found' =>
  ( is => 'rw', default => 0, writer => '_set_found', required => 0 );
has 'subdirectories' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub {
        my @empty = ("");
        return \@empty;
    },
    required => 0
);
has 'reference' => ( is => 'ro', required => 0 );
has 'mapper'    => ( is => 'rw', required => 0 );
has 'date'      => ( is => 'ro', required => 0 );
has 'verbose'   => ( is => 'ro', isa => 'Bool', default => 0, required => 0 );
has 'stats'     => ( is => 'ro', isa => 'ArrayRef', required => 0 );
# end optional

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

        # check if type exension should include mapstat id
        #print STDERR "check if type exension should include mapstat id\n";
        if ( $filetype && $type_extn =~ /MAPSTAT_ID/ ) {
            my $ms_id = $self->_get_mapstat_id($l);
            $type_extn =~ s/MAPSTAT_ID/$ms_id/;
        }

        # check ref, date or mapper matches
        #print STDERR "check ref, date or mapper matches\n";
        next if ( $ref    && !$self->_reference_matches($l) );
        next if ( $mapper && !$self->_mapper_matches($l) );
        next if ( $date   && !$self->_date_is_later($l) );

        if ( !$qc || ( $qc && $qc eq $l->qc_status() ) ) {

            #print STDERR "get full paths\n";
            my @paths = $self->_get_full_path($l);

            #print STDERR "loop through paths\n";
            foreach my $full_path (@paths) {
                if ($filetype) {

                    #print STDERR "filtering by filetype\n";
                    my $search_path = "$full_path/$type_extn";
                    next unless my $mfiles = $self->find_files($search_path);
					my @matching_files = @{ $mfiles };

					# exclude pool_1.fastq.gz files
					@matching_files = grep {!/pool_1.fastq.gz/} @matching_files;

                    #print STDERR "add files to print\n";
                    for my $m ( @matching_files ) {
                        if ( -e $m ) {
                            $self->_set_found(1);
							my %lane_hash = $self->_make_lane_hash( $m, $l );
                            push( @matching_paths, \%lane_hash );
                        }
                    }
                }
                else {
                    #print STDERR "no need to filter..add to print\n";
                    if ( -e $full_path ) {
                        $self->_set_found(1);
						my %lane_hash = $self->_make_lane_hash( $full_path, $l );
                        push( @matching_paths, \%lane_hash);
                    }
                }
            }
        }
    }

    return @matching_paths;
}

sub find_files {
    my ( $self, $full_path ) = @_;

    my @matches = glob $full_path;
    if (@matches) {
        return \@matches;
    }
    else {
        return undef;
    }
}

sub _make_lane_hash {
    my ( $self, $path, $lane_obj ) = @_;
    my $vb = $self->verbose;
	my $stats = $self->stats;
	
	my %lane_hash;
    if ($vb) {
        %lane_hash = (
            lane   => $lane_obj,
			path   => $path,
            ref    => $self->_reference_name($lane_obj),
            mapper => $self->_get_mapper($lane_obj),
            date   => $self->_date_changed($lane_obj),
        );

    }
    else {
        %lane_hash = ( 
			lane => $lane_obj,
			path => $path 
		);
    }

	if(defined $stats){
		$lane_hash{stats} = $self->_get_stats_paths($lane_obj);
	}
	
	return %lane_hash;
}

sub _get_full_path {
    my ( $self, $lane ) = @_;
    my $root    = $self->root;
    my @subdirs = @{ $self->subdirectories };

    my ( @fps, $lane_path );

    my $hierarchy_template = $self->hierarchy_template;
    my $pathtrack          = $self->pathtrack;

    $lane_path =
      $pathtrack->hierarchy_path_of_lane( $lane, $hierarchy_template );
    foreach my $subdir (@subdirs) {
        push( @fps, "$root/$lane_path$subdir" );
    }

    return @fps;
}

sub _get_stats_paths {
	my ($self, $lane_obj) = @_;
	my @lane_paths = $self->_get_full_path($lane_obj);
	my $stats = $self->stats;
	
	my @stats_paths;
	foreach my $l ( @lane_paths ){
		$l =~ s/annotation//;
		foreach my $sf ( @{ $stats } ){
			print "STATS PATHS GLOBBING:\t$l/$sf\t";
			my @stat_files = glob "$l/$sf";
			foreach my $st_file ( @stat_files ){
				if(-e $st_file){
					push(@stats_paths, $st_file);
					print "FOUND\n";
				}
				else {
					print "NOT FOUND\n";
				}
			}
			print "\n\n";
		}
		return \@stats_paths if( @stats_paths );
	}
	return undef;
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
