=begin nd

Topic: Name
Path::Find::Log.pm

Topic: Synopsis
use Path::Find::Log;
eval{ Path::Find::Log->new(logfile => 'my_log_file')->commandline; };

Topic: Description
A very simple logger. Output is in tab-delimited format which is 
human-readable, easy to parse and can be imported directly into a 
spreadsheet.

A log file name must be supplied but can be set to /dev/null. The 
log file will be created it it does not exist. 

If the user does not have write permission for the log file then 
the commandline() function will return false.

Topic: Contact
pathdevg@sanger.ac.uk

Topic: Author
Craig Porter (cp7@sanger.ac.uk), Carla Cummins (cc21@sanger.ac.uk)

Topic: Creation date
April 8, 2013

Topic: Last edit
Sept 11, 2013

Topic: Copyright and License
Copyright (C) 2013 Genome Research Limited. All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
USA.

=cut


package Path::Find::Log;
use Moose;
use File::Basename;
use File::Path qw(make_path);

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
		print "ARG: $arg\n";
        my $quot_char = ($arg =~ m/'/) ? '"':"'";
        $argstring .= ($arg =~ m/\s+/) ? qq[ $quot_char$arg$quot_char]:qq[ $arg];
		print "ARGSTRING: $argstring\n";
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
