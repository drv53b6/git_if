#------------------------------------------------------
# ࠡ�� � 䠩����
# �ਬ��:
=head1 NAME

=head1 SYNOPSIS

=cut
#------------------------------------------------------
    use strict;
    package fileLib;
#------------------------------------------------------
# 䠩� ��� ��ப�
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
#  ��ப� � 䠩�
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
