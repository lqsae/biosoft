#!/usr/bin/perl -w
use strict;
unless(@ARGV==2){
die"Usage: perl $0 <input.vcf> <out.ctx>\n";
}
my($infile,$outfile)=@ARGV;
my ($name,$Orientation,$chr1,$chr2,$Pos1,$Pos2,$Type,$Size,$num_Reads,@a,@b,$RE,$REF_strand,$flag);
open IN, "$infile" ||"error: can't open infile:$infile";
open OUT, "> $outfile" || die $!;
while (<IN>){
	next if (/##/);
	if(/#C/){
		chomp;	
		@a=split/\t/,$_;
		$name=pop @a;
	print OUT "#Chr1\tPos1\tOrientation1\tChr2\tPos2\tOrientation2\tType\tSize\tflag\tRE\tREF_strand\t$name\n";
	}else{
		chomp;
		@a=split/\t/,$_;
		@b=split/;/,$a[7];
		$chr1 = shift @a;
		$Pos1=shift @a;
		$Orientation="NA";
		$flag=substr($b[0],0);
		$chr2= substr($b[2],5);
		$Pos2=substr($b[3],4);
		$Type=substr($b[8],7);
		$Size=substr($b[10],6);
		$RE=substr($b[12],3);
		$REF_strand=substr($b[13],11);
		print OUT"$chr1\t$Pos1\t$Orientation\t$chr2\t$Pos2\t$Orientation\t$Type\t$Size\t$flag\t$RE\t$REF_strand\t$Orientation\n";
	}
}
close IN;
close OUT;
