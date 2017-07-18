biocozy
=======

## Bioinformatic tidbits

### degap_align.py

```
degap_align.py --help
usage: degap_align.py [-h] -f FASTA [--debug]

Removes gap-only columns from an aligned fasta file, thus maintaining the
alignment.

optional arguments:
  -h, --help            show this help message and exit
  -f FASTA, --fasta FASTA
                        FASTA file
  --debug
```

### fastcount

simply counts the number of sequences in a fasta or fastq file. `.gz` endings are supported.

```
fastcount FILENAME
```

### fastfilter

```
fastfilter --help
usage: fastfilter [-h] [-q QUERY | -f FILTERFILE] [-r] [-g] [-l LENGTH]
                  [--fasta] [-v]
                  FILE

Filters sequences (inclusive or exclusive) from a file (fasta or fastq) using
either pattern matching of the ID line or sequence lengths.

positional arguments:
  FILE                  fasta or fastq file to search (may be gzipped if
                        suffix = .gz)

optional arguments:
  -h, --help            show this help message and exit
  -q QUERY, --query QUERY
                        search term
  -f FILTERFILE, --filterfile FILTERFILE
                        file with list of query terms
  -r, --reverse         removes records with given terms (reverse of default
                        behavior)
  -g, --grep            grep matching of query term (default is exact match)
  -l LENGTH, --length LENGTH
                        length range, specified like 100-200 or -200 or 200-
  --fasta               output sequences as fasta (even if fastq input)
  -v, --verbose         increase output verbosity
```

### flash_overlap.py

```
flash_overlap.py --help
usage: flash_overlap.py [-h] file1 file2 flash

Calculates the overlap in flash-joined reads

positional arguments:
  file1       fastq file (input to flash)
  file2       fastq file (input to flash)
  flash       flash output

optional arguments:
  -h, --help  show this help message and exit
```

### gffliftover.pl

* required perl5 libs: TryCatch, Bio::Tools::GFF

```
gffliftover.pl 
Usage:
    gffliftover.pl -f alignment.fasta -g annotation.gff [-v
    input_gff_version] [-help] [-debug]

     Required arguments:
        -f        Aligned fasta file (includes the reference and at least 1 additional sequence)
        -g        Reference gff file

     Options:
        -v        GFF file version (default is 3)
        -help -h  Help
```
