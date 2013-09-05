#!/usr/bin/perl
use strict;
use warnings;

my ($file1, $file2, %hash ) ;

$file1 = $ARGV[0] ;
($file2 = $file1 ) =~ s/_1\./_2\./ ;
unless (-s $file1 and -s $file2) { die "Cannot find input files $file1 $file2\n" }
#if ($file1 =~ m/\.gz$/) { $file1 = "gunzip -c $file1 |"}
#if ($file2 =~ m/\.gz$/) { $file2 = "gunzip -c $file2 |"}
if ($file1 =~ m/\.gz$/) { $file1 = "zcat $file1 |"}
if ($file2 =~ m/\.gz$/) { $file2 = "zcat $file2 |"}

open(my $f1, $file1);
while (my $header = <$f1>) {
  chomp $header;
  $header =~ s/^@//;
  $header =~ s/\s.*$//;
  my $seq = <$f1> ;
  chomp $seq ;
  <$f1> ;
  my $qual = <$f1> ;
  chomp $qual ;
  $hash{$header} = [$seq, $qual] ;
}
close($f1);

open(my $f2, $file2);
while (my $header = <$f2>) {
  chomp $header;
  $header =~ s/^@//;
  $header =~ s/\s.*$//;
  my $seq = <$f2> ;
  chomp $seq ;
  <$f2> ;
  my $qual = <$f2> ;
  chomp $qual ;
  if (exists $hash{$header} ) {  push @{$hash{$header}}, $seq, $qual }
  else { $hash{$header} = [$seq, $qual] }
}
close($f2);


foreach (keys %hash) {
  print "$_\t";
  print join "\t", @{$hash{$_}};
  print "\n" ;

}
