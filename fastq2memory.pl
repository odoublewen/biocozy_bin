#!/usr/bin/perl
use strict;
use warnings;

my (@s, @q) ;
open IN, $ARGV[0] ;
while ( <IN> ) {
    if    ($. % 4 == 0) { chomp ; push @q, $_ ;}
    elsif ($. % 2 == 0) { chomp ; push @s, $_ ;}
}

