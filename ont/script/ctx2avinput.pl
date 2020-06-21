#/usr/bin/perl
use strict;

die"Function: convert SV (ctx)file generated from various software programs into ANNOVAR input format;only annotition deletion(DEL),inversion(INV),insersion(INS).\nUsage:perl $0 <ctx>\nDate:20120111\n"unless@ARGV==1;

open IN,"$ARGV[0]"||die"Can not open the file:$!";
while(<IN>){
	chomp;
	my@cut=split /\t/,$_;
	if($cut[6]eq "DEL"){
		print "$cut[0]\t$cut[1]\t$cut[4]\t0\t0\tDeletion\t$cut[6]:a $cut[7]bp deletion\n";
	}
	if($cut[6]eq "INV"){
		print "$cut[0]\t$cut[1]\t$cut[4]\t0\t0\tInversion\t$cut[6]:a $cut[7]bp inversion\n";
	}
	if($cut[6]eq "INS"){
		print "$cut[0]\t$cut[1]\t$cut[4]\t0\t0\tInsersion\t$cut[6]:a $cut[7]bp insersion\n";
	}
}
close IN;
