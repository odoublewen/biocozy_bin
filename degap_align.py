#!/usr/bin/env python
#

from Bio import AlignIO
import argparse
import logging
import os

def main(args):

    with open(args.fasta, 'r') as handle:
        align = AlignIO.read(handle, "fasta")

    to_delete = []
    old_length = align.get_alignment_length()
    logging.info('Examining {} columns of aligned fasta file'.format(old_length))
    for pos in range(old_length):
        column = align[ : , pos]
        if column == '-' * len(column):
            to_delete.append(pos)

    if len(to_delete) > 0:
        logging.info('Removing {} gap-only columns: {}'.format(len(to_delete), to_delete))
        to_delete.sort()
        to_delete.reverse()
        for pos in to_delete:
            align = align[:, :pos] + align[:, pos+1:]
        new_length = align.get_alignment_length()
        logging.info('Done! Old length: {}  New length: {}  Difference: {}'.
                     format(old_length, new_length, old_length-new_length))

    output_filename = os.path.basename(args.fasta) + '_degapped.fasta'
    with open(output_filename, 'w') as handle:
        AlignIO.write(align, handle, "fasta")


def make_arg_parser():
    parser = argparse.ArgumentParser(
        description="Removes gap-only columns from an aligned fasta file, thus maintaining the alignment."
    )
    parser.add_argument("-f", "--fasta", required=True, help="FASTA file")
    parser.add_argument("--debug", action='store_true')
    return parser


if __name__ == '__main__':

    arguments = make_arg_parser().parse_args()
    # Set up logging
    loglevel = logging.DEBUG if arguments.debug else logging.INFO
    logging.basicConfig(level=loglevel,
                        format='%(asctime)s__%(module)s__%(levelname)s__%(message)s')
    main(arguments)
