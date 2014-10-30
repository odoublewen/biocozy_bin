#!/usr/bin/env python
#

# import modules used here -- sys is a very standard one
import argparse
import logging
import tables

# Gather our code in a main() function
def main(args, loglevel):
    logging.basicConfig(format="%(levelname)s: %(message)s", level=loglevel)

    outfile = h5py.File(args.outfile, "w")
    h5container = outfile.create_dataset("v8bitscores", (10, 3))

    with open(args.infile, mode='r') as infile:
        for line in infile:
            line = line.rstrip()
            fields = line.split('\t')
            print fields

    outfile.close()



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Converts CSV (or similar) file to HDF5 format.")
    parser.add_argument(
        "-i",
        "--infile",
        required=True,
        help="input file")
    parser.add_argument(
        "-o",
        "--outfile",
        required=True,
        help="output file")
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
