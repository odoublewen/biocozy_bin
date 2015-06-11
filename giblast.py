#!/usr/bin/env python
#

from Bio import Entrez
import sys, argparse
import subprocess
import logging

def main(entrez, output, query, blastdb, email):

    logging.basicConfig(format="%(levelname)s: %(message)s", level=logging.INFO)

    if email is None:
        email = subprocess.check_output(['git', 'config', '--global', 'user.email']).strip()
        if '@' not in email:
            raise RuntimeError('No email provided, and cannot find it in the git global config')
        logging.info('No email provided, so using %s' % email)

    handle = Entrez.esearch(db=entrez, retmax=100000, term=query, email=email)
    record = Entrez.read(handle)
    logging.info('Found %d records using search term %s' % (len(record['IdList']), query))

    with open(output + '_gilist.txt') as giout:
        for rec in record['IdList']:
            giout.write(rec)

    subprocess.call(['blastdbcmd', '-db', blastdb, '-entry_batch', output + '_gilist.txt'], stdout=output + '.fasta')


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
        "--email",
        help="email address")
    args = parser.parse_args()

    main(entrez=args.entrez, output=args.output, query=args.query, blastdb=args.blast, email=args.email)

