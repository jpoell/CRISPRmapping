#!/usr/bin/perl -w
use strict;
use warnings;

unless (open(LIST, $ARGV[0])) {
    print "Cannot open file with guide sequences \n\n";
    exit;
}

if (open(OUTPUT, "guidecount_summary.tsv")) {
    print 'File already exists!! Overwrite (Y/N)? ';
    my$continue = <STDIN>;
    chomp $continue;
    unless ($continue =~ /^y/i) {
		print "\n\nProgram quit! \n\n";
		exit;
    }
}

open(OUTPUT, ">guidecount_summary.tsv");

print OUTPUT "sequence\t" . "gene";

my@list = <LIST>;

my%counts = ();

my@files = <guidecounts/*>;
my$filenumber = 0;
foreach my$file (@files) {
	my$sample;
	if ($file =~ /\/(.*)_guidecounts.tsv/) {
		++$filenumber;
		$sample = $1;
		print "Processing $sample\n";
		print OUTPUT "\t$sample";
		open (INPUT, "$file") or die "kut";
		push @{$counts{"other"}}, 0;
		while (<INPUT>) {
			chomp $_;
			if ($_ =~ /^[ACTG]/) {
				my@line = split (/\t/,$_);
				push @{$counts{$line[0]}}, $line[1];
			}
		}
		foreach my$thing (@list) {
			# for some reason, I can remove the vertical whitespace here instead of in the last foreach loop. This confuses me to no end! It seems to have something to do with a Windows or Mac based newline character.
			$thing =~ s/\v//g;
			my@seq = split (/\t/,$thing);
			unless (${$counts{$seq[0]}}[$filenumber-1]) {
				push @{$counts{$seq[0]}}, 0;
			}
		}
	}
}


foreach my$guide (@list) {
	$guide =~ s/\v//g;
	print OUTPUT "\n$guide";
	my@set = split (/\t/,$guide);
	my@shizzle = @{$counts{$set[0]}};
	foreach my$count (@shizzle) {
		print OUTPUT "\t$count";
	}
}

exit;

