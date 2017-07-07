import sys
sys.path.append("../choose_your_own/")
from class_vis import prettyPicture
import numpy as np
x = np.array([[-1, -1], [-2, -1], [1, 1], [2, 1]])
print x
y = np.array([1,1,2,2])
print y
from sklearn.svm import SVC
clf = SVC()
plt = clf.fit(x,y)
print plt
test_data = clf.predict([[-0.8, -1]])
print test_data
prettyPicture(clf,x,y)
