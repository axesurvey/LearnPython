#coding:utf-8
import re
import sys
import csv

__author__ = "Yulin Cui"
__version__ = "1.0"

#   格式：\033[显示方式;前景色;背景色m
#   说明:
#
#   前景色            背景色            颜色
#   ---------------------------------------
#     30                40              黑色
#     31                41              红色
#     32                42              绿色
#     33                43              黃色
#     34                44              蓝色
#     35                45              紫红色
#     36                46              青蓝色
#     37                47              白色
#
#   显示方式           意义
#   -------------------------
#      0           终端默认设置
#      1             高亮显示
#      4            使用下划线
#      5              闪烁
#      7             反白显示
#      8              不可见
#
#   例子：
#   \033[1;31;40m    <!--1-高亮显示 31-前景色红色  40-背景色黑色-->
#   \033[0m          <!--采用终端默认设置，即取消颜色设置-->]]]

STYLE = {
        'fore':
        {   # 前景色
            'black'    : 30,   #  黑色
            'red'      : 31,   #  红色
            'green'    : 32,   #  绿色
            'yellow'   : 33,   #  黄色
            'blue'     : 34,   #  蓝色
            'purple'   : 35,   #  紫红色
            'cyan'     : 36,   #  青蓝色
            'white'    : 37,   #  白色
        },

        'back' :
        {   # 背景
            'black'     : 40,  #  黑色
            'red'       : 41,  #  红色
            'green'     : 42,  #  绿色
            'yellow'    : 43,  #  黄色
            'blue'      : 44,  #  蓝色
            'purple'    : 45,  #  紫红色
            'cyan'      : 46,  #  青蓝色
            'white'     : 47,  #  白色
        },

        'mode' :
        {   # 显示模式
            'mormal'    : 0,   #  终端默认设置
            'bold'      : 1,   #  高亮显示
            'underline' : 4,   #  使用下划线
            'blink'     : 5,   #  闪烁
            'invert'    : 7,   #  反白显示
            'hide'      : 8,   #  不可见
        },

        'default' :
        {
            'end' : 0,
        },
}

def UseStyle(string, mode = '', fore = '', back = ''):

    mode  = '%s' % STYLE['mode'][mode] if STYLE['mode'].has_key(mode) else ''

    fore  = '%s' % STYLE['fore'][fore] if STYLE['fore'].has_key(fore) else ''

    back  = '%s' % STYLE['back'][back] if STYLE['back'].has_key(back) else ''

    style = ';'.join([s for s in [mode, fore, back] if s])

    style = '\033[%sm' % style if style else ''

    end   = '\033[%sm' % STYLE['default']['end'] if style else ''

    return '%s%s%s' % (style, string, end)

def TestColor( ):

    print UseStyle('正常显示')
    print ''

    print "测试显示模式"
    print UseStyle('高亮',   mode = 'bold'),
    print UseStyle('下划线', mode = 'underline'),
    print UseStyle('闪烁',   mode = 'blink'),
    print UseStyle('反白',   mode = 'invert'),
    print UseStyle('不可见', mode = 'hide')
    print ''


    print "测试前景色"
    print UseStyle('黑色',   fore = 'black'),
    print UseStyle('红色',   fore = 'red'),
    print UseStyle('绿色',   fore = 'green'),
    print UseStyle('黄色',   fore = 'yellow'),
    print UseStyle('蓝色',   fore = 'blue'),
    print UseStyle('紫红色', fore = 'purple'),
    print UseStyle('青蓝色', fore = 'cyan'),
    print UseStyle('白色',   fore = 'white')
    print ''


    print "测试背景色"
    print UseStyle('黑色',   back = 'black'),
    print UseStyle('红色',   back = 'red'),
    print UseStyle('绿色',   back = 'green'),
    print UseStyle('黄色',   back = 'yellow'),
    print UseStyle('蓝色',   back = 'blue'),
    print UseStyle('紫红色', back = 'purple'),
    print UseStyle('青蓝色', back = 'cyan'),
    print UseStyle('白色',   back = 'white')
    print ''

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

