#!/usr/bin/perl
use strict;
use Data::Dumper;
my %headers;
my $line; 
my $print = 0;
my $header ;

open (HEADERS, "$ARGV[0]") ;
while ( <HEADERS> ) {
    chomp;
    $_ =~ s/(\S+).*/$1/ ;
    $headers{$_} = 1 ; 
}

#print Dumper \%headers;

my $infile = $ARGV[1];

if ($infile =~ m/.*\.gz$/) { $infile = "zcat $infile";}
else {$infile = "cat $infile";}

#print $infile;

open ( FASTQ, "-|", $infile) ;

while ( my $line1 = <FASTQ> ) {
    my $line2 = <FASTQ>;
    my $line3 = <FASTQ>;
    my $line4 = <FASTQ>;

    $header = $line1;
    chomp $header;
    $header =~ s/@(\S+)\s*.*/$1/ ;
#    print "$header\n";
    unless ( exists $headers{$header} ) { print "$line1$line2$line3$line4";}

}

