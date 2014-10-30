#!/usr/bin/env python
#

import sys, argparse, logging
from Bio import AlignIO, Seq

def main(args, loglevel):
    logging.basicConfig(format="%(levelname)s: %(message)s", level=loglevel)

    infh = open(args.fasta, "rU")
    align = AlignIO.read(infh, "fasta")

    refgaps = []
    for pos, base in enumerate(align[0]):
        if base == '-':
            refgaps.append(pos)

    for pos in reversed(refgaps):
        align = align[:, :pos] + align[:, pos+1:]

    for seqidx, seq in enumerate(align):
        seqmut = seq.seq.tomutable()
        for pos, base in enumerate(seq):
            # print seq.id, pos, base
            if not base.upper() in 'ATGC':
                seqmut[pos] = 'n'
        seq.seq = seqmut

    AlignIO.write(align, sys.stdout, "fasta")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Provided with an aligned FASTA file in which the first sequence is taken as the reference, "
                    "this will (1) trim any non-ref sequences that extend past reference, (2) remove all gaps from the "
                    "reference (by removing the inserted characters in non-ref sequences), and (3) replace gap "
                    "characters in non-ref sequences with N characters.")
    parser.add_argument(
        "fasta",
        help="aligned fasta file to read",
        metavar="fasta")
    parser.add_argument(
        "-v",
        "--verbose",
        help="increase output verbosity",
        action="store_true")
    args = parser.parse_args()

    if args.verbose:
        loglevel = logging.DEBUG
    else:
        loglevel = logging.INFO

    main(args, loglevel)
