#!/usr/bin/perl
use strict;
use warnings;

my $file1 = $ARGV[0];
my $file2 = $ARGV[1];

if (! $file2 ) { ($file2 = $file1) =~ s/_1\.f/_2\.f/ }

    my %ngs;
    
    if ($file1 =~ m/\.gz$/) {open IN, '-|', 'zcat', $file1 }
    else                    {open IN, $file1 }
    my ($header, $seq);
    while ( <IN> ) {
        if    ($. % 4 == 1) { chomp ; $_ =~ m/@(\w+).*/ ; $header = $1 ; }
        elsif ($. % 4 == 2) { chomp ; $seq = $_ ;}
        elsif ($. % 4 == 0) { chomp ; $ngs{$header} = "$seq\t$_";}
    }
    close IN;
    
        if ($file2 =~ m/\.gz$/) {open IN, '-|', 'zcat', $file2 }
        else                    {open IN, $file2 }
        while ( <IN> ) {
            if    ($. % 4 == 1) { chomp ; $_ =~ m/@(\w+).*/ ; $header = $1 ; }
            elsif ($. % 4 == 2) { chomp ; $seq = $_ ;}
            elsif ($. % 4 == 0) { 
                chomp ; 
                if (exists $ngs{$header}) { $ngs{$header} .= "\t$seq\t$_"; }
                else                      { $ngs{$header} = "$seq\t$_"; }
            }
        }
        close IN;


		foreach $header (keys %ngs) { 
		    print "$header\t$ngs{$header}\n";
		}
