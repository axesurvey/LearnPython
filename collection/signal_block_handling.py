##time
# coding:utf-8
import re
import pandas as pd
import tqdm


def count_line(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    #print ("method4 line number is: " + str(i+1))
    return i + 1

logname = "C:/Users/eyulcui/Dropbox/LearnPython/raw_log/typical_trace_fordebug.txt"
#logname = "C:/Users/eyulcui/Dropbox/Python_CATM/capture_lienb2466.dec"
keyMsg = "LPP_UP_ULCELLPE_CI_SCHEDULE_RA_RESPONSE_IND"
total_line = count_line(logname)

current_line_number = 0
signal_block_checker = -999
stateMachine = [0, 0, 0]
# [0] is search indication, others to be defined
#currentTiming = 0
#lastBFN = 0
#wrappedBfnSub = 0
#currentBFN = 0
#currentSF = 0
#sig_location = []
#each_sig_loc = [-1, -1, -1]
#start_loc = 1
sig_data = []
each_sig_data = []
each_ie_data = [-1, -1, -1]
df_sig = pd.DataFrame()



with open(logname) as input_file:
    #progress_bar_file = tqdm(input_file, total=total_line)
    #for index, line in enumerate(progress_bar_file):
    for index, line in enumerate(input_file):

        if "LPP_UP_ULCELLPE_CI_SCHEDULE_RA_RESPONSE_IND" in line:
            #each_sig_loc[0] = start_loc
            #each_sig_loc[1] = index
            stateMachine = [1, 0, 0]

        if stateMachine[0] == 1:
            current_location = index
            #print (stateMachine,signal_block_checker, index)

            if "nrOfPreambles" in line:
                checker_1 = re.compile(r'nrOfPreambles\s+(\d+)', re.M | re.I)
                if int(checker_1.search(line).group(1)) == 0:
                #    checker_pass = 0
                    signal_block_checker = -999
                    each_ie_data = [-1, -1, -1]
                    #each_sig_loc = [-1, -1, -1]
                    each_sig_data = []
                    stateMachine = [0, 0, 0]
                #else:
                #    checker_pass = 1

            if signal_block_checker == 0:
                # elif re.search(re.compile("bfn:(\d*).*sf:(\d*)"), line):
                #if checker_pass == 1:
                #each_sig_loc[2] = index
                #sig_location.append(each_sig_loc[:])
                sig_data.append(each_sig_data[:])
                #df_sig = df_sig.append(each_sig_data)
                print(each_sig_data)
                each_sig_data = []
                each_ie_data = [-1, -1, -1]
                # print ("Edning index is: " + str(index))
                stateMachine = [0, 0, 0]
                signal_block_checker = -999

            if (index - current_location) >= 200:
                print("signal is borken or more than 200")
                print("Line number is: " + str(current_location))
                stateMachine = [0, 0, 0]
                signal_block_checker = 0

            else:
                if re.search(re.compile("{"), line):
                    if signal_block_checker == -999:
                        signal_block_checker = 1
                    else:
                        signal_block_checker += 1
                        # print(line, end="")
                        # print (str(signal_block_checker))

                if re.search(re.compile("}"), line):
                    if signal_block_checker == -999:
                        signal_block_checker = -1
                    else:
                        signal_block_checker -= 1
                        # print(line, end="")
                        # print (str(signal_block_checker))

                line_ie = re.compile(r'([a-zA-Z]+[\d]*[a-zA-Z]+[\d]*)\s+(\d+)', re.M | re.I)
                if line_ie.search(line):
                    # print (line_ie.search(line).group(0))
                    each_ie_data[0] = line_ie.search(line).group(1)
                    each_ie_data[1] = line_ie.search(line).group(2)
                    each_ie_data[2] = signal_block_checker
                    each_sig_data.append(tuple(each_ie_data[:]))
                    #print (each_ie_data)

#print(sig_location)
#print(sig_data)
#print(df_sig)