library(MASS)
library(class)
library(ISLR)
library(rpart)
library(rpart.plot)
library(randomForest)
library(tidyverse)


head(Default)
summary(Default)


ggplot(Default, aes(x = balance, y = income, colour = default)) +
  geom_point(alpha = 0.3) +
  facet_grid(cols = vars(student))


Default$student <- ifelse(Default$student == "Yes", 1, 0)


# I create a numeric vector of 8000 rows of random numbers from 1 to 10000 that is sample
# and therefore we create the train and test set.
rows  <- 1:10000
index <- sample(rows,8000)
default_train <- Default[index, ]
default_test  <- Default[-index, ]

#KNNknn_5_pred <- knn(train = default_train[,features],test = default_test[, features], default_train$default, k = 5)

features <- c("student", "balance", "income")
knn_5_pred <- knn(train = default_train[,features],test = default_test[, features], default_train$default, k = 5)
default_test$knn_5_pred <- knn_5_pred

ggplot(default_test, aes(x = balance, y = income, colour = default)) +
  geom_point(alpha = 1)

ggplot(default_test, aes(x = balance, y = income, colour = knn_5_pred)) +
  geom_point(alpha = 0.3)

knn_2_pred <- knn(train = default_train[,features],test = default_test[, features], default_train$default, k = 2)
default_test$knn_2_pred <- knn_2_pred

ggplot(default_test, aes(x = balance, y = income, colour = knn_2_pred)) +
  geom_point(alpha = 0.3)

# Confusion matrix
table(
  observed  = default_test$default, 
  predicted = knn_2_pred
)
# If classification were perfect, all cases would lie on the diagonal:
# true negatives and true positives, so about 1930 and 70.
# The off-diagonal cells, false positives and false negatives , would both be 0.

table(
  observed  = default_test$default, 
  predicted = knn_5_pred
)

lr_mod  <- glm(formula = default ~ student + balance + income,family = binomial,data = default_train)
summary(lr_mod)
prediction_train <- predict(object = lr_mod,newdata = default_train,type = "response")
prediction_test <- predict(object = lr_mod,newdata = default_test,type = "response")
default_train$prob <- prediction_train
ggplot(default_train, aes(x = default, y = prob)) + geom_boxplot()
default_test$prob <- prediction_test
ggplot(default_test, aes(x = default, y = prob)) + geom_boxplot()
coef(lr_mod)
exp(coef(lr_mod)["balance"])          # odds ratio per dollar
exp(coef(lr_mod)["balance"] * 100)
predcit <- predict(lr_mod, newdata = data.frame(student = 0, balance = 3000, income = 40000), type = "response")
balance_df <- data.frame(student = 0, balance = seq(0,3000,length.out = 500), income = mean(default_train$income))

balance_df$prob <- predict(lr_mod, newdata = balance_df, type = "response")
ggplot(balance_df, aes(x = balance, y = prob)) +geom_line()
lr_pred <- ifelse(default_test$prob > 0.5, "Yes", "No")
table(
  observed  = default_test$default, 
  predicted = lr_pred
)

tree_mod <- rpart(default ~ student + income + balance, data = default_train, method = "class")
tree_pred <- predict(tree_mod, newdata = default_test,type = "class")
rpart.plot(tree_mod)
table(
  observed  = default_test$default, 
  predicted = tree_pred
)
is.factor(default_train$default)
rf_mod <- randomForest(default ~ student + balance + income,data = default_train)
rf_mod
importance(rf_mod)

