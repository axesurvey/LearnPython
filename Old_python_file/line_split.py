#coding:utf-8
__author__ = "Yulin Cui"
__version__ = "1.0"

import re


#sep = re.compile(r'[\[\]\=\(\):;,\s]\s*')
#word_list = [0, 1, 2, 3, 5]

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

with open('eggs1.log') as f:
    for line in f:
        split_line = line_split(line)
        print split_line


