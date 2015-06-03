# ABSTRACT: The progress of a lane as it goes through the pipelines

=head1 NAME

Path::Find::LaneStatus

=head1 SYNOPSIS

	use Path::Find::LaneStatus;
	my $obj = Path::Find::LaneStatus->new(lane => $vlane, path => '/path/to/dir');
	$obj->imported
	> Done
	$obj->qc
	> Failed
  
The progress of a lane as it goes through the pipelines

=head1 CONTACT

pathdevg@sanger.ac.uk

=cut

package Path::Find::LaneStatus;
use lib "/software/pathogen/internal/pathdev/vr-codebase/modules";

use Moose;
use VRTrack::Lane;
use VRTrack::Core_obj;
use Path::Find::LaneJobStatusFiles;

has 'lane' => ( is => 'ro', isa => 'VRTrack::Lane', required => 1 );
has 'path' => ( is => 'ro', isa => 'Str', required => 1 );

has '_pipeline_names_to_flags' => ( is => 'rw', isa => 'HashRef', builder => '_build__pipeline_names_to_flags', lazy => 1 );

has '_lane_job_status_files'   => ( is => 'rw', isa => 'Path::Find::LaneJobStatusFiles', builder => '_build__lane_job_status_files', lazy => 1 );

has 'imported'           => ( is => 'rw', isa => 'Str', builder => '_build_imported',             lazy => 1 );
has 'qc'                 => ( is => 'rw', isa => 'Str', builder => '_build_qc',                 lazy => 1 );
has 'mapped'             => ( is => 'rw', isa => 'Str', builder => '_build_mapped',                 lazy => 1 );
has 'stored'             => ( is => 'rw', isa => 'Str', builder => '_build_stored',             lazy => 1 );
has 'improved'           => ( is => 'rw', isa => 'Str', builder => '_build_improved',           lazy => 1 );
has 'snp_called'         => ( is => 'rw', isa => 'Str', builder => '_build_snp_called',         lazy => 1 );
has 'rna_seq_expression' => ( is => 'rw', isa => 'Str', builder => '_build_rna_seq_expression', lazy => 1 );
has 'assembled'          => ( is => 'rw', isa => 'Str', builder => '_build_assembled',          lazy => 1 );
has 'annotated'          => ( is => 'rw', isa => 'Str', builder => '_build_annotated',          lazy => 1 );

sub _build__lane_job_status_files
{
  my ($self) = @_;
	return Path::Find::LaneJobStatusFiles->new(directory => $self->path);
}

sub _build__pipeline_names_to_flags {
    my ($self) = @_;
    my %flags = VRTrack::Core_obj->allowed_processed_flags();
    return \%flags;
}

sub _check_processed_flag {
    my ( $self, $bit_flag ) = @_;
    my $bin_o = $self->lane->processed() & $bit_flag;
    if ( ($self->lane->processed() & $bit_flag) == 0 ) {
        return 0;
    }
    else {
        return 1;
    }
}

sub _get_status_of_pipeline {
    my ( $self, $pipeline_name ) = @_;
    if ( $self->_check_processed_flag( $self->_pipeline_names_to_flags()->{$pipeline_name} ) ) {
        return 'Done';
    }
    if(defined($self->_lane_job_status_files->pipeline_status) && defined($self->_lane_job_status_files->pipeline_status->{$pipeline_name}))
    {
      return ucfirst($self->_lane_job_status_files->pipeline_status->{$pipeline_name}->current_status).' ('.$self->_lane_job_status_files->pipeline_status->{$pipeline_name}->time_stamp.')';
    }
    return '-';
}

sub _build_imported {
    my ($self) = @_;
    return $self->_get_status_of_pipeline('import');
}

sub _build_qc {
    my ($self) = @_;
    return $self->_get_status_of_pipeline('qc');
}

sub _build_mapped {
    my ($self) = @_;
    return $self->_get_status_of_pipeline('mapped');
}

sub _build_stored {
    my ($self) = @_;
    return $self->_get_status_of_pipeline('stored');
}

sub _build_improved {
    my ($self) = @_;
    return $self->_get_status_of_pipeline('improved');
}

sub _build_snp_called {
    my ($self) = @_;
    return $self->_get_status_of_pipeline('snp_called');
}

sub _build_rna_seq_expression {
    my ($self) = @_;
    return $self->_get_status_of_pipeline('rna_seq_expression');
}

sub _build_assembled {
    my ($self) = @_;
    return $self->_get_status_of_pipeline('assembled');
}

sub _build_annotated {
    my ($self) = @_;
    return $self->_get_status_of_pipeline('annotated');
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
