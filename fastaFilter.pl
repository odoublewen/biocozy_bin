#!/usr/bin/perl
use strict;
use Data::Dumper;
my %headers;
my $line; 
my $print = 0;
my $header ;

open (HEADERS, "$ARGV[0]") ;
while ( <HEADERS> ) {
    chomp;
    $_ =~ s/(\S+).*/$1/ ;
    $headers{$_} = 1 ; 
}

#print Dumper \%headers;

my $infile = $ARGV[1];

if ($infile =~ m/.*\.gz$/) { $infile = "zcat $infile";}
else {$infile = "cat $infile";}

open ( FASTA, "$infile |") ;

while ( $line = <FASTA> ) {
    if ( $line =~ m/^>/ ) { $header = $line; chomp $header; $header =~ s/>(\S+)\s*.*/$1/ ; }
    unless ( exists $headers{$header} ) { print $line;}
}

