#!/usr/bin/perl
use strict;
die"perl $0 <cnv>"unless@ARGV==1;
open IN,"$ARGV[0]"||die"Can not open the file:$!";
while(<IN>){
	chomp;
	my@cut=split /\t/,$_;
	my@seg=split /:/,$cut[1];
	my@co=split /-/,$seg[1];
	print "$seg[0]\t$co[0]\t$co[1]\t0\t0\t$cut[0]\t$cut[0]:a $cut[2]bp $cut[0]\tnormalized_RD:$cut[3]\n";
}
close IN;
