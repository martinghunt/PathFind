package Path::Find::Verbose;

# ABSTRACT:

=head1 SYNOPSIS


   
=method verbose_info

=cut

use Moose;
use Data::Dumper;

has 'lanes' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'reference' => ( is => 'ro', required => 0 );
has 'mapper'    => ( is => 'rw', required => 0 );
has 'date'      => ( is => 'ro', required => 0 );
has 'found' =>
  ( is => 'rw', required => 0, default => 0, writer => '_set_found' );

sub get_verbose_info {
    my ($self) = @_;
    my ( $ref, $mapper, $date );

    my @lanes = @{ $self->lanes };
    my @vb;
    foreach my $l (@lanes) {
        $ref    = $self->_reference_name($l);
        $mapper = $self->_get_mapper($l);
        $date   = $self->_bam_date($l);

        push( @vb, "$l\t$ref\t$mapper\t$date" );
    }
    $self->_set_found(1) if ( \@vb );
    return \@vb;
}

sub filter_on_reference {
    my ($self)    = @_;
    my @lanes     = @{ $self->lanes };
    my $given_ref = $self->reference;

    my @passed_lanes;
    foreach my $l (@lanes) {
        my $lane_ref = $self->_reference_name($l);
        push( @passed_lanes, $l ) if ( $lane_ref eq $given_ref );
    }
    return \@passed_lanes;
}

sub filter_on_mapper {
    my ($self)       = @_;
    my @lanes        = @{ $self->lanes };
    my $given_mapper = $self->mapper;

    my @passed_lanes;
    foreach my $l (@lanes) {
        my $lane_mapper = $self->_get_mapper($l);
        push( @passed_lanes, $l ) if ( $lane_mapper eq $given_mapper );
    }
    return \@passed_lanes;
}

sub filter_on_date {
    my ($self)        = @_;
    my @lanes         = @{ $self->lanes };
    my $earliest_date = $self->date;

    my @passed_lanes;
    foreach my $l (@lanes) {
        my $bam_date = $self->_bam_date($l);
        push( @passed_lanes, $l ) if ( $self->_is_later($bam_date) );
    }
    return \@passed_lanes;
}

sub _reference_name {
	my ($self, $lane) = @_;
	
	my @mapstats = @{ $lane->mappings_excluding_qc };
	return $mapstats[0]->assembly->name;
}

sub _get_mapper {
	my ($self, $lane) = @_;
	
	my @mapstats = @{ $lane->mappings_excluding_qc };
	return $mapstats[0]->mapper->name;
}

sub _bam_date {
	my ($self, $lane) = @_;
	
	my ($date, $time) = split(//, $lane->changed);
	my @date_elements = split('-', $date);
	return join('-', reverse @date_elements);
}

sub _is_later {
    my ( $self, $given_date ) = @_;
    my $earliest_date = $self->date;

    my ( $e_dy, $e_mn, $e_yr ) = split( "-", $earliest_date );
    my ( $g_dy, $g_mn, $g_yr ) = split( "-", $given_date );

    my $later = 0;

    $later = 1
      if ( ($e_yr < $g_yr)
        || ( $e_yr == $g_yr && $e_mn < $g_mn )
        || ( $e_yr == $g_yr && $e_mn == $g_mn && $e_dy < $g_dy ) );

    return $later;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
