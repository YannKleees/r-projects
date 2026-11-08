library(ISLR)
library(MASS)
library(tidyverse)

# Explicitly load the Boston dataset from the MASS package
data(Boston, package = "MASS")

# Run the regression model
lm_ses <- lm(medv ~ lstat, data = Boston)

print(coef(lm_ses))

summary <- summary(lm_ses)
print(summary)

y_pred <- predict(lm_ses)
print(y_pred)
plot(y_pred, Boston$medv, xlab = "Predicted medv", ylab = "True medv")
abline(0, 1, col = "red")
pred_dat <- data.frame(lstat = seq(0, 40, length.out = 1000))
y_pred_new <- predict(lm_ses,  pred_dat)
print(y_pred_new)

pred_dat$medv <- y_pred_new
y_pred_95 <- predict(lm_ses, pred_dat, interval = "confidence")
gg_pred <- data.frame(
  lstat = pred_dat$lstat,
  medv  = pred_dat$medv,
  lower = y_pred_95[, "lwr"],
  upper = y_pred_95[, "upr"]
)





p_scatter <- ggplot(Boston, aes(x = lstat, y = medv)) +
  geom_point()

# It is the fitted regression line, medv = 34.55 − 0.95 · lstat, evaluated at the 1000 lstat values in pred_dat.

p_line <- ggplot() + geom_ribbon(data = gg_pred, aes(x = lstat, ymin = lower, ymax = upper), fill = "steelblue", alpha = 0.3) + geom_line(data = pred_dat, aes(x = lstat, y = medv), colour = "steelblue") +
  geom_point(data = Boston, aes(x = lstat, y = medv), alpha = 0.5) +
  labs(x = "Proportion lower status (lstat)", y = "Median home value (medv)") +
  theme_minimal()
print(p_line)

# 14. The ribbon is the 95% confidence interval for the regression line.
# For each lstat value it shows the range in which the true mean medv is
# expected to lie with 95% confidence. It reflects uncertainty about the
# estimated line itself (intercept and slope), not about individual houses,
# so it is narrow where there is a lot of data (around the mean of lstat)
# and wider at the edges where the line is less certain.

y_pred_pi <- predict(lm_ses, pred_dat, interval = "prediction")

gg_pred_pi <- data.frame(
  lstat = pred_dat$lstat,
  medv  = pred_dat$medv,
  lower = y_pred_pi[, "lwr"],
  upper = y_pred_pi[, "upr"]
)

p_pi <- ggplot() +
  geom_ribbon(data = gg_pred_pi, aes(x = lstat, ymin = lower, ymax = upper),
              fill = "darkorange", alpha = 0.3) +
  geom_line(data = pred_dat, aes(x = lstat, y = medv), colour = "darkorange") +
  geom_point(data = Boston, aes(x = lstat, y = medv), alpha = 0.5) +
  labs(x = "Proportion lower status (lstat)", y = "Median home value (medv)") +
  theme_minimal()
print(p_pi)

# 15. The prediction interval is much wider than the confidence interval.
# It gives the range in which a single new observation is expected to fall
# with 95% probability, so it adds the residual variance of individual
# houses on top of the uncertainty about the fitted line.


mse <- function(y_true, y_pred) {
  mean((y_true-y_pred)^2)
}

print(mse(1:10, 10:1))
print(mse(Boston$medv, predict(lm_ses)))

splits <- c(rep("train", 253), rep("validation", 152), rep("test", 101))

set.seed(42)
boston_master <- mutate(Boston, split = sample(splits))

boston_train <- filter(boston_master, split == "train")
boston_valid <- filter(boston_master, split == "validation")
boston_test  <- filter(boston_master, split == "test")


model_1 <- lm(medv ~ lstat, data = boston_train)
print(summary(model_1))

model_1_mse_train <- mse(boston_train$medv, predict(model_1))
model_1_mse_valid <- mse(boston_valid$medv, predict(model_1, newdata = boston_valid))

model_2 <- lm(medv ~ lstat + age + tax, data = boston_train)
print(summary(model_2))

model_2_mse_train <- mse(boston_train$medv, predict(model_2))
model_2_mse_valid <- mse(boston_valid$medv, predict(model_2, newdata = boston_valid))

print(c(model_1_train = model_1_mse_train,
        model_1_valid = model_1_mse_valid,
        model_2_train = model_2_mse_train,
        model_2_valid = model_2_mse_valid))

model_2_mse_test <- mse(boston_test$medv, predict(model_2, newdata = boston_test))
print(model_2_mse_test)


# 26. Model 2 has a lower training MSE (35.1 vs 37.3) and a lower validation
# MSE (37.1 vs 38.1), so I choose model 2. The training MSE would drop anyway
# when adding predictors, so the validation MSE is the deciding number.

# 27. The test MSE of 44.0 is the estimate of the true out of sample error of
# model 2 on unseen data. It is higher than the validation MSE, which is
# expected: the validation set was used for model selection so its MSE is
# slightly optimistic, and with only 101 test rows the estimate is noisy.



cv_lm <- function(formula, dataset, k) {
  n <- nrow(dataset)
  folds <- sample(rep(1:k, length.out = n))
  outcome <- all.vars(formula)[1]
  mses <- numeric(k)
  
  for (i in 1:k) {
    train <- dataset[folds != i, ]
    valid <- dataset[folds == i, ]
    model <- lm(formula, data = train)
    mses[i] <- mse(valid[[outcome]], predict(model, newdata = valid))
  }
  
  mean(mses)
}

set.seed(42)
print(cv_lm(medv ~ lstat, Boston, 9))
print(cv_lm(medv ~ lstat + age + tax, Boston, 9))
