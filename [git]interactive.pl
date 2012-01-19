#------------------------------------------------------
=head1 NAME

=head1 SYNOPSIS

=cut
#------------------------------------------------------
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
# takeDiffList
#------------------------------------------------------
sub takeDiffList {
    my ($rev)=@_;

    my @list=readpipe(qq{git diff --cached --numstat $rev});

    my @sList=();
    for my $i (@list)
    {
        chomp($i);
        my ($del,$add,$file)=split(/\s+/,$i,3);

        push(@sList,
        {
           BINARY => undef,
           FILE => $file,
           INDEX => "(-$del,+$add)",
           INDEX_ADDDEL => "create",
           VALUE => "",
        });

    }
    return @sList;
}
#------------------------------------------------------
# diff_cmd
#------------------------------------------------------
sub diff_cmd {

    my @mods = takeDiffList($revision);

#    print dump(\@mods),"\n";

    my @update = git_menu::list_and_choose({ PROMPT => 'diff',
    			       HEADER => "Select file:", 
    			       IMMEDIATE => 1 
    			       },
    			     @mods);

    if (@update) {
        my $file=$update[0]->{FILE};
        system(qw{git diff --cached}, $revision, "--", $file);
    }

    return;
}
#------------------------------------------------------
# revert_cmd
#------------------------------------------------------
sub revert_cmd {

    my @mods = takeDiffList($revision);

#    print dump(\@mods),"\n";

    my @update = git_menu::list_and_choose({ PROMPT => 'revert',
    			       HEADER => "Select file:", 
    			       IMMEDIATE => 1 
    			       },
    			     @mods);

    if (@update) {
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
# main
#------------------------------------------------------
sub main
{

    git_lib::commit();
    $revision=git_lib::lastCommit();

    my @cmd = (
               [ 'set_ver', \&set_ver, ],
               [ 'diff', \&diff_cmd, ],
               [ 'revert', \&revert_cmd, ],
               [ 'quit', \&quit_cmd, ],
   );
    while (1) {
         print "-----------------\n";
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
git_settings::setEnv();
main(@ARGV);
