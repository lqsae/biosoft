#!/usr/bin/python3

import sys
import collections
import os
from argparse import ArgumentParser

SAMTOOLS = '/PUBLIC/software/public/VarCall/samtools/samtools-0.1.18/samtools'


protein_table = {'UUU': 'F', 'CUU': 'L', 'AUU': 'I', 'GUU': 'V', \
                 'UUC': 'F', 'CUC': 'L', 'AUC': 'I', 'GUC': 'V', \
                 'UUA': 'L', 'CUA': 'L', 'AUA': 'I', 'GUA': 'V', \
                 'UUG': 'L', 'CUG': 'L', 'AUG': 'M', 'GUG': 'V', \
                 'UCU': 'S', 'CCU': 'P', 'ACU': 'T', 'GCU': 'A', \
                 'UCC': 'S', 'CCC': 'P', 'ACC': 'T', 'GCC': 'A', \
                 'UCA': 'S', 'CCA': 'P', 'ACA': 'T', 'GCA': 'A', \
                 'UCG': 'S', 'CCG': 'P', 'ACG': 'T', 'GCG': 'A', \
                 'UAU': 'Y', 'CAU': 'H', 'AAU': 'N', 'GAU': 'D', \
                 'UAC': 'Y', 'CAC': 'H', 'AAC': 'N', 'GAC': 'D', \
                 'UAA': 'Stop', 'CAA': 'Q', 'AAA': 'K', 'GAA': 'E', \
                 'UAG': 'Stop', 'CAG': 'Q', 'AAG': 'K', 'GAG': 'E', \
                 'UGU': 'C', 'CGU': 'R', 'AGU': 'S', 'GGU': 'G', \
                 'UGC': 'C', 'CGC': 'R', 'AGC': 'S', 'GGC': 'G', \
                 'UGA': 'Stop', 'CGA': 'R', 'AGA': 'R', 'GGA': 'G', \
                 'UGG': 'W', 'CGG': 'R', 'AGG': 'R', 'GGG': 'G'
                 }


def parse_gff(gff):
    ''' 获取基因CDS起始位置'''
    dict_gene = collections.defaultdict(list)
    with open(gff) as f:
        for line in f:
            if not line.strip().startswith('#'):
                tags = line.strip().split('\t')
                info = tags[8]
                tag_3 = tags[2]
                if tag_3 == 'gene':
                    gene_id = info.split(';')[0].split('=')[1]
                elif tag_3 == 'CDS':
                    CDS_start = tags[3]
                    # dict_gene[gene_id].append(CDS_start)
                    CDS_end = tags[4]
                    tuple_CDS = (CDS_start, CDS_end)
                    dict_gene[gene_id].append(tuple_CDS)
    return dict_gene


def extract_sequence(cmd):
    '''从基因组中提取序列'''
    f = os.popen(cmd)
    dna_sequence = ''
    for line in f.readlines():
        if not line.strip().startswith('>'):
            dna_sequence += line.strip()
    return dna_sequence


def dna2mrna(dna_sequence):
    '''dna转化为mrna'''
    dict_nc = {'A': 'U', 'N': 'N', 'G': 'C', 'C': 'G', 'T': 'A'}
    mrna = ''.join([dict_nc[i] for i in reversed(dna_sequence.upper())])
    return mrna


def mrna2protein(mran_squence):
    '''mran转化为蛋白质'''
    protein = protein_table[mran_squence]
    return protein


def get_cmd(scaffold, fa, trans_start, trans_end):
    '''生成命令'''
    cmd = '{samtools} faidx {fa} {scaffold}:{trans_start}-{trans_end}'.format(
        samtools=SAMTOOLS,
        fa=fa,
        scaffold=scaffold,
        trans_start=trans_start,
        trans_end=trans_end)
    return cmd


def parse_snp(anno, dict_CDS, fa):
    ''' 根据SNP的位置获取SNP在CDS的位置,然后获取该SNP的编码序列'''
    with open(anno) as f:
        for line in f:
            if not line.strip().startswith('TransID'):
                tags = line.strip().split('\t')
                gene_id = tags[0]
                pos = tags[3]
                ref = tags[4]
                alt = tags[5]
                scaffold = tags[2]
                CDS_pos = dict_CDS.get(gene_id)
                unq_CDS_pos = set(CDS_pos)
                for i in unq_CDS_pos:
                    if int(i[0]) <= int(pos) <= int(i[1]):#判断该SNP位点在那个CDS内
                        if (int(pos) - int(i[0])) % 3 == 0:#如果该位点在密码子第3个位置
                            trans_start = int(pos) - 2
                            trans_end = int(pos)
                            bias = 0
                            cmd = get_cmd(scaffold=scaffold, fa=fa, trans_start=trans_start, trans_end=trans_end)
                            ref_dna = extract_sequence(cmd)
                            m1 = list(ref_dna)
                            m1[2] = alt
                            alt_dna = ''.join(m1)

                        elif (int(pos) - int(i[0])) % 3 == 1:#如果该位点在密码子第1个位置
                            trans_start = int(pos)
                            trans_end = int(pos) + 2
                            bias = 1
                            cmd = get_cmd(scaffold=scaffold, fa=fa, trans_start=trans_start, trans_end=trans_end)
                            ref_dna = extract_sequence(cmd)
                            m2 = list(ref_dna)
                            m2[0] = alt
                            alt_dna = ''.join(m2)
                        elif (int(pos) - int(i[0])) % 3 == 2:#如果该位点在密码子第2个位置
                            trans_start = int(pos) - 1
                            trans_end = int(pos) + 1
                            bias = 2
                            cmd = get_cmd(scaffold=scaffold, fa=fa, trans_start=trans_start, trans_end=trans_end)
                            ref_dna = extract_sequence(cmd)
                            m3 = list(ref_dna)
                            m3[1] = alt
                            alt_dna = ''.join(m3)
                        ref_mrna = dna2mrna(ref_dna)
                        alt_mrna = dna2mrna(alt_dna)
                        ref_protein = mrna2protein(ref_mrna)
                        alt_protein = mrna2protein(alt_mrna)
                        print(line.strip() + '\t' +
                              str(bias) + '\t'
                              + ref_mrna + '\t' + alt_mrna + '\t'
                              + ref_protein + '\t' + alt_protein)

def get_args():
    parser=ArgumentParser(description='get the protein of the SNP')
    parser.add_argument('--gff',help='gff file')
    parser.add_argument('--fa',help='genome file')
    parser.add_argument('--anno',type=str,help='anno file')
    args=parser.parse_args()
    return args


def main():
    args = get_args()
    gff = args.gff
    anno = args.anno
    fa = args.fa
    dict_gene = parse_gff(gff)
    parse_snp(anno, dict_gene, fa)

if __name__ == '__main__':
    main()
