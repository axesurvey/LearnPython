#coding:utf-8
import re
import sys
import csv
import pandas as pd

__author__ = "Yulin Cui"
__version__ = "1.0"

def remove_empty_in_list(old_list):
    new_list = []
    for element_val in old_list:
        if element_val:
            new_list.append(element_val)
    return new_list

def remove_empty_in_list_in_list(old_list):
    new_msg_list = []
    new_msg_list_data = []
    new_msg_list_header = []
    new_msg_list_header_len = []
    for each_msg in old_list:
        new_list = []
        new_list_header = []
        new_list_header_len = []
        new_list_data = []
        new_list_header_len = []
        for element_val in each_msg:
            if element_val:
                if len(element_val) == 2:
                    new_list.append(element_val)
                    new_list_header.append(element_val[0])
                    new_list_data.append(element_val[1])
                    new_list_header_len.append(len(element_val[0]) + 5)
        new_msg_list.append(new_list)
        new_msg_list_data.append(new_list_data)
        new_msg_list_header = new_list_header
        new_msg_list_header_len = new_list_header_len
    #return new_list,new_list_header,new_list_header_len,new_list_data
    return new_msg_list,new_msg_list_header, new_msg_list_data, new_msg_list_header_len

def clean_string(old_string, clean_pattern=re.compile('[\[\]{}<>]+')):
    """
    Remove symbol [ ] ( ) < > , "[ ]" use \ to ensure
    """
    cleaned_string = re.sub(clean_pattern, '', old_string)
    return cleaned_string

def split_string_remove_space(old_string, split_pattern=re.compile(r'[:;,()\s]\s*')):
    """
    Split Line(String) to a list, seperator are " = : ; , \s "
    Remove all empty and space element in List
    """
    split_line = re.split(split_pattern, old_string)
    split_line_no_space = [x for x in split_line if x != ' ']
    split_line_clean = remove_empty_in_list(split_line_no_space)
    return split_line_clean


#def readmsglist(filename, last_position=0, max_line=30000, clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[;\s]\s*')):
def readmsglist(filename, last_position=0, max_line=30000, clean_pattern=re.compile('[\[\]{}()<>]+'),
                    split_pattern=re.compile(r'[\s]\s*')):

    # msg_keyword_gap is the line number that equals line(keyword) - line(first"{") -1
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    # Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []  # List to include all lines with string format
    for i in range(max_line):
        line_item = file_obj.readline()
        current_position = file_obj.tell()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    new_whole_msg = []
    for each_line_message in part_file_lines:
        new_line_massage = []
        #cleaned_line = clean_string(each_line_message, clean_pattern)
        split_line_clean = split_string_remove_space(each_line_message, split_pattern)
        new_whole_msg.append(split_line_clean)

    return new_whole_msg

#log_path = sys.argv[1]
log_path_ref = "c:/Users/eyulcui/Dropbox/Python_CATM/170420-160358_lienb4027_17B.log"
log_path_ebb = "c:/Users/eyulcui/Dropbox/Python_CATM/170420-140750_lienb4027_EBBA.log"
#log_path = "eggs1.log"
max_line_tmp = 5000000
#print "sys.argv[1] is " + sys.argv[0] + " " + sys.argv[1]


splited_ref = readmsglist(log_path_ref,  max_line=max_line_tmp, last_position=0)
splited_ebb = readmsglist(log_path_ebb,  max_line=max_line_tmp, last_position=0)

tmp_i = 0
output_list = []
for each_ebb_counter in splited_ref:
    if len(each_ebb_counter) != 3:
        print (each_ebb_counter)


tmp_i = 0
output_list = []
for each_ebb_counter in splited_ebb:
    if len(each_ebb_counter) != 3:
        print (each_ebb_counter)

