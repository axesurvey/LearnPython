#coding:utf-8
import re
import csv
import pandas as pd
import numpy as np
from pandas import Series, DataFrame
import scipy

__author__ = "Yulin Cui"
__version__ = "1.0"


def remove_empty_in_list(old_list):
    new_list = []
    for element_val in old_list:
        if element_val:
            new_list.append(element_val)
    return new_list


def clean_string(old_string, clean_pattern=re.compile('[\[\]{}()<>]+')):
    """
    Remove symbol [ ] ( ) < > , "[ ]" use \ to ensure
    """
    cleaned_string = re.sub(clean_pattern, '', old_string)
    return cleaned_string


def split_string_remove_space(old_string, split_pattern=re.compile(r'[:;,\s]\s*')):
    """
    Split Line(String) to a list, seperator are " = : ; , \s "
    Remove all empty and space element in List
    """
    split_line = re.split(split_pattern, old_string)
    split_line_no_space = [x for x in split_line if x != ' ']
    split_line_clean = remove_empty_in_list(split_line_no_space)
    return split_line_clean


def readlog2list(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("assignableBytes"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    """
    Read part of a very big file to a CSV file.  Used to split a big file to several part.

    RESTRICTIONS:
        This function need to use another three function: remove_empty_in_list, clean_string, split_string_remove_space
    REFERENCE:
    INPUT:
        filename[String]:  absolute file location, or filename in same folder
        not_incl_columns_list[List]:  List with IE which will not be selected in data frame
        last_position[int]:  Used to locate pointer location in a big file, work when split big file
        max_line[int]:  How many line to handle when split big file
        clean_pattern[re compiler]: pattern which used to remove some symbol
        split_pattern[re compiler]: pattern which used to split string to list
    OUTPUT[List]:
        clean_part_file_list [List with List]: Main output, A list contain all line info, each line is one list again.
        column_len [int] :  for each list, how many column included
        current_position [int] : Location pointer for next split
    TO DO:
    .. note::
    EXAMPLES::

    """
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    matched_file_lines = []
    for each_tmp_line in part_file_lines:
        if re.search(select_pattern, each_tmp_line):
            matched_file_lines.append(each_tmp_line)

    clean_part_file_list = []
    for each_line in matched_file_lines:
        line_list = []
        cleaned_line = clean_string(each_line, clean_pattern)
        split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
        selected_columns = [ic for ic in range(len(split_line_clean)) if ic not in not_incl_columns_list]
        for c in selected_columns:
            line_list.append(split_line_clean[c])
        clean_part_file_list.append(line_list)

    current_position = file_obj.tell()
    column_len = len(clean_part_file_list[0])
    file_obj.close()
    return clean_part_file_list, column_len, current_position


def generate_df_namelist(column_len):
    """
    Generate column name list as Column1, Column2 ....
    """
    df_name_list = ["Column" + str(column) for column in range(1, column_len + 1)]
    return df_name_list


new_log_list = readlog2list("20161116_1051_bb2.txt.log.dec", select_pattern=re.compile("assignableBytes"), max_line=5000000)
df_namelist = generate_df_namelist(new_log_list[1])
df = DataFrame(new_log_list[0], columns=df_namelist)
df.to_csv("201602.csv")
#print df
print df.head(3)
df["Column4"].astype(float)
print df["Column4"].dtype
print "Example of the second list is " + str(new_log_list[0][2]) + "\n"
print "Total number of list " + str(len(new_log_list[0])) + "\n"
print "Column number is " + str(new_log_list[1]) + "\n"
print "Current position is " + str(new_log_list[2]) + "\n"
print "Namelist is " + str(df_namelist) + "\n"


#uu = readlog2list("test_1ue.dec", last_position=uu[2])
#df_namelist = generate_df_namelist(uu[1])
#print "Example of the second list is " + str(uu[0][2]) + "\n"
#print "Total number of list " + str(len(uu[0])) + "\n"
#print "Column number is " + str(uu[1]) + "\n"
#print "Current position is " + str(uu[2]) + "\n"
#print "Namelist is " + str(df_namelist) + "\n"