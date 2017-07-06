#!/usr/bin/env python
#

from Bio import SeqIO
import argparse
import gzip
import logging


def getlengths(path):

    logging.info('Getting seq lengths from {}'.format(path))
    a = {}
    if path[-3:] == '.gz':
        fh = gzip.open(path, 'rt')
    else:
        fh = open(path, 'rt')
    records = SeqIO.parse(fh, "fastq")
    for rec in records:
        a[rec.id] = len(rec.seq)
    fh.close()
    return a

def main(file1, file2, flash):

    l1 = getlengths(file1)
    l2 = getlengths(file2)
    lj = getlengths(flash)

    for seqid in set(list(l1.keys()) + list(l2.keys()) + list(lj.keys())):
        try:
            diff = l1[seqid] + l2[seqid] - lj[seqid]
        except KeyError:
            diff = None
        print("{}\t{}\t{}\t{}\t{}".format(seqid, l1.get(seqid), l2.get(seqid), lj.get(seqid), diff))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Calculates the overlap in flash-joined reads")

    parser.add_argument(
        "file1",
        help="fastq file (input to flash)")
    parser.add_argument(
        "file2",
        help="fastq file (input to flash)")
    parser.add_argument(
        "flash",
        help="flash output"
    )

    args = parser.parse_args()
    logging.basicConfig(format="%(levelname)s: %(message)s", level=logging.DEBUG)

    main(**vars(args))
