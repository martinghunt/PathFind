package Path::Find::SymLink;

# ABSTRACT:

=head1 SYNOPSIS

Logic to create symlinks for a list of lanes in a given directory

   use Path::Find::SymLink;
   my $obj = Path::Find::SymLink->new(
     lanes => \@lanes,
     sym_dest => $symlink_destination
   );
   
   $obj->create_links;
   
=method create_links

Creates symlinks to each given lane in the defined destination directory

=method _check_destination

Checks whether the defined destination exists. If not, it creates the
directory.

=cut

use Moose;

has 'lanes'    => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'sym_dest' => ( is => 'ro', isa => 'Str',      required => 1 );
has '_checked_dest' => (is => 'rw', isa => 'Str', lazy => 1, builder => '_build__checked_dest');

sub _build__checked_dest {
    my ($self) = @_;
    my $destination = $self->sym_dest;

	my $checked = $destination;
	$checked =~ s/\s+/_/;

    if ( !-e "./$checked" ) {
		system("mkdir ./$checked");
    }
	return $checked;
}

sub create_links {
    my ($self) = @_;
	my @lanes = @{ $self->lanes };
	my $destination = $self->_checked_dest;

    #create symlink
    foreach my $lane (@lanes) {
        my $cmd = "ln -s $lane $destination";
        system($cmd);
    }

}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
