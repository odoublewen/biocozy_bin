#!/usr/bin/env python
import sys

with open(sys.argv[1]) as fh:
    ids = set('@' + x.rstrip() for x in fh)

lineno = 0
flag = False

for l in sys.stdin:
    lineno += 1
    if lineno%4 == 1:
        flag = (l.split(' ')[0] in ids)
    if flag:
        sys.stdout.write(l)
