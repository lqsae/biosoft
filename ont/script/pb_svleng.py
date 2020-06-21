#user/bin/env/python3
#统计SV长度分布
import sys
import pandas as pd
import numpy as np
step=100
file=sys.argv[1]#ctx文件
df=pd.read_csv(file,sep='\t')
qujian_all=range(0,1200,step)
dict_win={}
dict_win['>1200']=0
for i in qujian_all:
    	dict_win[i]=0
for m in range(len(df)):
	try:	
		value=df.iloc[m,7]
		if int(value)>=1200:
			dict_win['>1200']+=1
		else:
			qujian=int(value/step)*step
			dict_win[qujian]+=1
	except:
		pass
all=sum(dict_win.values())
for key ,value in dict_win.items():
	if key!='>1200':
		name=str(key)+'-'+str(key+step)
		print(name+'\t'+str(round((value/all)*100,2)))
	else:
		print(str(key)+'\t'+str(round((value/all)*100,2)))

