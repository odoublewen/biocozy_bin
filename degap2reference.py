#!/usr/bin/env python
#

import sys, argparse, logging
from Bio import AlignIO, Seq

def main(args, loglevel):
    logging.basicConfig(format="%(levelname)s: %(message)s", level=loglevel)

    infh = open(args.fasta, "rU")
    align = AlignIO.read(infh, "fasta")

    # the first sequence (align[0]) is assumed to be the reference
    # locate the positions where the reference is gapped
    master_ref_id = align[0].id
    refgaps = [pos for pos, base in enumerate(align[0]) if base == '-']

    # remove alignment columns where the reference is gapped
    for pos in reversed(refgaps):
        align = align[:, :pos] + align[:, pos+1:]

    # loop thru each additional sequence in the alignment
    for seqidx, seq in enumerate(align):
        seqmut = seq.upper().seq.tomutable()
        for pos, base in enumerate(seq.upper()):
            # print seq.id, pos, base
            if not base in 'ATGC':
                if args.npadding:
                    seqmut[pos] = 'n'
                else:
                    seqmut[pos] = align[0][pos].lower()
        seq.seq = seqmut
        if args.rename:
            seq.id = master_ref_id + '__M__' + seq.id
            seq.name = seq.id
            seq.description = seq.id

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
        "-n",
        "--npadding",
        help="pad deletions with n characters, rather than the reference base (default)",
        action="store_true")
    parser.add_argument(
        "--rename",
        help="appends name of master reference to each seqeunce",
        action="store_true")
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
