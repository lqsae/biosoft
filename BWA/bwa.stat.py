#!/usr/bin/python3
import os
import time
import sys
import logging
from argparse import ArgumentParser
import multiprocessing as mp

BWAPATH = '/TJPROJ4/CCX/Users/liuqingshan/miniconda3/bin/bwa'
SAMTOOLSPATH = '/TJPROJ4/CCX/Users/liuqingshan/miniconda3/bin/samtools'
PERL = '/PUBLIC/software/public/System/Perl-5.18.2/bin/perl'
PERL_SCRIPT = '/TJPROJ4/CCX/Share/Pipeline/BSA/00.bin/indBin/depth_v2.pl'

logging.basicConfig(level=logging.INFO, format='%(asctime)s :: %(levelname)s :: %(message)s', filename='bwa.log')


class Bwa:
    def __init__(self, wkdir, thread, ref, length):
        self.wkdir = wkdir
        self.thread = thread
        self.length = length
        self.ref = ref
        self.bwa_dir = os.path.join(self.wkdir, '02.BWA')
        self.qc_dir = os.path.join(self.wkdir, '01.QC')

    def mkdir(self):
        '''创建文件夹'''
        if not os.path.exists(self.qc_dir):
            os.mkdir(self.qc_dir)
        else:
            logging.info('01.QC has exists')

        if not os.path.exists(self.bwa_dir):
            os.mkdir(self.bwa_dir)
        else:
            logging.info("02.BWA has exists")

    def bulid_fa_index(self):
        '''为参考基因组建立索引'''
        if not os.path.exists(self.ref):
            logging.info("The {0} is missing".format(self.ref))
        else:
            bwa_index = BWAPATH + ' index ' + self.ref
            os.system(bwa_index)
            samtools_faidx = SAMTOOLSPATH + ' faidx ' + self.ref
            os.system(samtools_faidx)

    def bwa_cmd(self, sample):
        '''数据比对'''
        sample_1_clean_fq_gz = os.path.join(self.qc_dir, sample + '_1_clean.fq.gz')
        sample_2_clean_fq_gz = os.path.join(self.qc_dir, sample + '_1_clean.fq.gz')
        if os.path.exists(sample_1_clean_fq_gz) and os.path.exists(sample_2_clean_fq_gz):
            cmd = '{bwa} mem -t {thread} -k 32 -M -R "@RG\\tID:{sample}\\tLB:FDSW19H001244-1a\\tSM:{sample}" \
            {ref} {sample_1_clean_fq_gz} {sample_2_clean_fq_gz}\
            |{samtools} sort -@ {thread} -o {bwa_dir}/{sample}.bam '.format(
                bwa=BWAPATH,
                samtools=SAMTOOLSPATH,
                sample=sample,
                ref=self.ref,
                sample_1_clean_fq_gz=sample_1_clean_fq_gz,
                sample_2_clean_fq_gz=sample_2_clean_fq_gz,
                bwa_dir=self.bwa_dir,
                thread=self.thread)
            os.system(cmd)

        elif not os.path.exists(sample_1_clean_fq_gz):
            logging.info('the {} is missing'.format(sample_1_clean_fq_gz))

        elif not os.path.exists(sample_1_clean_fq_gz):
            logging.info('the {} is  missing'.format(sample_2_clean_fq_gz))

    def rmdup(self, sample):
        sample_bam = os.path.join(self.bwa_dir, sample + '.bam')
        sample_rmdup_bam = os.path.join(self.bwa_dir, sample + '.rmdup.bam')
        if os.path.exists(sample_bam):
            rmdup_cmd = SAMTOOLSPATH + ' rmdup ' + sample_rmdup_bam
            os.system(rmdup_cmd)
        else:
            logging.info('the {0} is missing '.format(sample_bam))

    def samtools_index(self, sample):
        sample_rmdup_bam = os.path.join(self.bwa_dir, sample + '.rmdup.bam')
        if os.path.exists(sample_rmdup_bam):
            cmd = SAMTOOLSPATH + ' index ' + sample_rmdup_bam
            os.system(cmd)
        else:
            logging.info('the {0} is missing '.format(sample_rmdup_bam))

    def bwa_stat(self, sample):
        sample_rmdup_bam = os.path.join(self.bwa_dir, sample + '.rmdup.bam')
        sample_rmdup_bam_index = os.path.join(self.bwa_dir, sample + '.rmdup.bam.bai')
        depth_root_sample_dir = os.path.join(self.bwa_dir, 'depthNoN')
        if not os.path.exists(depth_root_sample_dir):
            os.mkdir(depth_root_sample_dir)

        depth_sample_dir = os.path.join(depth_root_sample_dir, sample)
        if not os.path.exists(depth_sample_dir):
            os.mkdir(depth_sample_dir)

        if os.path.exists(sample_rmdup_bam) and os.path.exists(sample_rmdup_bam_index):
            cmd = '{perl} {perl_script} -l {length} {sample_rmdup_bam} {depth_sample_dir}'.format(
                perl=PERL,
                perl_script=PERL_SCRIPT,
                length=self.length,
                sample_rmdup_bam=sample_rmdup_bam,
                depth_sample_dir=depth_sample_dir
            )
            # print(cmd)
            os.system(cmd)
        else:
            print('the {} mising'.format(sample_rmdup_bam))

    def get_sample_map_info(self, sample):
        sample_rmdup_bam = os.path.join(self.bwa_dir, sample + '.rmdup.bam')
        cmd = '{samtools} flagstat {bam}'.format(samtools=SAMTOOLSPATH, bam=sample_rmdup_bam)
        # print(cmd)
        all_mapped_info = os.path.join(self.bwa_dir, '{sample}_mapped_info.stat'.format(sample=sample))
        out_file = open(all_mapped_info, 'w')
        f = os.popen(cmd)
        all_reads = []
        for line in f.readlines():
            # print(line.strip())
            tags = line.strip().split(' ')
            all_reads.append(tags[0])
        clea_reads = all_reads[0]
        mapped_reads = all_reads[4]
        mapping_rate = int(mapped_reads) / int(clea_reads)
        line_s = sample + '\t' + clea_reads + '\t' + mapped_reads + '\t' + "%.2f%%" % (mapping_rate * 100) + '\n'
        out_file.write(line_s)

    def get_all_map_info(self):
        sample_mapped_info = os.path.join(self.bwa_dir, '*_mapped_info.stat')
        all_mapped_info = os.path.join(self.bwa_dir, 'all_mapping_info.stat')

        cat_cmd = 'cat {0} >>{1}'.format(sample_mapped_info, all_mapped_info)
        rm_cmd = 'rm {0} '.format(sample_mapped_info)
        os.system(cat_cmd)
        if os.path.exists(all_mapped_info):
            os.system(rm_cmd)
        else:
            logging.error('the all_mapped_info.stat is not exist... ')

    def get_sample_depth_info(self, sample):
        depth_root_sample_file = os.path.join(self.bwa_dir, 'depthNoN/{0}/summary.txt'.format(sample))
        sample_summary_txt = os.path.join(self.bwa_dir, '{sample}_summary.txt'.format(sample=sample))
        f_w = open(sample_summary_txt, 'w+')
        depth_list = []
        with open(depth_root_sample_file) as f:
            for line in f:
                tags = line.strip().split()
                depth_list.append(tags[1])
        Average_sequencing_depth = depth_list[0]
        Coverage_1X = depth_list[1]
        Coverage_4X = depth_list[2]
        line_S = '\t'.join([sample, Average_sequencing_depth, Coverage_1X, Coverage_4X]) + '\n'
        f_w.write(line_S)
        f_w.close()

    def get_all_depth_info(self):
        sample_summary_txt = os.path.join(self.bwa_dir, '*_summary.txt')
        all_summary_txt = os.path.join(self.bwa_dir, 'all.summary.txt')
        cat_cmd = 'cat {0} >> {1}'.format(sample_summary_txt, all_summary_txt)
        os.system(cat_cmd)
        if os.path.exists(all_summary_txt) and os.path.getsize(all_summary_txt) > 0:
            rm_cmd = 'rm {0}'.format(sample_summary_txt)
            os.system(rm_cmd)
        else:
            pass


