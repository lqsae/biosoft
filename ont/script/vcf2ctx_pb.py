#vcf文件转化为ctx文件 pacbio数据
import sys
import re
file=sys.argv[1]
with open(file) as f:
	head="#Chr1	Pos1	Orientation1	Chr2	Pos2	Orientation2	Type	Size	flag	RE	REF_strand	/NJPROJ2/CCX/Project/Long_Reads_Variation/H101SC19051885_mifeng_lqs/ngmlr/test.sorted.bam"
	print(head)
	for line in f:
		if line.strip()[0]!="#":
			tag=line.strip().split("\t")
			Chr1=tag[0]
			Pos1=tag[1]
			Orientation1="NA"
			Chr2=re.search('CHR2=(\w*\d*\.\d*);',line).group(1)
			Pos2=re.search('END=(\d+)',line).group(1)
			Orientation2="NA"
			Type=re.search('SVTYPE=([a-zA-Z]+)',line).group(1)
            try:
                Size=re.search('SVLEN=(.\d+)',line).group(1)
            except :
                Size='NA'
			flag=tag[7].split(";")[0]
			RE=re.search('RE=(\d+)',line).group(1)
			REF_strand=re.search('REF_strand=(\d+,\d+)',line).group(1)
			all=[Chr1,Pos1,Orientation1,Chr2,Pos2,Orientation2,Type,Size,flag,RE,REF_strand]
			print('\t'.join(all)+'\t'+'NA')
