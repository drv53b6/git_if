#------------------------------------------------------
# работа с файлами
# пример:
=head1 NAME

=head1 SYNOPSIS

=cut
#------------------------------------------------------
    use strict;
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
1;
