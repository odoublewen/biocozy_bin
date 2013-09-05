#!/usr/bin/perl

use strict;
use warnings;

open IN, "$ARGV[0]" or die $!;
my ($seq1, $seq2, $score);

while ( <IN> ) {
  if ( m/# 1: (.*)/ ) { $seq1 = $1 }
  if ( m/# 2: (.*)/ ) { $seq2 = $1 }
  if ( m/# Score: (.*)/ ) { 
    $score = $1;
    print "$seq1\t$seq2\t$score\n";
  }
  
}
close IN;
