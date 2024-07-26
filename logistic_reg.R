#install packages
install.packages ("tidyverse")
install.packages("caret")
install.packages("ROCR")
install.packages("ROSE")


#load libraries
library(tidyverse)
library(caret)
library(ROCR)
library(ROSE)


#set working directory (adjust this for your own computer)
setwd("C:/Users/cleec/Dropbox/Eastern/Courses/DS for business/Module 5/R")

#read dataset into R
optivadf <- read.csv("optiva.csv")
View(optivadf)

#Convert categorical variables to factors with levels and labels
optivadf$LoanDefault<-factor(optivadf$LoanDefault,levels = c(0,1),labels = c("No","Yes"))
optivadf$Entrepreneur<-factor(optivadf$Entrepreneur,levels = c(0,1),labels = c("No","Yes"))
optivadf$Unemployed<-factor(optivadf$Unemployed,levels = c(0,1),labels = c("No","Yes"))
optivadf$Married<-factor(optivadf$Married,levels = c(0,1),labels = c("No","Yes"))
optivadf$Divorced<-factor(optivadf$Divorced,levels = c(0,1),labels = c("No","Yes"))
optivadf$HighSchool<-factor(optivadf$HighSchool,levels = c(0,1),labels = c("No","Yes"))
optivadf$College<-factor(optivadf$College,levels = c(0,1),labels = c("No","Yes"))

#check for missing data
sum(is.na(optivadf))

#generate summary statistics for all variables in dataframe
summary(optivadf)



#set seed so the random sample is reproducible
set.seed(42)

#Partition the Optiva dataset into a training, validation and test set
Samples<-sample(seq(1,3),size=nrow(optivadf),replace=TRUE,prob=c(0.6,0.2,0.2))
Train<-optivadf[Samples==1,]
Validate<-optivadf[Samples==2,]
Test<-optivadf[Samples==3,]

#View descriptive statistics for each dataframe
summary(Train)
summary(Validate)
summary(Test)


#Addressing class imbalance in the training set

#Steps to create an oversampled or undersampled training subset

#Create a data frame with only the predictor variables by removing 
#column 2 (Loan Default)
xsdf<-Train[c(-2)]
View(xsdf)

#Create an undersampled training subset
set.seed(42)
undersample<-downSample(x=xsdf, y=Train$LoanDefault, yname = "LoanDefault")

table(undersample$LoanDefault)

#Create an oversampled training subset
set.seed(42)
oversample<-upSample(x=xsdf, y=Train$LoanDefault, yname = "LoanDefault")

table(oversample$LoanDefault)

#Create a training subset with ROSE
set.seed(42)
rose<-ROSE(LoanDefault ~ ., data  = Train)$data                         

table(rose$LoanDefault)


# fit logistic regression model on the LoanDefault outcome variable
# using specified input variables with the undersample dataframe

#Logistic regression is part of the general linear model family, so the R 
#function is glm.
options(scipen=999)
lrUnder <- glm(LoanDefault ~ . - CustomerID, data = undersample, 
               family = binomial(link = "logit"))

# model summary
summary(lrUnder)

# fit logistic regression model on the LoanDefault outcome variable
# using specified input variables with the oversample dataframe
lrOver <- glm(LoanDefault ~ . - CustomerID, data = oversample, 
              family = binomial(link = "logit"))

# model summary
summary(lrOver)

# fit logistic regression model on the LoanDefault outcome variable
# using specified input variables with the rose dataframe

lrrose <- glm(LoanDefault ~ . - CustomerID, data = rose, 
              family = binomial(link = "logit"))

# model summary
summary(lrrose)


#exponentiate the regression coefficients from the logistic regression model 
#using the oversample dataframe
exp(coef(lrOver))


#Steps to create a confusion matrix

#First using logistic regression model built on oversampled training subset

# obtain probability of defaulting for each observation in validation set
lrprobsO <- predict(lrOver, newdata = Validate, type = "response")

#Attach probability scores to Validate dataframe
Validate <- cbind(Validate, Probabilities=lrprobsO)

# obtain predicted class for each observation in validation set using threshold of 0.5
lrclassO <- as.factor(ifelse(lrprobsO > 0.5, "Yes","No"))

#Attach predicted class to Validate dataframe
Validate <- cbind(Validate, PredClass=lrclassO)

#Create a confusion matrix using "Yes" as the positive class 
confusionMatrix(lrclassO, Validate$LoanDefault, positive = "Yes" )


#Steps to create a confusion matrix

#Using logistic regression model built on undersampled training subset

# obtain probability of positive class for each observation in validation set
lrprobsU <- predict(lrUnder, newdata = Validate, type = "response")

