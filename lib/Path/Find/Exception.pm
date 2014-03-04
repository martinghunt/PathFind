package Path::Find::Exception;
# ABSTRACT: Exceptions for input data 

=head1 SYNOPSIS

Exceptions for input data 

=cut


use Exception::Class (
    Path::Find::Exception::InvalidInput         => { description => 'Input arguments are invalid' },
    Path::Find::Exception::FileDoesNotExist     => { description => 'Cannot find file' },
    Path::Find::Exception::InvalidDestination   => { description => 'Cannot access the specified location' },
    Path::Find::Exception::NoMatches            => { description => 'No lanes found with matching criteria' }

);  

1;