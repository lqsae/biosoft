#/usr/bin/perl
use strict;

#die"Function: convert SV (ctx)file generated from various software programs into ANNOVAR input format;only annotition deletion(DEL),inversion(INV),insersion(INS).\nUsage:perl $0 <ctx>\nDate:20120111\n"unless@ARGV==1;

open IN,"$ARGV[0]"||die"Can not open the file:$!";
open OUT,">$ARGV[1]";
while(<IN>){
	chomp;
	next if ($_ =~ /#/);
	my@cut=split /\t/,$_;
	my@a=split /;/,$cut[7];

	my$end=substr($a[3],4);
	my$length=substr($a[10],6);
	#print OUT "duplication\t$cut[0]\:$cut[1]\-$end\t$length\t0\t0\t0\t0\t0\t1\n";
	if($cut[4]eq "<DUP>"){
		print OUT "duplication\t$cut[0]\:$cut[1]\-$end\t$length\t0\t0\t0\t0\t0\t1\n";
	}
	if($cut[4]eq "<INVDUP>"){
		print OUT "InvertedDUP\t$cut[0]\:$cut[1]\-$end\t$length\t0\t0\t0\t0\t0\t1\n";
	}
	if($cut[4]eq "<DUP/INS>"){
		print OUT "InsertionDUP\t$cut[0]\:$cut[1]\-$end\t$length\t0\t0\t0\t0\t0\t1\n";
	}
}
close IN;
