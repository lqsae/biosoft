import sys

from get_format import get_number_chr, genetic_map, hebing_genetic_info, sort_hebing_file


def main():
    '''file2 namelist ; file3 genetic_data; file4 BIN.physical.map.xls'''
    sort = sys.argv[1]
    if sort == 'no':
        file1 = sys.argv[2]
        file2 = sys.argv[3]
        file3 = sys.argv[4]
        number_chr = get_number_chr(file1)
        dict_genetic = genetic_map(file2, number_chr)
        hebing_genetic_info(file3, dict_genetic)
    elif sort == 'yes':
        file1 = sys.argv[2]
        sort_hebing_file(file1)


if __name__ == "__main__":
    main()
