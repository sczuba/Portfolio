#install packages
install.packages ("tidyverse")

#load libraries
library(tidyverse)

#set working directory (adjust this for your own computer)
setwd("C:/Users/cleec/Dropbox/Eastern/Courses/DS for business/Module 4/R")

#Modeling a linear time series trend using regression

#read dataset into R
starbucksdf <- read.csv("starbucks_revenue.csv")
View(starbucksdf)

#create a time series plot showing yearly net revenue in billions
ggplot(data = starbucksdf, mapping = aes(x = Year, y = NetRevenue)) +
  geom_line () +
  geom_point() +
  labs(title = "Starbucks Yearly Net Revenue in Billions of Dollars, 
       2003 to 2021", x = "Year", y = "Net Revenue")

#Add a column of consecutive numbers corresponding with each year
starbucksdf$Time <- 1:nrow(starbucksdf) 

#Use simple linear regression analysis to create a regression equation for 
#forecasting
sbreg<-lm(NetRevenue ~ Time, data = starbucksdf)
summary(sbreg)

#Predict Starbucks revenue for 2022
2.547+1.209*20 

#Predict Starbucks revenue for 2022, 2023, 2024

#Create a data frame with the time periods to use for the prediction
new <- data.frame(Time = c(20, 21, 22))
predict(sbreg, newdata = new)


#Create functions for the accuracy measures (we've done this before)
mae<-function(actual,pred){
  mae <- mean(abs(actual-pred), na.rm=TRUE)
  return (mae)
}

mse<-function(actual,pred){
  mse <- mean((actual-pred)^2, na.rm=TRUE)
  return (mse)
}

rmse<-function(actual,pred){
  rmse <- sqrt(mean((actual-pred)^2, na.rm=TRUE))
  return (rmse)
}  

mape<-function(actual,pred){
  mape <- mean(abs((actual - pred)/actual), na.rm=TRUE)*100
  return (mape)
}

#Create a vector of predicted values generated from the 
#regression above (sbreg)
sb_pred = predict(sbreg)

#Run the accuracy measure functions with vector of actual values and vector
#of predicted values as inputs
mae (starbucksdf$NetRevenue, sb_pred)
mse (starbucksdf$NetRevenue, sb_pred)
rmse (starbucksdf$NetRevenue, sb_pred)
mape (starbucksdf$NetRevenue, sb_pred)

#Look at residuals from time series regression
#Steps to create a scatterplot of residuals vs. predicted values of the 
#dependent variable

#We have already created a vector of predicted values above

#Create a vector of residuals generated from the regression above
sb_res = resid(sbreg)

#Create a data frame of the predicted values and the residuals
pred_res_df <- data.frame(sb_pred, sb_res)

#create a scatterplot of the residuals versus the predicted values
ggplot(data = pred_res_df, mapping = aes(x = sb_pred, y = sb_res)) +
  geom_point() +
  labs(title = "Plot of residuals vs. predicted values", x = "Predicted values",
       y = "Residuals")


#Modeling seasonality in a time series using regression

#read dataset into R
nytdf <- read.csv("NYT_revenue.csv")
View(nytdf)

#create a time series plot showing NYT quarterly revenue
ggplot(data = nytdf, mapping = aes(x = Quarter, y = Revenue)) +
  geom_line (group=1) +
  geom_point() +
  labs(title = "New York Times Quarterly Revenue 2013 to 2016", 
       x = "Quarter", y = "Revenue")

#Create dummy variables corresponding to each quarter 
nytdf$Q1 <- ifelse(grepl("Q1",nytdf$Quarter), 1, 0)
nytdf$Q2 <- ifelse(grepl("Q2",nytdf$Quarter), 1, 0)
nytdf$Q3 <- ifelse(grepl("Q3",nytdf$Quarter), 1, 0)
nytdf$Q4 <- ifelse(grepl("Q4",nytdf$Quarter), 1, 0)

#Use multiple regression with quarter variables to generate a regression 
#equation for forecasting
nytreg<-lm(Revenue ~ Q1 + Q2 + Q3, data = nytdf)
summary(nytreg)


#Predict NYT revenue for 2017 Q1, Q2, Q3, Q4

#Create an object with the time periods to use for the prediction
new <- data.frame(Q1 = c(1,0,0,0), Q2 = c(0,1,0,0), Q3 = c(0,0,1,0)) 
predict(nytreg, newdata = new)


#Modeling trend and seasonality in a time series using regression

#read dataset into R
wfdf <- read.csv("whole_foods.csv")
View(wfdf)

#create a time series plot showing quarterly net sales
ggplot(data = wfdf, mapping = aes(x = Quarter, y = Net.Sales)) +
  geom_line (group=1) +
  geom_point() +
  theme(axis.text.x = element_text(angle = 90))
  labs(title = "Whole Foods Quarterly Net Sales 2005 to 2016 in $ millions", 
       x = "Quarter", y = "Net Sales")

#Add a column of consecutive numbers corresponding with each year
wfdf$Time <- 1:nrow(wfdf) 

#Create dummy variables corresponding to each quarter 
wfdf$Q1 <- ifelse(grepl("Q1",wfdf$Quarter), 1, 0)
wfdf$Q2 <- ifelse(grepl("Q2",wfdf$Quarter), 1, 0)
wfdf$Q3 <- ifelse(grepl("Q3",wfdf$Quarter), 1, 0)
wfdf$Q4 <- ifelse(grepl("Q4",wfdf$Quarter), 1, 0)

#Use regression with the time variable to generate a regression 
#equation for forecasting
wfreg<-lm(Net.Sales ~ Time, data = wfdf)
summary(wfreg)

#Create a vector of predicted values generated from the 
#regression above
wf_pred = predict(wfreg)

#calculate accuracy measures with vector of actual values and vector
#of predicted values as inputs
mae(wfdf$Net.Sales, wf_pred)
mse(wfdf$Net.Sales, wf_pred)
rmse(wfdf$Net.Sales, wf_pred)
mape(wfdf$Net.Sales, wf_pred)

#Use multiple regression with the time and quarters variables to generate 
#a regression equation for forecasting
wfreg2<-lm(Net.Sales ~ Time + Q2 + Q3 + Q4, data = wfdf)
summary(wfreg2)

#Create a vector of predicted values generated from the multiple 
#regression above
wf_pred2 = predict(wfreg2)

#calculate accuracy measures with vector of actual values and vector
#of predicted values as inputs
mae(wfdf$Net.Sales, wf_pred2)
mse(wfdf$Net.Sales, wf_pred2)
rmse(wfdf$Net.Sales, wf_pred2)
mape(wfdf$Net.Sales, wf_pred2)

#Predict Whole Foods Net Sales for 2017 Q1, Q2, Q3, Q4

#Create an object with the time periods to use for the prediction
new <- data.frame(Time = c(49, 50, 51, 52), Q2 = c(0,1,0,0), Q3 = c(0,0,1,0), 
                  Q4 = c(0,0,0,1)) 
predict(wfreg2, newdata = new)


#Modeling a quadratic trend in a time series using polynomial regression

#read dataset into R
lidf <- read.csv("linked_in.csv")
View(lidf)

#create a time series plot showing number of LinkedIn members by quarter, 
#in millions
ggplot(data = lidf, mapping = aes(x = Quarter, y = Members)) +
  geom_line (group=1) +
  geom_point() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "LinkedIn members by Quarter (millions), 2009 to 2014", 
       x = "Quarter", y = "Members")

