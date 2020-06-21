#!/usr/bin/perl -w
use strict;

die "perl $0 <indir> <in.samples> <outfile>" unless(@ARGV==3);

my $indir=shift;
my $sample=shift;
    scripts:"/mnt/CCX/pipeline/Variation/Long_Variation/ref/script/statBWA.pl"
my $outfile=shift;
my @samples = split /,/,$sample;
open OUT,">$outfile" or die $!;

print OUT "Sample\tclean reads\tclean bases\tmapped reads\tmapped bases\tmismatch bases\tmismatch rate\tMapping rate(%)\tAverage depth(X)\tCoverage 1X(%)\tCoverage 4X(%)\n";
for(my $i = 0; $i < @samples; $i++) {
	my @array = ($samples[$i], 0,0,0,0,0,0);
	open IN,"<$indir/$samples[$i]/$samples[$i].sorted.alninfo" or die $!;
	while (<IN>) {
		chomp;
		my @line = split /\t/,$_;
		$array[3] = $line[1] if ($line[0] eq "mapped reads:");
		$array[1] = $line[1] if ($line[0] eq "clean reads:");
		$array[2] = $line[1] if ($line[0] eq "clean bases(bp):");
		$array[4] = $line[1] if ($line[0] eq "mapped bases(bp):");
		$array[5] = $line[1] if ($line[0] eq "mismatch bases(bp):");
		$array[6] = $line[1] if ($line[0] eq "mismatch rate:");
		$array[7] = $line[1] if ($line[0] eq "mapping rate:");
		$array[6] =~ s/%//g;
		$array[7] =~ s/%//g;
	}
	close IN;
	open IN,"<$indir/$samples[$i]/summary.txt" or die $!;
	while (<IN>) {
		chomp;
		my @line = split /\t/,$_;
		$array[8] = $line[1] if ($line[0] eq "Average_sequencing_depth:");
		$array[9] = $line[1] if ($line[0] eq "Coverage:");
		$array[10] = $line[1] if ($line[0] eq "Coverage_at_least_4X:");
		$array[9] =~ s/%//g;
		$array[10] =~ s/%//g;
	}
	close IN;
	print OUT join("\t",@array),"\n";
}
close OUT;

