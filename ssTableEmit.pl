#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $indexfile ;

GetOptions ( 
	    'index=s' => \$indexfile 
	   );

#open my $seqfile, '<', "$ARGV[0]" or die $!;

open my $indexfh, '<', "$indexfile" or die $!;
my @indices = <$indexfh>;

foreach my $index (@indices) {
  my $seq;
  do {
    $seq = <>;
  } until $. == $index and defined $seq;
  print $seq if defined $seq;
}

#close $seqfile;
close $indexfh;
