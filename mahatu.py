
from  itertools import cycle
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
import numpy as np

def get_format_df(file):
    with open(file) as f:
        chr_list =[]
        pos_list = []
        p_list = []
        for line in f:
            if line.strip()[0] != 'P':
                tags = line.strip().split()
                chr_list.append(tags[0].split(':')[0])
                pos_list.append(tags[0].split(':')[1])
                p_list.append(tags[1])         
    df_p = pd.DataFrame({'CHR':chr_list,'POS':pos_list,'P_value':p_list})
    df_p = df_p.sort_values(by = ['CHR','POS'])
    df_p['position'] = range(len(df_p))
    df_p['P_value'] = df_p['P_value'].astype('float')
    df_p['P_value'] = -np.log10(df_p['P_value'])
    return df_p

def plot(df_p):
    plt.figure(figsize = (20,10))
    sns.set_style('whitegrid')
    plt.style.use('ggplot')
    sns.stripplot(x = "CHR",
                y = "P_value",
                data = df_p, 
                jitter = 0.4,
                palette = "Set1", 
                dodge = True,
                alpha = 0.5,
                linewidth = 0,
                s=5)
    plt.ylabel('-log1o(Pvalue)')
    plt.title('indel')
    plt.ylim(0,5)
    plt.show()
file ='c://生物学软件/LDAK/mm.pvalues'
df_p = get_format_df(file)
plot(df_p)
