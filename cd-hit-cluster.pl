#!/usr/bin/perl
use strict;
use warnings;


my %seq;
my $header;


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
    if ( m/.*(>[^\.]+)\.\.\. \*$/ ) { $clstr{$header} = "$1" ;}
}

foreach my $key (sort {$counts{$b} <=> $counts{$a} } keys %counts) {
    print "$key count=$counts{$key} rep=$clstr{$key}\n$seq{$clstr{$key}}\n";
}
