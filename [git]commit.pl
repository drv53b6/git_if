#!/usr/bin/perl
#------------------------------------------------------
=head1 NAME

=head1 SYNOPSIS

=cut
#------------------------------------------------------
    use strict;
    use git_lib;
    use git_settings;

#------------------------------------------------------
# null
#------------------------------------------------------
sub null {
    my ($par)=@_;

    return $par;
}
#------------------------------------------------------
# main
#------------------------------------------------------
sub main
{
    my (@text)=@_;

    git_lib::commit(join(" ",@text));
    return;
}
#------------------------------------------------------
git_lib::init();
main(@ARGV);
