# 04_regressions.R
# Reproduce the linear / multiple regression models reported in the paper
# (Figures 8-12). A tidy summary of every model is written to
# results/regression_summary.txt.

suppressMessages({
  library(dplyr)
  library(readr)
})

dir.create("results", showWarnings = FALSE, recursive = TRUE)

world      <- read_csv("data/processed/world_series.csv",     show_col_types = FALSE)
cross_2015 <- read_csv("data/processed/cross_country_2015.csv", show_col_types = FALSE)

sink("results/regression_summary.txt")

cat("Regression models reproducing the paper (global series)\n")
cat("=======================================================\n\n")

cat("## Fig 8 -- Temperature ~ global GDP per capita (1980-2019)\n")
d8 <- world %>% filter(year >= 1980, year <= 2019)
m8 <- lm(anomaly ~ gdp_per_capita, data = d8)
print(summary(m8))
cat("\n\n")

cat("## Fig 9 -- Temperature ~ global CO2 emissions\n")
d9 <- world %>% filter(!is.na(co2))
m9 <- lm(anomaly ~ co2, data = d9)
print(summary(m9))
cat("\n\n")

cat("## Fig 10 -- Temperature ~ GDP + CO2 (multiple regression)\n")
d10 <- world %>% filter(!is.na(co2), !is.na(gdp))
m10 <- lm(anomaly ~ gdp + co2, data = d10)
print(summary(m10))
cat("\nMulticollinearity note: GDP and CO2 are strongly correlated:\n")
cat("  Pearson r(GDP, CO2) =", round(cor(d10$gdp, d10$co2), 3), "\n\n\n")

cat("## Fig 11 -- global CO2 per capita ~ global GDP per capita (1990-2018)\n")
d11 <- world %>% filter(year >= 1990, year <= 2018,
                        !is.na(co2_per_capita), !is.na(gdp_per_capita))
m11 <- lm(co2_per_capita ~ gdp_per_capita, data = d11)
print(summary(m11))
cat("\n\n")

cat("## Fig 12 -- cross-country log(CO2 per capita) ~ log(GDP per capita), 2015\n")
m12 <- lm(log(co2_per_capita) ~ log(gdp_per_capita), data = cross_2015)
print(summary(m12))

sink()

message("regression summary written to results/regression_summary.txt")
