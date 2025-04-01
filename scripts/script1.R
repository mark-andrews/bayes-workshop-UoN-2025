library(tidyverse)
library(priorexposure)

m <- 14 # number of deaths
n <- 712 # number of coronavirus 

bernoulli_likelihood(n = n, m = m)
bernoulli_likelihood(n = n, m = m) + xlim(0, 0.1)
bernoulli_likelihood(n = n, m = m) + scale_x_continuous(limits = c(0, 0.1), breaks = seq(0, 10)/100)

m_prime <- 1
n_prime <- 50

bernoulli_likelihood(n = n_prime, m = m_prime) + scale_x_continuous(limits = c(0, 0.1), breaks = seq(0, 10)/100)

# Plot some beta distributions --------------------------------------------

beta_plot(alpha = 2, beta = 10)
beta_plot(alpha = 1, beta = 5)
beta_plot(alpha = 10, beta = 5)
beta_plot(alpha = 20, beta = 10)
beta_plot(alpha = 10, beta = 10)
beta_plot(alpha = 20, beta = 20)
beta_plot(alpha = 2, beta = 2)
beta_plot(alpha = 1, beta = 1)
beta_plot(alpha = 0.5, beta = 0.5)

# if we choose a beta(1, 10) prior then
# the posterior is 
beta_plot(m + 1, n - m + 10) + xlim(0, 0.1)

bernoulli_posterior_plot(n = n, m = m, alpha = 1, beta = 10) + xlim(0.0, 0.1)

# but what if prior is uniform
bernoulli_posterior_plot(n = n, m = m, alpha = 1, beta = 1) + xlim(0.0, 0.1)

# how about beta(10, 10)
bernoulli_posterior_plot(n = n, m = m, alpha = 10, beta = 10) + xlim(0.0, 0.1)

# posterior summary
bernoulli_posterior_summary(n = n, m = m, alpha = 1, beta = 10)


S <- bernoulli_posterior_summary(n = n, m = m, alpha = 1, beta = 10)

# Approx 95% area under curve range
S$mean + c(-1, 1) * 2 * S$sd

# 95% HPD
get_beta_hpd(m + 10, n - m + 10)

# 95% quantile interval
c(qbeta(0.025, m + 10, n - m + 10),
  qbeta(0.975, m + 10, n - m + 10))



