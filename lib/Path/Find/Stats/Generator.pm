package Path::Find::Stats::Generator;

# ABSTRACT: Generate correct stats for *find scripts

=head1 NAME

Path::Find::Stats::Generator

=head1 SYNOPSIS

	use Path::Find::Stats::Generator;
	use Path::Find;
	
	my @db_info = Path::Find->get_db_info($database);
	my $vrtrack = shift(@db_info);
	
	my $gen = Path::Find::Stats::Generator->new(
		lane_hashes => \@lanes
		output      => 'stats_file.csv',
		vrtrack     => $vrtrack
	);

	$gen->pathfind;
	$gen->mapfind;
   
=head1 CONTACT

path-help@sanger.ac.uk

=head1 METHODS

=cut

use Moose;
use Pathogens::Reports::Mapping::Report;
use Path::Find::Stats::Row;
use Path::Find::Exception;

# lane_hashes || lanes is required
has 'lane_hashes' => ( is => 'ro', isa => 'ArrayRef', required => 0 );
has 'lanes' => ( is => 'ro', isa => 'ArrayRef[VRTrack::Lane]', required => 0, );

#has 'output' => ( is => 'ro', isa => 'Str', required => 1 );
has 'vrtrack' => ( is => 'rw', required => 1 );

#has '_out_filehandle' => (is => 'rw', required => 0, lazy_build => 1);

# sub _build__out_filehandle {
#     my ($self) = @_;
#     my $outfile = $self->output;
#     open(my $fh, ">", $outfile) or Path::Find::Exception::InvalidDestination->throw( error => "Can't open $outfile to write statistics. Error code: $?\n");
#     return $fh;
# }

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

    my @complete_stats;

    #output headers
    my $header_line = join( "\t", @headers );
    push( @complete_stats, $header_line );

    #loop through lanes and print info to file
	my @all_stats;
    my $vrtrack = $self->vrtrack;
    foreach my $l_h (@lanes) {
        my $l       = $l_h->{lane};
        my @mapstat = @{$self->_select_mapstats( $l->qc_mappings, $l_h )};
        foreach my $m (@mapstat){
            my $row     = Path::Find::Stats::Row->new(
                lane     => $l,
                mapstats => $m,
                vrtrack  => $vrtrack
            );

            my @info;
            foreach my $c (@columns) {
                my $i = defined( $row->$c ) ? $row->$c : "NA";
                push( @info, $i );
            }
            my $row_joined = join( "\t", @info );
            push(@all_stats, $row_joined);
        }
    }
	my @uniq_stats = $self->remove_dups(\@all_stats);
    push(@complete_stats, @uniq_stats);
    return join( "\n", @complete_stats );
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

    my @complete_stats;

    #output headers
    my $header_line = join( "\t", @headers );
    push( @complete_stats, $header_line );

    #loop through lanes and print info to file
	my @all_stats;
    my $vrtrack = $self->vrtrack;
    foreach my $l_h (@lanes) {
        my $l       = $l_h->{lane};
        my @mapstats = @{ $self->_select_mapstats( $l->mappings_excluding_qc, $l_h ) };
        foreach my $m (@mapstats){
            my $row     = Path::Find::Stats::Row->new(
                lane     => $l,
                mapstats => $m,
                vrtrack  => $vrtrack
            );

            my @info;
            foreach my $c (@columns) {
                my $i = defined( $row->$c ) ? $row->$c : "NA";
                push( @info, $i );
            }
            my $row_joined = join( "\t", @info );
            push(@all_stats, $row_joined);
        }
    }
    my @uniq_stats = $self->remove_dups(\@all_stats);
    push(@complete_stats, @uniq_stats);
    return join( "\n", @complete_stats);
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
        'lanename',              'assembly_type',
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

    my @complete_stats;

    #output headers
    my $header_line = join( "\t", @headers );
    push( @complete_stats, $header_line );

    #loop through lanes and print info to file
    my @all_stats;
    my $vrtrack = $self->vrtrack;
    foreach my $l_h (@lanes) {
        my $l       = $l_h->{lane};
        my ( $stats_file, $bamcheck_file ) = @{ $l_h->{stats} };
        Path::Find::Exception::FileDoesNotExist->throw( error => "Stats file not found at $stats_file") unless ( -e $stats_file );
        my $row = Path::Find::Stats::Row->new(
            lane       => $l,
            mapstats   => undef,
            vrtrack    => $vrtrack,
            stats_file => $stats_file,
            bamcheck   => $bamcheck_file
        );

        my @info;
        foreach my $c (@columns) {
            my $i = defined( $row->$c ) ? $row->$c : "NA";
            push( @info, $i );
        }
        my $row_joined = join( "\t", @info );
        push(@all_stats, $row_joined);
    }
    my @uniq_stats = $self->remove_dups(\@all_stats);
    push(@complete_stats, @uniq_stats);
    return join( "\n", @complete_stats );
}

