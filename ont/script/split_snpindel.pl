#!/usr/bin/perl -w

#===============================================================================

=head1 Name
        split_snpindel.pl

=head1 Description
        split snp and indel from the file exonic_variant_function

=head1 Version
Author:   Zhaohongwei,zhaohongwei@novogene.cn
Company:  NOVOGENE                                  
Version:  1.0                                  
Created:  Fri Nov 23 17:42:07 CST 2012

=head1 Usage
        split_snpindel.pl exonic_variant_function indelfile snpfile

=head1 Exmple

=cut
#===============================================================================

use Getopt::Long;
GetOptions(
        "i=s" =>\ $in,
        "i1=s" =>\ $i1,
        "i2=s" =>\ $i2,
        "indel=s" =>\ $indel,
        "snp=s" =>\ $snp
);
print STDERR "Program begin at:\t".`date`."\n";

open IN,$in || die $!;
open INDEL,">$indel" || die $!;
open SNP,">$snp" || die $!;
$i1 ||= 6;
$i2 ||= 7;

while(<IN>){
	chomp;
	@info = split /\t/;
	if($info[$i1] ne "-" && $info[$i2] ne "-" && length $info[$i1] eq 1 && length $info[$i2] eq 1){
		print SNP $_,"\n";
	}else{
		print INDEL $_,"\n";
	}
}
print STDERR "Program finaly at:\t".`date`."\n";

close IN;
close INDEL;
close SNP;
