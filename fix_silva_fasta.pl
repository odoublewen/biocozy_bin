#!/usr/bin/perl
use strict;
use warnings;

my %acc2gi;
my $counter = 0;
open FASTA, $ARGV[1];
while (<FASTA>) {
    if ( m/^>(\S+)/ ) {
	my $acc = $1;
	$acc2gi{$acc} = '';
	$counter += 1;
    }
}
close FASTA;
my $size = keys %acc2gi;
print "$counter Silva sequnces\n";
print "$size unique accession numbers\n";

$counter = 0;
open LIVELIST, "zcat $ARGV[0] | ";
while (<LIVELIST>) {
    chomp;
    my @line = split ',';
    my $acc = $line[0];
    my $gi = $line[2];
    if (exists $acc2gi{$acc}) { 
	$acc2gi{$acc} = $gi;
	$counter += 1;
    }
}
close LIVELIST;
print "$counter Silva accessions in LiveList\n";

open OUT, "> $ARGV[2]";

my $selector = 0;
open FASTA, $ARGV[1];
while (<FASTA>) {
    if ( m/^>(\S+)/ ) {
	my $acc = $1;
	my $gi = $acc2gi{$acc};
	if ($gi ne '') {
	    $_ =~ s/>//;
	    print OUT ">gi|$gi $_";
	    $selector = 1;
	} else {
	    $selector = 0;
	}
    } elsif ($selector == 1) {
	print OUT;
    }
}

close FASTA;
close OUT;
