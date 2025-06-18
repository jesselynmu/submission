library(glmtoolbox)

df <- read.csv("D:/Submission/train_data.csv")

model <- glm(default ~ ., data = df, family = binomial)

prob <- predict(model, type = "response")

hltest(model = model, y = df$default, yhat = prob, g = 10)