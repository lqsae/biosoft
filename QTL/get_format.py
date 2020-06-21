import sys
from collections import defaultdict


def get_chr_number_dict(file):
    '''获取染色体和编号对应字典'''
    dict_chr_number = {}
    with open(file) as f:
        for line in f:
            tags = line.strip().split()
            chr = tags[0]
            number = tags[1]
            dict_chr_number[chr] = number
    return dict_chr_number


def get_number_chr(file):
    dict_number_chr = {}
    with open(file) as f:
        for line in f:
            tags = line.strip().split()
            chr = tags[0]
            number = tags[1]
            dict_number_chr[number] = chr
    return dict_number_chr


def get_format_list(file, dict_map):
    '''  获取binmap 输入文件格式 返回生成器'''
    # all_list = []
    with open(file) as f:
        for line in f:
            if not line.strip().startswith('#'):
                tags = line.strip().split()
                chr = tags[1][8:]
                if chr[0] == 'A' or chr[0] == 'C':
                    info_list = [dict_map[chr], tags[2]] + tags[3:]
                    yield info_list
                    # print(info_list)
                    # all_list.append(info_list)


def print_sort_list(all_list):
    ''' 对获取的生成器根据染色体编号和SNP 位置排序并打印出来 '''
    all_list_sort = sorted(all_list, key=lambda x: (int(x[0]), int(x[1])))
    for i in all_list_sort:
        print('\t'.join(i))


def get_joinmap(file, dict_map):
    '''把binmap转化为joinmap格式数据'''
    dict_chr = {v: k for k, v in dict_map.items()}
    with open(file) as f:
        for line in f:
            tags = line.strip().split()
            number = tags[1]
            chr = dict_chr[number]
            bin = tags[0]
            marker = "{bin}_{chr}".format(bin=bin, chr=chr)
            all_format = [marker] + tags[4:]
            print('\t'.join(all_format))


def genetic_map(file, dict_map):
    '''创建一个和genetic的Locus对应的字典'''
    dict_genetic = {}
    with open(file) as f:
        for line in f:
            tags = line.strip().split()
            bin = tags[0]
            number = tags[1]
            chr = dict_map[number]
            Locus = "{bin}_{chr}".format(bin=bin, chr=chr)
            info_list = tags[2:]
            dict_genetic[Locus] = info_list
    return dict_genetic


def hebing_genetic_info(file, dict_genetic):
    '''BIN.physical.map.xls 文件 和遗传距离信息合并'''
    with open(file) as f:
        for line in f:
            if not line.strip().startswith('S'):
                tags = line.strip().split()
                lg = tags[3]
                if int(lg) < 10:
                    LG = "LG0{0}".format(lg)
                else:
                    LG = "LG{0}".format(lg)
                GD = tags[4]
                Locus = tags[2]
                chr = Locus.split('_')[1]
                genetic_distance = [LG, Locus, GD, chr]
                info_list = genetic_distance + dict_genetic[Locus]
                print('\t'.join(info_list))


def sort_hebing_file(file):
    dict_map = defaultdict(list)
    with open(file) as f:
        for line in f:
            if not line.strip().startswith('#'):
                tags = line.strip().split('\t')
                LG = tags[0]
                dict_map[LG].append(tags)
            else:
                print(line.strip())
    # print(dict_map)
    for key, value in dict_map.items():
        pos_list = [i[4:6] for i in value]
        first_pos = int(pos_list[0][0])
        last_pos = int(pos_list[-1][0])
        if first_pos > last_pos:
            sort_pos_list = pos_list[::-1]
        else:
            sort_pos_list = pos_list
        for number, j in enumerate(value):
            info = [j[0], j[1], j[2], j[3], sort_pos_list[number][0], sort_pos_list[number][1]] + j[6:]
            print('\t'.join([str(i) for i in info]))


def main():
    file1 = sys.argv[1]
    file2 = sys.argv[2]
    # file3 = sys.argv[3]
    chr_number = get_chr_number_dict(file1)
    # all_list = get_format_list(file2, dict_map)
    # print_sort_list(all_list)
    get_joinmap(file2, chr_number)


if __name__ == '__main__':
    main()
