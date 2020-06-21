import os
import sys
import logging

import multiprocessing as mp

logging.basicConfig(level=logging.INFO, format='%(asctime)s :: %(levelname)s :: %(message)s', filename='bwa.log')

class ONT:
    def __init__(self, wkdir, sample):
        self.wkdir = wkdir
        self.sample = sample
        self.fast5_fail_dir = os.path.join(wkdir, '{0}/fast5_fail'.format(sample))
        self.fast5_pass_dir = os.path.join(wkdir, '{0}/fast5_pass'.format(sample))
        self.fastq_fail_dir = os.path.join(wkdir, '{0}/fastq_fail'.format(sample))
        self.fastq_pass_dir = os.path.join(wkdir, '{0}/fastq_pass'.format(sample))
        self.fast5_fail = os.path.join(self.fast5_fail_dir, '*.fast5')
        self.fast5_pass = os.path.join(self.fast5_pass_dir, '*.fast5')
        self.fastq_fail = os.path.join(self.fastq_fail_dir, '*.fastq')
        self.fastq_pass = os.path.join(self.fastq_pass_dir, '*.fastq')

    def gzip(self):
        if os.path.exists(self.fastq_fail):
            cmd_fastq_fail = 'gzip {0}'.format(self.fastq_fail)
            logging.info(cmd_fastq_fail)
            os.system(cmd_fastq_fail)
        else:
            pass
        if os.path.exists(self.fastq_pass):
            cmd_fastq_pass = 'gzip {0}'.format(self.fastq_pass)
            logging.info(cmd_fastq_pass)
            os.system(cmd_fastq_pass)
        else:
            pass

    def md5sum(self):
        fast5_fail_md5_txt = os.path.join(self.fast5_fail_dir, 'fast5_fail.md5.txt')
        fast5_pass_md5_txt = os.path.join(self.fast5_pass_dir, 'fast5_pass.md5.txt')
        fastq_fail_md5_txt = os.path.join(self.fastq_fail_dir, 'fastq_fail.md5.txt')
        fastq_pass_md5_txt = os.path.join(self.fastq_pass_dir, 'fastq_pass.md5.txt')
        fastq_fail_gz = os.path.join(self.fastq_fail_dir, '*.fastq.gz')
        fastq_pass_gz = os.path.join(self.fastq_pass_dir, '*.fastq.gz')
        cmd_fast5_fail = 'cd {0} ; md5sum {1} >>{2}'.format(self.fast5_fail_dir, self.fast5_fail, fast5_fail_md5_txt)
        logging.info(cmd_fast5_fail)
        os.system(cmd_fast5_fail)
        cmd_fast5_pass = 'cd {0} ; md5sum {0} >>{1}'.format(self.fast5_pass_dir, self.fast5_pass, fast5_pass_md5_txt)
        logging.info(cmd_fast5_pass)
        os.system(cmd_fast5_pass)
        cmd_fastq_fail = 'cd {0} ; md5sum {1} >>{2}'.format(self.fastq_fail_dir, fastq_fail_gz, fastq_fail_md5_txt)
        logging.info(cmd_fastq_fail)
        os.system(cmd_fastq_fail)
        cmd_fastq_pass = 'cd {0} ; md5sum {1} >>{2}'.format(self.fastq_pass_dir, fastq_pass_gz, fastq_pass_md5_txt)
        logging.info(cmd_fastq_pass)
        os.system(cmd_fastq_pass)


def get_sample_list(sample_file):
    sample_list = []
    with open(sample_file) as f:
        for line in f:
            tags = line.strip().split('\t')
            sample_list.append(tags[0])
    return sample_list

def main():
    wkdir = sys.argv[1]
    sample_file = sys.argv[2]
    sample_list = get_sample_list(sample_file)
    t = len(sample_list)
    p1 = mp.Pool(t)
    for sample in sample_list:
        ont = ONT(wkdir, sample)
        p1.apply_async(ont.gzip, args=())
    p1.close()
    p1.join()

    p2 = mp.Pool(t)
    for sample in sample_list:
        ont = ONT(wkdir, sample)
        p2.apply_async(ont.md5sum, args=())
    p2.close()
    p2.join()


if __name__ == '__main__':
    main()
