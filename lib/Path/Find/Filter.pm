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

sub _build_hierarchy_template {
    my ($self) = @_;

    return Path::Find->hierarchy_template;
}

sub filter {
    my ($self)   = @_;
    my $filetype = $self->filetype;
    my @lanes    = @{ $self->lanes };
    my $qc       = $self->qc;

    my $type_extn = $self->type_extensions->{$filetype} if ($filetype);

    my @matching_paths;
    foreach (@lanes) {
        my $l = $_;
        if ( !$qc || ( $qc && $qc eq $l->qc_status() ) ) {
            my @paths = $self->_get_full_path($l);

            foreach my $full_path (@paths) {
                if ($filetype) {
                    next
                      unless my $matching_files =
                      $self->find_files( $full_path, $type_extn );
                    for my $m ( @{$matching_files} ) {
                        chomp $m;
                        if ( -e "$full_path/$m" ) {
                            $self->_set_found(1);
                            push( @matching_paths, "$full_path/$m" );
                        }
                    }
                }
                else {
                    if ( -e $full_path ) {
                        $self->_set_found(1);
                        push( @matching_paths, $full_path );
                    }
                }
            }
        }
    }

    return @matching_paths;
}

sub find_files {
    my ( $self, $full_path, $type_extn ) = @_;

    if ( -e $full_path ) {
        my @matches = `ls $full_path | grep $type_extn`;
        return \@matches;
    }
    else {
        return undef;
    }
}

sub lane_objects{
	my ($self, $ml) = @_;
	my @matching_lanes = @{ $ml };
	
	print "\@MATCHING_LANES:\n";
	print Dumper \@matching_lanes;
	
	my @lane_objects = @{ $self->lanes };
	
	my @matching_objects;
	foreach my $o (@lane_objects){
		my $o_path = $self->_get_full_path($o);
		foreach my $m_path (@matching_lanes){
			if($m_path =~ /$o_path/){
				print "$o_path is in $m_path\n";
				push(@matching_objects, $o);
			}
		}
	}
	return \@matching_objects;
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

no Moose;
__PACKAGE__->meta->make_immutable;
1;
