
#Loading  libraries

library(dplyr)
library(caret)
library(rpart)
library(tree)
library(e1071)
library(randomForest)
library(kernlab)
library(readr)
library(knitr)


teams <- read.csv('My Data WC18.csv')
wc <- read.csv('data_WC_2018.csv')

kable(teams)
wc1 <- wc[c(1,3,4)]


# Checking to see if there are any Missing Values

sort(sapply(teams, function(x) sum(is.na(x))), decreasing = T)

sort(sapply(wc1, function(x) sum(is.na(x))), decreasing = T)


# Merging the datasets. I'm using left_join in order to preserve the order of the data

wc_home <- left_join(wc1, teams, by = c('team_1'= 'Team'))



wc_all <- left_join(wc_home, teams, by = c( 'team_2' = 'Team' ))

colnames(wc_all)[c(4:10)] <- c('AvgGS_T1','AvgGC_T1', 'GD_T1', 'Wins_T1', 'Losses_T1', 'AvgOdds_T1', 'Pressure_T1')
colnames(wc_all)[c(11:17)] <- c('AvgGS_T2','AvgGC_T2', 'GD_T2', 'Wins_T2', 'Losses_T2', 'AvgOdds_T2', 'Pressure_T2')

sort(sapply(wc_all, function(x) sum(is.na(x))), decreasing = T)




# Adding Results of every Match. 
# 1 represents a team_1 victory
# Draws are coded as wins for team_1


wc_all$Result <- as.factor(as.numeric(c(1,0,0,1,1,1,0,1,0,0,1,1,1,0,0,0,1,1,1,0,1,1,0,1,1,0,1,0,1,1,1,0,1,1,1,1,0,1,0,0,0,1,0,1,0,0,0,0)))




# Splitting into test and train

# We will train on the first and third round of matches and test on the second round of matches.

train <- wc_all[c(1:16,33:48), ]
test <- wc_all[17:32,]


#logistic regression
glm.fit <- glm(Result ~.,
               data = train[-c(1,2,3)],
               family = 'binomial')

glm.probs <- predict(glm.fit, test, type = "response")
predictions_lr <- ifelse(glm.probs < 0.1, '1', '0')

test_resultsc <- as.character(test$Result)
lr_conf <- confusionMatrix(predictions_lr, test_resultsc, positive = '1')
lr_conf$byClass[2]
lr_conf$overall[1]

test$predlr <- predictions_lr


#Decision tree


tree_1 <-  rpart(Result ~ ., data=train[-c(1,2,3)], method= "class")

plot(tree_1)

tree_1_pred <- predict(tree_1, test[-c(18,19)], type = "class")

tree_1_pred <- ifelse(tree_1_pred==1,"1","0")

dt_conf <- confusionMatrix(tree_1_pred, test_resultsc, positive = "1")
dt_conf

test$preddt <- tree_1_pred


#SVM


svm <- svm(Result ~.,
           data = train[-c(1,2,3)])

predictions_svm <- predict(svm, test[-c(18,19,20)])

svm_pred <- ifelse(predictions_svm==1,"1","0")

svm_conf <- confusionMatrix(svm_pred, test_resultsc, positive = "1")
svm_conf

test$predsvm <- svm_pred




#Random forest 


rf <- randomForest(Result ~. , data = train[-c(1,2,3)])

plot( rf)

predictions_rf <- predict(rf, test, type = 'class')


rf_conf<- confusionMatrix(predictions_rf, test_resultsc, positive = "1")
rf_conf


test$predrf <- predictions_rf



# Evaluating all Models Built

models <- as.data.frame(matrix(c(lr_conf$byClass[1], dt_conf$byClass[1], svm_conf$byClass[1], rf_conf$byClass[1],
                   lr_conf$byClass[2],dt_conf$byClass[2],svm_conf$byClass[2],rf_conf$byClass[2],
                   lr_conf$overall[1],dt_conf$overall[1], svm_conf$overall[1], rf_conf$overall[1]),nrow =3 ,ncol=4,byrow=TRUE))


colnames(models) <-  c( 'Logistic Regression', 'Decision Trees ', 'SVM', 'Random Forest')


models$Metrics <- c('Sensitivity','Specificity',  'Accuracy')

kable(models[,c(5,1,2,3,4)])



#   |Metrics     | Logistic Regression| Decision Trees |       SVM| Random Forest|
#   |:-----------|-------------------:|---------------:|---------:|-------------:|
#   |Sensitivity |           0.2727273|       0.8181818| 0.7272727|     0.8181818|
#   |Specificity |           0.0000000|       1.0000000| 0.8000000|     0.8000000|
#   |Accuracy    |           0.1875000|       0.8750000| 0.7500000|     0.8125000|


