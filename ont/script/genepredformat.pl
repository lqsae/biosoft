#!/usr/bin/perl -w

use Getopt::Long;

my ($pesoap,$out_file);
GetOptions(
  "i|in-file=s"  =>\$pesoap,
  "o|out-file=s"    =>\$out_file
  );
  
open IN, $pesoap or die "ERROR: open $pesoap: $!";
open OUTM, ">$out_file" or die "ERROR: open >$out_file: $!";
$n=0;
while(defined($line=<IN>)) {
	chomp $line;
	$n++;
	@colu=split(/\s+/,$line);
	#$chr="chr".$colu[1];
	$chr=$colu[1];
	print OUTM $n,"\t",$colu[0],"\t",$chr,"\t",join ("\t",@colu[2..14]),"\n";
}
	