#Add a column of consecutive numbers corresponding with each quarter
lidf$Time <- 1:nrow(lidf) 

#Use simple linear regression analysis to create a regression equation for 
#forecasting
lireg<-lm(Members ~ Time, data = lidf)
summary(lireg)

#Create a vector of predicted values generated from the 
#regression above
li_pred = predict(lireg)

#calculate accuracy measures with vector of actual values and vector
#of predicted values as inputs
mae (lidf$Members, li_pred)
mse (lidf$Members, li_pred)
rmse (lidf$Members, li_pred)
mape (lidf$Members, li_pred)

#Create a new variable that squares the Time variable
lidf$Time2 <- lidf$Time^2

#Use a quadratic regression model to create a regression equation for 
#forecasting
liregquad<-lm(Members ~ Time + Time2, data = lidf)
summary(liregquad)

#Create a vector of predicted values generated from the 
#regression above
li_pred2 = predict(liregquad)

#calculate accuracy measures with vector of actual values and vector
#of predicted values as inputs
mae (lidf$Members, li_pred2)
mse (lidf$Members, li_pred2)
rmse (lidf$Members, li_pred2)
mape (lidf$Members, li_pred2)


#Predict LinkedIn membership for Quarter 3 and Quarter 4 of 2014

#Create an object with the time periods to use for the prediction
new <- data.frame(Time = c(23, 24), Time2 = c(529, 576))
predict(liregquad, newdata = new)

             