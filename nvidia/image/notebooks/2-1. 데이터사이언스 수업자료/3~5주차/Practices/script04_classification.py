# libraries
import numpy as np
import scipy as sp
import pandas as pd
import matplotlib.pyplot as plt

# read data from file
df = pd.read_csv('data06_iris.csv')
X = df.iloc[:,:-1]
Y = df['Species']

# train & test data
from sklearn.model_selection import train_test_split
xtrain, xtest, ytrain, ytest = train_test_split(X,Y,test_size=0.4,random_state=1) 


###########################################################
# logistic regression
###########################################################

from sklearn.linear_model import LogisticRegression

# simple logistic regression
f = LogisticRegression()
f.fit(xtrain[['Petal.Length']],ytrain)
f.coef_
f.intercept_
x = np.arange(0,10,step=0.1)
x = x.reshape((len(x),1))
yhat_prob = f.predict_proba(x)
yhat = f.predict(x)

plt.plot(xtrain[['Petal.Length']],ytrain,'go')
plt.plot(x[:,0],yhat_prob[:,1])
plt.show()

# multiple logistic regression
f = LogisticRegression()
f.fit(xtrain,ytrain)
yhat_train = f.predict(xtrain)
yhat_train_prob = f.predict_proba(xtrain)
yhat_test = f.predict(xtest)
yhat_test_prob = f.predict_proba(xtest)

pd.crosstab(ytrain,yhat_train)
pd.crosstab(ytest,yhat_test)

f.score(xtrain,ytrain)
f.score(xtest,ytest)

# roc curve
from sklearn.metrics import roc_curve, roc_auc_score
fpr,tpr,th = roc_curve(ytest,yhat_test_prob[:,1])

auc = roc_auc_score(ytest,yhat_test_prob[:,1])

plt.plot(fpr,tpr)
plt.title('AUC: %.2f' % auc)
plt.show()


###########################################################
# linear discriminant analysis
###########################################################

# linear discriminant analysis: 2D
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis

# full model
f = LinearDiscriminantAnalysis()
f.fit(xtrain,ytrain)
yhat_train = f.predict(xtrain)
yhat_train_prob = f.predict_proba(xtrain)
yhat_test = f.predict(xtest)
yhat_test_prob = f.predict_proba(xtest)
f.score(xtrain,ytrain)
f.score(xtest,ytest)

# roc
fpr,tpr,th = roc_curve(ytest,yhat_test_prob[:,1])
auc = roc_auc_score(ytest,yhat_test_prob[:,1])
plt.plot(fpr,tpr)
plt.title('AUC: %.2f' % auc)
plt.show()

# quadratic discriminant analysis
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis

f = QuadraticDiscriminantAnalysis()
f.fit(xtrain,ytrain)
yhat_test = f.predict(xtest)
yhat_test_prob = f.predict_proba(xtest)
f.score(xtrain,ytrain)
f.score(xtest,ytest)

# roc
fpr,tpr,th = roc_curve(ytest,yhat_test_prob[:,1])
auc = roc_auc_score(ytest,yhat_test_prob[:,1])
plt.plot(fpr,tpr)
plt.title('AUC: %.2f' % auc)
plt.show()

###########################################################
# knn
###########################################################

from sklearn.neighbors import KNeighborsClassifier

f = KNeighborsClassifier(5)
f.fit(xtrain,ytrain)
yhat_test = f.predict(xtest)
yhat_test_prob = f.predict_proba(xtest)
f.score(xtrain,ytrain)
f.score(xtest,ytest)

# roc
fpr,tpr,th = roc_curve(ytest,yhat_test_prob[:,1])
auc = roc_auc_score(ytest,yhat_test_prob[:,1])
plt.plot(fpr,tpr)
plt.title('AUC: %.2f' % auc)
plt.show()


###########################################################
# all at once
###########################################################

classifier_names = ['logistic','lda','qda','knn']
classifiers = [
        LogisticRegression(),
        LinearDiscriminantAnalysis(),
        QuadraticDiscriminantAnalysis(),
        KNeighborsClassifier(5)]


col = ['r','b','g','k']
fig,ax = plt.subplots(1,2,figsize=(10,5))

err = np.zeros((4,2))
auc = np.zeros((4,2))
for i in range(len(classifiers)):
    f = classifiers[i].fit(xtrain,ytrain)
    yhat_train_prob = f.predict_proba(xtrain)
    yhat_test_prob = f.predict_proba(xtest)
    err[i,0] = f.score(xtrain,ytrain)
    err[i,1] = f.score(xtest,ytest)
    auc[i,0] = roc_auc_score(ytrain,yhat_train_prob[:,1])
    auc[i,1] = roc_auc_score(ytest,yhat_test_prob[:,1])
    fpr,tpr,th = roc_curve(ytrain,yhat_train_prob[:,1])
    ax[0].plot(fpr,tpr,col[i])    
    fpr,tpr,th = roc_curve(ytest,yhat_test_prob[:,1])
    ax[1].plot(fpr,tpr,col[i])
    
ax[0].set_title('Training Set')
ax[1].set_title('Test Set')
plt.show()


###########################################################
# Practices
###########################################################


df = pd.read_csv('data02_college.csv')
X = df.iloc[:,2:].as_matrix()
Y = df['Private'].factorize()[0]











































# PLEASE DO NOT GO DOWN BEFORE YOU TRY BY YOURSELF

###########################################################
# Practice Reference Code
###########################################################

df = pd.read_csv('data02_college.csv')
X = df.iloc[:,2:].as_matrix()
Y = df['Private'].factorize()[0]
xtrain, xtest, ytrain, ytest = train_test_split(X,Y,test_size=0.4,random_state=0) 

f = LogisticRegression(C=0.1)
f.fit(xtrain,ytrain)
f.score(xtrain,ytrain)
f.score(xtest,ytest)
yhat_test_prob = f.predict_proba(xtest)

fpr,tpr,th = roc_curve(ytest,yhat_test_prob[:,1])
auc = roc_auc_score(ytest,yhat_test_prob[:,1])
plt.plot(fpr,tpr)






