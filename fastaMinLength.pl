#!/usr/bin/perl
use strict;
use Data::Dumper;
my %headers;
my $line; 
my $print = 0;
my $header ;

my $minlen = $ARGV[0];

open ( FASTA, "$ARGV[1]") ;
my $length;
my $seq;

while ( $line = <FASTA> ) {
    if ( $line =~ m/^>/ ) { 
	if ( defined $header and length $seq >= $minlen ) {print ">$header\n$seq\n" }
	$seq = '';
	$header = $line; 
	chomp $header; 
	$header =~ s/>(\S+)\s*.*/$1/ ; 
	next; 
    }
    else { chomp $line; $seq .= $line;}
}

