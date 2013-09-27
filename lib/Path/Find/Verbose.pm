package Path::Find::Verbose;

# ABSTRACT:

=head1 SYNOPSIS


   
=method verbose_info

=cut

use Moose;

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
        $ref    = $self->_reference_ur($l);
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
        my $lane_ref = $self->_reference_ur($l);
        $lane_ref =~ /([^\/]+)\.gff$/;
        push( @passed_lanes, $l ) if ( $1 eq $given_ref );
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

sub _reference_ur {
    my ( $self, $bam_file ) = @_;

    open( SQ, "-|", "samtools view -H $bam_file | grep ^\@SQ" )
      or die "$bam_file could not be opened\n";
    while ( my $line = <SQ> ) {
        if ( $line =~ /UR:file:(.+)fa/ ) {
            return $1 . "gff";
        }
    }
    return undef;
}

sub _get_mapper {
    my ( $self, $bam_file ) = @_;
    my @possible_mappers =
      ( "bwa", "stampy", "smalt", "ssaha2", "bowtie2", "tophat" );

    open( PG, "-|", "samtools view -H $bam_file | grep ^\@PG" )
      or die "$bam_file could not be opened\n";
    while ( my $line = <PG> ) {
        if ( $line =~ /PP:([^\s]+)/ ) {
            return $1 if ( grep { $_ eq $1 } @possible_mappers );
        }
    }
    return undef;
}

sub _bam_date {
    my ( $self, $bam_file ) = @_;
    my $bam_date = `ls -l --time-style="+%Y-%m-%d" $bam_file | awk '{print \$6}'`;
    chomp $bam_date;
    return $bam_date;
}

sub _is_later {
    my ( $self, $given_date ) = @_;
    my $earliest_date = $self->date;

    my @e_date = split( "-", $earliest_date );
    my @g_date = split( "-", $given_date );

    for my $i ( 0 .. 3 ) {
        if ( $e_date[$i] == $g_date[$i] ) {
            next;
        }
        elsif ( $e_date[$i] < $g_date[$i] ) {
            return 1;
        }
        else {
            return 0;
        }
    }

}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
