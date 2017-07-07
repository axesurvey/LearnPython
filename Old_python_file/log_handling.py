import re
import csv

with open('eggs1.csv', 'wb') as csvfile:
    outfwriter = csv.writer(csvfile, delimiter=' ', quotechar='|', quoting=csv.QUOTE_MINIMAL)


select_ie = [0,1,2,3,5]
with open("test_1ue.dec") as f1:
    for line in f1:
        if line.find("nrofCellsWithValidSes") > -1:
            pattern1 = re.compile(r'[\[\]\=\(\):;,\s]\s*')
            info1 = re.split(pattern1, line)
            new_info1 = [x for x in info1 if x != '']
            new_info2 = [new_info1[i] for i in select_ie]
            outfwriter.writerow(new_info2)
