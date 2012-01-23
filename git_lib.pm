#------------------------------------------------------
=head1 NAME
well maked git user interface easy to use windows linux
=head1 SYNOPSIS
step 1

copy files:
    [git]commit.pl
    [git]interactive.pl
    [git]version.txt
    fileLib.pm
    git_lib.pm
    git_menu.pm
    git_settings.pm
to u progect derictory

step 2

edit file "git_settings.pm"

step 3

use 
    [git]commit.pl
    [git]interactive.pl
for save progect state
and for selective restore files from progect history

=cut
#------------------------------------------------------
    use strict;
    use fileLib;
    use git_settings;
#------------------------------------------------------
    package git_lib;

#------------------------------------------------------
# null
#------------------------------------------------------
sub null {
    my ($par)=@_;


    return $par;
}
#------------------------------------------------------
# lastCommit
#------------------------------------------------------
sub lastCommit {

    my @line=readpipe("git log --max-count 1");

    my ($_,$commit)=split(/ +/,$line[0],2);

    chomp($commit);

    return $commit;
}
#------------------------------------------------------
# getComment
#------------------------------------------------------
sub getComment {
    my ($hash)=@_;

    my @line=readpipe("git show -s $hash");

    return $line[4];
}
#------------------------------------------------------
# getVersion
#------------------------------------------------------
sub getVersion {
    my ($comment)=@_;


    my ($comment)=( $comment =~ m{\[version=(.+?)\]}m);

    my ($v1,$v2)=split(/\|/,$comment,2);


    return ($v1,$v2);
}
#------------------------------------------------------
# gitCommit
#------------------------------------------------------
sub gitCommit {
    my ($v1,$v2,$text)=@_;

    system("git", "commit", "-a", "-m", "${text}[version=$v1|$v2]");

    return;
}

#------------------------------------------------------
# takeCommitList
#------------------------------------------------------
sub takeCommitList {

    my @list=readpipe(qq[git log "--pretty=%H %s - %ar" --max-count ${git_settings::select_from_last_N_states}]);

    my @sList=();
    for my $i (@list)
    {
        chomp($i);
        my ($hash,$comment)=split(/ /,$i,2);

        my ($v1,$v2)=getVersion($comment);

        push(@sList,
        {
           BINARY => undef,
           FILE => $hash,
           INDEX => "($v1|$v2)",
           INDEX_ADDDEL => "create",
           VALUE => $comment,
        });

    }
    return @sList;
}
#------------------------------------------------------
# takeDiffList
#------------------------------------------------------
sub takeDiffList {
    my ($rev,$flagDiff)=@_;

    my @list=readpipe(qq{git diff --cached --numstat $rev});

    my @sList=();
    for my $i (@list)
    {
        chomp($i);
        my ($del,$add,$file)=split(/\s+/,$i,3);

        if ($flagDiff)
        {
           my $tmp=$del;
           $del=$add;
           $add=$tmp;
        }

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
# commit
#------------------------------------------------------
sub commit
{
    my ($text)=@_;

    my $lastC=lastCommit();
#    print "[$lastC]\n";
    my $comment=getComment($lastC);
#    print "c=$comment\n";
    my ($v1,$v2)=getVersion($comment);
#    print "v=($v1,$v2)\n";

    my $cV1=git_settings::getVersion();

#    print "cV1=$cV1\n";

    if ($cV1 eq $v1)
    {
       $v2++;
    }
    else
    {
       $v2=0;
    }

    print "v=($cV1,$v2)\n";

    gitCommit($cV1,$v2,$text);

    return;
}
#------------------------------------------------------
# init
#------------------------------------------------------
sub init {

    git_settings::setEnv();

    unless (-d(".git"))
    {
         system("git","init");
    }

    system("git", "rm", "--cached", "*");
    git_settings::controlArea();

    return;
}
#------------------------------------------------------
1;
