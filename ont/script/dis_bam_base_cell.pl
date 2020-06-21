#!/NJPROJ/DENOVO/software/ActivePerl-5.18/bin/perl -w
use strict;
use Getopt::Long;
use Pod::Usage;
use List::Util qw/sum max/;
use File::Path qw/make_path/;

my ($help, $file);
my $outdir ||= ".";
my $prefix ||= "test";

GetOptions(
	'help'=>\$help,
	'file:s' =>\$file,
	'outdir:s' =>\$outdir,
	'prefix:s' =>\$prefix,
);
pod2usage 1 if($help || ! defined $file || ! -e $file);

=head1 NAME

=head1 SYNOPSIS

perl dis_bam_base.pl -file -outdir -prefix 

=head1 OPTIONS

 -help     show help infomation
 -file     input bam  file [required]
 -outdir   output dir, default ./
 -prefix   output prefix, default test

=cut

my (%polyh,%insh,%subh);
my (%polyhf,%inshf,%subhf);
my (@polya,@insa,@suba);
my (@polya_s,@insa_s,@suba_s);
my $cnt = 0;

	if(!-e $file){print STDERR "WARNING: $file not exists, skip it!\n"; next;}
	$cnt++;
	open IN, "/mnt/CCX/Share/software/Anaconda3/bin/samtools view $file|" or die $!;
	while(<IN>){
    		my ($zmw,$len) = (split '[\t\/]', $_)[1,2];
		my @pos = split	'_', $len;
		#$polyh{"$zmw\_$cnt"} = $pos[1];
		push @{$polyh{"$zmw\_$cnt"}}, ($pos[0],$pos[1]);
		push @{$insh{"$zmw\_$cnt"}}, ($pos[1]-$pos[0]);
		push @suba, ($pos[1]-$pos[0]);
	}
	close IN;

#@polya = values %polyh;
foreach my $key (keys %polyh){
	my @tmph = @{$polyh{$key}};
	push @polya, ($tmph[-1]-$tmph[0]);
}

foreach my $key (keys %insh){
	push @insa, (max @{$insh{$key}});
}

make_path($outdir) unless(-d $outdir);
open OUTPF, ">$outdir/$prefix.Polymerase_frq.xlsx" or die $!;
open OUTIF, ">$outdir/$prefix.Insertsize_frq.xlsx" or die $!;
open OUTSF, ">$outdir/$prefix.Subreads_frq.xlsx" or die $!;

foreach(@polya){print OUTPF $_."\n";}
foreach(@insa){print OUTIF $_."\n";}
foreach(@suba){print OUTSF $_."\n";}

close OUTSF;
close OUTPF;
close OUTIF;
