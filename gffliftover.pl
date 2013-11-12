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

gffliftover.pl - Map annotations (e.g. gene locations) from a reference sequence to other sequences, based on user-provided alignment 

=head1 SYNOPSIS

gffliftover.pl -f alignment.fasta -g annotation.gff [-v input_gff_version] [-help] [-debug]

 Required arguments:
    -f        Aligned fasta file (includes the reference and at least 1 additional sequence)
    -g        Reference gff file

 Options:
    -v        GFF file version (default is 3)
    -help -h  Help

=head1 DESCRIPTION

Takes two or more aligned sequences and a GFF file that corresponds to one of the sequences, and outputs a GFF file showing positions in the non-ref sequence(s).

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
use Bio::Tools::GFF;
use Bio::AlignIO;
use Bio::SeqIO;
use Bio::LocatableSeq;
use Pod::Usage;

my $GeneticCode = Bio::Tools::CodonTable->new();
my $needsHelp = '';
my $fasta_file;
my $gff_file;
my $gff_version = 3;
my $debug       = 0;
my $force       = 0;

my $options = &Getopt::Long::GetOptions(
					     'f=s'     => \$fasta_file,
					     'g=s'     => \$gff_file,
					     'v=i'     => \$gff_version,
					     'debug'          => \$debug,
					     'force'          => \$force,
					     'help|h'         => \$needsHelp
);

# Check to make sure options are specified correctly and files exist
&check_opts();

my $basename = $gff_file;
$basename =~ s/.*?([^\/]*)\.gff/$1/ ;

my @errors;

my $refseq ;
my $refseqlength;

## Check to see if alignment is all flush (the is_flush method of SimpleAlign doesn't seem to work)
my $seqio = Bio::SeqIO->new( -file => "<$fasta_file", -format => 'fasta' );
while ( my $seq = $seqio->next_seq() ) {
  unless (defined $refseqlength) { $refseqlength = $seq->length() }
  if ( $seq->length() != $refseqlength ) { 
    push @errors, sprintf "ERROR: length of %s (%d) not same as reference (%d)\n", $seq->id, $seq->length, $refseqlength ;
  }
}
$seqio->close();

if ( (scalar @errors) > 0 ) { foreach (@errors) { print } }# }die }

