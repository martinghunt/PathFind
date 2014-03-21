package Path::Find::Exception;
# ABSTRACT: Exceptions for input data 



use Exception::Class (
    Path::Find::Exception::InvalidInput         => { description => 'Input arguments are invalid' },
    Path::Find::Exception::FileDoesNotExist     => { description => 'Cannot find file' },
    Path::Find::Exception::InvalidDestination   => { description => 'Cannot access the specified location' },
    Path::Find::Exception::NoMatches            => { description => 'No lanes found with matching criteria' },
    Path::Find::Exception::ConnectionFail       => { description => 'Failed to connect to database'},
    Path::Find::Exception::SymlinkFail          => { description => 'Failed to create symlinks'}
);  

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Path::Find::Exception - Exceptions for input data 

=head1 VERSION

version 1.140790

=head1 SYNOPSIS

Exceptions for input data 

=head1 AUTHOR

Carla Cummins <cc21@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
