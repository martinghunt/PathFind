package Path::Find::Sort;

# ABSTRACT: Sort routine for multiplexed lane names


use Moose;
use File::Basename;
use Data::Dumper;

has 'lanes' => ( is => 'rw', isa => 'ArrayRef', required => 1 );

sub sort_lanes {
    my ($self) = @_;
    my @lanes = @{ $self->lanes };

    my %lane_s;
    foreach my $i (0..$#lanes){
	if(ref($lanes[$i]) eq 'HASH'){
            my $lane_hash = $lanes[$i];
            my $p = $lane_hash->{path};
            $lane_s{$p} = $i;
	}
	else{
	    my $lanename = $lanes[$i]->name;
	    $lane_s{$lanename} = $i;
	}
    }

    my @sorted;
    foreach my $ln (sort lanesort keys %lane_s){
        my $index = $lane_s{$ln};
        push(@sorted, $lanes[$index]);
    }

    return \@sorted;
}


sub lanesort {
    my ($lane_a, $end_a) = _get_lane_name($a);
    my ($lane_b, $end_b) = _get_lane_name($b);

    my @a = split( /\_|\#/, $lane_a );
    my @b = split( /\_|\#/, $lane_b );

    # check @a and @b are the same length
    my $len_a = scalar(@a);
    my $len_b = scalar(@b);
    unless($len_a == $len_b){
        if($len_a > $len_b){
            foreach my $x (1 .. ($len_a-$len_b)){
                push(@b, '0');
            }
        }
        else{
            foreach my $x (1 .. ($len_b-$len_a)){
                push(@a, '0');
            }
        }
    }

    for my $i ( 0 .. $#a ) {
        return ( $a cmp $b )
          if ( $a[$i] =~ /\D+/ || $b[$i] =~ /\D+/ );
    }
    
    if( $#a == 2 && $#b == 2 && defined $end_a && defined $end_b ){
	return $a[0] <=> $b[0] || $a[1] <=> $b[1] || $a[2] <=> $b[2] || $end_a cmp $end_b;
    }
    elsif( $#a == 2 && $#b == 2 && !defined $end_a && !defined $end_b ){
	return $a[0] <=> $b[0] || $a[1] <=> $b[1] || $a[2] <=> $b[2];
    }
    elsif( $#a == 1 && $#b == 1 && defined $end_a && defined $end_b ){
	return $a[0] <=> $b[0] || $a[1] <=> $b[1] || $end_a cmp $end_b;
    }
    else{
	return $a[0] <=> $b[0] || $a[1] <=> $b[1];
    }
}

sub _get_lane_name {
    my ($lane) = @_;

    if ($lane =~ /\//){
        my @dirs = split('/', $lane);
        my ($tracking_index) = grep { $dirs[$_] ~~ 'TRACKING' } 0 .. $#dirs;
        my $lane_index = $tracking_index + 5;
        my $end = join('/', splice(@dirs, $lane_index+1));
        return ($dirs[$lane_index], $end);
    }
    else{
        return ($lane, undef);
    }
}

sub _get_lane_name_old {
    my ($lane) = @_;

    if ($lane =~ /\//){
	my @dirs = split('/', $lane);
	my $end = join('/', splice(@dirs, 15));
	return ($dirs[14], $end);
    }
    else {
	return ($lane, undef);
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Path::Find::Sort - Sort routine for multiplexed lane names

=head1 VERSION

version 1.140790

=head1 SYNOPSIS

Sort routine for multiplexed lane names (eg 1234_5#6)
Run, Lane and Tag are sorted in ascending order.
Reverts to alphabetic sort if cannot sort numerically

=head1 METHODS

=head2 sort_lanes

=head1 AUTHOR

Carla Cummins <cc21@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
