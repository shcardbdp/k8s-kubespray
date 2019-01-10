# libraries
import numpy as np
import scipy as sp
import scipy.stats
import pandas as pd
import matplotlib.pyplot as plt

# read data
df = pd.read_csv('data05_boston.csv')

# simple linear regression
from sklearn.linear_model import LinearRegression
X = df[ ['lstat','rm','age'] ]
y = df['medv']
lm = LinearRegression()
lm.fit(X,y)
lm.coef_  # coefficients
lm.intercept_ # intercepter
yhat = lm.predict(X) # prediction
r2 = lm.score(X,y) # R2
rmse = np.sqrt(((y-yhat)**2).mean())

plt.plot(X,y,'bo')
plt.plot(X,yhat,'r',linewidth=2)
plt.title('%s vs. Medv: %.2f' % ('lstat',r2))
plt.show()

# multiple linear regression
X = df.iloc[:,0:13]
y = df['medv']
lm = LinearRegression()
lm.fit(X,y)
lm.coef_  # coefficients
lm.intercept_ # intercepter
yhat = lm.predict(X) # prediction
r2 = lm.score(X,y) # R2
rmse = np.sqrt(((y-yhat)**2).mean())

plt.plot(yhat,y,'bo')
plt.title('All vs. Medv: %.2f' % r2)
plt.show()

# using StatsModel
import statsmodels.api as sm
X = df.iloc[:,0:13]
X = sm.add_constant(X)
y = df['medv']
f = sm.OLS(y,X)
r = f.fit()
r.summary()

# using StatsModel formula
import statsmodels.formula.api as smf
r = smf.ols('medv ~ crim+zn+indus',data=df).fit()
r.summary()

# add a new variable
plt.plot(df['lstat'],df['medv'],'bo')
#X = df.iloc[:,0:13]
X = df[ ['lstat'] ]
lstat2 = X['lstat']
X['lstat2'] = lstat2
X = sm.add_constant(X)
y = df['medv']
f = sm.OLS(y,X)
r = f.fit()
r.summary()

X = df[ ['lstat','rm'] ]
X['lstat_rm'] = X['lstat'] * X['rm']
X = sm.add_constant(X)
y = df['medv']
f = sm.OLS(y,X)
r = f.fit()
r.summary()


# training vs. test set
np.random.seed(1)
train_idx = list(np.random.choice(np.arange(df.shape[0]),300,replace=False))
test_idx = list(set(np.arange(df.shape[0])).difference(train_idx))
dftrain = df.iloc[train_idx,:]
dftest = df.iloc[test_idx,:]


xtrain = dftrain.iloc[:,0:13]
ytrain = dftrain['medv']
xtest = dftest.iloc[:,0:13]
ytest = dftest['medv']

lm = LinearRegression()
lm.fit(xtrain,ytrain)

yhat_train = lm.predict(xtrain)
rmse_train = np.sqrt( ((ytrain-yhat_train)**2).mean() )
r2_train = lm.score(xtrain,ytrain)

yhat_test = lm.predict(xtest)
rmse_test = np.sqrt( ((ytest-yhat_test)**2).mean() )
r2_test = lm.score(xtest,ytest)

print(rmse_train,rmse_test)


###########################################################
# Practice Reference Code
###########################################################

# data01_iris.csv를 읽으시오. 
# Sepal Width ~ Sepal.Length + Petal.Length + Petal.Width 로 
# 선형 회귀 분석을 수행하시오. 
# (1) R2와 RMSE 값은 얼마인가?
# (2) 어떤 변수의 제곱항을 추가하였을 때, 가장 높은 R2를 갖는 것은 어느 변수인가?
# (3) Sepal.Length와 Petal.Length의 interaction 항을 추가하였을 때, R2은 
# 얼마인가?
# (4) 범주형 변수 Sepcies를 포함시켜 선형 회귀 분석을 수행하시오.














































# PLEASE DO NOT GO DOWN BEFORE YOU TRY BY YOURSELF

###########################################################
# Practice Reference Code
###########################################################

# practice
df = pd.read_csv('data01_iris.csv')

# OLS
X = df[['Sepal.Length','Petal.Length','Petal.Width']]
y = df['Sepal.Width']

lm = LinearRegression()
lm.fit(X,y)
lm.score(X,y)

X = sm.add_constant(X)
f = sm.OLS(y,X)
f.fit().summary()


# adding 2nd order term
X = df[['Sepal.Length','Petal.Length','Petal.Width']]
y = df['Sepal.Width']
x1 = X['Petal.Length']**2
X['PL2'] = x1

X = sm.add_constant(X)
f = sm.OLS(y,X)
f.fit().summary()


# adding interaction term
X = df[['Sepal.Length','Petal.Length','Petal.Width']]
y = df['Sepal.Width']

x1 = X['Petal.Width']*X['Petal.Length']
X['Inter'] = x1

X = sm.add_constant(X)
f = sm.OLS(y,X)
r = f.fit()
r.summary()


# adding Species
X = df[['Sepal.Length','Petal.Length','Petal.Width']]

x1 = np.zeros(X.shape[0])
x1[ df['Species']=='versicolor' ] = 1

x2 = np.zeros(X.shape[0])
x2[ df['Species']=='virginica' ] = 1

X['Species_versicolor'] = x1
X['Species_virginica'] = x2
y = df['Sepal.Width']

X = sm.add_constant(X)
f = sm.OLS(y,X)
r = f.fit()
r.summary()









