from timeit import timeit
import re

def find(string, text):
    if string.find(text) > -1:
        pass

def re_find(string, text):
    if re.match(text, string):
        pass

def best_find(string, text):
    if text in string:
       pass

print (timeit("find(string, text)", "from __main__ import find; string='lookforme'; text='look'"))
print (timeit("re_find(string, text)", "from __main__ import re_find; string='lookforme'; text='look'"))
print (timeit("best_find(string, text)", "from __main__ import best_find; string='lookforme'; text='look'"))



__author__ = "Yulin Cui"
__version__ = "1.0"

import re
import sys
import json
from tqdm import tqdm


def count_line(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    #print ("method4 line number is: " + str(i+1))
    return i + 1

#if sys.argv[0] in dir():
#    try:
#        with open('C:/Users/eyulcui/Dropbox/LearnPython/raw_log/typical_trace.txt') as file:
#            input_file = file
#            pass
#    except IOError as e:
#        print ("Unable to open file, file not exist") #Does not exist OR no read permissions
#else:
#    print("\nUsage:\nscan_baseband_traces_hs_ue.pl <optional flag> <baseband_trace.log>\n", end="") #by default, print will change line, give change end symbol to none
#    print("\nScript scans content of these traces for FOE:\n", end="")
#    print("mtd peek -ta UpUlL1PeMasterFt -sig LPP_UP_ULL1PE_EI_DATA_IND\n", end="")
#    print("lhsh gcpu00512 te e trace5 UpUlL1PeSlaveBl_Spucch\n", end="")
#    print("\n -b     bbueref    Search for a specific bbueref", end="")
#    print("\n", end="")
#    sys.exit(0)


stateMachine = [0,0,0]
#[0] is search indication, others to be defined
currentTiming = 0
lastBFN = 0
wrappedBfnSub = 0
currentBFN = 0
currentSF = 0
fp = open('msg2.json', 'w')

logname = "C:/Users/eyulcui/Dropbox/Python_CATM/capture_lienb2466.dec"
start_line_number = 0
total_line = count_line(logname)
#keyMsg = "UPC_DLMACCE_FI_SCHEDULE_RA_MSG2_REQ"

tmp_count = 0

print ("Total line number for this log file is: " + str(total_line) + "\n", end="")
print ("bfn+sf;cellId;nrOfPreambles;bbueref;preambleId;timingOffset;preamblePower;freqOffEstPrach;\n", end="")

with open(logname) as input_file:
    progress_bar_file = tqdm(input_file,total=total_line)
    start_time = time.time()
#with open('C:/Users/eyulcui/Dropbox/LearnPython/raw_log/typical_trace.txt') as input_file:
#with open('C:\STUDY/Dropbox/LearnPython/raw_log/typical_trace.txt') as input_file:
    for eachLine in progress_bar_file:

        start_line_number += 1

        if "LPP_UP_ULCELLPE_CI_SCHEDULE_RA_RESPONSE_IND" in eachLine:

            searchObj_Msg2 = re.compile(r'.*bfn:(\d*).*sf:(\d*).*LPP_UP_ULCELLPE_CI_SCHEDULE_RA_RESPONSE_IND', re.M | re.I)

            if searchObj_Msg2.search(eachLine):
                tmp_count += 1
    running_time = time.time() - start_time
    print("Total match number is " + tmp_count)
    print("Total time used is " + running_time)
