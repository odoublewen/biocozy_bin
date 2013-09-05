#!/usr/bin/perl
use strict;
use warnings;

while (my $line = <STDIN> ) {
  my @fields = split '\t', $line;
  my $read = '';
  if ( $fields[1] & 64 ) { $read = '_1' }
  if ( $fields[1] & 128 ) { $read = '_2' }
  print ">$fields[0]$read\n$fields[9]\n";
}


