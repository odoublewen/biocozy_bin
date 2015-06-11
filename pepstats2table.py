#!/usr/bin/env python
#
__author__ = 'Owen Solberg'

import argparse
import logging
import re
import pandas as pd
import os
import sys
import tempfile
import subprocess


def run_pepstats(infile):
    if infile:
        inf = open(infile)
    else:
        inf = sys.stdin

    temp_outfile = tempfile.NamedTemporaryFile(delete=False)
    temp_filename = temp_outfile.name

    for line in inf:
        fields = line.strip().split()
        if len(fields) == 1:
            temp_outfile.write('>%s\n%s\n' % (fields[0], fields[0]))
        elif len(fields) == 2:
            temp_outfile.write('>%s\n%s\n' % (fields[0], fields[1]))
        elif len(fields) == 0:
            pass
        else:
            raise RuntimeError('Input file should contain either 1 or 2 columns')
    temp_outfile.close()

    subprocess.call(['pepstats', '-auto', '-sequence', temp_filename, '-outfile', temp_filename + '_pepstats'])

    delete_temp_file = True

    return temp_filename, delete_temp_file



def flatten_pepstat_output(temp_filename, outfile, delete_temp_file=True):
    logging.basicConfig(format="%(levelname)s: %(message)s", level=loglevel)

    stat_name = ['seqid', 'stat', 'value']
    stat_data = []

    fh = open(temp_filename + '_pepstats', 'rb')
    for line in fh:

        # ignore lines like:
        # A280 Molar Extinction Coefficients  = 0 (reduced)   0 (cystine bridges)
        # A280 Extinction Coefficients 1mg/ml = 0.000 (reduced)   0.000 (cystine bridges)
        # Improbability of expression in inclusion bodies = 0.966
        res = re.search('expression in inclusion bodies|Extinction Coefficients', line)
        if res:
            continue

        # matches lines like:
        # PEPSTATS of XY149969_PLKRGVVVLNGSG from 1 to 13
        res = re.match('PEPSTATS of (\S+)', line)
        if res:
            seqid = res.group(1)
            continue

        # matches lines like:
        # G = Gly         3               23.077          2.747
        res = re.match('(?P<aa>[A-Z]) = ...\s+(?P<number>\S+)\s+(?P<mole>\S+)\s+(?P<dayhoff>\S+)', line)
        if res:
            stat_data.append([seqid, 'aa__' + res.group('aa') + '__count', res.group('number')])
            stat_data.append([seqid, 'aa__' + res.group('aa') + '__mole', res.group('mole')])
            stat_data.append([seqid, 'aa__' + res.group('aa') + '__dayhoff', res.group('dayhoff')])
            continue

        # matches lines like:
        # Tiny            (A+C+G+S+T)             4               30.769
        res = re.match('(?P<property>\w+)\s+\(\S+\)\s+(?P<number>\S+)\s+(?P<mole>\S+)', line)
        if res:
            stat_data.append([seqid, 'prop__' + res.group('property') + '__count', res.group('number')])
            stat_data.append([seqid, 'prop__' + res.group('property') + '__mole', res.group('mole')])
            continue

        # matches lines like:
        # Molecular weight = 1295.55              Residues = 13
        resiter = re.finditer('(?P<property>[^\t]+) += (?P<value>\S+)', line)
        for res in resiter:
            if res:
                stat_data.append([seqid, 'meta__' + res.group('property').strip().replace(' ', '_'), res.group('value').strip()])

    fh.close()
    if delete_temp_file:
        os.remove(temp_filename)
        os.remove(temp_filename + '_pepstats')

    df = pd.DataFrame(data=stat_data, columns=stat_name)
    df.pivot(index='seqid', columns='stat', values='value').to_csv(outfile)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Converts output of pepstats (EMBOSS) to a tab-delimited text file."
    )
    parser.add_argument(
        "infile",
        nargs='?',
        help="input, which is a plain list of peptide seqeunces, one per line",
        metavar="infile")
    parser.add_argument(
        "-o",
        "--outfile",
        help="file name for output")
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

    if args.outfile is None:
        if args.infile is None:
            outfile = "pepstats2table.csv"
        else:
            outfile = os.path.splitext(args.infile)[0] + '.csv'
    else:
        outfile = args.outfile

    temp_filename, delete_temp_file = run_pepstats(infile=args.infile)

    flatten_pepstat_output(temp_filename=temp_filename, outfile=outfile, delete_temp_file=delete_temp_file)
