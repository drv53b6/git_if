#------------------------------------------------------
=head1 NAME

=head1 SYNOPSIS

=cut
#------------------------------------------------------
use Data::Dump qw(dump);
    use File::Copy;
    use Cwd;
    use File::Basename;
    use strict;

#------------------------------------------------------
    package fileLib;
#------------------------------------------------------
# файл как строка
#------------------------------------------------------
    sub fileToStr {
        my ($filename)=@_;

        open (file,"<$filename") or die "no file '$filename'";
        binmode file;
        my $data;
        read(file, $data, -s(file));
        close file;

        return $data;
    }
#------------------------------------------------------
#  строка в файл
#------------------------------------------------------
    sub strToFile {
        my ($filename,$str)=@_;

        open (file,">$filename") or die "cant open '$filename'";
        binmode file;
        print file $str;
        close file;

        return;
    }
#------------------------------------------------------
    package MAIN;
#------------------------------------------------------
# null
#------------------------------------------------------
sub null {
    my ($par)=@_;


    return $par;
}
#------------------------------------------------------
# subFiles
#------------------------------------------------------
sub subFiles {
    my ($list,$patt)=@_;

    my @res=();
    for my $name (@$list)
    {
        push(@res, $name) unless $name =~ m{^$patt$}i;
    }
    splice(@$list);
    push(@$list,@res);

    return;
}
#------------------------------------------------------
# addFiles
#------------------------------------------------------
sub addFiles {
    my ($list,$patt)=@_;

    for my $name (glob($patt))
    {
        push(@$list, $name);
    }

    return;
}
#------------------------------------------------------
# sysRAR
#------------------------------------------------------
sub sysRAR {
    my (@par)=@_;

    system('C:\Program Files (x86)\7-Zip\7z.exe',@par);

    return;
}

#------------------------------------------------------
# arxNameNext
#------------------------------------------------------
sub arxNameNext {
    my ($arxDir,$arxName)=@_;

    my $n=0;
    my $name;
    while (1)
    {
       $name=$arxDir."\\".$arxName.sprintf("%02i",$n).".7z";
       last unless -f($name);
       $n++;
    }


    return $name;
}

#------------------------------------------------------
# main
#------------------------------------------------------
sub main
{
    my ($flag)=@_;

    my $cwd=Cwd::getdcwd();

    my @dirs=split(m{[\\/]}, $cwd);

    my $arxName=pop(@dirs);

    my $arxDir='N:\_google_AI2011\_arx';

    my $name=arxNameNext($arxDir,$arxName."-b");

    print "$arxName=$cwd\n$name\n";

    sysRAR("a", "-r", "-x!test/*", "-xr!*.dll", "-xr!*.obj", "-xr!*.o","-xr!*.ipch", "-xr!*.sdf", "-xr!*.ncb", "-xr!*.pdb", $name, "*");

    print "$arxName=$cwd\n$name\n";


    return;
}
#------------------------------------------------------
main(@ARGV);
