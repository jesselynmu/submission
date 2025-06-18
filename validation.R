library(glmtoolbox)
library(ggplot2)
library(dplyr)

df <- read.csv("D:/Submission/train_data.csv")

model <- glm(default ~ ., data = df, family = binomial)

prob <- predict(model, type = "response")

hltest(model = model, y = df$default, yhat = prob, g = 10)

df_calib <- df %>%
  mutate(
    prob = predict(model, type = "response")
  )

# 2. Binning probabilitas ke dalam 10 grup (decile)
df_calib <- df_calib %>%
  mutate(bin = ntile(prob, 10)) %>%
  group_by(bin) %>%
  summarise(
    mean_prob = mean(prob),
    actual_rate = mean(default),
    n = n()
  )

# 3. Plot calibration curve
ggplot(df_calib, aes(x = mean_prob, y = actual_rate)) +
  geom_line(color = "steelblue") +
  geom_point(size = 2) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray") +
  labs(
    title = "Calibration Curve",
    x = "Predicted Probability",
    y = "Actual Default Rate"
  ) +
  theme_minimal()