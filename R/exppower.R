#------------------------------------------------------------------------------
# Authors: dlabes, Benjamin Lang
#------------------------------------------------------------------------------

# Approximate "expected" power according to Julious book ----------------------
# taking into account the uncertainty of an estimated se with 
# dfse degrees of freedom
# Only for log-transformed data.
# Raw function: see the call in .exppower.TOST()
.approx.exppower.TOST <- function(alpha=0.05, ltheta1, ltheta2, diffm, sem, 
                                  dfse, df, pts = FALSE) 
{
  if (pts) {
    # Need to integrate dinvgamma() from 0 to Inf
    # cf. .exact.exppower.TOST with prior.type = "CV"
    # Result will be 1 since dinvgamma is a density
    return(1)
  }
  tval <- qt(1 - alpha, df, lower.tail = TRUE)
  d1   <- sqrt((diffm-ltheta1)^2/sem^2)
  d2   <- sqrt((diffm-ltheta2)^2/sem^2)
  # in case of diffm=ltheta1 or =ltheta2 and se=0
  # d1 or d2 have then value NaN (0/0)
  d1[is.nan(d1)] <- 0
  d2[is.nan(d2)] <- 0
  pow <- pt(d1, dfse, tval) + pt(d2, dfse, tval) - 1
  # approx. may have led to negative expected power
  pow[pow < 0] <- 0
  return(pow)
}


# Exact implementation of expected power --------------------------------------
# Author(s) B. Lang & D. Labes

.pts.exppower.TOST <- function(f, ltheta1, ltheta2, prior.type) {
  # For the PTS calculation we only want to integrate the density function
  if (prior.type == "CV") {
    # For prior.type = "CV" integrate over whole range 0 to Inf
    # We already know the result from this: it will always be one
    return(1)
  } else if (prior.type == "theta0") {
    # For PTS, need to integrate the density from ltheta1 to ltheta2
    # Will be handled via change of variables so that it will
    # be mapped to -1 to 1. Need several cases since ltheta1 and/or ltheta2
    # may be finite or infinite
    # References regarding change of variables: e.g.
    # - http://ab-initio.mit.edu/wiki/index.php/Cubature
    # - pracma::quadinf
    fun <- match.fun(f)
    f <- function(t) fun(t)
    u <- -1
    v <- 1
    if (is.finite(ltheta1) && is.finite(ltheta2)) {
      dg <- (ltheta2 - ltheta1) / (v - u)
      i_fun <- function(x) {
        f(ltheta1 + dg * (x - u)) * dg
      }
    } else if (is.finite(ltheta1) && is.infinite(ltheta2)) {
      i_fun <- function(x) {
        dg <- (v - u) / (1 - x)^2
        z <- (x - u) / (v - u)
        f(ltheta1 + z / (1 - z)) * dg
      }
    } else if (is.infinite(ltheta1) && is.finite(ltheta2)) {
      ltheta1 <- -ltheta2
      i_fun <- function(x) {
        dg <- (v - u) / (1 - x)^2
        z <- (x - u) / (v - u)
        f(-(ltheta1 + z / (1 - z))) * dg
      }
    } else if (is.infinite(ltheta1) && is.infinite(ltheta2)) {
      i_fun <- function(x)
        f(x / (1 - x^2)) * (1 + x^2)/(1 - x^2)^2
    } else {
      stop("Specified values for theta1 and theta2 cannot be handled.", 
           call. = FALSE)
    }
    pts <- integrate(i_fun, -1, 1, rel.tol = 1e-05, stop.on.error = FALSE)
    if (pts$message != "OK") 
      warning(pts$message)
    return(pts$value)
  } else if (prior.type == "both") {
    fun <- match.fun(f)
    f2 <- function(t, v) fun(t, v)
    u <- -1
    v <- 1
    if (is.finite(ltheta1) && is.finite(ltheta2)) {
      i_fun <- function(x) {
        g <- function(y) y / (1 - y)
        dg <- 1 / (1 - x[1])^2
        h <- function(y) ltheta1 + dh * (y - u)
        dh <- (ltheta2 - ltheta1) / (v - u)
        f2(h(x[2]), g(x[1])) * abs(dg * dh)
      }
    } else if (is.finite(ltheta1) && is.infinite(ltheta2)) {
      i_fun <- function(x) {
        g <- function(y) y / (1 - y)
        dg <- 1 / (1 - x[1])^2
        h <- function(y) {
          z <- (y - u) / (v - u)
          ltheta1 + z / (1 - z)
        }
        dh <- (v - u) / (1 - x[2])^2
        f2(h(x[2]), g(x[1])) * abs(dg * dh)
      }
    } else if (is.infinite(ltheta1) && is.finite(ltheta2)) {
      ltheta1 <- -ltheta2
      i_fun <- function(x) {
        g <- function(y) y / (1 - y)
        dg <- 1 / (1 - x[1])^2
        h <- function(y) {
          z <- (y - u) / (v - u)
          -(ltheta1 + z / (1 - z))
        }
        dh <- (v - u) / (1 - x[2])^2
        f2(h(x[2]), g(x[1])) * abs(dg * dh)
      }
    } else if (is.infinite(ltheta1) && is.infinite(ltheta2)) {
      i_fun <- function(x) {
        g <- function(y) y / (1 - y)
        h <- function(y) y / (1 - y^2)
        f2(h(x[2]), g(x[1])) * abs(1/(1 - x[1])^2 * (1 + x[2]^2)/(1 - x[2]^2)^2)
      }
    } else {
      stop("Specified values for theta1 and theta2 cannot be handled.", 
           call. = FALSE)
    }
    pts <- cubature::hcubature(i_fun, lowerLimit = c(0, -1), 
                               upperLimit = c(1, 1), tol = 1e-04)
    return(min(pts$integral, 1))  # handle numerical inaccuarcies
  } else {
    return(NA)
  }
}

