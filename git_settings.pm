#------------------------------------------------------
=head1 NAME

=head1 SYNOPSIS

=cut
#------------------------------------------------------
    use strict;
    use fileLib;
#------------------------------------------------------
    package git_settings;
#------------------------------------------------------
# controlArea
#------------------------------------------------------
sub controlArea {

    system("git", "add", "*.h");
    system("git", "add", "*.cc");
    system("git", "add", "*.pl");
    system("git", "add", "*.pm");
    system("git", "add", "*.txt");
    system("git", "add", "*.bat");
    system("git", "add", "README");

    return;
}
#------------------------------------------------------
# getVersion
#------------------------------------------------------
sub getVersion {

    my $ver=fileLib::fileToStr('[git]version.txt');
    chomp($ver);
    return $ver;
}
#------------------------------------------------------
# setEnv
#------------------------------------------------------
sub setEnv {

    $ENV{PATH} .= q{;F:\cygwin\usr\local\bin;F:\cygwin\bin;F:\cygwin\bin};

    return;
}

#------------------------------------------------------
1;
