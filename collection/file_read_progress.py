from __future__ import with_statement
from tqdm import tqdm

def opcount_line(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    #print ("method4 line number is: " + str(i+1))
    return i + 1


start_line_number = 0
#keyMsg = "UPC_DLMACCE_FI_SCHEDULE_RA_MSG2_REQ"


#logname = "C:/Users/eyulcui/Dropbox/Python_CATM/capture_lienb2466.dec"
logname = "C:/STUDY/Dropbox/Python_CATM/capture_lienb2466.dec"
file_lines = opcount_line(logname)

print ("Total line number for this log file is: " + str(file_lines) + "\n", end="")

#with open(logname) as log:
#    for eachline in log:
#        start_line_number += 1
#        if start_line_number/file_lines > 0.1:
#            print ("Current reading progress is: " + str(start_line_number) + "/" + str(file_lines))


f = open(logname,'r')
i = 0
for line in tqdm(f, total=opcount_line(logname)):
    i += 1
print (i)
