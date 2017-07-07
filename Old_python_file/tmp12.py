#coding:utf-8
import re
import sys
import csv
import pandas as pd
import numpy as np


hwProfileSystConstants = ' {  185,  32 } {  195,  120 } {  204,  1200 } {  212,  29250 } {  213,  6500 } {  228,  1200 } {  229,  1080 } {  230,  524 } {  257,  8000 } {  264,  8 } {  303,  84 } {  304,  16 } {  305,  96 } {  306,  18 } {  316,  1200 } {  362,  6000 } {  383,  400 } {  384,  39 } {  427,  8 } {  428,  16 } {  448,  400 } {  449,  39 } {  515,  600 } {  516,  120 } {  517,  15 } {  546,  140 } {  556,  110 } {  557,  200 } {  639,  16 } {  640,  32 } {  799,  30 } {  800,  20 } {  801,  80 } {  803,  95 } {  806,  31 } {  808,  6 } {  809,  140 } {  908,  6500 } {  912,  1 } {  959,  144 } {  960,  144 } {  961,  48 } {  1041,  80 } {  1042,  10 } {  1122,  83 } {  1123,  180 } {  1156,  16 } {  1213,  8000 } {  1309,  18 } {  1339,  20000 } {  1340,  4 } {  1371,  10 } {  1372,  10 } {  1373,  8 } {  1374,  8 } {  1438,  2 } {  1499,  140 } {  1500,  1400 } {  1501,  1400 } {  1613,  5 } {  1674,  144 } {  1675,  144 } {  1676,  120 } {  1677,  144 } {  1678,  144 } {  1679,  120 } {  1680,  500 } {  1681,  500 } {  1682,  500 } {  1683,  804 } {  1684,  804 } {  1685,  600 } {  1686,  39 } {  1687,  39 } {  1688,  15 } {  1689,  150 } {  1690,  150 } {  1691,  75 } {  1712,  90 } {  1898,  1080 } {  1899,  24 } {  1937,  96 } {  1938,  28 } {  2157,  6 } {  2294,  72 } {  2346,  1200 } {  2663,  60 } {  2664,  60 }'

hwp1= ['185,32', '195,120', '204,1200', '212,29250', '213,6500', '228,1200', '229,1080', '230,524', '257,8000', '264,8', '303,84', '304,16', '305,96', '306,18', '316,1200', '362,6000', '383,400', '384,39', '427,8', '428,16', '448,400', '449,39', '515,600', '516,120', '517,15', '546,140', '556,110', '557,200', '639,16', '640,32', '799,30', '800,20', '801,80', '803,95', '806,31', '808,6', '809,140', '908,6500', '912,1', '959,144', '960,144', '961,48', '1041,80', '1042,10', '1122,83', '1123,180', '1156,16', '1213,8000', '1309,18', '1339,20000', '1340,4', '1371,10', '1372,10', '1373,8', '1374,8', '1438,2', '1499,140', '1500,1400', '1501,1400', '1613,5', '1674,144', '1675,144', '1676,120', '1677,144', '1678,144', '1679,120', '1680,500', '1681,500', '1682,500', '1683,804', '1684,804', '1685,600', '1686,39', '1687,39', '1688,15', '1689,150', '1690,150', '1691,75', '1712,90', '1898,1080', '1899,24', '1937,96', '1938,28', '2157,6', '2294,72', '2346,1200', '2663,60', '2664,60']

hwProfileSystConstants2="185,32}195,120}204,1200}212,29250}213,6500}228,1200}229,1080}230,524}257,8000}264,8}303,84}304,16}305,96}306,18}316,1200}362,6000}383,400}384,39}427,8}428,16}448,400}449,39}515,600}516,120}517,15}546,140}556,110}557,200}639,16}640,32}799,30}800,20}801,80}803,95}806,31}808,6}809,140}908,6500}912,1}959,144}960,144}961,48}1041,80}1042,10}1122,83}1123,180}1156,16}1213,8000}1309,18}1339,20000}1340,4}1371,10}1372,10}1373,8}1374,8}1438,2}1499,140}1500,1400}1501,1400}1613,5}1674,144}1675,144}1676,120}1677,144}1678,144}1679,120}1680,500}1681,500}1682,500}1683,804}1684,804}1685,600}1686,39}1687,39}1688,15}1689,150}1690,150}1691,75}1712,90}1898,1080}1899,24}1937,96}1938,28}2157,6}2294,72}2346,1200}2663,60}2664,60}"

hwp_L17B = ['185,32', '195,120', '204,1200', '212,29250', '213,6500', '228,1200', '229,1080', '230,524', '257,8000', '264,8', '303,84', '304,16', '305,96', '306,18', '316,1200', '362,6000', '383,400', '384,39', '427,8', '428,16', '448,400', '449,39', '515,600', '516,120', '517,15', '546,140', '556,110', '557,200', '639,16', '640,32', '799,30', '800,20', '801,80', '803,95', '806,31', '808,6', '809,140', '908,6500', '912,1', '959,144', '960,144', '961,48', '1041,80', '1042,10', '1122,83', '1123,180', '1156,16', '1213,8000', '1309,18', '1339,20000', '1340,4', '1371,10', '1372,10', '1373,8', '1374,8', '1438,2', '1499,140', '1500,1400', '1501,1400', '1613,5', '1674,144', '1675,144', '1676,120', '1677,144', '1678,144', '1679,120', '1680,500', '1681,500', '1682,500', '1683,804', '1684,804', '1685,600', '1686,39', '1687,39', '1688,15', '1689,150', '1690,150', '1691,75', '1712,90', '1898,1080', '1899,24', '1937,96', '1938,28', '2157,6', '2294,72', '2346,1200', '2663,60', '2664,60']

hwp_EBB = ['185,32','195,120','204,1200','212,29250','213,6500','228,1200','229,1080','230,524','257,8000','264,8','303,84','304,16','305,96','306,18','316,1200','362,6000','383,400','384,39','427,8','428,16','448,400','449,39','515,600','516,120','517,15','546,140','556,110','557,200','639,16','640,32','799,30','800,20','801,80','803,95','806,31','808,6','809,140','908,6500','912,1','959,144','960,144','961,48','1041,80','1042,10','1122,83','1123,180','1156,16','1213,8000','1309,18','1339,20000','1340,4','1371,10','1372,10','1373,8','1374,8','1438,2','1499,140','1500,1400','1501,1400','1613,5','1674,144','1675,144','1676,120','1677,144','1678,144','1679,120','1680,500','1681,500','1682,500','1683,804','1684,804','1685,600','1686,39','1687,39','1688,15','1689,150','1690,150','1691,75','1712,90','1898,1080','1899,24','1937,96','1938,28','2157,6','2294,72','2346,1200','2663,60','2664,60']

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

def clean_string(old_string, clean_pattern=re.compile('[\[\]<>\s]+')):
    """
    Remove symbol [ ] ( ) < > , "[ ]" use \ to ensure
    """
    cleaned_string = re.sub(clean_pattern, '', old_string)
    return cleaned_string

def split_string_remove_space(old_string, split_pattern=re.compile(r'[:;()}\s]\s*')):
    """
    Split Line(String) to a list, seperator are " = : ; , \s "
    Remove all empty and space element in List
    """
    split_line = re.split(split_pattern, old_string)
    split_line_no_space = [x for x in split_line if x != ' ']
    split_line_clean = remove_empty_in_list(split_line_no_space)
    return split_line_clean


tmp1 = clean_string(hwProfileSystConstants)
print tmp1
tmp2 = split_string_remove_space(tmp1)
print tmp2
