# ABSTRACT: parse a directory and extract out the info from the job status files

=head1 NAME

Path::Find::LaneJobStatusFiles

=head1 SYNOPSIS

	use Path::Find::LaneJobStatusFiles;
	my $obj = Path::Find::LaneJobStatusFiles->new(directory => '/path/to/dir');
  $obj->pipeline_status->{assembled}->current_status;
  $obj->pipeline_status->{assembled}->time_stamp;
  
Parse a job status file

=head1 CONTACT

pathdevg@sanger.ac.uk

=cut

package Path::Find::LaneJobStatusFiles;
use Moose;
use File::Slurp;
use Path::Find::LaneJobStatusFile;

has 'directory'              => ( is => 'ro', isa => 'Str',     required => 1 );
has 'job_status_file_suffix' => ( is => 'ro', isa => 'Str',     default  => '_job_status$' );
has 'pipeline_status'        => ( is => 'rw', isa => 'HashRef', default  => sub { {} } );

sub BUILD {
    my ($self) = @_;
    $self->parse_job_status_files();
}

sub parse_job_status_files {
    my ($self) = @_;
    return undef unless (-d $self->directory);
    
    my @files  = read_dir( $self->directory );
    my $regex  = $self->job_status_file_suffix;
    my @job_status_files = grep { $_ =~ /$regex/ } @files;

    for my $file (@job_status_files) {
        next unless ( -e $self->directory . '/' . $file );
        my $job_status_obj = Path::Find::LaneJobStatusFile->new( filename => $self->directory . '/' . $file );
        if ( defined( $job_status_obj->pipeline_name ) ) {
            $self->pipeline_status->{ $job_status_obj->pipeline_name } = $job_status_obj;
        }
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
