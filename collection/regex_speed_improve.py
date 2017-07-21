import string
#from string import maketrans
import re, timeit

pat = re.compile('[\w-]*$')
pat_inv = re.compile ('[^\w-]')
allowed_chars=string.ascii_letters + string.digits + '_-'
allowed_set = set(allowed_chars)
#trans_table = str.maketrans('','')
trans_table3 = dict((ord(char), '') for char in allowed_chars)

def check_set_diff(s):
    return not set(s) - allowed_set

def check_set_all(s):
    return all(x in allowed_set for x in s)

def check_set_subset(s):
    return set(s).issubset(allowed_set)

def check_re_match(s):
    return pat.match(s)

def check_re_inverse(s): # Search for non-matching character.
    return not pat_inv.search(s)

#def check_trans(s):
#    return not s.translate(trans_table)
def check_trans(s):
    return not s.translate(trans_table3)

test_long_almost_valid='a_very_long_string_that_is_mostly_valid_except_for_last_char'*99 + '!'
test_long_valid='a_very_long_string_that_is_completely_valid_' * 99
test_short_valid='short_valid_string'
test_short_invalid='/$%$%&'
test_long_invalid='/$%$%&' * 99
test_empty=''

def main():
    funcs = sorted(f for f in globals() if f.startswith('check_'))
    tests = sorted(f for f in globals() if f.startswith('test_'))
    for test in tests:
        print ("Test %-15s (length = %d):" % (test, len(globals()[test])))
        for func in funcs:
            print ("  %-20s : %.3f" % (func,
                   timeit.Timer('%s(%s)' % (func, test), 'from __main__ import pat,allowed_set,%s' % ','.join(funcs+tests)).timeit(10000)))
        print()

if __name__=='__main__': main()