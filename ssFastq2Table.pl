#!/usr/bin/perl
use strict;
use warnings;

my ($seq, $qual, $file1, $file2, $paired ) ;

sub read_fastq {
    my $fh = shift;
    if ($fh and my $seq = <$fh>) {
	$seq = <$fh> ;
	chomp $seq ;
	$qual = <$fh> ;
	$qual = <$fh> ;
	chomp $qual ;
	return [ $seq, $qual ];
    }
    return;
}

sub tablefy_pair {
    ## CALL QFILTER PAIRED AS MODULE
    print "$_[0]\t$_[1][0]\t$_[1][1]\t$_[2][0]\t$_[2][1]\n" ;
}
sub tablefy_single {
    ## CALL QFILTER SINGLE AS MODULE
    print "$_[0]\t$_[1][0]\t$_[1][1]\n" ;
}

if    (scalar @ARGV == 1) { $paired = 0 }
elsif (scalar @ARGV == 2) { $paired = 1 }
else  {die "Exactly 1 or 2 input files required\n" }

if ($paired) {
    $file1 = $ARGV[0];
    $file2 = $ARGV[1];
    if ($file1 =~ m/\.gz$/) { $file1 = "gunzip -c $file1 |"}
    if ($file2 =~ m/\.gz$/) { $file2 = "gunzip -c $file2 |"}
    open(my $f1, $file1);
    open(my $f2, $file2);
    my $pair1 = read_fastq($f1);
    my $pair2 = read_fastq($f2);
    my $count = 1;
    while ($pair1 and $pair2) {
	tablefy_pair($count,$pair1, $pair2);
	$pair1 = read_fastq($f1);
	$pair2 = read_fastq($f2);
	$count ++ ;
    }
    close($f1);
    close($f2);
}
else {
    $file1 = $ARGV[0];
    if ($file1 =~ m/\.gz$/) { $file1 = "gunzip -c $file1 |"}
    open(my $f1, $file1);
    my $pair1 = read_fastq($f1);
    my $count = 1;
    while ($pair1) {
	tablefy_single($count,$pair1);
	$pair1 = read_fastq($f1);
	$count ++ ;
    }
    close($f1);
}
