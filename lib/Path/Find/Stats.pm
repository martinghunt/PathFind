package Path::Find::Stats;

# ABSTRACT:

=head1 SYNOPSIS


   
=method verbose_info

=cut

use Moose;
use Pathogens::Reports::Mapping::Report;

has 'lanes' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'output' => ( is => 'ro', isa => 'Str', required => 1 );
has 'vrtrack'    => ( is => 'rw', required => 1 );

sub output_csv_file {
    my ($self) = @_;
	my ( $lanes, $csv_file, $vrtrack );
	$lanes = $self->lanes;
	$csv_file = $self->output;
	$vrtrack = $self->vrtrack;
	
	# create file handle for csv file
	open(my $csv_fh, ">", $csv_file);
	
    my $report =
      Pathogens::Reports::Mapping::Report->new( vrtrack => $vrtrack, filehandle => $csv_fh, lanes => $self->lanes );
    $report->output_csv();

	close($csv_fh);
    return;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;