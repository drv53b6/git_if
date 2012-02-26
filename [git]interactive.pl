#!/usr/bin/perl
#------------------------------------------------------
=head1 NAME

=head1 SYNOPSIS

=cut
#------------------------------------------------------
use File::Copy;

    use strict;
    use fileLib;
    use git_lib;
    use git_menu;
    use git_settings;

    use vars qw($revision);

#------------------------------------------------------
# null
#------------------------------------------------------
sub null {
    my ($par)=@_;


    return $par;
}
#------------------------------------------------------
# quit_cmd
#------------------------------------------------------
sub quit_cmd {
	print "Bye.\n";
	exit(0);
}
#------------------------------------------------------
# set_ver
#------------------------------------------------------
sub set_ver {

    my @mods = git_lib::takeCommitList();

#    print dump(\@mods),"\n";

    my @update = git_menu::list_and_choose({ PROMPT => 'set_ver',
                                   HEADER => "Select version:", 
                                   IMMEDIATE => 1 
                                 },
                                 @mods);

    if (@update) {
           $revision=$update[0]->{FILE};
    }

    return;
}
#------------------------------------------------------
# diff_cmd
#------------------------------------------------------
sub diff_cmd {

    my @mods = git_lib::takeDiffList($revision,1);

    my @update = git_menu::list_and_choose({ PROMPT => 'diff',
    			       HEADER => "Select file:", 
    			       IMMEDIATE => 1 
    			       },    @mods);

    if (@update) {
        print "-----------------\n";
        my $file=$update[0]->{FILE};
        system(qw{git diff --cached}, $revision, "--", $file);
    }

    return;
}
#------------------------------------------------------
# revert_cmd
#------------------------------------------------------
sub revert_cmd {

    my @mods = git_lib::takeDiffList($revision);

    my @update = git_menu::list_and_choose({ PROMPT => 'revert',
    			       HEADER => "Select file:", 
    			       IMMEDIATE => 1 
    			       },    @mods);

    if (@update) {
        print "-----------------\n";
        my $file=$update[0]->{FILE};
        system(qw{git diff --cached}, $revision, "--", $file);

        print "revert?[y,n]\n";
        my $ans=<STDIN>;chomp($ans);

        return unless $ans eq "y";

        system(qw{git checkout}, $revision, "--", $file);
    }

    return;
}
#------------------------------------------------------
# revertSF_cmd
#------------------------------------------------------
sub revertSF_cmd {

    my @mods = git_lib::takeDiffList($revision);

    my @update = git_menu::list_and_choose({ PROMPT => 'revert',
    			       HEADER => "Select file:", 
    			       IMMEDIATE => 1 
    			       },    @mods);

    if (@update) {
        print "-----------------\n";
        my $file=$update[0]->{FILE};
        system(qw{git diff --cached}, $revision, "--", $file);

        print "revert to separate file?[y,n]\n";
        my $ans=<STDIN>;chomp($ans);

        return unless $ans eq "y";

        move($file,".git/temp");

        system(qw{git checkout}, $revision, "--", $file);


        my $comment=git_lib::getComment($revision);
        my ($v1,$v2)=git_lib::getVersion($comment);

        my $ext;
        if ($v1)
        {
           $ext=".V${v1}B${v2}";
        }
        else
        {
           $ext=".$revision";
        }

        move($file,$file.$ext);

        move(".git/temp",$file);


    }

    return;
}
#------------------------------------------------------
# commit_cmd
#------------------------------------------------------
sub commit_cmd
{
    print "comment for commit:\n";
    my $ans=<STDIN>;chomp($ans);

    git_lib::commit($ans);
    return;
}
#------------------------------------------------------
# help_cmd
#------------------------------------------------------
sub help_cmd {
	print <<EOF ;
set_ver       - select working [progect state]
diff	      - view diff between selected [progect state] and current state
revert        - revert selected file back from the selected [progect state]
SFrevert      - revert selected file to separate file
commit        - save current state as new [progect state]
help          - print this help
quit          - exit
at start [progect state] is last saved state
EOF
}
#------------------------------------------------------
# main
#------------------------------------------------------
sub main
{

#    git_lib::commit();
    $revision=git_lib::lastCommit();

    my @cmd = (
               [ 'set_ver', \&set_ver, ],
               [ 'diff', \&diff_cmd, ],
               [ 'revert', \&revert_cmd, ],
               [ 'SFrevert', \&revertSF_cmd, ],
               [ 'commit', \&commit_cmd, ],
               [ 'help', \&help_cmd, ],
               [ 'quit', \&quit_cmd, ],
   );
    while (1) {
         print "-working [progect state]:------------\n";
         system("git","show","-s",$revision);

         my ($it) = git_menu::list_and_choose({ PROMPT => 'What now',
                                      SINGLETON => 1,
                                      LIST_FLAT => 4,
                                      HEADER => '*** Commands ***',
                                      ON_EOF => \&quit_cmd,
                                      IMMEDIATE => 1 }, @cmd);
         if ($it) {
             eval {
             $it->[1]->();
             };
             if ($@) {
                 print "$@";
             }
         }
    }
}
#------------------------------------------------------
git_lib::init();
main(@ARGV);
