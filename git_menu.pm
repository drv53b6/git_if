#------------------------------------------------------
=head1 NAME

=head1 SYNOPSIS

=cut
#------------------------------------------------------
    use strict;
#------------------------------------------------------
    package git_menu;

#------------------------------------------------------
# null
#------------------------------------------------------
sub null {
    my ($par)=@_;


    return $par;
}
#------------------------------------------------------
# find_unique
#------------------------------------------------------
sub find_unique {
	my ($string, @stuff) = @_;
	my $found = undef;
	for (my $i = 0; $i < @stuff; $i++) {
		my $it = $stuff[$i];
		my $hit = undef;
		if (ref $it) {
			if ((ref $it) eq 'ARRAY') {
				$it = $it->[0];
			}
			else {
				$it = $it->{VALUE};
			}
		}
		eval {
			if ($it =~ /^$string/) {
				$hit = 1;
			};
		};
		if (defined $hit && defined $found) {
			return undef;
		}
		if ($hit) {
			$found = $i + 1;
		}
	}
	return $found;
}
#------------------------------------------------------
# filters out prefixes which have special meaning to list_and_choose()
#------------------------------------------------------
sub is_valid_prefix {
	my $prefix = shift;
	return (defined $prefix) &&
	    !($prefix =~ /[\s,]/) && # separators
	    !($prefix =~ /^-/) &&    # deselection
	    !($prefix =~ /^\d+/) &&  # selection
	    ($prefix ne '*') &&      # "all" wildcard
	    ($prefix ne '?');        # prompt help
}

#------------------------------------------------------
# given a prefix/remainder tuple return a string with the prefix highlighted
# for now use square brackets; later might use ANSI colors (underline, bold)
#------------------------------------------------------
sub highlight_prefix {
	my $prefix = shift;
	my $remainder = shift;

	if (!defined $prefix) {
		return $remainder;
	}

	if (!is_valid_prefix($prefix)) {
		return "$prefix$remainder";
	}

	return "[$prefix]$remainder";
}
#------------------------------------------------------
# inserts string into trie and updates count for each character
#------------------------------------------------------
sub update_trie {
	my ($trie, $string) = @_;
	foreach (split //, $string) {
		$trie = $trie->{$_} ||= {COUNT => 0};
		$trie->{COUNT}++;
	}
}
#------------------------------------------------------
# returns an array of tuples (prefix, remainder)
#------------------------------------------------------
sub find_unique_prefixes {
	my @stuff = @_;
	my @return = ();

	# any single prefix exceeding the soft limit is omitted
	# if any prefix exceeds the hard limit all are omitted
	# 0 indicates no limit
	my $soft_limit = 0;
	my $hard_limit = 3;

	# build a trie modelling all possible options
	my %trie;
	foreach my $print (@stuff) {
		if ((ref $print) eq 'ARRAY') {
			$print = $print->[0];
		}
		elsif ((ref $print) eq 'HASH') {
			$print = $print->{VALUE};
		}
		update_trie(\%trie, $print);
		push @return, $print;
	}

	# use the trie to find the unique prefixes
	for (my $i = 0; $i < @return; $i++) {
		my $ret = $return[$i];
		my @letters = split //, $ret;
		my %search = %trie;
		my ($prefix, $remainder);
		my $j;
		for ($j = 0; $j < @letters; $j++) {
			my $letter = $letters[$j];
			if ($search{$letter}{COUNT} == 1) {
				$prefix = substr $ret, 0, $j + 1;
				$remainder = substr $ret, $j + 1;
				last;
			}
			else {
				my $prefix = substr $ret, 0, $j;
				return ()
				    if ($hard_limit && $j + 1 > $hard_limit);
			}
			%search = %{$search{$letter}};
		}
		if (ord($letters[0]) > 127 ||
		    ($soft_limit && $j + 1 > $soft_limit)) {
			$prefix = undef;
			$remainder = $ret;
		}
		$return[$i] = [$prefix, $remainder];
	}
	return @return;
}
#------------------------------------------------------
# list_and_choose
#------------------------------------------------------
sub list_and_choose {
	my ($opts, @stuff) = @_;
	my (@chosen, @return);
	my $i;
	my @prefixes = find_unique_prefixes(@stuff) unless $opts->{LIST_ONLY};

        my $status_fmt = '%12s %12s %s';
      
      TOPLOOP:
	while (1) {
		my $last_lf = 0;

		if ($opts->{HEADER}) {
			if (!$opts->{LIST_FLAT}) {
				print "     ";
			}
			print "$opts->{HEADER}\n";
		}
		for ($i = 0; $i < @stuff; $i++) {
			my $chosen = $chosen[$i] ? '*' : ' ';
			my $print = $stuff[$i];
			my $ref = ref $print;
			my $highlighted = highlight_prefix(@{$prefixes[$i]})
			    if @prefixes;
			if ($ref eq 'ARRAY') {
				$print = $highlighted || $print->[0];
			}
			elsif ($ref eq 'HASH') {
				my $value = $highlighted || $print->{VALUE};
				$print = sprintf($status_fmt,
				    $print->{INDEX},
				    $print->{FILE},
				    $value);
			}
			else {
				$print = $highlighted || $print;
			}
			printf("%s%2d: %s", $chosen, $i+1, $print);
			if (($opts->{LIST_FLAT}) &&
			    (($i + 1) % ($opts->{LIST_FLAT}))) {
				print "\t";
				$last_lf = 0;
			}
			else {
				print "\n";
				$last_lf = 1;
			}
		}
		if (!$last_lf) {
			print "\n";
		}

		return if ($opts->{LIST_ONLY});

		print $opts->{PROMPT};
		if ($opts->{SINGLETON}) {
			print "> ";
		}
		else {
			print ">> ";
		}
		my $line = <STDIN>;
		if (!$line) {
			print "\n";
			$opts->{ON_EOF}->() if $opts->{ON_EOF};
			last;
		}
		chomp $line;
		last if $line eq '';
		if ($line eq '?') {
			$opts->{SINGLETON} ?
			    singleton_prompt_help_cmd() :
			    prompt_help_cmd();
			next TOPLOOP;
		}
		for my $choice (split(/[\s,]+/, $line)) {
			my $choose = 1;
			my ($bottom, $top);

			# Input that begins with '-'; unchoose
			if ($choice =~ s/^-//) {
				$choose = 0;
			}
			# A range can be specified like 5-7 or 5-.
			if ($choice =~ /^(\d+)-(\d*)$/) {
				($bottom, $top) = ($1, length($2) ? $2 : 1 + @stuff);
			}
			elsif ($choice =~ /^\d+$/) {
				$bottom = $top = $choice;
			}
			elsif ($choice eq '*') {
				$bottom = 1;
				$top = 1 + @stuff;
			}
			else {
				$bottom = $top = find_unique($choice, @stuff);
				if (!defined $bottom) {
#					error_msg "Huh ($choice)?\n";
					next TOPLOOP;
				}
			}
			if ($opts->{SINGLETON} && $bottom != $top) {
#				error_msg "Huh ($choice)?\n";
				next TOPLOOP;
			}
			for ($i = $bottom-1; $i <= $top-1; $i++) {
				next if (@stuff <= $i || $i < 0);
				$chosen[$i] = $choose;
			}
		}
		last if ($opts->{IMMEDIATE} || $line eq '*');
	}
	for ($i = 0; $i < @stuff; $i++) {
		if ($chosen[$i]) {
			push @return, $stuff[$i];
		}
	}
	return @return;
}
#------------------------------------------------------
1;
