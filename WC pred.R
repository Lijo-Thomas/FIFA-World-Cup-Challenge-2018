
#Loading  libraries

library(dplyr)
library(caret)
library(rpart)
library(tree)
library(e1071)
library(randomForest)


teams <- read.csv('My Data WC18.csv')
wc <- read.csv('data_WC_2018.csv')

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


# Logistic Regression
glm.fit <- glm(Result ~.,
               data = train[-c(1,2,3)],
               family = 'binomial')

glm.probs <- predict(glm.fit, test, type = "response")
predictions_lr <- ifelse(glm.probs < 0.07, '1', '0')

test_resultsc <- as.character(test$Result)
test_conf <- confusionMatrix(predictions_lr, test_resultsc, positive = '1')
test_conf

test$predlr <- predictions_lr


# Classification Tree


tree_1 <-  rpart(Result ~ ., data=train[-c(1,2,3)], method= "class")

plot(tree_1)

tree_1_pred <- predict(tree_1, test[-c(18,19)], type = "class")

tree_1_pred <- ifelse(tree_1_pred==1,"1","0")

confusionMatrix(tree_1_pred, test_resultsc, positive = "1")

test$preddt <- tree_1_pred


# SVM


svm <- svm(Result ~.,
           data = train[-c(1,2,3)])

predictions_svm <- predict(svm, test[-c(18,19,20)])

svm_pred <- ifelse(predictions_svm==1,"1","0")

confusionMatrix(svm_pred, test_resultsc, positive = "1")

test$predsvm <- svm_pred


# Random Forest 



rf <- randomForest(Result ~. , data = train[-c(1,2,3)])


predictions_rf <- predict(rf, test, type = 'class')


confusionMatrix(predictions_rf, test_resultsc, positive = "1")


test$predrf <- predictions_rf



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
predictions_rf16svm <- predict(svm, wc_r16all)




wc_r16all$pred <- predictions_rf16
wc_r16all$predsvm <- predictions_rf16svm




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
predictions_qfsvm <- predict(svm, wc_qfall)




wc_qfall$pred <- predictions_qf
wc_qfall$predsvm <- predictions_qfsvm






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
predictions_sfsvm <- predict(svm, wc_sfall)



wc_sfall$pred <- predictions_sf
wc_sfall$predsvm <- predictions_sfsvm





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
predictions_fsvm <- predict(svm, wc_fall)



wc_fall$pred <- predictions_f
wc_fall$predsvm <- predictions_fsvm



# URUGUAY to win the World Cup
# -------


