#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: statApp_SVLen.pl
#
#        USAGE: ./statApp_SVLen.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 2015年08月21日 11时20分27秒
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Getopt::Long;
use File::Path qw(make_path remove_tree);
use File::Copy;
use Cwd 'abs_path';
use FindBin qw($RealBin);

my $USAGE = qq{
Name:
    $0
Function:
    1.Statictic SNP and Indel: ts/tv, Het Rate, Density, SNP and Indel compare
    2.Annotation
Usage:
    $0 -projDir projectDirectory -outDir outDirectory
Options:
    -projDir <string>    project Directory
    -outDir <string>    project Directory
Notice:

Author:

    Cao Yinchuan;Cao hong\@novogene.cn
Version:
        v1.0;2013-10-12
        v1.1;2015-12-31
        v1.2;2016-11-08 change  cut[0] != cut[3] to cut[0] != cut[3]
};
my ($outDir,$projDir);
GetOptions (
    "projDir=s" => \$projDir,
    "outDir=s" => \$outDir,
);
die "$USAGE" unless ($outDir);
$outDir = abs_path($outDir);
if(!defined($projDir)){
	$projDir = $outDir;
}else{
	$projDir = abs_path($projDir);
}

sub main(){
 #stat SV results
	my @samples = getSampleList("$projDir/01.detection",".ctx");
	if(@samples==0){
		print STDERR "no SV result files in $projDir/01.detection\n";
		print STDERR "please check the path\n";
		exit(0);
	}
	my @SVCtxFiles;
	foreach my $sample(@samples){
		push (@SVCtxFiles,"$projDir/01.detection/$sample.ctx");
	}
	my $svLenRateFile = "$outDir/SV.len.rate";
    my $svLenFile = "$outDir/SV.len.num";
	statSVLen(\@SVCtxFiles,\@samples, $svLenRateFile, $svLenFile);
	plotSVlen($svLenRateFile);
}

sub plotSVlen {
    my $file = $_[0];
	my $out = $file;
    open IN,"<$file" or die $!;
    open OUT,">$out.data" or die $!;
    print OUT "X\tY\tSample\n";
    my @array;
    while (<IN>) {
        chomp;
        my @line = split /\t/, $_;
        if (@array) {
            for(my $i = 1; $i < @line; $i++) {
                print OUT join("\t", $line[0], $line[$i], $array[$i]),"\n";
            }
        } else {
            @array = @line;
        }
    }
    close IN;
    close OUT;
    open RCMD,">$out.R" or die $!;
    print RCMD "library(\"ggplot2\")\n";
    print RCMD "library(scales)\n";
    print RCMD "cols<-c(brewer_pal(palette=\"Set2\")(8),brewer_pal(palette=\"Set3\")(12),brewer_pal(palette=\"Accent\")(8),brewer_pal(palette=\"Paired\")(12))\n";
    print RCMD "data <- read.table('$out.data', header=T)\n";
    print RCMD "data\$X <- factor(data\$X, levels = unique(data\$X), ordered = TRUE)\n";
    #print RCMD "png(\"$out.png\", type='cairo')\n";
    print RCMD "p<-ggplot(data, aes(x=X,y=Y,fill=factor(Sample)))+geom_bar(position = 'dodge', stat='identity')+coord_flip()+labs(list(title=\"SV length Distribution\",x=\"SV length(bp)\",y=\"Percentage of SVs(%)\"))+scale_fill_manual(values=cols)+guides(fill=guide_legend(title=\"Sample\"))\n";
    print RCMD "ggsave(filename=\"$out.png\", type='cairo',plot=p)\n";
    print RCMD "ggsave(filename=\"$out.pdf\", plot=p)\n";
    #print RCMD "dev.off()\n";
    close RCMD;
    system "R -f $out.R";
}

sub getSampleList {
	my ($dir,$regex) = @_;
	my @files = `ls $dir/*$regex`;
	my @samples;
	foreach my $f (@files) {
		chomp $f;
		next unless ($f =~ /([^\/]+)$regex$/); 
		push(@samples, $1);
	}
	return @samples;
}
sub statSVLen{
    my $filesArrPtr=$_[0];
    my $sampleArrPtr=$_[1];
	my $svLenRateFile = $_[2];
	my $svLenFile = $_[3];
    my @dataHashPtrArr;
    my @totals;
    my@name=("0-100","100-200","200-300","300-400","400-500","500-600","600-700","700-800","800-900","900-1000","1000-1100","1100-1200",">1200");
    foreach my $file(@{$filesArrPtr}){
        open IN,"<$file" or die $!;
        my%hash=(
        $name[0]=>0,
        $name[1]=>0,
        $name[2]=>0,
        $name[3]=>0,
        $name[4]=>0,
        $name[5]=>0,
        $name[6]=>0,
        $name[7]=>0,
        $name[8]=>0,
        $name[9]=>0,
        $name[10]=>0,
        $name[11]=>0,
        $name[12]=>0,
        );
        
        my$total=0;
        while(<IN>){
            chomp;
            next if(/#/);
             my@cut=split /\t/,$_;
			 next if ($cut[0] ne $cut[3]);#去掉对染色体间易位的统计2015.12.31
            my$size=0;
            $total++;
            $size=abs($cut[7]);         
            my$low=(int ($size/100));
            if($low<12){
                $hash{$name[$low]}++;
            }else{
                $hash{$name[12]}++;
            }           
        }
        close IN;
        push @dataHashPtrArr,\%hash;
        push @totals,$total;
    }
    
    open OUTRATE,">$svLenRateFile" or die $!;
    open OUTNUM, ">$svLenFile" or die $!;
    print OUTRATE join("\t","",@{$sampleArrPtr});print OUTRATE "\n";
    print OUTNUM join("\t","",@{$sampleArrPtr});print OUTNUM "\n";
    foreach my $item(@name){
        my $lineNum = $item."\t";
        my $lineR = $item."\t";
        my $n=0;
        foreach my $ptr(@dataHashPtrArr){
            $lineNum .= $ptr->{$item}."\t";
            my $rate = ($ptr->{$item}/$totals[$n])*100;
            $lineR .= $rate."\t";
            $n++;
        }
        print OUTRATE $lineR."\n";
        print OUTNUM $lineNum."\n"; 
    }
    close OUTRATE;
    close OUTNUM;
}
main();
