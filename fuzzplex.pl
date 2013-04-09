#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my ($bcfile, $prefix, $paired);
my ($sref, $qref);
my (@s1, @q1, @s2, @q2, @bin, @stats);


GetOptions (
	    'bcfile=s' => \$bcfile,
	    'prefix=s' => \$prefix
	   );

sub readfastq {
    my $filename = shift;
    my (@s, @q) ;
    open IN, $filename ;
    while ( <IN> ) {
	if    ($. % 4 == 0) { chomp ; push @q, $_ ;}
	elsif ($. % 2 == 0) { chomp ; push @s, $_ ;}
    }
    close IN;
    return (\@s, \@q) ;
}


if    (scalar @ARGV == 1 and -s $ARGV[0]) { $paired=0; }#print "Processing single read file $ARGV[0]\n";}
elsif (scalar @ARGV == 2 and -s $ARGV[0] and -s $ARGV[1]) { print "Processing paired reads files $ARGV[0] and $ARGV[1]\n"; $paired = 1;}
else {die "Exactly one or two input files must be specified.\n";}

unless (-s $bcfile) {die "Barcode file not found\n"}

my %bc;
open IN, $bcfile ;
while ( <IN> ) {
    chomp;
    my @temp = split "\t" ;
    $bc{$temp[0]} = $temp[1];
}
#print "Read ", scalar keys %bc, " barcodes\n";


($sref, $qref) = readfastq($ARGV[0]);
@s1 = @$sref;
@q1 = @$qref;

if ($paired){
    ($sref, $qref) = readfastq($ARGV[1]);
    @s2 = @$sref;
    @q2 = @$qref;
}    

SEQ: foreach my $seq (@s1){
  PASS1: foreach my $index (keys %bc){
	if ( $seq =~ m/$bc{$index}/ ) {
	    push @bin , $index ;
	    push @stats, "$index\_0";
	    next SEQ ;
	}
    }
  TRIM: foreach my $trim (1..4) {
      PASS2: foreach my $index (keys %bc){
	    my $trimmed = substr($bc{$index}, 1, -$trim);
#	    print "$trimmed\n";
	    if ( $seq =~ m/$trimmed$/ ) {
		push @bin , $index ;
		push @stats, "$index\_$trim";
		next SEQ ;
	    }
	}
    }
    push @bin, "U";
    push @stats, "U";
}

foreach (@stats) {print "$_\n";}

if (scalar @bin != scalar @s1 ) { die "Incongruent arrays\n"}

foreach my $bckey (keys %bc) {
#    print "Doing $bckey\n";
    open OUT, "> $prefix\_$bckey\_1.fq";
    if ($paired) { open OUT2, "> $prefix\_$bckey\_2.fq"; }
    foreach my $counter (0..((scalar @bin)-1)) {
	if ($bin[$counter] eq $bckey) {
	    print OUT "\@$counter\n$s1[$counter]\n+\n$q1[$counter]\n";
	    if ($paired) { print OUT2 "\@$counter\n$s2[$counter]\n+\n$q2[$counter]\n";}
	}
    }
    close OUT;
    if ($paired) { close OUT2;}
}



