import pandas as pd
from pandas import Series, DataFrame

input1 = ['2016-11-03', '20', '22', '39.660413', 'bfn']
input2 = ['2016-11-03', '20', '22', '39.660412', 'bfn']
input3 = ['2016-11-03', '20', '22', '39.660412', 'bfn']
input4 = ['2016-11-03', '20', '22', '39.660413', 'bfn']
input5 = ['2016-11-03', '20', '22', '39.660413', 'bfn']

obj = Series(input1)
obj.index = ['date', 'sfn', 'bfn1', 'bfn2', 'bfn3']


data = {'state': ['Ohio', 'Ohio', 'Ohio', 'Nevada', 'Nevada'],
        'year': [2000, 2001, 2002, 2001, 2002],
        'pop': [1.5, 1.7, 3.6, 2.4, 2.9]}
frame = DataFrame(data, columns=['year', 'state', 'pop'], index=['one', 'two', 'three', 'four', 'five'])
print (frame)
print (frame['state'])
print (frame['year'])
print (frame.ix['three'])