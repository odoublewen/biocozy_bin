#!/usr/bin/env python
#

# import modules used here -- sys is a very standard one
import sys, argparse, logging, gzip, re
from Bio import SeqIO


# Gather our code in a main() function
def main(args, loglevel):

    trimlen = int(args.length)
    logging.basicConfig(format="%(levelname)s: %(message)s", level=loglevel)

    if args.fastq[-3:] == '.gz':
        fh = gzip.GzipFile(args.fastq, 'r')
    else:
        fh = open(args.fastq, 'r')

    for seq in SeqIO.parse(fh, format='fastq'):
        SeqIO.write(seq[:trimlen], sys.stdout, format = 'fastq')

# Standard boilerplate to call the main() function to begin
# the program.
if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Trims sequences down to a max of N.")
    parser.add_argument(
        "-f",
        "--fastq",
        required=True,
        help="fasta or fastq file to search (may be gzipped if suffix = .gz)"
        )
    parser.add_argument(
        "-l",
        "--length",
        required=True,
        help="maximum length"
        )
    parser.add_argument(
        "-v",
        "--verbose",
        help="increase output verbosity",
        action="store_true")
    args = parser.parse_args()

    # Setup logging
    if args.verbose:
        loglevel = logging.DEBUG
    else:
        loglevel = logging.INFO

    main(args, loglevel)
