#!/usr/bin/env python
#

from Bio import Entrez
import sys, argparse
import subprocess
import logging

def main(args):

    #entrez, output, query, blastdb, email):

    logging.basicConfig(format="%(levelname)s: %(message)s", level=logging.INFO)

    if args.email is None:
        email = subprocess.check_output(['git', 'config', '--global', 'user.email']).strip()
        if '@' not in email:
            raise RuntimeError('No email provided, and cannot find it in the git global config')
        logging.info('No email provided, so using %s (from git profile)' % email)
    else:
        email = args.email

    logging.info('Querying NCBI Entrez with %s' % args.query)
    handle = Entrez.esearch(db=args.entrez, retmax=args.retmax, term=args.query, email=email)
    record = Entrez.read(handle)
    logging.info('Found %d records' % len(record['IdList']))

    with open(args.output + '_gilist.txt', 'wb') as gi_out:
        for rec in record['IdList']:
            gi_out.write('%s\n' % rec)

    fasta_out = open(args.output + '.fasta', 'wb')
    error_out = open(args.output + '_error.log', 'wb')
    subprocess.call(['blastdbcmd', '-db', args.blast, '-entry_batch', args.output + '_gilist.txt'], stdout=fasta_out, stderr=error_out)
    fasta_out.close()
    error_out.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Pings NCBI to executes a Entrez query, gets GI list, and extracts sequeces from a local BLAST db.")
    parser.add_argument(
        "-q",
        "--query",
        required=True,
        help="entrez query")
    parser.add_argument(
        "-o",
        "--output",
        required=True,
        help="output file")
    parser.add_argument(
        "-e",
        "--entrez",
        default='protein',
        help="entrez database")
    parser.add_argument(
        "-b",
        "--blast",
        default='refseq_protein',
        help="blast database")
    parser.add_argument(
        "-m",
        "--retmax",
        default=10**9,
        help="max results returned by entrez search")
    parser.add_argument(
        "--email",
        help="email address")
    args = parser.parse_args()

    main(args)

