package Path::Find::Filter;

# ABSTRACT:

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
use Path::Find;

has 'lanes' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'hierarchy_template' =>
  ( is => 'rw', required => 0, builder => '_build_hierarchy_template' );
has 'filetype' => ( is => 'ro', required => 1 );
has '_file_extensions' => (
    is       => 'rw',
    isa      => 'HashRef',
    required => 0,
    builder  => '_build__file_extensions'
);
has 'qc' => ( is => 'ro', isa => 'Str', required => 1 );
has 'root' => ( is => 'ro', required => 1 );
has 'found' =>
  ( is => 'rw', required => 0, default => 0, writer => '_set_found' );
has 'pathtrack' => ( is => 'ro', required => 1 );

sub _build_hierarchy_template {
    my ($self) = @_;

    return Path::Find->hierarchy_template;
}

sub _build__file_extensions {
    my ($self) = @_;

    my %exts = (
        fastq     => '\.fastq$',
        bam       => '\.bam$',
        gff       => '\.gff$',
        faa       => '\.faa$',
        ffn       => '\.ffn$',
        contigs   => 'contigs\.fa$',
        scaffolds => '\_scaffolded.fa$'
    );
    return \%exts;
}

sub filter {
    my ($self)   = @_;
    my $filetype = $self->filetype;
    my @lanes    = @{ $self->lanes };
    my $qc       = $self->qc;

	my $type_extn = $self->_file_extensions->{$filetype};

    my @matching_lanes;
    foreach (@lanes) {
        my $l = $_;
        if ( !$qc || ( $qc && $qc eq $l->qc_status() ) ) {
            my $full_path = $self->_get_full_path($l);

            if ($filetype) {
				my @matches = `ls $full_path | grep $type_extn`;
				for my $m (@matches){
					chomp $m;
					if( -e "$full_path/$m"){
						$self->_set_found(1);
						push(@matching_lanes, "$full_path/$m");
					}
				}
            }
			else{
				if(-e $full_path){
					$self->_set_found(1);
					push(@matching_lanes, $full_path);
				}
			}
        }
    }
	return @matching_lanes;
}

sub _get_full_path {
    my ( $self, $lane ) = @_;
    my $hierarchy_template = $self->hierarchy_template;
    my $root               = $self->root;
    my $pathtrack          = $self->pathtrack;

    my $lane_path =
      $pathtrack->hierarchy_path_of_lane( $lane, $hierarchy_template );
    return "$root/$lane_path";
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
