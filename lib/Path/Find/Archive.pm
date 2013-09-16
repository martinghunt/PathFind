package Path::Find::Archive;

# ABSTRACT:

=head1 SYNOPSIS

Logic to archive a list of lanes

   use Path::Find::Archive;
   my $archive_obj = Path::Find::Archive->new(
       lanes        => \@matching_lanes,
       archive_name => $archive
   );
   $archive_obj->create_archive;
   
=method create_archive

Creates a tar.gz archive containing specified lanes named in accordance with
$self->archive_name.

=cut

use Moose;
use File::Temp;
use Cwd;
use Data::Dumper;

has 'lanes'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'archive_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has '_checked_name' => (is => 'rw', isa => 'Str', lazy => 1, builder => '_build__checked_name');
has '_tmp_dir' => (is => 'rw', isa => 'Str', builder => '_build__tmp_dir');

sub _build__tmp_dir {
    my $tmp_dir = File::Temp->newdir( CLEANUP => 0 );
    return $tmp_dir->dirname;
}

sub _build__checked_name {
	my ($self) = @_;
	my $name = $self->archive_name;
	
	my $checked = $name;
	$checked =~ s/\s+/_/gi;
	return $checked;
}

sub create_archive {
    my ($self) = @_;
    my @lanes = @{ $self->lanes };
	my $arc_name = $self->_checked_name;
	my $tmp_dir = $self->_tmp_dir;
	
	print "Archiving lanes:\n";
	#create symlinks in a tmp directory
	my $dest = "$tmp_dir/$arc_name";
	system("mkdir $dest");
	for my $file (@lanes){
		system("ln -s $file $dest");
	}
	
	#tar up directory and move to CWD
	$self->_tar;
}

sub _tar {
	my ($self) = @_;
	my $tmp_dir = $self->_tmp_dir;
	my $arc_name = $self->_checked_name;
	my $error = 0;
	
	my $current_cwd = getcwd;
	system("cd $tmp_dir; tar cvhfz archive.tar.gz $arc_name") == 0 or $error = 1;
	
	if($error){
		print "An error occurred while creating the archive: $arc_name\n";
		print "No output written to $arc_name.tar.gz\n";
	    File::Temp::cleanup();
		return 0;
	}
	else{
		system("mv $tmp_dir/archive.tar.gz $current_cwd/$arc_name.tar.gz") == 0 or $error = 1;
		print "An error occurred while writing archive $arc_name\n";
		File::Temp::cleanup();
		return $error;
	}
}	

no Moose;
__PACKAGE__->meta->make_immutable;
1;
