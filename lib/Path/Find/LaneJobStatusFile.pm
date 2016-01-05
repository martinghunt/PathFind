# ABSTRACT: parse a job status file

=head1 NAME

Path::Find::LaneJobStatusFile

=head1 SYNOPSIS

	use Path::Find::LaneJobStatusFile;
	my $obj = Path::Find::LaneJobStatusFile->new(filename => 'example_job_status');
	$obj->pipeline_name;
	$obj->time_stamp;
	$obj->current_status;
  
Parse a job status file

=head1 CONTACT

pathdevg@sanger.ac.uk

=cut

package Path::Find::LaneJobStatusFile;
use Moose;
use File::Slurp;
use Time::Piece;

has 'filename'                 => ( is => 'ro', isa => 'Str', required => 1 );
has 'number_of_attempts'       => ( is => 'rw', isa => 'Maybe[Int]', required => 0 );
has 'current_status'           => ( is => 'rw', isa => 'Maybe[Str]', required => 0 );
has 'unix_time_of_last_update' => ( is => 'rw', isa => 'Maybe[Num]', required => 0 );
has 'config_file'              => ( is => 'rw', isa => 'Maybe[Str]', required => 0 );

sub BUILD {
    my ($self) = @_;
    $self->parse_job_status_file();
}

sub pipeline_name{
  my ($self) = @_;
  return undef unless defined($self->config_file);
  
  my %regex_to_processed_flag_name = (
    import             => 'import',
    mapping            => 'mapped',
    qc                 => 'qc',
    stored             => 'stored',
    rna_seq            => 'rna_seq_expression',
    snps               => 'snp_called',
    assembly           => 'assembled',
    annotate_assembly  => 'annotated'
  );
  
  for my $regex (keys %regex_to_processed_flag_name)
  {
    if( $self->config_file =~ m/$regex/)
    {
      return $regex_to_processed_flag_name{$regex};
    }
  }
  return undef;
}

sub time_stamp
{
  my ($self) = @_;
  return unless defined($self->unix_time_of_last_update);
  return localtime($self->unix_time_of_last_update)->dmy();
}

sub parse_job_status_file
{
   my ($self) = @_;
   return unless( -r $self->filename ); # The file might exist but not readable
   my @file_contents = read_file($self->filename, chomp => 1 );
   
   if(@file_contents == 4)
   {
     $self->config_file($file_contents[0]);
     $self->unix_time_of_last_update((stat($self->filename))[9]);
     $self->current_status($file_contents[2]);
     $self->number_of_attempts($file_contents[3]);
   }
   else
   {
     # Doesnt look like a job status file so do nothing
     return;
   }
   
}



__PACKAGE__->meta->make_immutable;
no Moose;
1;
