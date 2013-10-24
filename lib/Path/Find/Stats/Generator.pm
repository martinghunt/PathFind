package Path::Find::Stats::Generator;

# ABSTRACT:

=head1 SYNOPSIS


   
=method 

=cut

use Moose;
use Pathogens::Reports::Mapping::Report;
use Path::Find::Stats::Row;

use Data::Dumper;

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
        'Duplication Rate',
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
        my $mapstat = $self->_select_mapstat( $l->qc_mappings );
        print Dumper $mapstat;
        my $row = Path::Find::Stats::Row->new(
            lane     => $l,
            mapstats => $mapstat,
            vrtrack  => $vrtrack
        );

        my @info;
        foreach my $c (@columns) {
            push( @info, $row->$c );
        }
        my $row_joined = join( ',', @info );
        print OUT "$row_joined\n";
    }
}

sub mapfind {
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
        'Genome Covered (% >= 1X)',
        'Genome Covered (% >= 5X)',
        'Genome Covered (% >= 10X)',
        'Genome Covered (% >= 50X)',
        'Genome Covered (% >= 100X)',
    );

    my @columns = (
        'study_id',            'sample',
        'lanename',            'cycles',
        'reads',               'bases',
        'map_type',            'reference',
        'reference_size',      'mapper',
        'mapstats_id',         'mapped_perc',
        'paired_perc',         'mean_insert_size',
        'depth_of_coverage',   'depth_of_coverage_sd',
        'genome_covered_1x',   'genome_covered_5x',
        'genome_covered_10x',  'genome_covered_50x',
        'genome_covered_100x'
    );

    # set up output file handle
    open( OUT, ">", $self->output );

    #output headers
    my $header_line = join( ",", @headers );
    print OUT "$header_line\n";

    #loop through lanes and print info to file
    my $vrtrack = $self->vrtrack;
    foreach my $l (@lanes) {
        my $mapstat = $self->_select_mapstat( $l->mappings_excluding_qc );
        print Dumper $mapstat;
        my $row = Path::Find::Stats::Row->new(
            lane     => $l,
            mapstats => $mapstat,
            vrtrack  => $vrtrack
        );

        my @info;
        foreach my $c (@columns) {
            push( @info, $row->$c );
        }
        my $row_joined = join( ',', @info );
        print OUT "$row_joined\n";
    }
}

sub _select_mapstat {
    my ( $self, $mapstats ) = @_;

    my @sorted_mapstats = sort { $a->row_id <=> $b->row_id } @{$mapstats};
    return pop(@sorted_mapstats);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
