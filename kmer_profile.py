#!/usr/bin/env python
#

import argparse
import logging
from Bio import SeqIO
from collections import defaultdict

def main(args, loglevel):
    logging.basicConfig(format="%(levelname)s: %(message)s", level=loglevel)

    d = defaultdict(int)
    fh = open(args.fasta, "rU")
    for record in SeqIO.parse(fh, "fasta"):
        seq = str(record.seq)

        for i in xrange(len(seq) - (args.length-1)):
            d[seq[i:i + args.length]] += 1

    fh.close()

    print d

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Profiles kmers present in a FASTA file, containing 1 or more records.")
    parser.add_argument(
        "-f",
        "--fasta",
        required=True,
        help="input file in fasta format")
    parser.add_argument(
        "-l",
        "--length",
        help="kmer length",
        type=int,
        default=3)
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true"
    )

    args = parser.parse_args()

    # Setup logging
    if args.verbose:
        loglevel = logging.DEBUG
    else:
        loglevel = logging.INFO

    main(args, loglevel)
