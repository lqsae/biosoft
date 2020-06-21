#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
为变异检测注释结果文件添加深度信息
对*.avinput文件添加深度信息从而使得之后的注释结果均带有深度信息
深度信息来自*.filted.vcf文件DP4
之前用gevent包读取输入文件内容到内存，再用map的并行处理方式内存消耗大，因此改写.
改后测试发现比之前还快一点。

编码:caohong
邮箱:caohong@novogene.com
2015-05-28 11:01 周四
2019-12-24 10:09 周二 改写
"""
import re
import argparse
import traceback


class DepthAdd(object):
    def __init__(self, avinput_file, vcf_file, out_file):
        self.__avinput_file = avinput_file
        self.__vcf_file = vcf_file
        self.__out_file = out_file
        self.__avinput_file_info = None
        self.__vcf_file_info = None
        self.__avinput_format_info = None
        self.__vcf_file_handle = None
        self.__pattern = re.compile(r'DP4=(\d+),(\d+),(\d+),(\d+)')

    def __read_out_vcf_head(self):
        line = self.__vcf_file_handle.readline()
        while line:
            if line.startswith('#'):
                line = self.__vcf_file_handle.readline()
            else:
                return line

    def __get_dp4_info(self, avi_chr_info, avi_loc_info, vcf_line):
        while 1:
            items = vcf_line.split('\t')
            chr_info = items[0]
            loc_info = items[1]

            if 'INDEL' in items[7]:
                loc_info = str(int(loc_info) + len(items[3])-1)
            if chr_info == avi_chr_info and loc_info == avi_loc_info:
                depth_info = self.__pattern.findall(items[7])
                #depth_info = [('0', '0', '4', '0')]
                if(len(depth_info[0])) != 4:
                    print('DP4 info has less than 4 depth info:{0}'.format(items[7]))
                else:
                    ref_dp4_info = str(int(depth_info[0][0]) + int(depth_info[0][1]))
                    alt_dp4_info = str(int(depth_info[0][2]) + int(depth_info[0][3]))
                    #end_time = datetime.datetime.now()
                    #print("串行findOne:{0}".format((end_time - begin_time).microseconds))
                    return (ref_dp4_info, alt_dp4_info)
            vcf_line = self.__vcf_file_handle.readline()
            if not vcf_line:
                break

    def write_out_simple(self):
        """
        简单版本
        """
        try:
            out_file_handle = open(self.__out_file, 'w')
        except OSError as e:
            print('check file if can be written:{0}'.format(self.__avinput_file))
        except Exception as e:
            traceback.print_exc(e)
            return

        try:
            self.__vcf_file_handle = open(self.__vcf_file)
        except Exception as e:
            traceback.print_exc(e)

        try:
            avi_file_handle = open(self.__avinput_file)
        except Exception as e:
            traceback.print_exc(e)

        vcf_line = self.__read_out_vcf_head()
        for line in avi_file_handle:
            line = line.strip()
            items = line.split('\t')
            chr_info = items[0]
            loc_info = items[2]
            find_result = self.__get_dp4_info(chr_info, loc_info, vcf_line)
            if find_result:
                items.extend([find_result[0], find_result[1]])
                new_line = '\t'.join(items) + '\n'
                out_file_handle.write(new_line)

        out_file_handle.close()
        avi_file_handle.close()
        self.__vcf_file_handle.close()



def arg_init():
    parser = argparse.ArgumentParser(
        description="Novo Compare.SNP.xls depth and ANNO info add program.")
    parser.add_argument(
        '--vcf', help='*.filted.vcf', required = True)
    parser.add_argument(
        '--avinput', help='*.avinput', required=True)
    parser.add_argument(
        '--out', help='output file path, include file name', required=False)
    argv = vars(parser.parse_args())

    vcf_file = argv['vcf'].strip()
    avinput_file = argv['avinput'].strip()
    out_file = argv['out']
    return vcf_file, avinput_file, out_file

def main():
    vcf_file, avinput_file, out_file = arg_init()
    depth_adder = DepthAdd(avinput_file, vcf_file, out_file)
    depth_adder.write_out_simple()
    #depth_adder.write_out()

if __name__ == '__main__':
    main()