def multi_bwa(fn, t, sample_list):
    '''添加多进程 每个样本同时进行比对'''
    t = int(t)
    p = mp.Pool(t)
    for sample in sample_list:
        p.apply_async(fn, args=(sample,))

    # logging.info('waiting for subprocess   ...')    
    p.close()
    p.join()
    # logging.info('the subprocess have done')


def get_sample_list(sample_file):
    '''生成sample.list 列表'''

    sample_list = []
    with open(sample_file) as f:
        for line in f:
            sample = line.strip()
            sample_list.append(sample)
    return sample_list


def get_args():
    parser = ArgumentParser(description="数据比对")
    parser.add_argument("--s", type=str, help="sample file")
    parser.add_argument("--wkdir", type=str, help="工作目录")
    parser.add_argument("--ref", type=str, help="参考基因组")
    parser.add_argument("--thread", type=str, help="比对所需的线程数 ")
    parser.add_argument("--l", type=str, help="基因组长度")
    parser.add_argument("--t", type=str, help="开几个进程")
    args = parser.parse_args()
    return args


def main():
    args = get_args()
    sample_file = args.s
    wkdir = args.wkdir
    ref = args.ref
    length = args.l
    thread = args.thread  # bwa 比对的线程
    t = args.t  # 启动几个进程
    sample_list = get_sample_list(sample_file)

    BWA = Bwa(wkdir=wkdir, thread=thread, ref=ref, length=length)
    # BWA.mkdir()
    # logging.info('创建文件结束,下一步为基因组建立索引.....')
    # BWA.bulid_fa_index()
    # logging.info('基因组建立索引结束')

    # logging.info('数据比对开始....')

    # multi_bwa(fn = BWA.bwa_cmd,t = t,sample_list = sample_list)
    # logging.info('数据比结束于,下一步开始去重.....')

    # multi_bwa(fn=BWA.rmdup, t=t, sample_list=sample_list)
    # logging.info('数据比结束,下一步开始对bam文件建立索引.....')
    # multi_bwa(fn = BWA.samtools_index,t = t,sample_list = sample_list)
    # logging.info('建立索引结束于 ')

    # 获取测序深度信息
    # multi_bwa(fn=BWA.bwa_stat, t=t, sample_list=sample_list)
    multi_bwa(fn=BWA.get_sample_depth_info, t=t, sample_list=sample_list)
    BWA.get_all_depth_info()

    # 获取比对率信息
    # multi_bwa(fn=BWA.get_sample_map_info, t=t, sample_list=sample_list)
    # BWA.get_all_map_info()


if __name__ == '__main__':
    main()
