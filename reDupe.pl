#! /usr/bin/perl -w
use strict ;

unless ( @ARGV == 3 ) { die "Usage:$0 indexfile fqfile outfile\n" }
my ( $indexfile, $fqfile , $outfile ) = ( @ARGV ) ;
my ( %dupe ,  %seqs ) ;
open IN , "$indexfile" ;
while ( <IN> ) {
 if ( /^#/ ) { next }
 chomp ;
 my @flds = split "\t" , $_ ;
 if ( $flds[6] ) { $dupe{$flds[0]} = $flds[0] }
 if ( $flds[7] ) { $dupe{$flds[0]} = $flds[7] }
}
close IN ;
print scalar ( keys %dupe ) , " models and dupes\n" ;

open IN , "$fqfile" ;
while ( my $header = <IN> ) {
 $header =~ s/^\@// ;
 chomp $header ;
 $header =~ s/\s.*// ;
 $seqs{$header} .= <IN> ;
 $seqs{$header} .= <IN> ;
 $seqs{$header} .= <IN> ;
}
close IN ;
print scalar ( keys %seqs ) , "	seqs\n" ;

my $ct ;
open OUT , ">$outfile" ;
for my $read ( sort { $a <=> $b } keys %dupe ) {
 $ct ++ ;
 print OUT "\@$read\n$seqs{$dupe{$read}}" ;
}
close OUT ;
print "$ct reads written\n" ;
