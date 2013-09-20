#!/usr/bin/perl
use strict;
use warnings;


my %seq;
my $header;
my $total;

open FASTA, "$ARGV[0]";
while (<FASTA>) {
    chomp;
    if ( m/^>/ ) { $header = $_ ; next; }
    $seq{$header} .= $_;
}
close FASTA;

my %clstr;
my %counts;
open CLSTR, "$ARGV[0].clstr";
while (<CLSTR>) {
    chomp;
    if ( m/^>/ ) { $header = $_ ; next; }
    $counts{$header} ++;
    $total ++;
    if ( m/.*(>[^\.]+)\.\.\. \*$/ ) { $clstr{$header} = "$1" ;}
}

foreach my $key (sort {$counts{$b} <=> $counts{$a} } keys %counts) {
if ($counts{$key}/$total > 0.001) {
	print "$key count=$counts{$key} (";
	printf("%.1f", 100*$counts{$key}/$total);
	print "%) rep=$clstr{$key}\n$seq{$clstr{$key}}\n";
}
}