.exact.exppower.TOST <- function(alpha=0.05, ltheta1, ltheta2, ldiff, se,
                                 sefac_n, df_n, df_m, sem_m, prior.type,
                                 pts = FALSE, cp_method = "exact") {
  # Infinite df_m should give expected power identical to conditional power   
  if (is.infinite(df_m) && !pts) {
    return(.calc.power(alpha, ltheta1, ltheta2, ldiff, sefac_n*se, df_n, 
                       cp_method))
  }
  if (prior.type == "CV") {
    # Define expected power integrand
    # For prior densitiy, see for example Bertsche et al or 
    # Held and Sabanes Bove Example 6.25
    # NB: prior density is the posterior distribution from the prior trial
    #
    # density
    d_t <- function(v) {
      dinvgamma(v, shape = df_m/2, scale = df_m/2 * se^2)
    }
    # conditional power
    p_t <- function(v) .calc.power(alpha, ltheta1, ltheta2, ldiff, 
                                   sefac_n*sqrt(v), df_n, cp_method)
    if (pts) {
      # Integrate only density d_t
      return(.pts.exppower.TOST(d_t, ltheta1, ltheta2, prior.type))
    } else {
      # Integrate p_t * d_t from 0 to Inf:
      # Numerical integration from 0 to Inf is likely to result in wrong result
      # because the function d_t (and thus p_t*d_t as well) will be zero over 
      # nearly all its range. To avoid numerical difficulties arising by this,
      # we perform a change of variables: map (0, Inf) to (0, 1),
      # see http://ab-initio.mit.edu/wiki/index.php/Cubature
      i_fun <- function(x) {
        p_t(x/(1 - x)) * d_t(x/(1 - x)) / (1 - x)^2
      }
      pwr <- integrate(i_fun, 0, 1, rel.tol = 1e-05, stop.on.error = FALSE)
      if (pwr$message != "OK")
        warning(pwr$message)
      return(pwr$value)
    }
  } else if (prior.type == "theta0") {
    # Define expected power integrand
    # Use conditional density of posteriori distribution, i.e.
    # theta0 | sigma^2=sigma^2_hat
    # See e.g. Held and Sabanes Bove (6.23) and Example 6.25
    # NB: We do not use the marginal distribution/density of theta0 (i.e. the
    # non-standardized t-distribution)
    
    # Define lambda parameter, follows from (6.28) & (6.30) Held + Bove
    lambda <- (se / sem_m)^2  # No missing data => lambda = 1 / sefac_m^2
    d_v <- function(t) {
      dnorm(t, mean = ldiff, sd = se / sqrt(lambda))
      #dt_ls(t, df_m, ldiff, sem_m)  # non-standardized t-distr.
    }
    p_v <- function(t) .calc.power(alpha, ltheta1, ltheta2, t, sefac_n*se, 
                                   df_n, cp_method)
    
    if (pts) {
      # Integrate only density d_v
      return(.pts.exppower.TOST(d_v, ltheta1, ltheta2, prior.type))
    } else {
      # Otherwise we have to integrate p_v * d_v from -Inf to Inf
      # Perform change of variables
      i_fun <- function(x)
        p_v(x / (1 - x^2)) * d_v(x / (1 - x^2)) * (1 + x^2)/(1 - x^2)^2
      pwr <- integrate(i_fun, -1, 1, rel.tol = 1e-05, stop.on.error = FALSE)
      if (pwr$message != "OK") 
        warning(pwr$message)
      return(pwr$value)
    }
  } else if (prior.type == "both") {
    # Define expected power integrand
    # Use 2-dimensional posterior density
    # See e.g. Held and Sabanes Bove Example 6.26 for density and parameters
    lambda <- (se / sem_m)^2
    d_ <- function(t, v)
      dninvgamma(t, v, mu = ldiff, lambda = lambda, alpha = df_m/2, 
                 beta = df_m/2 * se^2)
    p_ <- function(t, v)
      .calc.power(alpha, ltheta1, ltheta2, t, sefac_n*sqrt(v), df_n, cp_method) 
    
    if (pts) {
      return(.pts.exppower.TOST(d_, ltheta1, ltheta2, prior.type))
    } else {
      # Perform change of variables
      i_fun <- function(x) {
        g <- function(y) y / (1 - y)
        h <- function(y) y / (1 - y^2)
        d_(h(x[2]), g(x[1])) * p_(h(x[2]), g(x[1])) * 
          abs(1/(1 - x[1])^2 * (1 + x[2]^2)/(1 - x[2]^2)^2)
      }
      pwr <- cubature::hcubature(i_fun, lowerLimit = c(0, -1), 
                                 upperLimit = c(1, 1), tol = 1e-04)
      return(min(pwr$integral, 1))  # handle numerical inaccuarcies
    }
  } else {
    return(NA)
  }
}

