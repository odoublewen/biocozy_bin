#!/usr/bin/perl
use strict;
use warnings;

foreach my $txtfile ( @ARGV ) {
  die "File $_ not found!\n" unless -s $txtfile ;
  ( my $basename = $txtfile ) =~ s/\.txt//  ;
  die "File $basename.fa already exists! Will not overwrite!\n" if -s "$basename.fa" ;
  open FAS, ">$basename.fa";
  open TXT, $txtfile;
  print FAS ">$basename\n";
  while (<TXT>) { print FAS $_ }
  close TXT;
  close FAS;
}
