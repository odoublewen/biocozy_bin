#!/bin/sh
sed -n '
# script to pull out seqs from multipe FASTA file
# based on regex matching with id line
# Adapted by Owen Solberg, 9/13/2011
# thanks to http://www.grymoire.com/Unix/Sed.html
#
# if matching description, check the paragraph
/^>/ b para
# else add it to the hold buffer
H
# at end of file, check paragraph
$ b para
# now branch to end of script
b
# this is where a paragraph is checked for the pattern
:para
# return the entire paragraph
# into the pattern space
x
# look for the pattern, if there - print
/'$1'/ p
' $2
