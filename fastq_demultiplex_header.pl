#!/usr/bin/perl
use strict;

# written by O. D. Solberg 3/1/2012

## variables
my ( $infile, $header, $seq, $qual, %qhash , $line, $spacer) ;

## help message
if ( @ARGV != 1 ) {
 print STDERR <<EOF;

Bins sequences from a fastq file based on the Illumina header line.

\@M00297:3:000000000-A0F15:1:1:17669:1802 1:N:0:1 
                                               ^ 
                                               Bins are determined
                                               solely by what comes
                                               after the third colon
                                               in the second header
                                               block

Usage: ods_demultiplex_header.pl infile.fq

EOF
 exit(1);
}

$infile = @ARGV[0];

open ( IN , "<$infile" ) or die "Cannot open file $infile\n";

while ( $header = <IN> ) {
    $line ++ ;
    $seq = <IN> ;
    $spacer = <IN> ;
    $qual = <IN> ;
    chomp ( $header, $seq , $spacer, $qual ) ;
    if ( $header =~ m/\@.+ .+:.+:.+:(.+)$/ ) {
	push @{ $qhash{$1}} , $header, $seq , $spacer, $qual  ;

    } else {
	print "Problem with input file around line ". (($line * 4) - 3) ."\n" ;
	die ;
    }
}
close (IN) ;

my $numseqs ;
my $outfile ;
my $line ;
for my $bin ( sort {$a <=> $b} keys %qhash ) {
    $outfile = $infile ;
    $outfile =~ s/(.*)(\.[^\.]+$)/$1\_$bin$2/ ;
    $numseqs = scalar(@{ $qhash{$bin} }) / 4 ;
    print "Writing $numseqs sequences to file $outfile.\n" ;
    open ( OUT , ">$outfile" ) ;
    foreach $line (@{ $qhash{$bin} }) {
	print OUT "$line\n" ;
    }
    close (OUT);
}
