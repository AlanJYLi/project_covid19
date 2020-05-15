# exploration
data=read.csv('covid.csv')
data=data[,5:10] #remove unneeded columns
data=data.frame(scale(data)) #scale the data
a=lm(Cases~.,data)
summary(a)


#Gibbs sampling
library(MASS)
library(coda)
X=data[,-1]
n=dim(X)[1]
intercept=as.data.frame(rep(1,n))
colnames(intercept)='intercept'
X=as.matrix(cbind(intercept,X))
y=data$Cases

m=10000
beta=matrix(0,nrow=m,ncol=6)
sigma2=numeric(m)
sigma2[1]=summary(a)$sigma^2
Sinv=solve(t(X)%*%X)
betahat=Sinv%*%t(X)%*%y
for(i in 2:m)
{
  beta[i,]=mvrnorm(1,betahat,sigma2[i-1]*Sinv)
  e=y-X%*%beta[i,]
  sigma2[i]=1/rgamma(1,n/2,t(e)%*%e/2)
}


#Density plot
par(mfrow=c(3,2))
plot(density(beta[100:m,1]), main='intercept, beta0')
abline(v=0,col=2)
plot(density(beta[100:m,2]), main='Population, beta1')
abline(v=0,col=2)
plot(density(beta[100:m,3]), main='GDP, beta2')
abline(v=0,col=2)
plot(density(beta[100:m,4]), main='Distance, beta3')
abline(v=0,col=2)
plot(density(beta[100:m,5]), main='PassengerTurnover, beta4')
abline(v=0,col=2)
plot(density(beta[100:m,6]), main='TravelConnection, beta5')
abline(v=0,col=2)


#MCMC Diagnostics
effectiveSize(beta)
effectiveSize(sigma2)


#MCMC Diagnostics: acf
par(mfrow=c(3,2))
acf(beta[100:m,1], main=NA)
title('ACF plot of intercept, beta0')
acf(beta[100:m,2], main=NA)
title('ACF plot of Population, beta1')
acf(beta[100:m,3], main=NA)
title('ACF plot of GDP, beta2')
acf(beta[100:m,4], main=NA)
title('ACF plot of Distance, beta3')
acf(beta[100:m,5], main=NA)
title('ACF plot of PassengerTurnover, beta4')
acf(beta[100:m,6], main=NA)
title('ACF plot of TravelConnection, beta5')


#HDI interval
library(HDInterval)
hdi(beta)