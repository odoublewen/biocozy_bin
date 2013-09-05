#!/usr/bin/perl
use strict;
use Data::Dumper;
my %headers;
my $line; 
my $print = 0;
my $header ;

open ( FASTA, "$ARGV[0]") ;

while ( $line = <FASTA> ) {
    if ( $line =~ m/^>/ ) {
      if (tell(OUT) != -1) { close OUT }
      $header = $line; 
      chomp $header; 
      $header =~ s/>(\S+)\s*.*/$1/;
      $header =~ s/\//_/g;
      $header =~ s/([^\.]*)\..*\.([^\.]*)/$1\__$2/;
      open OUT, "> $header.fa";
    }
    print OUT $line;
}

