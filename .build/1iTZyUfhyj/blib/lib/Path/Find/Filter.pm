package Path::Find::Filter;

# ABSTRACT: Logic to filter lanes based on given criteria


use Moose;
use VRTrack::Lane;
use VRTrack::Individual;
use Path::Find;
use Data::Dumper;
use Storable;

use lib "../../";
use Path::Find::Exception;


# required
has 'lanes' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'root'      => ( is => 'ro', required => 1 );
has 'pathtrack' => ( is => 'ro', required => 1 );
# end required

#optional
has 'hierarchy_template' =>
  ( is => 'rw', builder => '_build_hierarchy_template', required => 0 );
has 'filetype'        => ( is => 'ro', required => 0 );
has 'type_extensions' => ( is => 'rw', isa => 'HashRef', required => 0 );
has 'alt_type'        => ( is => 'ro', isa => 'Str',     required => 0 );
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

    return Path::Find->new()->hierarchy_template;
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

	   # check date format
	   if(defined $date){
	       ( $date =~ /\d{2}-\d{2}-\d{4}/ ) or Path::Find::Exception::InvalidInput->throw( error => "Date (-d option) '$date' is not in the correct format. Use format: DD-MM-YYYY\n");
	   }

        if ( !$qc || (defined($l->qc_status()) && ( $qc && $qc eq $l->qc_status() )) ) {
            my @paths = $self->_get_full_path($l);

            foreach my $full_path (@paths) {
                if ($filetype) {
                    #my $search_path = "$full_path/$type_extn";
                    next unless my $mfiles = $self->find_files($full_path, $type_extn);
				    my @matching_files = @{ $mfiles };

				    # exclude pool_1.fastq.gz files
				    @matching_files = grep {!/pool_1.fastq.gz/} @matching_files;

                    for my $m ( @matching_files ) {
                        if ( -e $m ) {
                            $self->_set_found(1);
						    my %lane_hash = $self->_make_lane_hash( $m, $l );

                            # check ref, date or mapper matches
                            next if ( defined $ref    && !$self->_reference_matches($lane_hash{ref}) );
                            next if ( defined $mapper && !$self->_mapper_matches($lane_hash{mapper}) );
                            next if ( defined $date   && !$self->_date_is_later($lane_hash{date}) );


                            push( @matching_paths, \%lane_hash );
                        }
                    }
                }
                else {
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
    my ( $self, $full_path, $type_extn ) = @_;

    my @matches = glob "$full_path/$type_extn";
    if (@matches) {
        return \@matches;
    }
    else {
        my $alt_type = $self->alt_type;
        if( defined $alt_type ){
            my $alt_extn = my $type_extn = $self->type_extensions->{$alt_type};
            @matches = glob "$full_path/$alt_extn";
            return undef unless ( @matches );
            return \@matches;
        }
        else{
            return undef;
        }
    }
}

sub _make_lane_hash {
    my ( $self, $path, $lane_obj ) = @_;
    my $vb = $self->verbose;
	my $stats = $self->stats;
	
	my %lane_hash;
    if ($vb) {
        my $mapstat = $self->_match_mapstat($path, $lane_obj);
        %lane_hash = (
            lane   => $lane_obj,
			path   => $path,
            ref    => $self->_reference_name($mapstat),
            mapper => $self->_get_mapper($mapstat),
            date   => $self->_date_changed($mapstat),
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

sub _match_mapstat {
    my ($self, $path, $lane) = @_;

    $path =~ /(\d+)\.[ps]e/;
    my $ms_id = $1;

    my @mapstats = @{ $lane->mappings_excluding_qc };
    foreach my $ms ( @mapstats ){
        return $ms if($ms_id eq $ms->id);
    }
    return undef;
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
			my @stat_files = glob "$l/$sf";
			foreach my $st_file ( @stat_files ){
				if(-e $st_file){
					push(@stats_paths, $st_file);
				}
			}
		}
		return \@stats_paths if( @stats_paths );
	}
	return undef;
}

sub _reference_matches {
    my ( $self, $lane_ref ) = @_;
    my $given_ref = $self->reference;

    if ( $lane_ref eq $given_ref ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _mapper_matches {
    my ( $self, $lane_mapper ) = @_;
    my $given_mapper = $self->mapper;

    if ( $lane_mapper eq $given_mapper ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _date_is_later {
    my ( $self, $given_date ) = @_;
    my $earliest_date = $self->date;

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
    my ( $self, $mapstat ) = @_;

  return 'NA' if(!defined($mapstat));
	my $assembly_obj = $mapstat->assembly;
	
	if(defined $assembly_obj){
		return $assembly_obj->name;
	}
	else{
		return 'NA';
	}
}

sub _get_mapper {
    my ( $self, $mapstat ) = @_;
return 'NA' if(!defined($mapstat));
	my $mapper_obj = $mapstat->mapper;
	if( defined $mapper_obj ){
    	return $mapper_obj->name;
	}
	else{
		return 'NA';
	}
}

sub _date_changed {
    my ( $self, $mapstat ) = @_;
    return '01-01-1900' if(!defined($mapstat));
    my $msch = $mapstat->changed;
    my ( $date, $time ) = split( /\s+/, $msch );
    my @date_elements = split( '-', $date );
    return join( '-', reverse @date_elements );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Path::Find::Filter - Logic to filter lanes based on given criteria

=head1 VERSION

version 1.140790

=head1 SYNOPSIS

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

=head1 METHODS

=head2 filter

Returns a list of full paths to lanes that match the given criteria

=head1 AUTHOR

Carla Cummins <cc21@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
