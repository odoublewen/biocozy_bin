#!/usr/bin/env python
#
__author__ = 'Owen Solberg'


# import modules used here -- sys is a very standard one
import sys, argparse, logging, re
import pandas as pd
import os

# Gather our code in a main() function
def main(infile, loglevel):
    logging.basicConfig(format="%(levelname)s: %(message)s", level=loglevel)

    stat_name = ['seqid', 'stat', 'value']
    stat_data = []
    outfile = os.path.splitext(infile)[0] + '.csv'

    fh = open(infile, 'rb')
    for line in fh:
        res = re.match('PEPSTATS of (\S+)', line)
        if res:
            seqid = res.group(1)
            continue

        res = re.match('(?P<aa>[A-Z]) = ...\s+(?P<number>\S+)\s+(?P<mole>\S+)\s+(?P<dayhoff>\S+)', line)
        if res:
            stat_data.append([seqid, res.group('aa') + '__count', res.group('number')])
            stat_data.append([seqid, res.group('aa') + '__mole', res.group('mole')])
            stat_data.append([seqid, res.group('aa') + '__dayhoff', res.group('dayhoff')])
            continue

        res = re.match('(?P<property>\w+)\s+\(\S\)\s+(?P<number>\S+)\s+(?P<mole>\S+)', line)
        if res:
            stat_data.append([seqid, res.group('property') + '___count', res.group('number')])
            stat_data.append([seqid, res.group('property') + '___mole', res.group('mole')])
            continue

        resiter = re.finditer('(?P<property>[^\t]+) += (?P<value>\S+)', line)
        for res in resiter:
            if res:
                stat_data.append([seqid, res.group('property').strip(), res.group('value').strip()])

    fh.close()
    df = pd.DataFrame(data=stat_data, columns=stat_name)

    df.pivot(index='seqid', columns='stat', values='value').to_csv(outfile)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Converts output of pepstats (EMBOSS) to a tab-delimited text file."
    )
    parser.add_argument(
        "infile",
        help="input, which is the raw output of pepstats",
        metavar="infile")
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

    main(infile=args.infile, loglevel=loglevel)
