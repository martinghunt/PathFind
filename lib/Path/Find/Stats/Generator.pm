package Path::Find::Stats::Generator;

# ABSTRACT:

=head1 SYNOPSIS


   
=method 

=cut

use Moose;
use Pathogens::Reports::Mapping::Report;

has 'lanes'  => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'output' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'vrtrack' => ( is => 'rw', required => 1 );

sub pathfind {
    my ($self) = @_;
    my @lanes = @{ $self->lanes };

    # set up headers and info to retrieve for each row
    my @headers = (
        'Study ID',
        'Sample',
        'Lane Name',
        'Cycles',
        'Reads',
        'Bases',
        'Map Type',
        'Reference',
        'Reference Size',
        'Mapper',
        'Mapstats ID',
        'Mapped %',
        'Paired %',
        'Mean Insert Size',
        'Depth of Coverage',
        'Depth of Coverage sd',
        'Adapter %',
        'Transposon %',
        'Genome Covered',
        ' Duplication Rate',
        'Error Rate',
        'NPG QC',
        'Manual QC'
    );

    my @columns = (
        'study_id',          'sample',
        'lanename',          'cycles',
        'reads',             'bases',
        'map_type',          'reference',
        'reference_size',    'mapper',
        'mapstats_id',       'mapped_perc',
        'paired_perc',       'mean_insert_size',
        'depth_of_coverage', 'depth_of_coverage_sd',
        'adapter_perc',      'transposon_perc',
        'genome_covered',    'duplication_rate',
        'error_rate',        'npg_qc',
        'manual_qc'
    );

    # set up output file handle
    open( OUT, ">", $self->output );

    #output headers
    my $header_line = join( ",", @headers );
    print OUT "$header_line\n";

    #loop through lanes and print info to file
    my $vrtrack = $self->vrtrack;
    foreach my $l (@lanes) {
        my $mapstat = $l->qc_mappings;
        my $row     = Path::Find::Stats::Row->new(
            lane     => $l,
            mapstats => $mapstat,
            vrtrack  => $vrtrack
        );

		my @info;
        foreach my $c (@columns) {
			push(@info, $row->$c);
        }
		my $row_joined = join(',', @info);
		print OUT "$row_joined\n";
    }
}

sub mapfind {
    my ($self) = @_;

    $self->output_mapping_report;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
