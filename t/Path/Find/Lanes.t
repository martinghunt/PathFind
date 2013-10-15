#!/usr/bin/env perl
use strict;
use warnings;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Path::Find::Lanes');
}




done_testing();