#! /usr/bin/perl -w
use strict ;

my $infile1 = $ARGV[0] ;
my $infile2 = $infile1 ;
$infile2 =~ s/_1/_2/ ;

my ( %s1 , %s2, $seqname, $endofseq, $prefixname ) ;

$prefixname = $infile1 ;
#$prefixname =~ s/([ATGC]+)_.*/$1/ ;
$prefixname =~ s/_1/_paired/ ;
$prefixname =~ s/\.fq// ;
print $prefixname . "\n" ;

#die ;

open IN , $infile1 ;
$endofseq = 0;
while ( <IN> ) {
    if ( /^@(.+)/ ) { $seqname = $1 ; $endofseq = 0; next }
    if ( $_ !~ /^\+/ && $endofseq != 1 ) { $s1{$seqname} .= $_ ; next }
    if ( /^\+/ ) { $endofseq = 1 ; next }
}
close IN ;

open IN , $infile2 ;
$endofseq = 0;
while ( <IN> ) {
    if ( /^@(.+)/ ) { $seqname = $1 ; $endofseq = 0; next }
    if ( $_ !~ /^\+/ && $endofseq != 1 ) { $s2{$seqname} .= $_ ; next }
    if ( /^\+/ ) { $endofseq = 1 ; next }
}
close IN ;

my @common = ();
foreach (keys %s1) {
    push(@common, $_) if exists $s2{$_};
}

#@common = sort { $a <=> $b } @common ;

open OUTseq , ">$prefixname.seq" ;
open OUTmate, ">$prefixname.mates" ;

print OUTmate "library\t1\t50\t3000\n" ;

foreach (@common) {
    print OUTseq ">" . $_ . "_1\n";
    print OUTseq $s1{$_} ;
    print OUTseq ">" . $_ . "_2\n";
    print OUTseq $s2{$_} ;
    
    print OUTmate $_ . "_1\t" . $_ . "_2\t1\n";
}



#my ($k, $v);
#while ( ($k,$v) = each %s1 ) {
#    print "$k => $v\n";
#}


close OUTseq ;
close OUTmate ;
