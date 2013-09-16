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

sub create_links {
    my ($self) = @_;
    $self->_check_destination;
	my $lanes = @{ $self->lanes };

    #create symlink
    foreach my $lane (@lanes) {
        my $cmd = "ln -s $lane $destination";
        system($cmd);
    }

}

sub _check_destination {
    my ($self) = @_;
    my $destination = $self->sym_dest;

    if ( !-e "./$destination" ) {
		system("mkdir ./$destination");
    }
	return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
