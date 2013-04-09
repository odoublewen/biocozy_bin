#!/usr/bin/perl

use strict;
use warnings;

open my $indexfile, '<', "$ARGV[0]" or die $!;
open my $seqfile, '<', "$ARGV[1]" or die $!;

my ($seq, $seqnum);

my @indices = <$indexfile>;
foreach my $index (@indices) {
    chomp $index;
    $index =~ s/^(\d*).*/$1/;
    do {
	$seq = <$seqfile>;
	last unless defined $seq;
	$seqnum = $seq;
	chomp $seqnum;
	$seqnum =~ s/^(\d*).*/$1/;
	unless ( $seqnum == $index ) {print $seq if defined $seq}
    } until $seqnum >= $index or not defined $seq;
}

while ($seq = <$seqfile>) { print $seq }

close $seqfile;
close $indexfile;
