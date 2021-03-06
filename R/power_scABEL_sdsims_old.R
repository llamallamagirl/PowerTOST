# ----------------------------------------------------------------------------
# simulate replicate design subject data and evaluate via EMA ABEL method
# ANOVA & average BE with expanding limits
#
# Author D. Labes with suggestions by Ben
# This is the version trying to optimize more things
# using Ben's function to simulate multiple right-hand sides
# Trying to made more self-contained, df and C2 from a first, single lm() call
# design definition now alternatively via data.frame 'design_dta'
# a data.frame with columns subject, sequence, period and tmt and optional logval
# sequence and tmt in R/T notation
# ----------------------------------------------------------------------------
power.scABEL.sdsims.old <- function(alpha=0.05, theta1, theta2, theta0, CV, n,   
                                design=c("2x3x3", "2x2x4", "2x2x3"), 
                                design_dta=NULL, regulator,
                                nsims=1E5, details=FALSE, setseed=TRUE, progress)
{
  # check theta0 and ABE limits
  if (missing(theta0)) theta0 <- 0.90
  if (length(theta0)>1) {
    theta0 <- theta0[2]
    warning(paste0("theta0 has to be scalar. theta0 = ",
                   theta0, " used."), call. = FALSE)
  }
  if (missing(theta1) & missing(theta2)) theta1 <- 0.8
  if (missing(theta2)) theta2 <- 1/theta1
  if (missing(theta1)) theta1 <- 1/theta2
  
  # check regulator
  if (missing(regulator)) regulator <- "EMA"
  reg  <- reg_check(regulator)
  if (reg$est_method=="ISC") stop("ISC evaluation not allowed in this function.")
  # Check CV
  if (missing(CV)) stop("CV must be given!")
  # CV scalar or vector
  CVwT <- CV[1]
  if (length(CV)==2) CVwR <- CV[2] else CVwR <- CVwT
  # intra-subject variabilities from CV
  s2wT <- CV2mse(CVwT)
  s2wR <- CV2mse(CVwR)
  
  if (is.null(design_dta)){
    # check design
    desi <- match.arg(design)
    # degrees of freedom no longer set here
    # will be determined in the working horse via a first, single call of lm
    if(desi=="2x3x3"){
      bk    <- 1.5
      bkni  <- 1/6
      seqs  <- c("TRR", "RTR", "RRT")
    }
    if(desi=="2x2x3"){
      bk    <- 1.5
      bkni  <- 3/8
      seqs  <- c("TRT", "RTR")
    }
    if(desi=="2x2x4"){
      bk    <- 1
      bkni  <- 1/4
      seqs  <- c("TRTR", "RTRT")
    }
    seqn <- length(seqs)
    # check n
    if (missing(n))  stop("Number of subjects n must be given!")
    # check n: vector or scalar
    if (length(n)==1){
      # for unbalanced designs we divide the ns by ourself
      # to have 'smallest' imbalance
      nv <- nvec(n=n, grps=seqn)
      if (nv[1]!=nv[length(nv)]){
        message("Unbalanced design. n(i)=", paste(nv, collapse="/"), " assumed.")
      }
      C2 <- sum(1/nv)*bkni
      n <- sum(nv)
      design_dta <- prep_data2(seqs, nseq=nv, muR=log(10), ldiff=log(theta0), 
                               s2wT=s2wT, s2wR=s2wR)
    } else {
      # check length
      if (length(n)!=seqn) stop("n must be a vector of length=",seqn,"!")
      C2 <- sum(1/n)*bkni
      nv <- n
      n <- sum(n)
    }
  } else {
    # check data.frame design_dta 
    # TODO
    
    # delete NA in logval if logval is defined in data.frame
    if ("logval" %in% names(design_dta)){
      design_dta <- design_dta[!is.na(design_dta$logval),]
    }
    seqs <- unique(design_dta$sequence)
    seqn <- length(seqs)
    nv   <- as.numeric(table(unique(design_dta[,c("subject", "sequence")])[,"sequence"]))
    n    <- sum(nv)
    # C2 is calculated in the working horse
    # above for definition via design and n it is given to the working horse 
    # for comparative purposes only
    C2   <- NULL
  }
  # progressbar or not
  if(missing(progress)) {
    progress <- FALSE
    if(nsims>=5E5) progress <- TRUE
    if(nsims>=1E5 & n>72) progress <- TRUE
  }
  
  # after introducing multiple right-hand sides .lm.fit seems to have no longer
  # an advantage in run-time, fitmethod removed May 2018
  
  # call the working horse
  pwr <- .pwr.ABEL.sds.old(design_dta=design_dta, ldiff=log(theta0), 
                       s2WR=s2wR, s2WT=s2wT, C2=C2, nsims=nsims, regulator=reg, 
                       ln_lBEL=log(theta1), ln_uBEL=log(theta2), alpha=alpha, 
                       setseed=setseed, details=details, progress=progress)
  pwr
}
  

