#coding:utf-8
__author__ = "Yulin Cui"
__version__ = "1.0"

import re
import sys
import simplejson
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


print ("Total line number for this log file is: " + str(total_line) + "\n", end="")
print ("bfn+sf;cellId;nrOfPreambles;bbueref;preambleId;timingOffset;preamblePower;freqOffEstPrach;\n", end="")

with open(logname) as input_file:
    progress_bar_file = tqdm(input_file,total=total_line)
#with open('C:/Users/eyulcui/Dropbox/LearnPython/raw_log/typical_trace.txt') as input_file:
#with open('C:\STUDY/Dropbox/LearnPython/raw_log/typical_trace.txt') as input_file:
    for eachLine in progress_bar_file:

        start_line_number += 1

        searchObj_Msg2 = re.compile(r'.*bfn:(\d*).*sf:(\d*).*LPP_UP_ULCELLPE_CI_SCHEDULE_RA_RESPONSE_IND', re.M | re.I)

        if searchObj_Msg2.search(eachLine):
            currentBFN = int(searchObj_Msg2.search(eachLine).group(1))
            currentSF = int(searchObj_Msg2.search(eachLine).group(2))
            currentTiming = currentBFN*10 + currentSF
            if currentTiming + 20000 < lastBFN:
                wrappedBfnSub = wrappedBfnSub + 1
            lastBFN = currentTiming
            printBfnSub = wrappedBfnSub * 40960 + currentTiming
            stateMachine[0] = 1
            #print (printBfnSub)
            #print (searchObj.group(0))

        elif stateMachine[0] == 1:
            searchObj_Msg2_cellId = re.compile(r'.*cellId (\S*),', re.M | re.I)
            searchObj_Msg2_nrOfPreambles = re.compile(r'.*nrOfPreambles (\S*),', re.M | re.I)
            searchObj_Msg2_subframeRach = re.compile(r'.*subframeRach (\S*),', re.M | re.I)
            searchObj_Msg2_sfnRach = re.compile(r'.*sfnRach (\S*),', re.M | re.I)


            if searchObj_Msg2_cellId.search(eachLine):
                cellId = int(searchObj_Msg2_cellId.search(eachLine).group(1))
                stateMachine[1] = cellId

            elif searchObj_Msg2_nrOfPreambles.search(eachLine):
                nrOfPreambles = int(searchObj_Msg2_nrOfPreambles.search(eachLine).group(1))
                if nrOfPreambles > 0:
                    stateMachine[2] = 1
                else:
                    stateMachine = [0,0,0]

            elif searchObj_Msg2_subframeRach.search(eachLine):
                subframeRach = int(searchObj_Msg2_subframeRach.search(eachLine).group(1))

            elif searchObj_Msg2_sfnRach.search(eachLine):
                sfnRach = int(searchObj_Msg2_sfnRach.search(eachLine).group(1))


        if stateMachine[0] == 1 and stateMachine[2] ==1:
            searchObj_Msg2_bbUeRef = re.compile(r'.*bbUeRef (\S*),', re.M | re.I)
            searchObj_Msg2_preambleId = re.compile(r'.*preambleId (\S*),', re.M | re.I)
            searchObj_Msg2_timingOffset = re.compile(r'.*timingOffset (\S*),', re.M | re.I)
            searchObj_Msg2_preamblePower = re.compile(r'.*preamblePower (\S*),', re.M | re.I)
            searchObj_Msg2_freqOffEstPrach = re.compile(r'.*freqOffEstPrach (\S*),', re.M | re.I)

            if searchObj_Msg2_bbUeRef.search(eachLine):
                bbUeRef = int(searchObj_Msg2_bbUeRef.search(eachLine).group(1))

            elif searchObj_Msg2_preambleId.search(eachLine):
                preambleId = int(searchObj_Msg2_preambleId.search(eachLine).group(1))

            elif searchObj_Msg2_timingOffset.search(eachLine):
                timingOffset = int(searchObj_Msg2_timingOffset.search(eachLine).group(1))

            elif searchObj_Msg2_preamblePower.search(eachLine):
                preamblePower = int(searchObj_Msg2_preamblePower.search(eachLine).group(1))

            elif searchObj_Msg2_freqOffEstPrach.search(eachLine):
                freqOffEstPrach = int(searchObj_Msg2_freqOffEstPrach.search(eachLine).group(1))
                stateMachine = [0,0,0]
                msg2_output = [printBfnSub,cellId,nrOfPreambles,preambleId,timingOffset,preamblePower,freqOffEstPrach]
                json.dump(msg2_output, fp)
                print (str(printBfnSub) + ";" + str(cellId) + ";" + str(nrOfPreambles) + ";" + str(preambleId) + ";" + str(timingOffset) + ";" + str(preamblePower) + ";" + str(freqOffEstPrach) + ";" + "\n", end="")





#            print ("searchObj.group() : ", searchObj.group())
#            print ("searchObj.group(1) : ", searchObj.group(1))
#            print ("searchObj.group(2) : ", searchObj.group(2))
#        else:
#            print ("Nothing found!!")


#[2016-12-01 12:51:54.682170] 0xc5021225=(bfn:3152, sfn:80, sf:2.20, bf:34) duId:1 EMCA1/UpUlCellPeMasterFt_MTD BIN_SEND : LPP_UP_ULCELLPE_CI_SCHEDULE_RA_RESPONSE_IND (775) <= UNKNOWN (sessionRef=0x4)
#UpUlCellPeCiScheduleRaResponseInd {
#  sigNo 4294901760,
#  cellId 4,
#  subframeRach 1,
#  sfnRach 80,
#  nrOfPreambles 1,
#  padding0 0,
#  rachPreambleArray {
#    rachPreambleArray {
#      preambleId 0,
#      timingOffset 1,
#      preamblePower 4675,
#      sectorId 0,
#      freqOffEstPrach 0,
#      prachCeLevel 1
#    }
#  }
#}

