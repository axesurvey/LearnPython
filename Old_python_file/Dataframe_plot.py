#coding:utf-8
import re
import csv
import pandas as pd
import numpy as np
from pandas import Series, DataFrame
import scipy
import matplotlib.pyplot as plt

__author__ = "Yulin Cui"
__version__ = "1.0"

df = pd.read_csv("201604.csv", index_col=0)


df.plot(x=list(df.axes[0]), y='A38_assignableBytes', kind='scatter')
plt.show()