#!/usr/bin/env python
#

import sys
import argparse
import logging
import gzip
import time
from Bio import SeqIO

def main(args, loglevel):

    logging.basicConfig(format="%(levelname)s: %(message)s", level=loglevel)

    if args.seqfile[-3:] == '.gz':
        fh = gzip.open(args.seqfile, 'rt')
    else:
        fh = open(args.seqfile, 'r')

    for line in fh:
        if line[0] == '>':
            filetype = 'fasta'
            break
        elif line[0] == '@':
            filetype = 'fastq'
            break
        else:
            raise RuntimeError("Cannot guess file type for %s" % args.seqfile)
    fh.close()

    logging.info("Indexing {} file {}".format(filetype, args.seqfile))

    record_dict = SeqIO.index(args.seqfile, filetype)

    logging.info("Reading filter file {}".format(args.filterfile))
    with open(args.filterfile, 'r') as fh:
        id_count = sum(1 for line in fh)
        fh.seek(0)
        start_time = time.time()
        try:
            for i, line in enumerate(fh):
                if i % 1000 == 0:
                    try:
                        rate = i / (time.time()-start_time)
                        time_remain = (id_count - i) / rate
                    except ZeroDivisionError:
                        rate = 0
                        time_remain = 0
                    logging.info("Processed {} of {} IDs ({:.2f} per second, est. complete at {})".
                                 format(i, id_count, rate, time.asctime(time.localtime(time.time() + time_remain))))
                try:
                    rec = record_dict[line.rstrip()]
                    print(rec.format(filetype))
                except KeyError:
                    logging.debug('record id {} not found'.format(line.strip()))
                    pass
        except IOError:
            try:
                sys.stdout.close()
            except IOError:
                pass
            try:
                sys.stderr.close()
            except IOError:
                pass


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Filters sequences (inclusive or exclusive) from a file (fasta or fastq) using either pattern "
                    "matching of the ID line or sequence lengths.")
    parser.add_argument(
        "filterfile",
        help="file with list of query terms")
    parser.add_argument(
        "seqfile",
        help="fasta or fastq file to search (may be gzipped if suffix = .gz)")
    parser.add_argument(
        "-r",
        "--reverse",
        help="removes records with given terms (reverse of default behavior)",
        action="store_true")
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