def readmsgthroughsymbolpreamble(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("nrOfPreambles [1-9]"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg_pattern = select_pattern
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg_info_list = []
    #tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        #tmp_line_number += 1
        if re.search(msg_pattern, each_tmp_line):
            cur_line_number = part_file_lines.index(each_tmp_line)
            #!!!!!!!!  number 5 should be improved soon!!!!!!
            msg_start_line_number = cur_line_number - 5
            #for tmp_ii in range(6):
                #if re.search(re.compile("nrOfPreambles [1-9]"), part_file_lines[msg_start_line_number + tmp_ii]):
            tmp_symbol_check = 1
            each_msg_ie = []
            for internal_msg_index in range(200):
                if tmp_symbol_check !=0:
                    each_msg_ie.append(part_file_lines[msg_start_line_number + internal_msg_index])
                    if re.search(re.compile("{"), part_file_lines[msg_start_line_number + internal_msg_index]):
                        tmp_symbol_check += 1
                    if re.search(re.compile("}"), part_file_lines[msg_start_line_number + internal_msg_index]):
                        tmp_symbol_check -= 1
                    #print tmp_symbol_check
                if tmp_symbol_check == 0:
                    #current_position = file_obj.tell()
                    break
            msg_info_list.append(each_msg_ie)

    new_whole_msg = []
    for each_msg1_message in msg_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand



#log_path = sys.argv[1]
log_path = "c:/Users/eyulcui/Documents/tmp/lienb2466_20170104_1752_bb.log.dec"
max_line_tmp = 2000000
#print "sys.argv[1] is " + sys.argv[0] + " " + sys.argv[1]


new_log_list = readmsgthroughsymbolpreamble(log_path, max_line=max_line_tmp)

raw_data =  new_log_list[0]

for i in raw_data:
    print i

#new_log_list = readmsgthroughsymbolrar(log_path, max_line=max_line_tmp)

#new_log_list = readmsgthroughsymbolmpdcch(log_path, max_line=max_line_tmp)

#new_log_list = readmsgthroughsymbolmsg2pdsch(log_path, max_line=max_line_tmp)




"""
def readmsgthroughsymbolpreamble(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpUlCellPeCiScheduleRaResponseInd"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpUlCellPeCiScheduleRaResponseInd")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(6):
                if re.search(re.compile("nrOfPreambles [1-9]"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(200):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand


def readmsgthroughsymbolrar(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpcDlMacCeFiScheduleRaMsg2Req"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpcDlMacCeFiScheduleRaMsg2Req")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            tmp_symbol_check = 1
            each_msg1_ie = []
            for tmp_i in range(150):
                if tmp_symbol_check !=0:
                    each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                    if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                        tmp_symbol_check += 1
                    if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                        tmp_symbol_check -= 1
                    #print tmp_symbol_check
                if tmp_symbol_check == 0:
                    break
            msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand

def readmsgthroughsymbolmpdcch(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpDlMacPeCiMpdcchInd"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpDlMacPeCiMpdcchInd")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(16):
                if re.search(re.compile("totalNrOfMpdcchDci [1-9]"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(200):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand

def readmsgthroughsymbolmsg2pdsch(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpDlMacPeCiDlCatmCchAllocInd"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpDlMacPeCiDlCatmCchAllocInd")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(16):
                if re.search(re.compile("nrOfRaMsg2Msg [1-9]"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(150):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand

def readmsgthroughsymbolmsg2pdschdlphy(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpDlMacPeCiDlCatmCchAllocInd"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpDlL1PeEiDlL1DataInd")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(16):
                if re.search(re.compile("msgType 2"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(150):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand

def readmsgthroughsymbolmsg3ind(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpUlMacPeCiRaMsg3Ind"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpUlMacPeCiRaMsg3Ind")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(16):
                if re.search(re.compile("noOfRaMsg3Allocations [1-9]"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(150):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand

def readmsgthroughsymbolmsg3indulphy(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpUlL1PeEiAllocationInd"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpUlL1PeEiAllocationInd")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(16):
                if re.search(re.compile("noOfPuschAllocations [1-9]"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(150):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand

def readmsgthroughsymbolmsg3feedback(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpUlMacPeCiUlMacCtrlInfoInd"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpUlMacPeCiUlMacCtrlInfoInd")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(16):
                if re.search(re.compile("nrOfUeUlMacCtrlInfo [1-9]"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(150):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand

def readmsgthroughsymbolmsg4pdsch(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpDlMacPeCiDlCatmCchAllocInd"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpDlMacPeCiDlCatmCchAllocInd")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(16):
                if re.search(re.compile("nrOfComMsg [1-9]"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(150):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand

def readmsgthroughsymbolmsg4pdschdlphy(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpDlL1PeEiDlL1DataInd"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpDlL1PeEiDlL1DataInd")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(16):
                if re.search(re.compile("msgType 4"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(150):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand

def readmsgthroughsymbolmsg4pucchharq(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpUlL1PeEiAllocationInd"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpUlL1PeEiAllocationInd")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(16):
                if re.search(re.compile("noOfPucchAllocations [1-9]"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(150):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand

def readmsgthroughsymbolmsg4harqresult(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("UpUlMacPeCiUlL1Measrprt2DlInd"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpUlMacPeCiUlL1Measrprt2DlInd")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(16):
                if re.search(re.compile("nrOfPucchReports [1-9]"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(150):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    new_whole_msg_cleand = remove_empty_in_list_in_list(new_whole_msg)
    return new_whole_msg_cleand
"""