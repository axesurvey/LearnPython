from __future__ import with_statement
import time
import mmap
import random
from collections import defaultdict

def mapcount(filename):
    f = open(filename, "r+")
    buf = mmap.mmap(f.fileno(), 0)
    lines = 0
    readline = buf.readline
    while readline():
        lines += 1
    print ("method1 line number is: " + str(lines))
    buf.close()
    return lines

def simplecount(filename):
    lines = 0
    for line in open(filename):
        lines += 1
    print ("method2 line number is: " + str(lines))
    return lines

def bufcount(filename):
    f = open(filename)
    lines = 0
    buf_size = 1024 * 1024
    read_f = f.read # loop optimization

    buf = read_f(buf_size)
    while buf:
        lines += buf.count('\n')
        buf = read_f(buf_size)
    print ("method3 line number is: " + str(lines))
    return lines

def opcount(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    print ("method4 line number is: " + str(i+1))
    return i + 1


counts = defaultdict(list)

for i in range(5):
    for func in [mapcount, simplecount, bufcount, opcount]:
        start_time = time.time()
        assert func("C:/Users/eyulcui/Dropbox/Python_CATM/capture_lienb2466.dec") == 8023336
        #func("C:/Users/eyulcui/Dropbox/Python_CATM/capture_lienb2466.dec")
        counts[func].append(time.time() - start_time)

for key, vals in counts.items():
    print (key.__name__, ":", sum(vals) / float(len(vals)))