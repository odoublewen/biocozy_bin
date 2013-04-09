#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;

sub printFASTQpaired {
    shift;
    my @line = split "\t";
    if    (scalar @line == 5 ) {print ">$line[0]/1\n$line[1]\n@\n$line[2]\n>$line[0]/2\n$line[3]\n@\n$line[4]\n" }
}

sub printFASTQsingle {
    shift;
    my @line = split "\t";
    if (scalar @line == 3 ) {print ">$line[0]\n$line[1]\n@\n$line[2]\n" }
}

sub printFASTApaired {
    shift;
    my @line = split "\t";
    if    (scalar @line == 5 ) {print ">$line[0]/1\n$line[1]\n>$line[0]/2\n$line[3]\n" }
}

sub printFASTAsingle {
    shift;
    my @line = split "\t";
    if (scalar @line == 3 ) {print ">$line[0]\n$line[1]\n" }
}

my ($lineout, $fastq, $paired) ;
GetOptions ( "fastq" => \$fastq, "paired" => \$paired ) ;

if (  $fastq and   $paired) { $lineout = \&printFASTQpaired }
if (  $fastq and ! $paired) { $lineout = \&printFASTQsingle }
if (! $fastq and   $paired) { $lineout = \&printFASTApaired }
if (! $fastq and ! $paired) { $lineout = \&printFASTAsingle }

while (<STDIN>) {
    chomp;
    &$lineout($_);
}

