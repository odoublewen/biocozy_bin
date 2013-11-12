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

averageinsertsize.pl - From a BAM file with paired reads, provides stats on the insert sizes.

=head1 SYNOPSIS

averageinsertsize.pl bamfiles [-help] [-debug]

 Options:
    -f        Output gzipped fastq file (if not provided, output is STDOUT)
    -help -h  Help

=head1 DESCRIPTION

From a BAM file with paired reads, provides stats on the insert sizes.

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
use List::Util qw(max min sum);
use Statistics::Basic qw(:all nofill);

my $needsHelp = '';
my $debug       = 0;

my $options = &Getopt::Long::GetOptions(
					'debug'   => \$debug,
					'help|h'  => \$needsHelp
);

# Check to make sure options are specified correctly and files exist
&check_opts();


foreach my $bam_file ( @ARGV ) { 

  my $unpaired = 0;
  my $paired = 0;
  my @a ;

  open BAM, "samtools view $bam_file |";
 
 BAM: while (<BAM>) {
    my @line = split "\t";
    my $flag = $line[1] ;

    if (! ($flag & 2) ) { $unpaired ++; next BAM ; }

    if ( $flag & 66 ) { $paired ++; push @a, abs($line[8]); 
#		      print "$bam_file\t$line[0]\t$flag \t". abs($line[8]). "\n";
		    }
  
  }
  close BAM;

  @a = sort {$a <=> $b} @a ;
  print "$bam_file\t";
  if (scalar @a == 0) { print "ALL UNPAIRED!\n";}
  else {
    print "$a[0]\t";
    printf("%.2f", sum(@a)/@a );
    print "\t";
    printf("%.2f", stddev(\@a));
    print "\t$a[-1]\n";
  }

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
  foreach my $bam_file (@ARGV) {
    if ( !-e $bam_file ) {
      pod2usage(
		-exitval => 2,
		-verbose => 1,
		-message => "Cannot read bam file: '$bam_file'!\n"
	       );
    }
  }
}
