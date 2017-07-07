#coding:utf-8
__author__ = "Yulin Cui"
__version__ = "1.0"
import re
import pandas as pd
from pandas import Series, DataFrame

def sample_read(file_name="test_1ue.dec", key_words="nrofCellsWithValidSes", read_number=5, start_pos=1):
    """
    Give the Cholesky decomposition of this quadratic form `Q` as a real matrix

    RESTRICTIONS:
        Q must be given as a QuadraticForm defined over `\ZZ`, `\QQ`, or some

    REFERENCE:
    INPUT:
    OUTPUT:
    TO DO:
    .. note::
    EXAMPLES::

    """
    sample_output = []
    tmp_n = 1

    if start_pos > 0:
        with open(file_name, 'r') as input_file:
            for each_line in input_file:
                if each_line.find(key_words) > -1:
                    if tmp_n <= read_number:
                        sample_output.append(each_line)
                        tmp_n += 1

    else:
        with open(file_name, 'r') as f:  # 打开文件
            off = -100 * read_number  # 设置偏移量
            while True:
                f.seek(off, 2)  # seek(off, 2)表示文件指针：从文件末尾(2)开始向前50个字符(-50)
                lines = f.readlines()  # 读取文件指针范围内所有行
                if len(lines) > (read_number + 1):  # 判断是否最后至少有两行，这样保证了最后一行是完整的
                    sample_output = lines[-(read_number + 1):-1]  # 取最后一行
                    break
                # 如果off为50时得到的readlines只有一行内容，那么不能保证最后一行是完整的
                # 所以off翻倍重新运行，直到readlines不止一行
                off *= 2

    return sample_output


def line_split(line_input, sep=re.compile(r'[\[\]\=\(\):;,\s]\s*'), word_list=[0, 1, 2, 3, 5]):
    """
    Give the Cholesky decomposition of this quadratic form `Q` as a real matrix

    RESTRICTIONS:
        Q must be given as a QuadraticForm defined over `\ZZ`, `\QQ`, or some

    REFERENCE:
    INPUT:
    OUTPUT:
    TO DO:
    .. note::
    EXAMPLES::

    """

    split_word = re.split(sep, line_input)
    split_word_no_space = [x for x in split_word if x != '']
    selected_word = [split_word_no_space[i] for i in word_list]
    return selected_word


f1 = sample_read(read_number=10)
output_array = []
for line in f1:
    output_array.append(line_split(line_input=line))

frame = DataFrame(output_array, columns=['aa', 'bb', 'cc', 'dd', 'ee'])

print (frame)
print (frame.dtypes)









