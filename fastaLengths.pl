#!/usr/bin/perl
use strict;
use Data::Dumper;
my %headers;
my $line; 
my $print = 0;
my $header ;

open ( FASTA, "$ARGV[0]") ;
my $length;

while ( $line = <FASTA> ) {
    if ( $line =~ m/^>/ ) { 
        if ( defined $header ) {print "$header\t$length\n" }
        $length = 0; 
        $header = $line; 
        chomp $header; 
        $header =~ s/>(\S+)\s*.*/$1/ ; 
        next; 
    }
    else { chomp $line; $length += length $line;}
}

print "$header\t$length\n";
