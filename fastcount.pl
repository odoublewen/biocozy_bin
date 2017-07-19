#!/usr/bin/perl
use strict;

my $infilecat ;
my $i ;

foreach (@ARGV) {

    if    (m/\.gz$/ )   { $infilecat = "zcat $_" }
    else                { $infilecat = "cat $_" }

    if    (m/\.fq|\.fastq/ and -s $_ )  { 
	open ( IN , "-|", $infilecat ) or die "Cannot access file $_\n";
	$i = 0;
	while ( <IN> ) {
	    $i ++ ;
	}
	$i = $i / 4;
    }

    elsif (m/\.fa|\.fasta/ and -s $_ )  { 
	open ( IN , "-|", $infilecat ) or die "Cannot access file $_\n";
	$i = 0;
	while ( <IN> ) {
	    if ( m/^>/ ) {$i ++ }
	}
    }

    else                                {die "Infile $_ not recognized or not found." }

    print "$i\n";
}
