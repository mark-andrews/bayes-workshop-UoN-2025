#' Plot the likelihood function of a Bernoulli/binomial model
#'
#' @export
#' @param n Number of trials
#' @param m Number of successes
#' @return A ggplot object
#' @examples
#' bernoulli_likelihood(250, 135)
#' @import tibble
#' @import ggplot2
bernoulli_likelihood <- function(n, m){

  data_df <- tibble(x = seq(0, 1, length.out = 1000),
                    y = x^m * (1-x)^(n-m))

  data_df %>%
    ggplot(aes(x = x, y = y)) +
    geom_line() +
    labs(x = latex2exp::TeX("$\\theta$"),
         y = latex2exp::TeX("$L(\\theta | n, m)$")) +
    ggtitle(sprintf("%d successes in %d trials", m, n)) +
    theme_classic() +
    theme(axis.text.y = element_blank(),
          axis.ticks.y = element_blank())
}

#' Plot a Beta distribution
#'
#' @param alpha First shape parameter of the Beta distribution.
#' @param beta Second shape parameter of the Beta distribution.
#' @param show_hpd Show the HPD interval as a line segment.
#' @return A ggplot object.
#' @import tibble
#' @import ggplot2
#' @examples
#' beta_plot(2, 2)
#' beta_plot(10, 5)
#' @export
beta_plot <- function(alpha, beta, show_hpd = FALSE){

  data_df <- tibble(x = seq(0, 1, length.out = 1000),
                    y = dbeta(x, shape1 = alpha, beta))

  p <- data_df %>%
    ggplot(aes(x = x, y = y)) +
    geom_line() +
    labs(x = latex2exp::TeX("$\\theta$"),
         y = latex2exp::TeX("$P(\\theta)$")) +
    ggtitle(sprintf("Beta(%2.1f, %2.1f)", alpha, beta)) +
    theme_classic()

  if (show_hpd){
    hpd_interval <- get_beta_hpd(alpha, beta)
    p + geom_segment(aes(x = hpd_interval$lb,
                         xend = hpd_interval$ub,
                         y = hpd_interval$p_star,
                         yend = hpd_interval$p_star),
                     colour = 'red',
                     size = 0.5,
                     data = NULL)
  } else {
    p
  }

}

#' Plot the posterior distribution of a Bernoulli model with Beta prior
#'
#' @param n Number of trials
#' @param m Number of successes
#' @param alpha First shape parameters of the Beta prior
#' @param beta Second shape parameter of the Beta prior
#' @param show_hpd Show the HPD interval
#' @return A ggplot object
#' @examples
#' bernoulli_posterior_plot(250, 139, 5, 5)
#' bernoulli_posterior_plot(100, 60, 2, 2)
#' @export
bernoulli_posterior_plot <- function(n, m, alpha, beta, show_hpd = FALSE){
  beta_plot(m + alpha, n - m + beta, show_hpd = show_hpd)
}

#' The high posterior density interval of a Beta distribution.
#'
#' @param alpha First shape parameter of the Beta distribution.
#' @param beta Second shape parameter of the Beta distribution.
#' @return A list with lower and upper bound of the HPD interval, and minimum density.
#' @examples
#' get_beta_hpd(10, 5)
#' @export
get_beta_hpd <- function(alpha, beta){
  # This will break if either alpha < 1.0 or beta < 1.0
  # or alpha = beta = 1.0
  stopifnot(alpha >= 1.0, beta >= 1.0, !((alpha == 1) & (beta ==1)))

  interval_mass <- function(p_star){
    # Return the area under the curve for the
    # set of points whose density >= p_star.

    f <- function(val){
      d <- dbeta(val, alpha, beta)
      if (d >= p_star){
        return(d)
      }
      else {return(0)}
    }

    return(integrate(Vectorize(f), 0.0, 1.0)$value)

  }

  err_fn <- function(p_star, hpd_mass=0.95){
    (hpd_mass-interval_mass(p_star))^2
  }

  max_f <- dbeta((alpha-1)/(alpha+beta-2), alpha, beta)

  Q <- optimize(err_fn,
                interval = c(0, max_f)
  )

  precision <- 3
  p_star <- round(Q$minimum, precision)

  inside <- FALSE
  for (x in seq(0.0, 1.0, by=10^(-precision-1))) {
    if (round(dbeta(x, alpha, beta), precision) >= p_star) {
      if (inside){
        stop_interval <- x
      } else {
        start_interval <- x
        inside <- TRUE
      }
    } else
    {
      if (inside){
        inside <- FALSE
        interval <- c(start_interval, stop_interval)
      }
    }
  }

  list(lb = interval[1],
       ub = interval[2],
       p_star = p_star)

}

#' Summary statistics of a Beta distribution
#'
#' @param alpha First shape parameter of the Beta distribution
#' @param beta Second shape parameter of the Beta distribution
#' @param interval The probability mass in posterior quantile interval
#' @return A list with summary statistics of the Beta distribution
#' @examples
#' beta_summary(3, 5)
#' @export
beta_summary <- function(alpha, beta, interval = 0.95, hpd=FALSE){
  mean <- alpha/(alpha+beta)
  var <- (alpha*beta)/( (alpha+beta)^2 * (alpha + beta + 1))
  sd <- sqrt(var)
  mode <- (alpha - 1)/(alpha + beta - 2)
  
  lb <- (1-interval)/2
  ub <- interval + (1-interval)/2

  list(mean = mean,
       var = var,
       sd = sqrt(var),
       mode = mode,
       qi = c(qbeta(lb, alpha, beta),
              qbeta(ub, alpha, beta)))
}

#' Summary stats of posterior distribution of Bernoulli model with Beta prior
#'
#' @param n Number of trials
#' @param m Number of successes
#' @param alpha First shape parameter of the Beta prior
#' @param beta Second shape parameter of the Beta prior
#' @return A list with summary statistics of the posterior distribution
#' @examples
#' bernoulli_posterior_summary(150, 120)
#' @export
bernoulli_posterior_summary <- function(n, m, alpha=1, beta=1){
  beta_summary(m + alpha, n - m + beta)
}

#' Exact high posterior density interval of Bernoulli model with Beta prior
#'
#' @param n Number of trials
#' @param m Number of successes
#' @param alpha First shape parameter of the Beta prior
#' @param beta Second shape parameter of the Beta prior
#' @return A list with lower and upper bound of the HPD interval, and minimum density.
#' @examples
#' bernoulli_posterior_hpd(150, 120)
#' @export
bernoulli_posterior_hpd <- function(n, m, alpha=1, beta=1){
  get_beta_hpd(m + alpha, n - m + beta)
}