# Working horse for exppower.TOST() and expsampleN.TOST() ---------------------
.exppower.TOST <- function(alpha=0.05, ltheta1, ltheta2, ldiff, se, sefac_n,
                           df_n, df_m, sem_m, method="exact", prior.type,
                           pts = FALSE, cp_method = "exact") {
  if (method == "approx" && prior.type == "CV") {
    return(.approx.exppower.TOST(alpha, ltheta1, ltheta2, ldiff, sefac_n*se,
                                 df_m, df_n, pts))
  }
  if (method == "approx" && prior.type != "CV")
    warning(paste0("Argument method = \"approx\" only affects caluclations ",
                   "if prior.type = \"CV\"."), call. = FALSE)
  return(.exact.exppower.TOST(alpha, ltheta1, ltheta2, ldiff, se, sefac_n, 
                              df_n, df_m, sem_m, prior.type, pts, cp_method))
}

# Main function for expected power --------------------------------------------
exppower.TOST <- function(alpha = 0.05, logscale = TRUE, theta0, theta1, theta2, 
                          CV, n, design = "2x2", robust = FALSE, 
                          prior.type = c("CV", "theta0", "both"),
                          prior.parm = list(),
                          method = c("exact", "approx")) {
  # Error handling
  stopifnot(is.numeric(alpha), alpha >= 0, alpha <= 1, is.logical(logscale),
            is.numeric(CV), CV > 0, is.numeric(n), is.character(design),
            is.logical(robust))
  if (length(CV) > 1) {
    CV <- CV[[1]]
    warning("CV has to be a scalar here. Only CV[1] used.", call. = FALSE)
  }
  
  # Data log-normal or normal?
  if (logscale) {
    if (missing(theta0)) theta0 <- 0.95
    if (theta0 <= 0) 
      stop("theta0 must be > 0.", call. = FALSE)
    if (missing(theta1)) theta1 <- 0.8 
    if (missing(theta2)) theta2 <- 1/theta1
    if (theta1 < 0 || theta1 > theta2) 
      stop("theta1 and/or theta2 not correctly specified.", call. = FALSE)
    ltheta1 <- log(theta1)
    ltheta2 <- log(theta2)
    ldiff <- log(theta0)
    se <- CV2se(CV)
  } else {
    if (missing(theta0)) theta0 <- 0.05
    if (missing(theta1)) theta1 <- -0.2 
    if (missing(theta2)) theta2 <- -theta1
    if (theta1 > theta2) 
      stop("theta1 and/or theta2 not correctly specified.", call. = FALSE)
    ltheta1 <- theta1
    ltheta2 <- theta2
    ldiff <- theta0
    se <- CV
  }
  
  # Check method and uncertainty type
  method <- tolower(method)
  method <- match.arg(method)
  prior.type <- match.arg(prior.type)
  # Derive df and prefactor of SEM for study to be conducted
  ds_n <- get_df_sefac(n = n, design = design, robust = robust)
  if (ds_n$df < 1)
    stop("n too low. Degrees of freedom <1!", call. = FALSE)
  
  # Check how prior.parm was specified
  names(prior.parm) <- tolower(names(prior.parm))  # also allow "sem"
  if (length(prior.parm$df) > 1 || length(prior.parm$sem) > 1)
    warning("df and SEM must be scalar, only first entry used.", call. = FALSE) 
  # Check if other components have been specified
  unpar_nms <- c("df", "sem", "m", "design")  # correct possibilities
  if (sum(no_nms <- !(names(prior.parm) %in% unpar_nms)) > 0)
    warning("Unknown names in prior.parm: ", 
            paste(names(prior.parm)[no_nms], collapse = ", "), 
            call. = FALSE)
  nms_match <- unpar_nms %in% names(prior.parm)  # check which parms are given
  # Based on information in nms_match derive degrees of freedom and 
  # standard error of prior trial
  df_m <- sem_m <- NA
  if (sum(nms_match[3:4]) == 2) {  # m and design given
    if (prior.parm$design == "parallel" && design != "parallel")
      stop(paste0("CV in case of parallel design is total variability. This ",
                  "cannot be used to plan a future trial with ",
                  "intra-individual comparison."), call. = FALSE)
    if (prior.parm$design != "parallel" && design == "parallel")
      warning(paste0("The meaning of a CV in an intra-individual design ",
                     "is not the same as in a parallel group design.", 
                     " The result may not be meaningful."), call. = FALSE)
    ds_m <- get_df_sefac(n = prior.parm$m, 
                         design = prior.parm$design, robust = robust)
    df_m <- ds_m$df
    sem_m <- ds_m$sefac * se[[1]]
  }
  if (prior.type == "CV") {
    if (nms_match[1]) {  # df given
      df_m <- prior.parm$df[[1]]  # possibly overwrite df_m
    }
    if (is.na(df_m))
      stop("df or combination m & design must be supplied to prior.parm!", 
           call. = FALSE)
  }
  if (prior.type == "theta0") {
    if (nms_match[2]) {  # SEM given
      sem_m <- prior.parm$sem[[1]]  # possibly overwrite sem_m
    }
    if (is.na(sem_m))
      stop("SEM or combination m & design must be supplied to prior.parm!", 
           call. = FALSE)
  }
  if (sum(nms_match[1:2]) == 2) {  # df and SEM given
    df_m <- prior.parm$df[[1]]  # possibly overwrite df_m
    sem_m <- prior.parm$sem[[1]]  # and sem_m
  }
  if (is.na(df_m) && is.na(sem_m))
    stop("Combination df & SEM or m & design must be supplied to prior.parm!", 
         call. = FALSE)
  
  # Check for meaningful input
  if (!is.na(df_m) && (!is.numeric(df_m) || df_m <= 4))
    stop("Degrees of freedom need to be numeric and > 4.", call. = FALSE)
  if (!is.na(sem_m) && (!is.numeric(sem_m) || sem_m < 0))
    stop("SEM needs to be numeric and >= 0.", call. = FALSE)
  if (prior.type == "both") {
    # Rough plausibility check for relationship between df and SEM
    semc <- sqrt(2 / (df_m + 2)) * CV2se(CV)
    if (sem_m > 0 && abs(semc - sem_m) / sem_m > 0.5)
      warning(paste0("Input values df and SEM do not appear to be consistent. ", 
                     "While the formal calculations may be correct, ", 
                     "the resulting power may not be meaningful."), 
              call. = FALSE)
  }
  
  # Call working horse
  .exppower.TOST(alpha = alpha, ltheta1 = ltheta1, ltheta2 = ltheta2, 
                 ldiff = ldiff, se = se, sefac_n = ds_n$sefac, df_n = ds_n$df, 
                 df_m = df_m, sem_m = sem_m, method = method, 
                 prior.type = prior.type, pts = FALSE, cp_method = "exact")
}