# working horse
.pwr.ABEL.sds.old <- function(muR=log(10), design_dta, ldiff, s2WR, s2WT, C2, nsims, 
                          regulator, ln_lBEL, ln_uBEL, alpha=0.05, setseed=TRUE, 
                          details=FALSE, progress=FALSE)
{
  # start time measurement
  ptm <- proc.time()
  
  CVcap     <- regulator$CVcap
  CVswitch  <- regulator$CVswitch
  r_const   <- regulator$r_const
  pe_constr <- regulator$pe_constr
  # paranoia
  if(is.null(pe_constr)) pe_constr <- TRUE
  
  if(progress) pb <- txtProgressBar( min = 0, max = 1, style = 3)

  if(setseed) set.seed(123456)
#  set.seed(146389) # seed for the scripts in directory /workspace/replicate_simul
  dta <- design_dta
    # make a first simulation of logval
  dta$logval <- sim_data2_y(data_tmt=dta$tmt, ldiff=ldiff, s2wT=s2WT, s2wR=s2WR)

  dta$tmt     <- as.factor(dta$tmt)
  dta$period  <- as.factor(dta$period)
  dta$subject <- as.factor(dta$subject)
  # change coding to 1=R, 2=T
  dta_tmt <- as.numeric(dta$tmt)
  # measurements under treatments, values to simulate
  nT <- length(dta_tmt[dta_tmt==2])
  nR <- length(dta_tmt[dta_tmt==1])

  oc <- options(contrasts=c("contr.treatment","contr.poly"))
  # save the model matrices for reuse in the simulation loop
  # the inclusion of sequence doesn't change the residual ms
  # model.matrix full
  mm <- model.matrix(~tmt+period+subject, data=dta)
  # model.matrix for R data only
  dtaR <- dta[dta$tmt=="R",]
  mmR   <- model.matrix(~period+subject, data=dtaR)
  
  if(is.finite(CVcap)) wABEL_cap <- r_const*CV2se(CVcap) else wABEL_cap <- Inf
  s2switch <- CV2mse(CVswitch)
  s2cap    <- CV2mse(CVcap)
  
  # make a first evaluation via lm.fit to obtain degrees of freedom
  model  <- lm(logval~tmt+period+subject, data=dta)
  df     <- model$df.residual
  
  # calculate C2 for the equation CI half width hw = tcrit*sqrt(C2*mse) 
  # may be different to argument C2 in case of missing data
  # in case of alpha=0 C21 becomes NaN (tcrit=Inf, hw1=Inf)
  # therefore we calculate C21 with alpha=0.05
  tcrit <- qt(1-0.05, df)
  hw1   <- as.numeric(confint(model, level=1-2*0.05)["tmtT", 2]-coef(model)["tmtT"])
  mse1  <- summary(model)$sigma^2
  C21   <- (hw1/tcrit)^2/mse1
  C2    <- C21
  # now the correct tcrit to be used
  tcrit <- qt(1-alpha, df)
  
  modelR <- lm.fit(x=mmR, y=dtaR$logval)
  dfRR   <- modelR$df.residual
  
  # allocate memory space for the results of the simulation loop
  pes   <- vector(mode="numeric", length=nsims)
  mses  <- vector(mode="numeric", length=nsims)
  s2wRs <- vector(mode="numeric", length=nsims)
  
  # yet another set.seed because the first sim is now done in prep_data2 above
  # and only with this set.seed we obtain the same value as in V1.4-4
  if(setseed) set.seed(123456)
  
  # working with multiple right-hand side logvals 
  # attention! the code breaks if no_rhs = 1. then the returns of .lm.fit
  # or qr.coef are no longer matrices
  no_rhs <- 500
  # at least nsims sims
  nsi <- ceiling(nsims/no_rhs)
  nsims <- nsi*no_rhs
  j1  <- 1
  j2  <- no_rhs
  # only ".lm.fit" and "qr" retained.
  # programming each fitmethod in own loop to avoid 1 Mio if's. but this give 
  # no notable difference in run-time
  # qr decomp saved for re-use
  qr_all <- qr(mm)
  qr_R   <- qr(mmR)
  for(j in 1:nsi){
    logval <- sim_mrhs(data_tmt=dta_tmt, nT=nT, nR=nR, ldiff=ldiff, 
                       s2wT=s2WT, s2wR=s2WR, no=no_rhs)
    logvalR <- logval[dta_tmt==1,]
      
  # Instead of qr.resid() we use faster approach via y - X * coefs
    coefs <- qr.coef(qr_all, logval)
    pes[j1:j2]  <- coefs["tmtT", ]
    mses[j1:j2] <- colSums((logval - mm %*% coefs)^2)/df
      
    s2wRs[j1:j2] <- colSums((qr.resid(qr_R, logvalR))^2)/dfRR
      
    # show progress
    if(progress){
      jsim <- j*no_rhs
      if(100*trunc(jsim/100)==jsim) setTxtProgressBar(pb, jsim/nsims)
    }  
    j1 <- j1+no_rhs
    j2 <- j2+no_rhs
  } 

  # reset options
  options(oc)
  # vectorized calculations of CI's and widened acceptance limits 
  # (moved outside of loops)
  hw <- tcrit*sqrt(C2*mses)
  loCL <- pes - hw
  upCL <- pes + hw
  # conventional ABE decision
  BE_ABE <- (loCL >=  ln_lBEL) & (upCL <= ln_uBEL)
  # widened acceptance limits
  wABEL  <- ifelse(s2wRs<=s2switch, ln_uBEL, r_const*sqrt(s2wRs))
  # cap on widening
  wABEL  <- ifelse(s2wRs>s2cap, wABEL_cap, wABEL)
  # scaled ABE (ABEL) decision
  BE_sc  <- (loCL >= -wABEL) & (upCL <= wABEL)
  # pe constraint
  BE_pe <- (pes >= ln_lBEL & pes <= ln_uBEL)
  if(pe_constr) BE <- BE_sc & BE_pe else BE <- BE_sc
  
  # done with the progressbar
  if(progress) close(pb)
  
  # same output as power.scABEL
  p <- vector("numeric", length=4)
  names(p) <- c("p(BE)", "p(BE-wABEL)", "p(BE-pe)", "p(BE-ABE)")
  p[1] <- sum(BE)/nsims
  p[2] <- sum(BE_sc)/nsims
  p[3] <- sum(BE_pe)/nsims
  p[4] <- sum(BE_ABE)/nsims
  
  if (details){
    ptm <- summary(proc.time()-ptm)
    tunit <- "sec"
    if(ptm["elapsed"]>60){
      ptm <- ptm/60; tunit <- "min"
    }
    message(nsims," sims. Time elapsed (",tunit,"): ", 
            formatC(ptm["elapsed"], digits=3), "\n")
    
    if (!pe_constr) p <- p[-3] # without pe constraint
    p
  } else {
    as.numeric(p["p(BE)"])
  }
}
