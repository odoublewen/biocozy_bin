#!/usr/bin/perl
foreach my $line ( <> ) {
    chomp $line;
    my @split = split /\t+/, $line;

    if (scalar(@split) == 2) {
	print ">$split[0]\n$split[1]\n";
    } else {
	print ">$split[0]\n$split[0]\n";
    }

}
