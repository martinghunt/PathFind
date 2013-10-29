package Path::Find::Stats::Generator;

# ABSTRACT:

=head1 SYNOPSIS


   
=method 

=cut

use Moose;
use Pathogens::Reports::Mapping::Report;
use Path::Find::Stats::Row;

use Data::Dumper;

# lane_hashes || lanes is required
has 'lane_hashes' => ( is => 'ro', isa => 'ArrayRef', required => 0 );
has 'lanes'       => ( is => 'ro', isa => 'ArrayRef[VRTrack::Lane]', required => 0,  );

has 'output'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'vrtrack'     => ( is => 'rw', required => 1 );

sub pathfind {
    my ($self) = @_;
    my @lanes = @{ $self->lane_hashes };

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
    foreach my $l_h (@lanes) {
		my $l = $l_h->{lane};
        my $mapstat = $self->_select_mapstat( $l->qc_mappings );
        my $row     = Path::Find::Stats::Row->new(
            lane     => $l,
            mapstats => $mapstat,
            vrtrack  => $vrtrack
        );

        my @info;
        foreach my $c (@columns) {
            my $i = defined( $row->$c ) ? $row->$c : "NA";
            push( @info, $i );
        }
        my $row_joined = join( ',', @info );
        print OUT "$row_joined\n";
    }
}

sub mapfind {
    my ($self) = @_;
    my @lanes = @{ $self->lane_hashes };

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
        'study_id',           'sample',
        'lanename',           'cycles',
        'reads',              'bases',
        'map_type',           'reference',
        'reference_size',     'mapper',
        'mapstats_id',        'mapped_perc',
        'paired_perc',        'mean_insert_size',
        'depth_of_coverage',  'depth_of_coverage_sd',
        'genome_covered_1x',  'genome_covered_5x',
        'genome_covered_10x', 'genome_covered_50x',
        'genome_covered_100x'
    );

    # set up output file handle
    open( OUT, ">", $self->output );

    #output headers
    my $header_line = join( ",", @headers );
    print OUT "$header_line\n";

    #loop through lanes and print info to file
    my $vrtrack = $self->vrtrack;
    foreach my $l_h (@lanes) {
		my $l = $l_h->{lane};
        my $mapstat = $self->_select_mapstat( $l->mappings_excluding_qc );
        my $row     = Path::Find::Stats::Row->new(
            lane     => $l,
            mapstats => $mapstat,
            vrtrack  => $vrtrack
        );

        my @info;
        foreach my $c (@columns) {
            my $i = defined( $row->$c ) ? $row->$c : "NA";
            push( @info, $i );
        }
        my $row_joined = join( ',', @info );
        print OUT "$row_joined\n";
    }
}

sub assemblyfind {
    my ($self) = @_;
	my @lanes = @{ $self->lane_hashes };

    my @headers = (
        'Lane',
        'Assembly Type',
        'Total Length',
        'No Contigs',
        'Avg Contig Length',
        'Largest Contig',
        'N50',
        'Contigs in N50',
        'N60',
        'Contigs in N60',
        'N70',
        'Contigs in N70',
        'N80',
        'Contigs in N80',
        'N90',
        'Contigs in N90',
        'N100',
        'Contigs in N100',
        'No scaffolded bases (N)',
        'Total Raw Reads',
        'Reads Mapped',
        'Reads Unmapped',
        'Reads Paired',
        'Reads Unpaired',
        'Total Raw Bases',
        'Total Bases Mapped',
        'Total Bases Mapped (Cigar)',
        'Average Read Length',
        'Maximum Read Length',
        'Average Quality',
        'Insert Size Average',
        'Insert Size Std Dev'
    );
    my @columns = (
		'lanename',				 'assembly_type',
        'total_length',          'num_contigs',
        'average_contig_length', 'largest_contig',
        'n50',                   'n50_n',
        'n60',                   'n60_n',
        'n70',                   'n70_n',
        'n80',                   'n80_n',
        'n90',                   'n90_n',
        'n100',                  'n100_n',
        'n_count',               'sequences',
        'reads_mapped',          'reads_unmapped',
        'reads_paired',          'reads_unpaired',
        'raw_bases',             'bases_mapped',
        'bases_mapped_cigar',    'avg_length',
        'max_length',            'avg_qual',
        'avg_insert_size',       'sd_insert_size'
    );

    # set up output file handle
    open( OUT, ">", $self->output );

    #output headers
    my $header_line = join( "\t", @headers );
    print OUT "$header_line\n";

    #loop through lanes and print info to file
    my $vrtrack = $self->vrtrack;
    foreach my $l_h (@lanes) {
		my $l = $l_h->{lane};
        my $mapstat = $self->_select_mapstat( $l->mappings_excluding_qc );
		my ($stats_file, $bamcheck_file) = @{ $l_h->{stats} };
		die "Stats file not found at $stats_file" unless(-e $stats_file);
        my $row     = Path::Find::Stats::Row->new(
            lane          => $l,
            mapstats      => $mapstat,
            vrtrack       => $vrtrack,
			stats_file    => $stats_file,
			bamcheck      => $bamcheck_file
        );

        my @info;
        foreach my $c (@columns) {
            my $i = defined( $row->$c ) ? $row->$c : "NA";
            push( @info, $i );
        }
        my $row_joined = join( "\t", @info );
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
