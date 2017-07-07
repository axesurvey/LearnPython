import pandas as pd
from pandas import Series, DataFrame

import re
def Line_handle(line):
    predef_re_pattern = re.compile(r'[\[\]\=\(\):;,\s]\s*')
    predef_select_ie = [0, 1, 2, 3, 5]

    info1 = re.split(predef_re_pattern, line)
    new_info1 = [x for x in info1 if x != '']
    new_info2 = [new_info1[i] for i in predef_select_ie]
    return new_info2

with open('eggs1.log') as f:
    for line in f:
        split_line = Line_handle(line)
        print split_line