# We will tune SVM and Random Forests to see if we get better results



#--------------------------------------------------------------------------------------
############   Hyperparameter tuning and Cross Validation #####################
#--------------------------------------------------------------------------------------

# 1. SVM


#Constructing SVM Models using different kernels to determine the best kernel



#   Using Linear Kernel
#-------------------------


Model_linear <- ksvm(Result~ ., data = train, scale = FALSE, kernel = "vanilladot")
Eval_linear<- predict(Model_linear, test)

#confusion matrix - Linear Kernel
confusionMatrix(Eval_linear,test$Result)


#           Accuracy : 0.75         
#           Sens     : 0.80
#           Spec     : 0.72
#           __________________




#    Using RBF Kernel
#----------------------------


Model_RBF <- ksvm(Result~ ., data = train, scale = FALSE, kernel = "rbfdot")
Eval_RBF<- predict(Model_RBF, test)

#confusion matrix - RBF Kernel
confusionMatrix(Eval_RBF,test$Result)


#           Accuracy : 0.75         
#           Sens     : 0.80
#           Spec     : 0.72
#           __________________




#    Using Kernel Poly
#----------------------------------

Model_Poly <- ksvm(Result~ ., data = train, scale = FALSE, kernel = "polydot")
Eval_Poly<- predict(Model_Poly, test)

#confusion matrix - Poly Kernel
confusionMatrix(Eval_Poly,test$Result)



#           Accuracy : 0.75         
#           Sens     : 0.80
#           Spec     : 0.72
#           __________________



#Thus, all three kernels have the same accuracy. Therefore , we will tune the Linear SVM , to find the best parameters.

# Tuning the Hyper parameters

#traincontrol function Controls the computational nuances of the train function.
# i.e. method =  CV means  Cross Validation.
#      Number = 2 implies Number of folds in CV.

trainControl <- trainControl(method="cv", number=3)




# Metric <- "Accuracy" implies our Evaluation metric is Accuracy.

metric <- "Accuracy"




#Expand.grid functions takes set of hyperparameters, that we shall pass to our model.

grid <- expand.grid( .C= c(1,5,10) )





# We will use the train function from caret package to perform Cross Validation. 


#train function takes Target ~ Prediction, Data, Method = Algorithm
#Metric = Type of metric, tuneGrid = Grid of Parameters,
# trcontrol = Our traincontrol method.

fit.svm <- train(Result~., data=train, method="svmLinear", metric=metric, 
                 tuneGrid=grid, trControl=trainControl)

print(fit.svm)


plot(fit.svm)





#The final values used for the model were C = 1, which can be seen below,


Model_linear <- ksvm(Result~ ., data = train, scale = FALSE, kernel = "vanilladot", C = 1)
Eval_linear<- predict(Model_linear, test)

#confusion matrix - RBF Kernel
confusionMatrix(Eval_linear,test$Result)


#           Accuracy : 0.75         
#           Sens     : 0.80
#           Spec     : 0.72
#           __________________


# Thus, this model will be the FINAL SVM MODEL we use. 




# 2. Random Forest
#   _______________

#-----------------------------------------------------
# Tuning the Hyper Parameters of the Random Forest 
#-----------------------------------------------------


# Grid Search

control <- trainControl(method="repeatedcv", number=10, repeats=3, search="grid")
metric <- "Accuracy"
set.seed(100)
tunegrid <- expand.grid(.mtry=c(1:15))
rf_gridsearch <- train(Result ~ ., data=train, method="rf", metric=metric, tuneGrid=tunegrid, trControl=control)
print(rf_gridsearch)
plot(rf_gridsearch)


# mtry = 4 is the best


# So our final model is

rf <- randomForest(Result ~. , data = train[-c(1,2,3)], mtry = 4, ntree = 1000)

plot( rf)

predictions_rf <- predict(rf, test, type = 'class')


confusionMatrix(predictions_rf, test_resultsc, positive = "1")

test$predrf <- predictions_rf

#             Accuracy    : 0.8125
#             Sensitivity : 0.8182          
#             Specificity : 0.8000 
#           _____________________________


# This is the best combination of Accuracy , Sensitivity and Specificity that we have got. We will use this as our final model.



#---------------------------------------------------------------------------------------------------------------------------

# -------------
# PREDICTIONS
# -------------


# Predicting for RO16

team_1 <- c('France', 'Uruguay', 'Spain', 'Croatia','Brazil', 'Belgium', 'Sweden', 'Colombia') 
team_2 <- c('Argentina', 'Portugal', 'Russia', 'Denmark', 'Mexico','Japan', 'Switzerland', 'England')

