package Path::Find::Sort;

# ABSTRACT: Sort routine for multiplexed lane names

=head1 SYNOPSIS

Sort routine for multiplexed lane names (eg 1234_5#6)
Run, Lane and Tag are sorted in ascending order.
Reverts to alphabetic sort if cannot sort numerically
   
=method sort_lanes

=cut

use Moose;
use File::Basename;
use Data::Dumper;

has 'lanes' => ( is => 'rw', isa => 'ArrayRef', required => 1 );

sub sort_lanes {
    my ($self) = @_;
    my @lanes = @{ $self->lanes };

    my %lane_paths;
    foreach my $i (0..$#lanes){
        my $lane_hash = $lanes[$i];
        my $p = $lane_hash->{path};
        $lane_paths{$p} = $i;
    }

    my @sorted;
    foreach my $ln (sort lanesort keys %lane_paths){
        my $index = $lane_paths{$ln};
        push(@sorted, $lanes[$index]);
    }

    return \@sorted;
}


sub lanesort {
    my ($lane_a, $end_a) = _get_lane_name($a);
    my ($lane_b, $end_b) = _get_lane_name($b);

    my @a = split( /\_|\#/, $lane_a );
    my @b = split( /\_|\#/, $lane_b );

    for my $i ( 0 .. $#a ) {
        return ( $a cmp $b )
          if ( $a[$i] =~ /\D+/ || $b[$i] =~ /\D+/ );
    }

    $a[0] <=> $b[0] || $a[1] <=> $b[1] || $a[2] <=> $b[2] || $end_a cmp $end_b;
}

sub _get_lane_name {
    my ($path) = @_;

    my @dirs = split('/', $path);

    my $end = join('/', splice(@dirs, 15));

    return ($dirs[14], $end);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
