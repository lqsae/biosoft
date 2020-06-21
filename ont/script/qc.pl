#!/usr/bin/perl -w
#author:yanglingyun
#input.bam:需要进行质控的bam文件。
#outdir:数据输出路径。
#filter:subreads length >=1.5k && rq >= 0.8
use strict;
use File::Path qw(make_path);
use File::Basename;
unless (@ARGV==3){
die"Usage:perl $0 <input.bam> <outdir>\n";
}
my ($sample,$infile,$path)=@ARGV;
#my $infileBN = basename($infile);
#`mkdir $path/cleandata`;
#`mkdir $path/QCstat`;
make_path("$path/01.cleandata", {verbose => 1, mode => 0755}) unless (-d "$path/cleandata");
make_path("$path/02.QCstat", {verbose => 1, mode => 0755}) unless (-d "$path/QCstat");
#open IN , $infile|| "error:can't open $infile";
#open IN ,"samtools view  $infile |" or die; 
open IN, "samtools view -h $infile | " or die $!;   ##samtools转换时需要头文件
#open IN,"$infile |" or die;
print "$path/01.cleandata/$sample.clean.bam\n";
open OUT,">$path/01.cleandata/$sample.clean.sam" || die $!;   ###此处生成的应该为sam文件
open OUT2,">$path/02.QCstat/$sample.QCresult" || die $!;
open OUT3,">$path/02.QCstat/$sample.clean_reads_length" ||die $!; 
print OUT2"sample\tdata_length\tsubreads_number\tmean_subreads_length\tGC(%)\tN50\tdata_lenth\tsubreads_number\tmean_subreads_length\tGC(%)\tN50\n";
my(@a,@a1,@a2,%a1,%a2);
my $m=0;
my $n=0;
my $all=();
my $all2=0;
my $allGC=0;
my $allGC2=0;
my ($length,$rq,$GC,$gc,$gc2);
while (<IN>) {
	chomp;
	if(/^@/) {
		print OUT "$_\n";
		next;
	}
	$m++;
#	last if($m>100);    # test for samtools view -bS
	@a=split/\t/,$_;
	$length=length $a[9];
	$all+=$length;
	$a1{$a[0]}=$length;
	$GC=($a[9]=~s/G/G/g)+($a[9]=~s/C/C/g);
	$allGC+=$GC;
	$rq=(split(/:/,$a[17],3))[2];
	if ($length >=1500 && $rq>=0.8){		
#		print OUT"$_";
		print OUT "$_\n";   ### 这里需要加一个回车
		$n++;
		$all2+=$length;
		$a2{$a[0]}=$length;
		$allGC2+=$GC;
	}
}
#print "$m\n";
close IN;
close OUT;
my $avlen=int($all/$m);
my $avlen2=int($all2/$n);
$gc=$allGC/$all*100;
$gc2=$allGC2/$all2*100;
$gc=sprintf("%.2f",$gc);
$gc2=sprintf("%.2f",$gc2);
@a1=sort{$a<=>$b} values %a1;
my $i=0;my $i1=0;my $i2;
for (@a1){                    ###这里是计算读长的N50，不过这里计算有问题，N50应该为跨过N50长度的那个片段，而不是前一个片段的长度，
	if($i<$all/2){            ###并且这里算到第一个大于一半长度并没有暂停，而是继续算下去了，此处需要修改
		$i+=$_;
		$i1++;
	}else{
#		$i2=$a1[$i1-1];
		$i2 = $a1[$i1];   ###已做出修改, 下同
		last;
	}
}
@a2=sort{$a<=>$b} values %a2;
my $j=0;my $j1=0;my $j2;
for (@a2){
#print"$_\t";
	if($j<$all2/2){
		$j+=$_;
		$j1++;
	} else {
#		$j2=$a2[$j1-1];
		$j2 = $a2[$j1]; 
		last;
	}
}
print OUT2"$sample\t$all\t$m\t$avlen\t$gc\t$i2\t$all2\t$n\t$avlen2\t$gc2\t$j2\n";
close OUT2;
print OUT3"reads_name\treads_length\n";
my ($key,$value);
while (($key,$value)=each %a2){   ###这里可以修改为按照reads长度由小到大进行排序
	print OUT3"$key\t$value\n";
}

close OUT3;
