#------------------------------------------------------
# ࠡ�� � 䠩����
# �ਬ��:
=head1 NAME

=head1 SYNOPSIS

=cut
#------------------------------------------------------
    use strict;
    package fileLib;
use Time::Local;
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
# null
#------------------------------------------------------
    sub null {
        my ($par)=@_;


        return $par;
    }
#------------------------------------------------------
# ����� �������� ᯨ᪠
#------------------------------------------------------
    sub printList {
        my ($list)=@_;

        my ($i);
        for $i (@$list)
        {   
           my ($link,$tmb)=@$i;
           print "($link,$tmb)\n";

        }

        return;
    }
#------------------------------------------------------
# �६� �� sql �ଠ� � UNIX
#------------------------------------------------------
    sub toUnix {
        my ($par)=@_;

        my ($year,$mon,$mday,$hour,$min,$sec)=
        ($par =~ /(....)-(..)-(..) (..):(..):(..)/);

        return 0+timegm($sec,$min,$hour,$mday,$mon-1,$year-1900);
    }
#------------------------------------------------------
# �६� � sql �ଠ� �� UNIX
#------------------------------------------------------
    sub toSql {
        my ($par)=@_;

        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                            gmtime($par);

        $year+=1900;
        $mon++;

        ($mon,$mday,$hour,$min,$sec)=map(substr("00".$_,-2,2),($mon,$mday,$hour,$min,$sec));

        return "$year-$mon-$mday $hour:$min:$sec";

    }
#------------------------------------------------------
# ᫮���� �ਡ����� � ��ࢮ�� 㪠��⥫� �� HASH ��ன
#------------------------------------------------------
    sub addHash {
        my ($h1,$h2)=@_;

        for my $i (keys(%$h2))
        {
#            print "$i = $$h2{$i}+$$h1{$i};\n";
            $$h1{$i} = $$h2{$i}+$$h1{$i};
        };

        return ;
    }
#------------------------------------------------------
# ������ ����� � ��ࢮ�� 㪠��⥫� �� HASH ��ன
#------------------------------------------------------
    sub subHash {
        my ($h1,$h2)=@_;

        for my $i (keys(%$h2))
        {
#            print "$i = $$h2{$i}-$$h1{$i};\n";
            $$h1{$i} = $$h1{$i}-$$h2{$i};
        };

        return ;
    }
#------------------------------------------------------
# ��ப� � HASH 
#------------------------------------------------------
    sub strToHash {
        my ($par)=@_;

        my %rez=();

        return %rez if not $par;

        for my $i (split(/;/,$par))
        {
           my ($key,$znach)=split(/=/,$i,2);
           $rez{$key}=$znach;
#           print "{$key}";
        };
#        print "*\n";

        return %rez;
    }
#------------------------------------------------------
# 㪠��⥫� �� HASH � ��ப�
#------------------------------------------------------
    sub hashToStr {
        my ($par)=@_;

        my $res="";
        for my $i (keys(%$par))
        {
           next if $$par{$i}==0;
           $res.="$i=$$par{$i};";
        };

        return $res;
    }
#------------------------------------------------------
# �����蠥� ᫥���騩 id � ⠡���
#------------------------------------------------------
    sub nextId {
        my ($db,$table)=@_;    

        my $query = "SELECT id FROM $table ORDER BY id DESC LIMIT 1";
        my $comm_dsk = $db->prepare($query);
        $comm_dsk->execute;
        my ($id) = $comm_dsk->fetchrow_array;
        $id=1+$id;

        return $id;
    }
#------------------------------------------------------
# Select to file
#------------------------------------------------------
    sub selToFile {
        my ($comm_dsk,$file)=@_;

        open (file,">$file") or die "no file '$file'";
        
        print file join("\t",@{$comm_dsk->{NAME}})."\n";
        my @res;
        while ( @res = $comm_dsk->fetchrow_array ) 
        {
           print file join("\t",@res)."\n";
        };
        
        close(file);

        return ;
    }
#------------------------------------------------------
# Select to Table
#------------------------------------------------------
    sub selToTable {
        my ($comm_dsk)=@_;

        my $res="";
        
        $res.="<tr>".join(" ",map("<td>$_</td>",@{$comm_dsk->{NAME}}))."</tr>\n";
        my @res;
        while ( @res = $comm_dsk->fetchrow_array ) 
        {
           $res.="<tr>".join(" ",map("<td>$_</td>",@res))."</tr>\n";
        };
        

        return $res;
    }
#------------------------------------------------------
# �����頥� ��⠫�� �ਯ�
#------------------------------------------------------
    sub mePath {
        $0 =~ m{[^\\/]*$};
        return $`;
    }
#------------------------------------------------------
1;