sub rnaseqfind {
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
        'Genome Covered (% >= 100X)'
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

    my @complete_stats;

    #output headers
    my $header_line = join( "\t", @headers );
    push( @complete_stats, $header_line );

    #loop through lanes and print info to file
    my @all_stats;
    my $vrtrack = $self->vrtrack;
    foreach my $l_h (@lanes) {
        my $l = $l_h->{lane};

        my @mapstats = @{ $self->_select_mapstats( $l->mappings_excluding_qc, $l_h ) };
        foreach my $ms ( @mapstats ){
            my $row = Path::Find::Stats::Row->new(
                lane       => $l,
                mapstats   => $ms,
                vrtrack    => $vrtrack
            );

            my @info;
            foreach my $c (@columns) {
                my $i = defined( $row->$c ) ? $row->$c : "NA";
                push( @info, $i );
            }
            my $row_joined = join( "\t", @info );
            push(@all_stats, $row_joined);
        }
    }
	my @uniq_stats = $self->remove_dups(\@all_stats);
    push(@complete_stats, @uniq_stats);
    return join( "\n", @complete_stats );
}

sub annotationfind {
    my ($self) = @_;
    my @lanes = @{ $self->lane_hashes };

    # set up headers and info to retrieve for each row
    my @headers = (
        'Study ID',
        'Lane Name',
        'Reads',
        'Reference',
        'Reference Size',
        'Mapped %',
        'Depth of Coverage',
        'Adapter %',
        'Total Length',
        'No Contigs',
        'N50',
        'Reads Mapped',
        'Average Quality',
        'No. genes',
        'No. CDS genes'
    );

    my @columns = (
        'study_id',          'lanename',
        'reads',             'reference',
        'reference_size',    'mapped_perc',
        'depth_of_coverage', 'adapter_perc',
        'total_length',      'num_contigs',
        'n50',               'reads_mapped',
        'avg_qual',          'gene_n',
        'cds_n'
    );

    my @complete_stats;

    #output headers
    my $header_line = join( "\t", @headers );
    push( @complete_stats, $header_line );

    #loop through lanes and print info to file
	my @all_stats;
    my $vrtrack = $self->vrtrack;
    foreach my $l_h (@lanes) {
        my $l       = $l_h->{lane};
        my @mapstats = @{ $self->_select_mapstats( $l->qc_mappings, $l_h ) };
		my ( $stats_file, $bamcheck_file, $gff_file ) = @{ $l_h->{stats} };
        foreach my $ms ( @mapstats ){
            my $row = Path::Find::Stats::Row->new(
                lane       => $l,
                mapstats   => $ms,
                vrtrack    => $vrtrack,
                stats_file => $stats_file,
                bamcheck   => $bamcheck_file,
		  	    gff_file   => $gff_file
            );

            my @info;
            foreach my $c (@columns) {
                my $i = defined( $row->$c ) ? $row->$c : "NA";
                push( @info, $i );
            }
            my $row_joined = join( "\t", @info );
            push(@all_stats, $row_joined);
        }
    }
    my @uniq_stats = $self->remove_dups(\@all_stats);
    push(@complete_stats, @uniq_stats);
    return join( "\n", @complete_stats );
}

sub _select_mapstats {
    my ($self, $maps, $lane) = @_;
    my @mappings = @{ $maps };

    # get ms_id from path
    my $path = $lane->{path};
    my $ms_id = $lane->{mapstat_id};

    
    unless (defined $ms_id){
        return [undef] unless( @mappings );
        return \@mappings;
    }

    foreach my $ms ( @mappings ){
        return [$ms] if( $ms->id eq $ms_id );
    }
}

sub remove_dups {
	my ($self, $st) = @_;
	my @stats = @{ $st };
	my %sh;
	foreach my $line (@stats){
		$sh{$line} = 1;
	}

    my @uniq;
    foreach my $s (@stats){
        if($sh{$s} == 1){
            push(@uniq, $s);
            $sh{$s} = 0;
        }
    }
    return @uniq;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
