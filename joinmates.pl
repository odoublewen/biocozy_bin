#!/usr/bin/perl -w

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 NAME

joinmates.pl - From a BAM file with paired reads, joins the pairs and pads with the observed number of N characters.

=head1 SYNOPSIS

joinmates.pl -b bamfile [-f fastqfile] [-help] [-debug]

 Required arguments:
    -b        Input BAM file

 Options:
    -f        Output gzipped fastq file (if not provided, output is STDOUT)
    -help -h  Help

=head1 DESCRIPTION

From a BAM file with paired reads, joins the pairs and pads with the observed number of N characters.

=head1 AUTHOR

Owen Solberg <owen@myway.com>

=head1 LICENSE

Copyright (c) 2013, Owen Solberg

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

=cut

use strict;
use warnings;
use Data::Dumper;
use File::Basename;
use Getopt::Long;
use Pod::Usage;

my $needsHelp = '';
my $bam_file;
my $fastq_file;
my $debug       = 0;

my $options = &Getopt::Long::GetOptions(
					'f=s'     => \$fastq_file,
					'b=s'     => \$bam_file,
					'debug'   => \$debug,
					'help|h'  => \$needsHelp
);

# Check to make sure options are specified correctly and files exist
&check_opts();

open BAM, "samtools view $bam_file |";
my $seq;
my $qual;

my %hash;
while (<BAM>) {
  my @line = split "\t";
  my $header = $line[0];
  my $flag = $line[1];
  $seq = $line[9];
  $qual = $line[10];

  # unmated reads
  if ( !($flag & 2) ) {
    if ( $flag & 16 ) { &RevComp }
    print "\@$header\n$seq\n+\n$qual\n"; 
    next; 
  }

  if (exists $hash{$header} ) {
  
    my $seq2 = $hash{$header}{s};
    my $qual2 = $hash{$header}{q};

    my $pad = abs($line[8]) - length($seq) - length($seq2) ;

    if ($line[8] > 0) {
      
      my $Ltrim = length($seq); my $Rtrim = 0;
      if ($pad < 0) { $Rtrim = abs($pad); $pad = 0 }
      if ( $Rtrim > length($seq2) ) { $Ltrim = length($seq2) - $Rtrim; $Rtrim = length($seq2) }

      $seq = substr($seq, 0, $Ltrim) . 'N'x$pad . substr($seq2, $Rtrim);
      $qual = substr($qual, 0, $Ltrim) . '!'x$pad . substr($qual2, $Rtrim);
    }

    else {

      my $Ltrim = length($seq2); my $Rtrim = 0;
      if ($pad < 0) { $Rtrim = abs($pad); $pad = 0 }
      if ( $Rtrim > length($seq) ) { $Ltrim = length($seq) - $Rtrim; $Rtrim = length($seq) }

      $seq = substr($seq2, 0, $Ltrim) . 'N'x$pad . substr($seq , $Rtrim) ;
      $qual =  substr($qual2, 0, $Ltrim) . '!'x$pad . substr($qual, $Rtrim) ;
    }

    # flag & 80 = "first in pair, read reverse strand"
    # flag & 128 = "second in pair"
    # ! flag & 16 = NOT "read reverse strand" (ie, read forward strand)
    if ( ($flag & 80) or ( ($flag & 128) and !($flag & 16) ) ) { &RevComp }

    print "\@$header\n$seq\n+\n$qual\n" ;
  }
 
  else {
    $hash{$header}{s} = $seq;
    $hash{$header}{q} = $qual;
  }

}

close BAM;


# parallel -j 1 "joinmates.pl -b {} | bowtie2 -p 24 --very-sensitive --n-ceil C,1000 --np 0 --rdg 8,3 --rfg 8,3 -x ~/ReferenceSequences/HIV_CNDO -U - --score-min C,-1000000 | samtools view -Sb - | samtools sort - {.}_joined2" ::: *paired.bam

sub RevComp {
  $seq =~ tr/ATGC/TACG/ ; 
  $seq = reverse $seq; 
  $qual = reverse $qual; 
}

# Check for problem with the options or if user requests help
sub check_opts {
  if ($needsHelp) {
    pod2usage( -verbose => 2 );
  }
  if ( !$options ) {
    pod2usage(
	      -exitval => 2,
	      -verbose => 1,
	      -message => "Error specifying options."
	      );
  }
  if ( !-e $bam_file ) {
    pod2usage(
	      -exitval => 2,
	      -verbose => 1,
	      -message => "Cannot read bam file: '$bam_file'!\n"
	      );
  }
}
