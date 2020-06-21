#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
my $USAGE = qq{
Name:
	$0
Function:

Options:
	-fai	<string>	samtools faidx file of reference
	-ann	<string>	sample.avinput.exonic_variant_function file
	-stp	<integer>	Step size for calculate SNP and indel density [default 5000000]
	-wsz	<integer>	Windows size for calculate SNP density [default 5000000]
	-out	<string>	Output file name prefix
Author:
	CaoYinchuan;caoyinchuan\@novogene.cn
Version:
	v1.0;2013-10-30
};
my($faiFile,$annFile,$stepSize,$windowSize,$outFile);
GetOptions(
	"fai=s" => \$faiFile,
	"ann=s" => \$annFile,
	"stp=i" => \$stepSize,
	"wsz=i" => \$windowSize,
	"out=s" => \$outFile,
);
die "$USAGE" unless ($outFile and $faiFile and $annFile);
$stepSize ||= 5000000;
$windowSize ||= 5000000;
my %density;
open FAI,"<$faiFile" or die $!;
while (<FAI>) {
	chomp;
        my @line = split;
        next if (@line < 5);
        my ($chr,$len) = @line[0,1];
        my @array;
        for(my $i = 0; $i * $stepSize + $windowSize <= $len; $i++) {
                $array[$i] = [$i * $stepSize + 1, $i * $stepSize + $windowSize, 0, 0];
        }
        $density{$chr} = [@array];
}
close FAI;
open IN,"sort -k5,5 -k6,6n $annFile |" or die $!;
while (<IN>) {
	chomp;
	my @line = split;
	next if ($line[1] eq "synonymous");
	my ($chr,$pos) = @line[4,5];
	next unless (exists $density{$chr});
	my $index = int(($pos - $windowSize) / $stepSize);
	$index = 0 if ($index < 0);
	for (my $i = $index; $i < @{$density{$chr}}; $i++) {
		last if ($density{$chr}->[$i]->[0] > $pos);
		next if ($density{$chr}->[$i]->[1] < $pos);
		($line[2] eq "SNV") ? $density{$chr}->[$i]->[2]++ : $density{$chr}->[$i]->[3]++;
	}
}
close IN;
open OUT,">$outFile.varDensity" or die $!;
foreach my $chr (sort keys %density) {
	foreach my $d (@{$density{$chr}}) {
		#my $snp = 100 * $d->[2] / ($d->[1]-$d->[0]+1);
		#my $indel = 100 * $d->[3] / ($d->[1]-$d->[0]+1);
		print OUT join("\t",$chr, @$d),"\n";
	}
}
close OUT;
open RCMD,"|R --vanilla --slave" or die $!;
print RCMD "data <- read.table('$outFile.varDensity',header=FALSE)\n";
print RCMD "data[,2] <- data[,2]/1000000\n";
print RCMD "data[,3] <- data[,3]/1000000\n";
print RCMD "pdf('$outFile.varDensity.pdf',h=4,w=8)\n";
foreach my $chr (sort keys %density) {
	next unless (@{$density{$chr}});
	print RCMD "par(mfrow=c(2,1),mar=c(0,4.1,4.1,2.1))\n";
	print RCMD "subdata <- data[data[,1]=='$chr',]\n";
	print RCMD "maxy1 <- max(subdata[,4])\n";
	print RCMD "maxy2 <- max(subdata[,5])\n";
	print RCMD "maxx <- max(subdata[,2])\n";
	print RCMD "plot(subdata[,2],subdata[,4], type='l', col='blue',xlim=c(0,maxx), ylim=c(0,maxy1),main='Nonsynonymous variation distribution on $chr', xlab='',ylab='SNP Number',col.lab='blue',axes=FALSE)\n";
	print RCMD "axis(2,col='blue',col.axis='blue')\n";
	print RCMD "box()\n";
	print RCMD "par(mar=c(5.1,4.1,0,2.1))\n";
	print RCMD "plot(subdata[,2],subdata[,5], type='l', xlim=c(0,maxx),ylim=c(0,maxy2),main='',xlab='',ylab='Indel Number',col='red',col.lab='red',col.axis='red')\n";
	print RCMD "title(xlab='position(Mb),WindowSize=$windowSize',col='black')\n";
}
print RCMD "dev.off()\n";
close RCMD;