#hwProfileSystConstants == SysConstPairD{id 185,value"32"}SysConstPairD{id 195,value"120"}SysConstPairD{id 204,value"1200"}SysConstPairD{id 212,value"29250"}SysConstPairD{id 213,value"6500"}SysConstPairD{id 228,value"1200"}SysConstPairD{id 229,value"1080"}SysConstPairD{id 230,value"524"}SysConstPairD{id 257,value"8000"}SysConstPairD{id 264,value"8"}SysConstPairD{id 303,value"84"}SysConstPairD{id 304,value"16"}SysConstPairD{id 305,value"96"}SysConstPairD{id 306,value"18"}SysConstPairD{id 316,value"1200"}SysConstPairD{id 362,value"6000"}SysConstPairD{id 383,value"400"}SysConstPairD{id 384,value"39"}SysConstPairD{id 427,value"8"}SysConstPairD{id 428,value"16"}SysConstPairD{id 448,value"400"}SysConstPairD{id 449,value"39"}SysConstPairD{id 515,value"600"}SysConstPairD{id 516,value"120"}SysConstPairD{id 517,value"15"}SysConstPairD{id 546,value"140"}SysConstPairD{id 556,value"110"}SysConstPairD{id 557,value"200"}SysConstPairD{id 639,value"16"}SysConstPairD{id 640,value"32"}SysConstPairD{id 799,value"30"}SysConstPairD{id 800,value"20"}SysConstPairD{id 801,value"80"}SysConstPairD{id 803,value"95"}SysConstPairD{id 806,value"31"}SysConstPairD{id 808,value"6"}SysConstPairD{id 809,value"140"}SysConstPairD{id 908,value"6500"}SysConstPairD{id 912,value"1"}SysConstPairD{id 959,value"144"}SysConstPairD{id 960,value"144"}SysConstPairD{id 961,value"48"}SysConstPairD{id 1041,value"80"}SysConstPairD{id 1042,value"10"}SysConstPairD{id 1122,value"83"}SysConstPairD{id 1123,value"180"}SysConstPairD{id 1156,value"16"}SysConstPairD{id 1213,value"8000"}SysConstPairD{id 1309,value"18"}SysConstPairD{id 1339,value"20000"}SysConstPairD{id 1340,value"4"}SysConstPairD{id 1371,value"10"}SysConstPairD{id 1372,value"10"}SysConstPairD{id 1373,value"8"}SysConstPairD{id 1374,value"8"}SysConstPairD{id 1438,value"2"}SysConstPairD{id 1499,value"140"}SysConstPairD{id 1500,value"1400"}SysConstPairD{id 1501,value"1400"}SysConstPairD{id 1613,value"5"}SysConstPairD{id 1674,value"144"}SysConstPairD{id 1675,value"144"}SysConstPairD{id 1676,value"120"}SysConstPairD{id 1677,value"144"}SysConstPairD{id 1678,value"144"}SysConstPairD{id 1679,value"120"}SysConstPairD{id 1680,value"500"}SysConstPairD{id 1681,value"500"}SysConstPairD{id 1682,value"500"}SysConstPairD{id 1683,value"804"}SysConstPairD{id 1684,value"804"}SysConstPairD{id 1685,value"600"}SysConstPairD{id 1686,value"39"}SysConstPairD{id 1687,value"39"}SysConstPairD{id 1688,value"15"}SysConstPairD{id 1689,value"150"}SysConstPairD{id 1690,value"150"}SysConstPairD{id 1691,value"75"}SysConstPairD{id 1712,value"90"}SysConstPairD{id 1898,value"1080"}SysConstPairD{id 1899,value"24"}SysConstPairD{id 1937,value"96"}SysConstPairD{id 1938,value"28"}SysConstPairD{id 2157,value"6"}SysConstPairD{id 2294,value"72"}SysConstPairD{id 2346,value"1200"}SysConstPairD{id 2663,value"60"}SysConstPairD{id 2664,value"60"}

"""
for each_ref_counter in splited_ref:
    if each_ref_counter[0] == splited_ebb[0][0] and each_ref_counter[1] == splited_ebb[0][1]:
        splited_ebb[0].append(each_ref_counter[2])
        print splited_ebb[0]
"""


"""
tmp_i = 0
for each_ebb_counter in splited_ebb:
    if tmp_i <= 10:
        print each_ebb_counter
        tmp_i += 1

tmp_i = 0
for each_ebb_counter in splited_ref:
    if tmp_i <= 10:
        print each_ebb_counter
        tmp_i += 1
"""

#tmp_ebb_counter1 = ['ManagedElement=kienb1501,ENodeBFunction=1', 'pmLic5MHzSectorCarrierActual', '18']

"""
def matchWithRefL16B(ebb_counter,ref_counter):
    for each_ref_counter in ref_counter:
        if each_ref_counter[0] == ebb_counter[0] and each_ref_counter[1] == ebb_counter[1]:
            ebb_counter.append(each_ref_counter[2])
    return ebb_counter


with open('c:/Users/eyulcui/Dropbox/Python_CATM/STAB20_output_latest_commit.txt','wb') as f:
    for each_ebb_counter in splited_ebb:
        ebb_ref_combine_value = matchWithRefL16B(each_ebb_counter,splited_ref)
        f.write(str(ebb_ref_combine_value) + '\n')
"""


def matchWithRefL16B(ebb_counter,ref_counter):
    for each_ref_counter in ref_counter:
        if each_ref_counter[0] == ebb_counter[0] and each_ref_counter[1] == ebb_counter[1]:
            ebb_counter.append(each_ref_counter[2])
    return ebb_counter


with open('c:/Users/eyulcui/Dropbox/Python_CATM/monica_output_17b_ebb.txt','wb') as f:
    for each_ebb_counter in splited_ebb:
        ebb_ref_combine_value = matchWithRefL16B(each_ebb_counter,splited_ref)
        f.write(str(ebb_ref_combine_value) + '\n')
