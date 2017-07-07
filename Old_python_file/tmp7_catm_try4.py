#/usr/bin/python
#-*- coding: utf-8 -*-
import csv

tmplist1 = [['sigNo', '4'], ['header'], ['cellId', '4'], ['sfn', '505'], ['subFrameNo', '3'], [], ['isMtc', '0'], ['noOfRaMsg3Allocations', '1'], ['raMsg3List'], ['raMsg3List'], ['common'], ['clientRef', '71303264'], ['crnti', '16845'], ['raType', '0'], [], ['l1'], ['ulHarqProcessId', '0'], ['rvIdx', '0'], ['newDataFlag', '1'], ['qm', '2'], ['tbs', '72'], ['dmRsCyclicShift', '0'], ['prbListStart', '44'], ['prbListEnd', '45'], ['prbListStart2', '0'], ['prbListEnd2', '0'], ['fh', '0'], ['shortFormat', '0'], ['firstTxShortFormat', '0'], ['ttiBundlingCounter', '0'], ['primarySectorId', '0'], ['isDciFormatAllocated', '0'], ['padding', '0'], ['cfrInfo'], ['cfrInfo'], ['ri', '0'], ['riBitWidth', '0'], ['cfrLength', '0'], ['cfrFormat', '0'], ['cfrValid', '0'], ['cfrExpected', '0'], ['cfrCrcFlag', '0'], ['dlBandwidth', '0'], ['padding0', '0'], [], ['cfrInfo'], ['ri', '0'], ['riBitWidth', '0'], ['cfrLength', '0'], ['cfrFormat', '0'], ['cfrValid', '0'], ['cfrExpected', '0'], ['cfrCrcFlag', '0'], ['dlBandwidth', '0'], ['padding0', '0'], [], ['cfrInfo'], ['ri', '0'], ['riBitWidth', '0'], ['cfrLength', '0'], ['cfrFormat', '0'], ['cfrValid', '0'], ['cfrExpected', '0'], ['cfrCrcFlag', '0'], ['dlBandwidth', '0'], ['padding0', '0'], [], ['cfrInfo'], ['ri', '0'], ['riBitWidth', '0'], ['cfrLength', '0'], ['cfrFormat', '0'], ['cfrValid', '0'], ['cfrExpected', '0'], ['cfrCrcFlag', '0'], ['dlBandwidth', '0'], ['padding0', '0'], [], [], ['dlHarqAllocInfo'], ['dlHarqIndExpected', '0'], ['nrOfTb', '0'], ['nrOfHarqBits', '0'], ['dlHarqProcessId', '0'], ['dlSubframeSchedInd', '0'], ['isCatm', '0'], [], ['rxPuschSector', '1'], ['triggerBeamformingCalc', 'false'], ['cmMasterRef_p', "'00", '00', '00', "00'H"], ['cmCbData_p', "'00", '00', '00', "00'H"], ['nRxSectors', '0'], ['rxSectors'], ['rxSectors', '65535'], ['rxSectors', '65535'], [], ['measSectorId', '65535'], ['nReps', '1'], ['subframeCnt', '1'], [], ['raUeInfo'], ['timingOffset', '1'], ['taSfn', '504'], ['taSubframe', '5'], ['rxPuschSector', '1'], ['rxPucchSector', '1'], ['freqOffEstPusch', '0'], ['msg3TimeStamp', '0'], ['rxPower'], ['prbListStart', '0'], ['prbListEnd', '0'], ['prbListStart2', '0'], ['prbListEnd2', '0'], ['rxPowerReport', '0'], ['sinr', '0'], [], ['lcid', '0'], ['msg3Bfn', '0'], ['msg3Subframe', '0'], ['prachCeLevel', '1'], ['shortBsr', '0'], ['phr', '0'], [], ['raPmInfo'], ['crnti', '16845'], ['taCmd', '1'], ['ulGrant', '975456'], [], ['freqOffEstPrach', '0'], ['padding0', '0'], [], [], []]

def remove_empty_in_list(old_list):
    new_list = []
    new_list_header = []
    new_list_header_len = []
    new_list_data = []
    for element_val in old_list:
        if element_val:
            if len(element_val) == 2:
                new_list.append(element_val)
                new_list_header.append(element_val[0])
                new_list_data.append(element_val[1])
                new_list_header_len.append(len(element_val[0]) + 4)
    return new_list,new_list_header,new_list_header_len,new_list_data

tmplist2 = remove_empty_in_list(tmplist1)


for i in tmplist2[1]:
    print i + "     ",
print "\n"
for i in range(len(tmplist2[2])):
    tmp_str = "%-" + str(tmplist2[2][i]) + "s "
    print tmp_str % tmplist2[3][i],

"""
str_format = ""
for i in tmplist2[2]:
    strlen = "%-" + str(i) + "d "
    str_format += strlen
print str_format

with open('output.csv', 'wb') as csvfile:
    csvwriter = csv.writer(csvfile, quoting=csv.QUOTE_MINIMAL)
    csvwriter.writerow(tmplist2[1])
    csvwriter.writerow(tmplist2[2])
csvfile.close()
"""
#msg1preamble_handled_data1 = "%-10d %-10d %-10d %-10d %-10d %-10d %-20d %-20d" % (cellId[0], sfn[0], subframe[0], preambleId[0], prachCeLevel[0], timingOffset[0], nrOfPreambles[0], preamblePower[0])

#print str_format % int(tmplist2[1][0])




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
#if __name__ == '__main__':

    #TestColor( )

print "\n"
print UseStyle('XXXXXXXXXXXXX',   back = 'yellow')