## Reload FASTA file as an alignment object
my $aln = Bio::AlignIO->new( -file   => "<$fasta_file", -format => 'fasta' );
$aln = $aln->next_aln();
my $aln2 = $aln;
foreach my $seq ( $aln->each_seq() ) {

  my @warnings;
  my $seqid = $seq->id ;
  chomp $seqid;
  
  # take the first sequence as the refseq
  unless (defined $refseq) { $refseq = $seq ; printf "Using %s as the reference\n", $seqid }

  my $new_gff_file = $seqid . '.gff';
  ## Scan through GFF file and look up location for each feature for each seq in the alignment
  my $gffio = Bio::Tools::GFF->new( -file => "$gff_file", -gff_version => $gff_version );
  open NEWGFF, "> $new_gff_file";
  print NEWGFF "##gff-version 3\n";

  while ( my $feature = $gffio->next_feature() ) {

    my $start_column = $aln->column_from_residue_number($feature->seq_id, $feature->start) ;
    my $end_column = $aln->column_from_residue_number($feature->seq_id, $feature->end) ;
    my $start_loc = $seq->location_from_column($start_column)->start;
    my $end_loc = $seq->location_from_column($end_column)->start;
    my $outofframe_indel = 0;
    my $stop_codons = 0;
    my (@codons, @aminos);

    my $gene = $seq->subseq($start_column, $end_column) ;
    my $refgene = $refseq->subseq($start_column, $end_column) ;
    
    my $degap = '';
    for (my $i=0; $i < length($gene); $i++) {
      if (substr($gene, $i, 1) eq '-' and substr($refgene, $i, 1) eq '-') { next }
      else { $degap .= substr($gene, $i, 1) }
    }
    
    for (my $i=0; $i < length($degap); $i += 3) {
      my $codon = substr($degap, $i, 3);
      my $aa = $GeneticCode->translate($codon);
      my $gapcount += () = $codon =~ m/-/g ;
	if ( $gapcount != 0 and $gapcount != 3 ) { $outofframe_indel += 1 }
      if ( $aa eq '*' ) { $stop_codons += 1 }
      push @codons , $codon ;
      push @aminos , $aa ;
    }

    if ($debug) { 
      printf "Mapping %s: ref %d-%d (%d) --> col %d-%d --> seq %d-%d (%d)  [ref is %s, seq is %s]\n" , $feature->get_tag_values('ID'), $feature->start, $feature->end, ($feature->end - $feature->start + 1 ) % 3,  $start_column, $end_column, $start_loc, $end_loc, ($end_loc - $start_loc + 1) % 3, $refseq->id, $seq->id;
      foreach my $codon (@codons) { print "$codon " }
      print "\n";
      foreach my $amino (@aminos) { print " $amino  " }
      print "\n";
    }
 
    if ( $outofframe_indel ) { push @warnings, sprintf "WARNING: %s %s has %d out-of-frame_indels\n" , $seq->id, $feature->get_tag_values('ID'), $outofframe_indel }
    if ( $stop_codons )      { push @warnings, sprintf "WARNING: %s %s has %d stop codons\n" ,  $seq->id, $feature->get_tag_values('ID'), $stop_codons }

    print NEWGFF join "\t", $seq->id, $feature->source_tag.'_gffliftover', $feature->primary_tag, $start_loc, $end_loc, '.', $feature->strand > 0 ? '+' : '-', $feature->frame;
    my $tagstring = '';
    for my $tag ($feature->get_all_tags) { my @values = $feature->get_tag_values($tag); $tagstring .= "$tag=$values[0];"; }
    $tagstring = substr($tagstring, 0, -1);
    print NEWGFF "\t$tagstring\n";
    
  }
  close NEWGFF;
  $gffio->close();

  my $new_fasta_file = $seqid . '.fa';
  my $new_fasta = Bio::SeqIO->new( -file   => ">$new_fasta_file", -format => 'fasta' ) ;
  my $newseq = $seq->seq;
  $newseq =~ s/-//g ;
  my $newseqobject = Bio::Seq->new( -seq => $newseq, -id => $seq->id );
  $new_fasta->write_seq($newseqobject);
  $new_fasta->close();

  if ( (scalar @warnings ) > 0 ) { 
    for ( @warnings ) { print }
    unless ($force) {
      unlink $new_fasta_file;
      unlink $new_gff_file;
    }
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
  if ( ! $fasta_file or ! $gff_file ) {
    pod2usage( -verbose => 1 );
  }
  if ( !-e $fasta_file ) {
    pod2usage(
	      -exitval => 2,
	      -verbose => 1,
	      -message => "Cannot read fasta file: '$fasta_file'!\n"
	      );
  }
  if ( !-e $gff_file ) {
    pod2usage(
	      -exitval => 2,
	      -verbose => 1,
	      -message => "Cannot read gff file: '$gff_file'!\n"
	      );
  }
}



sub validateSequence {
  my $nt = shift;

  my @codons;
  my @aminos;

  my $outofframe_indel = 0;
  my $stop_codons = 0;

  for (my $i=0; $i < length($nt); $i += 3) {
    my $codon = substr($nt, $i, 3);
    my $aa = $GeneticCode->translate($codon);

    push @codons , $codon ;
    push @aminos , $aa ;

    my $gapcount += () = $codon =~ m/-/g ;

    if ( $gapcount != 0 or $gapcount != 3 ) { $outofframe_indel += 1 }

    if ( $codon eq '*' ) { $stop_codons += 1 }
    
  }

#      unless ( $force ) { die "Out-of-frame indel detected.\n" }
#      else { warn "Out-of-frame indel detected.\n" }
#      unless ( $force ) { die "Stop codon detected.\n" }
#      else { warn "Stop codon detected.\n" }



}
