#从vcf文件获取cnv文件
import sys
file=sys.argv[1]
with open(file) as f:
	for line in f:
		if line.strip()[0]=="#":
			print(line.strip())
		else:
			list=line.strip().split("\t")
			type=list[4]
			if (type=="<DUP>")or(type=="<INVDUP>"):
				print(line.strip())
