#!/usr/bin/perl
use strict;
use Data::Dumper;
my %headers;
my $line; 
my $print = 0;

my $numreq = int $ARGV[0];

my $numseq = int(`cat $ARGV[1] | wc -l`/4);

if ($numreq > $numseq) {die "You cannot sample $numreq from $numseq\n";}

my $prob = $numreq / $numseq ;

open ( FASTQ, "$ARGV[1]") ;

my $header ;
my $seq;
my $dummy;
my $qual;

while ( $header = <FASTQ> ) {
    $seq = <FASTQ> ;
    $dummy = <FASTQ> ;
    $qual = <FASTQ> ;

    if (rand() <= $prob) {
	print "$header$seq$dummy$qual"
    }
}
