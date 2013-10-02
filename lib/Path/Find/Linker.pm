package Path::Find::Linker;

# ABSTRACT:

=head1 SYNOPSIS

Logic to create symlinks or archives for a list of lanes

   use Path::Find::Linker;
   my $obj = Path::Find::Linker->new(
     lanes => \@lanes,
     name => <symlink_destination|archive_name>,
	 use_default_type => <1|0>
   );
   
   $obj->sym_links;
   $obj->archive;

use_default_type option should be switched on when a filetype has not been
specified by the user.
   
=method create_links

Creates symlinks to each given lane in the defined destination directory

=method _check_destination

Checks whether the defined destination exists. If not, it creates the
directory.

=cut

use Moose;
use File::Temp;
use Cwd;
use Data::Dumper;

has 'lanes' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has '_dehashed_lanes' => (is => 'rw', isa => 'ArrayRef', required => 0, lazy => 0, builder => '_build__dehashed_lanes');
has '_tmp_dir' => ( is => 'rw', isa => 'Str', builder  => '_build__tmp_dir' );
has 'name'     => ( is => 'ro', isa => 'Str', required => 1 );
has '_checked_name' =>
  ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build__checked_name' );
has 'destination' =>
  ( is => 'ro', isa => 'Str', required => 0, writer => '_set_destination' );
has '_default_type' => (is => 'ro', isa => 'Str', required => 0, lazy => 1, builder => '_build__default_type');
has 'use_default_type' => (is => 'ro', isa => 'Bool', required => 1);
has '_given_destination' => (is => 'ro', isa => 'Str', required => 0, writer => '_set__given_destination');

sub _build__dehashed_lanes {
	my ($self) = @_;
	
	print "SELF:\n";
	print Dumper $self;
	
	my @dh_lanes;
	foreach my $l ( @{ $self->lanes } ){
		push(@dh_lanes, $l->{lane});
	}
	return \@dh_lanes;
}

sub _build__checked_name {
    my ($self) = @_;
    my $name = $self->name;

	# check if full path, if so, set given destination
	# if not, set given destination to CWD
	if($name =~ /^\//){
		my @dirs = split('/', $name);
		$name = pop(@dirs);
		$self->_set__given_destination(join('/', @dirs));
	}
	else{
		my $current_cwd = getcwd;
		$self->_set__given_destination($current_cwd);
	}
    $name =~ s/\s+/_/;
    return $name;
}

sub _build__tmp_dir {
    my $tmp_dir_obj = File::Temp->newdir( CLEANUP => 0 );
    return $tmp_dir_obj->dirname;
}

sub _build__default_type {
    my ($self) = @_;
    my %default_ft = (
        pathfind       => '/*.fastq.gz',
        assemblyfind   => 'contigs',
        annotationfind => '/*.gff',
        mapfind        => '/*markdup.bam',
        snpfind        => 'vcf',
        rnaseqfind     => 'spreadsheet',
        tradisfind     => '/*insertion.csv',
    );

	# capture calling script name
	$0 =~ /([^\/]+$)/;
    return $default_ft{$1};
}

sub archive {
    my ($self) = @_;

	my $c_name = $self->_checked_name;
	my $final_dest = $self->_given_destination;

    #set destination for symlinks
    my $tmp_dir = $self->_tmp_dir;
    $self->_set_destination("$tmp_dir");

    #create symlinks
    $self->_create_symlinks;

    #tar and move to CWD
    print "Archiving lanes to $final_dest/$c_name:\n";
    $self->_tar;

    File::Temp::cleanup();
}

sub sym_links {
    my ($self) = @_;
	my $s_d = $self->_checked_name;

    #set destination for symlinks
    my $dest = $self->_given_destination;
    $self->_set_destination($dest);

    #create symlinks
    $self->_create_symlinks;
	print "Symlinks created in $dest/$s_d\n";
}

sub _create_symlinks {
    my ($self)      = @_;
    my @lanes       = @{ $self->_dehashed_lanes };
    my $destination = $self->destination;
    my $name        = $self->_checked_name;

    #check destination exists and create if not
    $self->_check_dest("$destination/$name");

	#set default filetype if not already specified
	my $default_type = "";
	$default_type = $self->_default_type if($self->use_default_type);

    #create symlink
    foreach my $lane (@lanes) {
        my $cmd = "ln -s $lane$default_type $destination/$name";
        system($cmd) == 0
          or die
"Could not create symlink for $lane in $destination/$name: error code $?\n";
    }
    return 1;
}

sub _check_dest {
    my ( $self, $destination ) = @_;

    if ( !-e $destination ) {
        system("mkdir $destination") == 0
          or die "Could not create $destination: error code $?\n";
    }
    return 1;
}

sub _tar {
    my ($self)   = @_;
    my $tmp_dir  = $self->_tmp_dir;
    my $arc_name = $self->_checked_name;
	my $final_destination = $self->_given_destination;
    my $error    = 0;

    system("cd $tmp_dir; tar cvhfz archive.tar.gz $arc_name") == 0
      or $error = 1;

    if ($error) {
        print "An error occurred while creating the archive: $arc_name\n";
        print "No output written to $arc_name.tar.gz\n";
        File::Temp::cleanup();
        return 0;
    }
    else {
        system("mv $tmp_dir/archive.tar.gz $final_destination/$arc_name.tar.gz") == 0
          or die
          "An error occurred while writing archive $arc_name: error code $?\n";
        File::Temp::cleanup();
        return $error;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
