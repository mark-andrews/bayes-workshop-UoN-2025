library(tidyverse)
library(brms)

# to get data_df1 etc etc
source("https://raw.githubusercontent.com/mark-andrews/ibdar24/main/data/sim_data.R")


# Classical aka frequentist aka sampling theory normal linear model -------

M_1 <- lm(y ~ x_1 + x_2, data = data_df1)

summary(M_1)
confint(M_1)

# Bayesian version of the normal linear model -----------------------------


# Classical aka frequentist aka sampling theory normal linear model -------

M_2 <- brm(y ~ x_1 + x_2, data = data_df1)

# to get summary, do ...
summary(M_2)
# or ...
M_2

# compare lm coefficients with brms coefficient (linear coefs)
round(summary(M_1)$coefficients,2)

round(fixef(M_2), 2)
  
plot(M_2)  

mcmc_plot(M_2, type = 'hist')
mcmc_plot(M_2, type = 'hist', binwidth = 0.1)
mcmc_plot(M_2, type = 'hist', bins = 10)
mcmc_plot(M_2, type = 'hist', variable = 'b_Intercept', bins = 50)
mcmc_plot(M_2, type = 'intervals', variable = 'b_Intercept')
mcmc_plot(M_2, type = 'intervals', variable = 'b_x_.*', regex = TRUE)
mcmc_plot(M_2, type = 'areas', variable = 'b_x_.*', regex = TRUE)
mcmc_plot(M_2, type = 'areas', variable = 'b_x_.*', regex = TRUE, prob = 0.8)
mcmc_plot(M_2, type = 'areas', variable = 'b_x_.*', regex = TRUE, prob = 0.8)
mcmc_plot(M_2, type = 'violin', variable = 'b_x_.*', regex = TRUE)
mcmc_plot(M_2, type = 'intervals', variable = 'sigma')

# look at samples
head(prepare_predictions(M_2)$dpar$mu$fe$b, 20)

# show me the priors
prior_summary(M_2)

# sample from a normal distribution
quantile(rnorm(1e5), probs = c(0.025, 0.5, 0.975))

# high df standard t distribution
quantile(rt(1e5, df = 100), probs = c(0.025, 0.5, 0.975))

# low df standard t distribution
quantile(rt(1e5, df = 3), probs = c(0.025, 0.25, 0.5, 0.75, 0.975))
quantile(rt(1e5, df = 1), probs = c(0.025, 0.25, 0.5, 0.75, 0.975))

