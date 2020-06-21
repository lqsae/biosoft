#!usr/bin/perl
open IN,"samtools view -h $ARGV[0]|";
open OUT,">$ARGV[1]";
print OUT "readsid\tflag\tchr\tpos\tMQ\treads_start\treads_end\treads_length\tmem_length\tidentity\n";
while(<IN>){
	chomp;
	my @line=split(/\t/,$_);
	$line[5]=~s/S/\t/g;
	$line[5]=~s/=/\t/g;
	my @readspos=split(/\t/,$line[5]);
	 my $readslength=length($line[9]);
	my @identity=split(/:/,$line[19]);
	my $iden=1-$identity[2];
	if($line[1]eq"0"||$line[1]eq "2048"){

		my $readsstart=$readspos[0];
		my $readsend=$readslength - $readspos[-1];
		my $memlength=$readsend - $readsstart;
		 print OUT "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$readsstart\t$readsend\t$readslength\t$memlength\t$iden\n";
	}elsif($line[1]eq"16"||$line[1]eq "2064"){
		my $readsstart=$readspos[-1];
		my $readsend=$readslength - $readspos[0];
		my $memlength=$readsend - $readsstart;
		 print OUT "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$readsstart\t$readsend\t$readslength\t$memlength\t$iden\n";
	}
#	print OUT "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$readsstart\t$readsend\t$readslength\t$memlength\t$readspos[0]\n";
}
