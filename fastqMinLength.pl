#!/usr/bin/perl
use strict;
use Data::Dumper;
my %headers;
my $line; 
my $print = 0;

my $minlen = $ARGV[0];

open ( FASTQ, "$ARGV[1]") ;

my $header ;
my $seq;
my $dummy;
my $qual;


while ( $header = <FASTQ> ) {
    $seq = <FASTQ> ;
    chomp $seq;
    $dummy = <FASTQ> ;
    $qual = <FASTQ> ;

    if (length $seq >= $minlen) {
	print "$header$seq\n$dummy$qual"
    }
}
