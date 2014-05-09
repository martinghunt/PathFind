package Path::Find::Linker;

# ABSTRACT: Logic to create symlinks or archives for a list of lanes

=head1 SYNOPSIS

Logic to create symlinks or archives for a list of lanes

   use Path::Find::Linker;
   my $obj = Path::Find::Linker->new(
     lanes => \@lanes,
     name => <symlink_destination|archive_name>,
	 use_default_type => <1|0>
	 rename_links => <hash ref linking lane path (key) to desired name (value)>
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
use File::Basename;
use File::Path qw( remove_tree);
use Path::Find::Exception;

has 'lanes' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has '_tmp_dir' => ( is => 'rw', lazy => 1, builder  => '_build__tmp_dir' );
has 'name'     => ( is => 'ro', isa => 'Str', required => 1 );
has '_checked_name' =>
  ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build__checked_name' );
has 'destination' =>
  ( is => 'ro', isa => 'Str', required => 0, writer => '_set_destination' );
has '_default_type' => (
    is       => 'ro',
    isa      => 'Str',
    required => 0,
    lazy     => 1,
    builder  => '_build__default_type'
);
has 'use_default_type' =>
  ( is => 'ro', isa => 'Bool', required => 0, default => 0 );
has '_given_destination' => (
    is       => 'ro',
    isa      => 'Str',
    required => 0,
    writer   => '_set__given_destination'
);
has 'rename_links' => ( is => 'ro', isa => 'HashRef', required => 0 );
has 'script_name'  => ( is => 'ro', isa => 'Str', required => 0, default => $0 );
has 'index_files'   => ( is => 'rw', isa => 'Maybe[Str]', required => 0 );
has 'stats' => ( is => 'ro', isa => 'Maybe[Str]', required => 0 );
has 'replace_hashes' => ( is => 'ro', isa => 'Maybe[Int]', required => 0 );

sub _build__checked_name {
    my ($self) = @_;
    my $name = $self->name;

    # check if full path, if so, set given destination
    # if not, set given destination to CWD
    if ( $name =~ /^\// ) {
        my($filename, $directories, $suffix) = fileparse($name);
        Path::Find::Exception::InvalidDestination->throw( error => "$directories does not exist\n" ) unless( -e $directories );
        $self->_set__given_destination( $directories );
		$name = $filename;
    }
    else {
        my $current_cwd = getcwd;
        $self->_set__given_destination($current_cwd);
    }
    $name =~ s/\W+/_/g;
    return $name;
}

sub _build__tmp_dir {
    my $tmp_dir_obj = File::Temp->newdir( DIR => getcwd, CLEANUP => 1 );
    return $tmp_dir_obj;
}

sub _build__default_type {
    my ($self) = @_;
	my $script_name = $self->script_name;
	
    my %default_ft = (
        pathfind       => '/*.fastq.gz',
        annotationfind => '/*.gff',
        mapfind        => '/*markdup.bam',
        snpfind        => '/*.snp/mpileup.unfilt.vcf.gz',
        rnaseqfind     => '/*corrected.bam',
        tradisfind     => '/*insertion.csv',
		reffind        => '/*.fa'
    );

    #index files
    if($script_name eq 'mapfind'){
        $self->index_files('bai');
    }
    elsif($script_name eq 'snpfind'){
        $self->index_files('tbi')
    }

    # capture calling script name
    $script_name =~ /([^\/]+$)/;
    return $default_ft{$1};
}

sub archive {
    my ($self) = @_;

    my $c_name     = $self->_checked_name;
    my $final_dest = $self->_given_destination;

    #set destination for symlinks
    #my $tmp_dir = $self->_tmp_dir;
	my $tmp_dir = File::Temp->newdir( DIR => getcwd, CLEANUP => 0 );
	my $dirname = $tmp_dir->dirname;
    $self->_set_destination("$dirname");

    #create symlinks
    $self->_create_symlinks;

    #add stats
    my $stats = $self->stats;
    if(defined $stats){
        open(STATS, ">", "$dirname/$c_name/stats.csv") or Path::Find::Exception::InvalidDestination->throw( error => "Can't write statistics to archive. Error code: $?\n");
        print STATS $stats;
        close STATS;
    }

    #tar and move to CWD
    print STDERR "Archiving lanes to $final_dest/$c_name:\n";
    my $er_code = $self->_tar($dirname);

	File::Temp::cleanup();
    remove_tree($dirname);

	return $er_code;
}

sub sym_links {
    my ($self) = @_;
    my $s_d = $self->_checked_name;

    #set destination for symlinks
    my $dest = $self->_given_destination;
    $self->_set_destination($dest);

    #create symlinks
    $self->_create_symlinks;
    print STDERR "Symlinks created in $dest/$s_d\n";

	return 1;
}

sub _create_symlinks {
    my ($self) = @_;

    #my @lanes       = @{ $self->_dehashed_lanes };
    my @lanes       = @{ $self->lanes };
    my $destination = $self->destination;
    my $name        = $self->_checked_name;
    my $index_files  = $self->index_files;

    #check destination exists and create if not
    $self->_check_dest("$destination/$name");

    #set default filetype if not already specified
    my $default_type = "";
    $default_type = $self->_default_type if ( $self->use_default_type );

    #create symlink
    foreach my $lane (@lanes) {
        my $l = $lane->{path};
        my @files2link;
		if(defined $default_type){
			@files2link = $self->_link_names( $l, $default_type );
		}
		else {
			@files2link = $self->_link_names( $l, undef );
		}
        foreach my $linkf (@files2link) {
            my ( $source, $dest ) = @{$linkf};
            my $cmd = "ln -sf $source $dest";
            system($cmd) == 0 or Path::Find::Exception::SymlinkFail->throw( error => "Could not create symlink for $lane in $destination/$name: error code $?\n");
            if( defined $index_files && -e "$source.$index_files" ){
                $cmd = "ln -sf $source.$index_files $dest.$index_files";
                system($cmd) == 0 or Path::Find::Exception::SymlinkFail->throw( error => "Could not create symlink for $lane in $destination/$name: error code $?\n");
            }
        }
    }
    return 1;
}

sub _check_dest {
    my ( $self, $destination ) = @_;

    if ( !-e $destination ) {
        system("mkdir $destination") == 0
          or Path::Find::Exception::InvalidDestination->( error => "Could not create $destination: error code $? , $!\n");
    }
    return 1;
}

sub _link_names {
    my ( $self, $lane, $dt ) = @_;
    my $destination = $self->destination;
    my $name        = $self->_checked_name;
    my $linknames   = $self->rename_links;

    my @files2link;
	my @matching_files;
    if ( $dt ) {
        @matching_files = `ls $lane$dt`;
    }
	else{
		@matching_files = ($lane);
	}

    foreach my $mf (@matching_files) {
        chomp $mf;
        my $lf;
        if( $linknames ){
            $lf = $linknames->{$mf};
        }
        else{
            $mf =~ /([^\/]+)$/;
            $lf = $1;
        }
        
        $lf =~ s/[^\w\.]+/_/g if($self->replace_hashes);
        
        push( @files2link, [ $mf, "$destination/$name/$lf" ] );
    }
    
    return @files2link;
}

sub _tar {
    my ($self, $tmp_dir)  = @_;
    my $arc_name          = $self->_checked_name;
    my $final_destination = $self->_given_destination;
    my $error             = 0;

    system("cd $tmp_dir; tar cvhfz archive.tar.gz $arc_name > /dev/null >&2") == 0 or $error = 1;

    if ($error) {
        print STDERR "An error occurred while creating the archive: $arc_name: error code $?, $!\n";
        print STDERR "No output written to $arc_name.tar.gz\n";
        return 0;
    }
    else {
	my $mv_error = 0;
        system("mv $tmp_dir/archive.tar.gz $final_destination/$arc_name.tar.gz") == 0 or $mv_error = 1;
        if($mv_error){
        	print STDERR "An error occurred while writing archive $arc_name: error code $?\n";
			return $mv_error;
		}
        return 1;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
