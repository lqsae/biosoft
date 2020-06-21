#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: statApp_SVAnno.pl
#
#        USAGE: ./statApp_SVAnno.pl  
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
    1.Statictic SV info in ctx and avinput files
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
	my @samples = getSampleList("$projDir/01.detection",".ctx");
	if(@samples==0){
		print STDERR "no SV files in $projDir/01.detection\n";
		print STDERR "please check the path\n";
		exit(-1);
	}
	my $parentDir = `dirname $RealBin`;
	chomp $parentDir;
#    my $appInfoFile="$parentDir/appPath.info";
 #   if(! -f $appInfoFile){
  #      die "need app path file:$appInfoFile";
   # }
   # my $appHashPtr=getAppPath($appInfoFile);
	#make_path("$outDir/04.SV", {verbose => 1, mode => 0755});
	my @SVCtxFiles;
	my @SVInputFiles_forAnno;
	foreach my $sample(@samples){
		push (@SVCtxFiles,"$projDir/01.detection/$sample.ctx");
		my @tmp;
		if ( -f "$projDir/02.ANNO/$sample.avinput.variant_function"){
			push (@tmp,"$projDir/02.ANNO/$sample.avinput.variant_function");
			push (@tmp,"$projDir/02.ANNO/$sample.avinput.exonic_variant_function");
		}else{
			print STDERR "$sample has no avinput.variant_function file in $projDir/02.ANNO/\n";
		}

		push @SVInputFiles_forAnno,\@tmp;
	}
	my %hash_stat;
	statSV(\%hash_stat,\@SVCtxFiles);
	my $dataHashPtr;
	$dataHashPtr = statAnno(\@SVInputFiles_forAnno);
	my @items=("Category","upstream","exonic","downstream","intronic","upstream;downstream","intergenic","splicing","INS","DEL","INV","DUP","INVDUP","TRA","Total");
	my @itemsName=("Category","Upstream","Exonic","Downstream","Intronic", "Upstream/Downstream","Intergenic","Splicing","INS","DEL","INV","DUP","INVDUP","TRA","Total");    
	my $outFilePath = "$outDir/SV.table.xls";   
	@{$dataHashPtr}{keys %hash_stat}=values(%hash_stat);
	printStateTable($dataHashPtr,\@items,$outFilePath,\@samples,\@itemsName);
}
sub printStateTable{
    my ($dataHashPtr,$itemsArrPtr,$outFilePath,$sampleArrPtr,$namePtr,$tabFlag) = ($_[0],$_[1],$_[2],$_[3],$_[4],$_[5]);
    my $exonic_begin_loc = 4;
    my $n = 2;
    open OUT ,">$outFilePath" or die $!;
    my $categoryStyle = "Category";
    if($tabFlag){
        $categoryStyle = "\tCategory";
    }else{
        $categoryStyle = "Category";
    }
    print OUT join("\t",$categoryStyle,@{$sampleArrPtr});#print OUT join("\t","","Category",@{$sampleArrPtr},"\n");
    print OUT "\n";
    for(my $i=1;$i<@{$namePtr};$i++){
        if($i<@{$itemsArrPtr} and exists $dataHashPtr->{$itemsArrPtr->[$i]}){
            if($namePtr->[$i]=~/^Exonic/){              
                print OUT join("\t",$namePtr->[$i],@{$dataHashPtr->{$itemsArrPtr->[$i]}},"\n");
                next;
            }
            if($namePtr->[$i]=~/^\tCom|Unique/){
                next;#暂时不需要，略过
                print OUT join("\t","",$namePtr->[$i],$dataHashPtr->{$itemsArrPtr->[$i]},"\n");
                
            }
            print OUT join("\t",$namePtr->[$i],@{$dataHashPtr->{$itemsArrPtr->[$i]}},"\n"); #print OUT join("\t","",$namePtr->[$i],@{$dataHashPtr->{$itemsArrPtr->[$i]}},"\n");         
        }
       else{
           if($namePtr->[$i]=~/^Exonic/){
               print OUT join("\t",$namePtr->[$i],"0\t" x @{$sampleArrPtr},"\n");
               next;
           }
           print OUT join("\t",$namePtr->[$i],"0\t" x @{$sampleArrPtr},"\n");#print OUT join("\t","",$namePtr->[$i],"0\t" x @{$sampleArrPtr},"\n");
       }
    }
    close OUT;
}
sub statAnno{
    my @files=@{$_[0]};
    my %hash;
	my $flag = 0;
    #$hash{"total"} = [(0) x @files];
    for (my $i = 0; $i < @files; $i++) {
        open IN,"<$files[$i]->[0]" or $flag = 1;
		if($flag){
			warn $!.":$files[$i]->[0]";
			$flag = 0;
			next;
		}
        while (<IN>) {
            chomp;
            my @line = split;
            next if (@line < 8);
            #$hash{"total"}->[$i]++;
            $line[0] =~ s/^\s+//;
            $line[0] =~ s/^\s+$//;
            #$line[7] =~s/^\s+//;
            #$line[7] =~s/^\s+$//;
            $hash{$line[0]} = [(0) x @files] unless (exists $hash{$line[0]});
            #$hash{$line[7]} = [(0) x @files] unless (exists $hash{$line[7]});
            $hash{$line[0]}->[$i]++;
            #$hash{$line[7]}->[$i]++;
        }
        close IN;
        next if (@{$files[$i]} < 2);
        open IN,"<$files[$i]->[1]" or next;
        while (<IN>) {
            chomp;
            my @line = split;
            $hash{"$line[2] $line[1]"} = [(0) x @files] unless (exists $hash{"$line[2] $line[1]"});
            $hash{"$line[2] $line[1]"}->[$i]++;
        }
    }
    return \%hash;
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
sub getAppPath($){
    my $appPathFile = $_[0];
    open IN,"<$appPathFile" or die "$!";
    my $line;
    my %appHash;
    while($line=<IN>){
        my @tmp=split/=/,$line;
		chomp $tmp[1];
        $appHash{$tmp[0]} = $tmp[1];
    }
    close IN;
    return \%appHash;
}
sub statSV{
    my $hash_statPtr= $_[0];
    my $vcfFilesArrPtr = $_[1];
    my %dataHash;
    my (@INS,@DEL,@INV,@DUP,@INVDUP,@TRA,@Total);
    
    foreach my $file(@{$vcfFilesArrPtr}){
        open IN,"<$file" or die $!;
        my @items;
        my $beginStat = 0;
        $dataHash{"INS"}=0;
        $dataHash{"DEL"}=0;
        $dataHash{"INV"}=0;
	$dataHash{"DUP"}=0;
	$dataHash{"INVDUP"}=0;
        $dataHash{"TRA"}=0;
        $dataHash{"Total"}=0;
        my $line;
	my $error=0;
        while ($line=<IN>){
            @items = split /\t/,$line;
#=pod    

        if(@items<6) {
                next;
            }
            if(@items>5 and $items[6] eq "Type"){
                $beginStat = 1;
                next;
            }


#	if ($items[6]=~ m/INS/){
#print "yes\t";}
	
           next unless ($beginStat);
            $dataHash{$items[6]}++;
            $dataHash{"Total"}++;
	$error++;
	
        }
print "$error\n";   
        push @INS,$dataHash{"INS"};
        push @DEL,$dataHash{"DEL"};
        push @INV,$dataHash{"INV"};
        push @DUP,$dataHash{"DUP"};
        push @INVDUP,$dataHash{"INVDUP"};
	push @TRA,$dataHash{"TRA"};
        push @Total,$dataHash{"Total"};
    }
    $hash_statPtr->{"INS"}=\@INS;
    $hash_statPtr->{"DEL"}=\@DEL;
    $hash_statPtr->{"INV"}=\@INV;
    $hash_statPtr->{"DUP"}=\@DUP;
    $hash_statPtr->{"INVDUP"}=\@INVDUP;
    $hash_statPtr->{"TRA"}=\@TRA;
    $hash_statPtr->{"Total"}=\@Total;
}
main();
