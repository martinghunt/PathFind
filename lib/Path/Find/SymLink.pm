#check symlink destination
if ($symlink) {
    $destination = defined($output) ? $output : getcwd;
    if ( !-e $destination ) {
        print
"The directory $destination does not exist, please specify a valid destination output directory for the symlinks";
        exit;
    }
}

#create symlink
if ($symlink) {
    my $cmd = qq[ ln -s $full_path $destination ];
    qx( $cmd );
}

