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


def new_df_name(df_list):
    new_list = []
    count = 0
    for list_ie in df_list:
        count += 1
        if re.search(r'(\w+)=(\d+)', str(list_ie)) is not None:
            select_pattern = re.compile(r'(\w+)=(\d+)')
            new_str = 'A' + str(count) + '_' + str(select_pattern.sub(r'\1', list_ie))
            new_list.append(new_str)
        else:
            tmp_str = 'A' + str(count)
            new_list.append(tmp_str)
    return new_list


def clean_df_list(df_list):
    new_list_name = []
    for i in df_list:
        if re.search(r'(\w+)=(\d+)', str(i)) is not None:
            select_pattern = re.compile(r'(\w+)=(\d+)')
            new_str = select_pattern.sub(r'\2', i)
            try:
                try_int = int(new_str)
            except ValueError:
                try_int = new_str
            new_list_name.append(try_int)
        else:
            new_list_name.append(i)
    return new_list_name


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
        first_matched_line [str]: first line
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

    new_df_data_list = []
    for each_list in clean_part_file_list:
        new_df_data_list.append(clean_df_list(each_list))

    new_df_column_name = new_df_name(clean_part_file_list[0])

    current_position = file_obj.tell()
    column_len = len(clean_part_file_list[0])
    first_matched_line = matched_file_lines[0]
    file_obj.close()
    return clean_part_file_list, new_df_data_list, new_df_column_name, column_len, current_position, first_matched_line


def generate_df_namelist(column_len):
    """
    Generate column name list as Column1, Column2 ....
    """
    df_name_list = ["Column" + str(column) for column in range(1, column_len + 1)]
    return df_name_list


new_log_list = readlog2list("20161116_1051_bb2.txt.log.dec", select_pattern=re.compile("assignableBytes"), max_line=5000000)
df = DataFrame(new_log_list[1], columns=new_log_list[2])
df.to_csv("201604.csv")

print "Total number of list " + str(len(new_log_list[0])) + "\n"
print "Column number is " + str(new_log_list[3]) + "\n"
print "Current position is " + str(new_log_list[4]) + "\n"
print str(new_log_list[0][2]) + '\n'
print "New Namelist, New First list, orginal Line are " + '\n' + str(new_df_name(new_log_list[0][2])) + "\n"
print str(clean_df_list(new_log_list[0][2])) + '\n'
print new_log_list[5] + '\n'
#print df.head(4)

df.plot(y='A38_assignableBytes')