wc_r16 <- data.frame(cbind(team_1, team_2))

wc_r16 <- data.frame(sapply(wc_r16, function(x) as.factor(x)))

wc_r16h <- left_join(wc_r16, teams, by = c('team_1'= 'Team'))


wc_r16all <- left_join(wc_r16h, teams, by = c( 'team_2' = 'Team' ))

colnames(wc_r16all)[c(3:9)] <- c('AvgGS_T1','AvgGC_T1', 'GD_T1', 'Wins_T1', 'Losses_T1', 'AvgOdds_T1', 'Pressure_T1')
colnames(wc_r16all)[c(10:16)] <- c('AvgGS_T2','AvgGC_T2', 'GD_T2', 'Wins_T2', 'Losses_T2', 'AvgOdds_T2', 'Pressure_T2')


# Predicting results


predictions_rf16 <- predict(rf, wc_r16all, type = 'class')





wc_r16all$pred <- predictions_rf16




# Quarter Final Teams

# France, Uruguay, Spain, Croatia, Brazil, Belgium, Sweden, England 




# Predicting for Quarter Finals

team_1 <- c( 'Uruguay', 'Brazil', 'Spain', 'Sweden') 
team_2 <- c('France', 'Belgium', 'Croatia', 'England')

wc_qf <- data.frame(cbind(team_1, team_2))

wc_qf <- data.frame(sapply(wc_qf, function(x) as.factor(x)))

wc_qfh <- left_join(wc_qf, teams, by = c('team_1'= 'Team'))


wc_qfall <- left_join(wc_qfh, teams, by = c( 'team_2' = 'Team' ))

colnames(wc_qfall)[c(3:9)] <- c('AvgGS_T1','AvgGC_T1', 'GD_T1', 'Wins_T1', 'Losses_T1', 'AvgOdds_T1', 'Pressure_T1')
colnames(wc_qfall)[c(10:16)] <- c('AvgGS_T2','AvgGC_T2', 'GD_T2', 'Wins_T2', 'Losses_T2', 'AvgOdds_T2', 'Pressure_T2')


# Predicting results


predictions_qf <- predict(rf, wc_qfall, type = 'class')



wc_qfall$pred <- predictions_qf







# Semi-Final Teams

# Uruguay, Spain, Brazil, England 




# Predicting for Semi Finals

team_1 <- c( 'Uruguay', 'Spain') 
team_2 <- c( 'Brazil', 'England')

wc_sf <- data.frame(cbind(team_1, team_2))

wc_sf <- data.frame(sapply(wc_sf, function(x) as.factor(x)))

wc_sfh <- left_join(wc_sf, teams, by = c('team_1'= 'Team'))


wc_sfall <- left_join(wc_sfh, teams, by = c( 'team_2' = 'Team' ))

colnames(wc_sfall)[c(3:9)] <- c('AvgGS_T1','AvgGC_T1', 'GD_T1', 'Wins_T1', 'Losses_T1', 'AvgOdds_T1', 'Pressure_T1')
colnames(wc_sfall)[c(10:16)] <- c('AvgGS_T2','AvgGC_T2', 'GD_T2', 'Wins_T2', 'Losses_T2', 'AvgOdds_T2', 'Pressure_T2')


# Predicting results

predictions_sf <- predict(rf, wc_sfall, type = 'class')


wc_sfall$pred <- predictions_sf






# Semi Final Predictions

# Uruguay vs Brazil  ---- Uruguay Wins
#   Spain vs England ---- Spain wins

# Final ->  Uruguay vs Spain



# Predicting the Finals

team_1 <- c( 'Uruguay') 
team_2 <- c( 'Spain')

wc_f <- data.frame(cbind(team_1, team_2))


wc_fh <- left_join(wc_f, teams, by = c('team_1'= 'Team'))


wc_fall <- left_join(wc_fh, teams, by = c( 'team_2' = 'Team' ))

colnames(wc_fall)[c(3:9)] <- c('AvgGS_T1','AvgGC_T1', 'GD_T1', 'Wins_T1', 'Losses_T1', 'AvgOdds_T1', 'Pressure_T1')
colnames(wc_fall)[c(10:16)] <- c('AvgGS_T2','AvgGC_T2', 'GD_T2', 'Wins_T2', 'Losses_T2', 'AvgOdds_T2', 'Pressure_T2')



# Predicting result



predictions_f <- predict(rf, wc_fall, type = 'class')




wc_fall$pred <- predictions_f




# URUGUAY to win the World Cup
# -------