# obtain predicted class for each observation in validation set using threshold of 0.5
lrclassU <- as.factor(ifelse(lrprobsU > 0.5, "Yes","No"))

# output performance metrics using "Yes" as the positive class 
confusionMatrix(lrclassU, Validate$LoanDefault, positive = "Yes" )


#Steps to create a confusion matrix

#First using logistic regression model built on ROSE training subset


# obtain probability of positive class for each observation in validation set
lrprobsR <- predict(lrrose, newdata = Validate, type = "response")

# obtain predicted class for each observation in validation set using threshold of 0.5
lrclassR <- as.factor(ifelse(lrprobsR > 0.5, "Yes","No"))

# output performance metrics using "Yes" as the positive class 
confusionMatrix(lrclassR, Validate$LoanDefault, positive = "Yes" )


#change the probability cutoff to 0.6, still using the model built on ROSE subset

# obtain probability of positive class for each observation in validation set
lrprobsR2 <- predict(lrrose, newdata = Validate, type = "response")

# obtain predicted class for each observation in validation set using threshold of 0.5
lrclassR2 <- as.factor(ifelse(lrprobsR2 > 0.6, "Yes","No"))

# output performance metrics using "Yes" as the positive class 
confusionMatrix(lrclassR2, Validate$LoanDefault, positive = "Yes" )



#Plot ROC Curve for model from oversampled training set

#create a prediction object to use for the ROC Curve
predROC <- prediction(lrprobsO, Validate$LoanDefault)

#create a performance object to use for the ROC Curve
perfROC <- performance(predROC,"tpr", "fpr")

#plot the ROC Curve
plot(perfROC)
abline(a=0, b= 1)

# compute AUC 
performance(predROC, measure="auc")@y.values[[1]]


#Plot ROC Curve for model from undersampled training set

#create a prediction object to use for the ROC Curve
predROCU <- prediction(lrprobsU, Validate$LoanDefault)

#create a performance object to use for the ROC Curve
perfROCU <- performance(predROCU,"tpr", "fpr")

#plot the ROC Curve
plot(perfROCU)
abline(a=0, b= 1)

# compute AUC 
performance(predROCU, measure="auc")@y.values[[1]]


#Plot ROC Curve for model from ROSE training set

#create a prediction object to use for the ROC Curve
predROCR <- prediction(lrprobsR, Validate$LoanDefault)

#create a performance object to use for the ROC Curve
perfROCR <- performance(predROCR,"tpr", "fpr")

#plot the ROC Curve
plot(perfROCR)
abline(a=0, b= 1)

# compute AUC 
performance(predROCR, measure="auc")@y.values[[1]]


# Evaluate accuracy of the model built using the oversampled training set
# applied to the test set


# obtain probability of defaulting for each observation in test set
lrprobstest <- predict(lrOver, newdata = Test, type = "response")

# obtain predicted class for each observation in test set using threshold of 0.5
lrclasstest <- as.factor(ifelse(lrprobstest > 0.5, "Yes","No"))

#Create a confusion matrix using "Yes" as the positive class 
confusionMatrix(lrclasstest, Test$LoanDefault, positive = "Yes" )


#Plot ROC Curve for model from oversampled training set using Test set

#create a prediction object to use for the ROC Curve
predROCtest <- prediction(lrprobstest, Test$LoanDefault)

#create a performance object to use for the ROC Curve
perfROCtest <- performance(predROCtest,"tpr", "fpr")

#plot the ROC Curve
plot(perfROCtest)
abline(a=0, b= 1)

# compute AUC 
performance(predROCtest, measure="auc")@y.values[[1]]


#predict probability of default for new customers

#read new dataset into R
new_customers <- read.csv("OptivaNewData.csv")
View(new_customers)

#Convert categorical variables to factors with levels and labels
new_customers$Entrepreneur<-factor(new_customers$Entrepreneur,levels = c(0,1),labels = c("No","Yes"))
new_customers$Unemployed<-factor(new_customers$Unemployed,levels = c(0,1),labels = c("No","Yes"))
new_customers$Married<-factor(new_customers$Married,levels = c(0,1),labels = c("No","Yes"))
new_customers$Divorced<-factor(new_customers$Divorced,levels = c(0,1),labels = c("No","Yes"))
new_customers$HighSchool<-factor(new_customers$HighSchool,levels = c(0,1),labels = c("No","Yes"))
new_customers$College<-factor(new_customers$College,levels = c(0,1),labels = c("No","Yes"))

# make predictions for new data (for which loan default is unknown)
lrprobsnew <- predict(lrOver, newdata = new_customers , type = "response")

#Attach probability scores to new_customers dataframe 
new_customers <- cbind(new_customers, Probabilities=lrprobsnew)
View(new_customers)




