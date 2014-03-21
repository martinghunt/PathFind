# ABSTRACT: A very simple logger for *find scripts



package Path::Find::Log;
use Moose;
use File::Basename;
use File::Path qw(make_path);
use Data::Dumper;

has 'logfile'      => ( is => 'ro', isa => 'Str',       required   => 1 );
has 'args'         => ( is => 'ro', isa => 'ArrayRef',  required   => 1 );
has '_username'    => ( is => 'ro', isa => 'Str',       lazy_build => 1 );
has '_progname'    => ( is => 'ro', isa => 'Str',       lazy_build => 1 );
has '_args_string' => ( is => 'ro', isa => 'Str',       lazy_build => 1 );
has '_row'         => ( is => 'ro', isa => 'ArrayRef',  lazy_build => 1 );

sub _build__username
{
    my($self) = @_;
    my $user = getpwuid( $< );
    $user = 'Unknown' unless $user;
    return $user;
}

sub _build__progname
{
    my($self) = @_;
    return $0;
}

sub _build__args_string
{
    my($self) = @_;
    my $argstring = '';

    for(@{$self->args})
    {
        my $arg = $_;
        my $quot_char = ($arg =~ m/'/) ? '"':"'";
        $argstring .= ($arg =~ m/\s+/) ? qq[ $quot_char$arg$quot_char]:qq[ $arg];
    }

    return $argstring;
}

sub _build__row
{
    my($self) = @_;

    my @timestamp = localtime(time);
    my $day  = sprintf("%04d-%02d-%02dT", $timestamp[5]+1900,$timestamp[4]+1,$timestamp[3]);
    my $hour = sprintf("%02d:%02dZ"     , $timestamp[2]     ,$timestamp[1]);
    my $user = $self->_username();
    my $prog = $self->_progname();
    my $args = $self->_args_string();

    return [$day.$hour, $user, $prog.$args];
}

sub commandline
{
    my($self) = @_;

    my $dir_mode  = 0777;
    my $file_mode = 0666;

    # create logfile
    if ( !( -e $self->logfile ) ) {
        my ( $filename, $directories, $suffix ) = fileparse( $self->logfile );
        make_path($directories, {mode => $dir_mode});
    }

    # write logfile
    open( my $fh, '+>>', $self->logfile ) or return 0;
    print $fh join("\t",@{$self->_row}),"\n";
    close($fh);
    chmod $file_mode, $self->logfile;

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Path::Find::Log - A very simple logger for *find scripts

=head1 VERSION

version 1.140790

=head1 SYNOPSIS

	use Path::Find::Log;
	eval{ Path::Find::Log->new(logfile => 'my_log_file')->commandline; };

Output is in tab-delimited format which is human-readable, easy to parse 
and can be imported directly into a spreadsheet.

A log file name must be supplied but can be set to /dev/null. The 
log file will be created it it does not exist. 

If the user does not have write permission for the log file then 
the commandline() function will return false.

=head1 NAME

Path::Find::Log

=head1 METHODS

=head1 CONTACT

pathdevg@sanger.ac.uk

=head1 AUTHOR

Carla Cummins <cc21@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
