# libraries
import numpy as np
import scipy as sp
import pandas as pd
import matplotlib.pyplot as plt

# read data
df = pd.read_csv('data09_diabetes.csv')
df_data = df.iloc[:,:-1]
df_target = df['Y']

# boston data set
from sklearn.model_selection import train_test_split
xtrain,xtest,ytrain,ytest = train_test_split(
        df_data,df_target,test_size=0.33,random_state=0)

# forward feature selection
import statsmodels.api as sm
vn = list(xtrain.columns)
f_sel= []
score = []
for i in range(xtrain.shape[1]):
    s = np.zeros(len(vn))
    for j in range(len(vn)):
        v = f_sel.copy()
        v.append(vn[j])
        x = sm.add_constant(xtrain[v])
        r = sm.OLS(ytrain,x).fit() # model fitting
        s[j] = r.rsquared_adj # evaluation
    v = vn[s.argmax()]
    f_sel.append(v)
    vn.remove(v)
    score.append(s.max())
    print("%02d Selected:"%i,f_sel)
    print("%02d Score   :"%i,np.round(10000*np.array(score))/10000)

# finally selected features    
f_sel_final = f_sel[:(np.array(score).argmax()+1)]

# test on the test set
from sklearn.linear_model import LinearRegression
f = LinearRegression()
f.fit(xtrain[f_sel_final],ytrain)
yhat_test = f.predict(xtest[f_sel_final])
rmse_test = np.sqrt( ((ytest-yhat_test)**2).mean() )

# comparison



# practice 1
# implement backward feature selection and test over the diabetes data set

# practice 2
df = pd.read_csv('data02_college.csv')
X = df.iloc[:,3:]
y = df['Accept']/df['Apps']
xtrain,xtest,ytrain,ytest = train_test_split(X,y,test_size=0.33,random_state=0)
# find the best model using feature selection methods

























# PLEASE DO NOT GO DOWN BEFORE YOU TRY BY YOURSELF

###########################################################
# Practice Reference Code
###########################################################

# practice 1

# libraries
import numpy as np
import scipy as sp
import pandas as pd
import matplotlib.pyplot as plt

# read data
df = pd.read_csv('data09_diabetes.csv')
df_data = df.iloc[:,:-1]
df_target = df['Y']

# boston data set
from sklearn.model_selection import train_test_split
xtrain,xtest,ytrain,ytest = train_test_split(
        df_data,df_target,test_size=0.33,random_state=0)

# backward feature selection
import statsmodels.api as sm
vn = list(xtrain.columns)
f_sel_list = []
score = []
for i in range(xtrain.shape[1]):
    if i == 0: # full model
        x = sm.add_constant(xtrain)
        r = sm.OLS(ytrain,x).fit()
        s = np.array(r.rsquared_adj)
    else: 
        s = np.zeros(len(vn))
        for j in range(len(vn)):
            v = vn.copy()
            v.remove(vn[j])
            x = sm.add_constant(xtrain[v])
            r = sm.OLS(ytrain,x).fit() # model fitting
            s[j] = r.rsquared_adj # evaluation
        v = vn[s.argmax()]
        vn.remove(v)
    f_sel_list.append(vn.copy())
    score.append(s.max())
    print("%02d Selected:"%i,vn)
    print("%02d Score   :"%i,np.round(10000*np.array(score))/10000)


# finally selected features    
f_sel_final = f_sel_list[np.array(score).argmax()]

# test on the test set
from sklearn.linear_model import LinearRegression
f = LinearRegression()
f.fit(xtrain[f_sel_final],ytrain)
yhat_test = f.predict(xtest[f_sel_final])
rmse_test = np.sqrt( ((ytest-yhat_test)**2).mean() )


# practice 2



