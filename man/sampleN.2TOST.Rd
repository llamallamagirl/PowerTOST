\encoding{utf-8}
\name{sampleN.2TOST}
\alias{sampleN.2TOST}
\title{
Sample size based on power of two TOSTs
}
\description{
Calculates the necessary sample size to have at least a given power when two
parameters are being tested simultaneously.
}
\usage{
sampleN.2TOST(alpha = c(0.05, 0.05), targetpower = 0.8, logscale = TRUE, 
              theta0, theta1, theta2, CV, rho, design = "2x2", setseed = TRUE,
              robust = FALSE, print = TRUE, details = FALSE, imax = 100,
              nsims = 1e+05)
}
\arguments{
  \item{alpha}{
  Vector; contains one-sided significance level for each of the two TOSTs.\cr
  For one TOST, by convention mostly set to 0.05.
  }
  \item{targetpower}{
Power to achieve at least. Must be >0 and <1.\cr
Typical values are 0.8 or 0.9.
  }
  \item{logscale}{
Should the data used on log-transformed (\verb{TRUE}) or on original
scale (\verb{FALSE})?\cr
Defaults to \verb{TRUE}.
  }
  \item{theta0}{
Vector; contains \sQuote{true} assumed bioequivalence ratio for each of the two TOSTs. \cr
In case of \code{logscale=TRUE} each element must be given as ratio,\cr
otherwise as difference to 1. See examples.\cr
Defaults to \code{c(0.95, 0.95)} if \code{logscale=TRUE} or to 
\code{c(0.05, 0.05)} if \code{logscale=FALSE}.
  }
  \item{theta1}{
Vector; contains lower bioequivalence limit for each of the two TOSTs.\cr
In case of \code{logscale=TRUE} it is given as ratio, otherwise as diff. to 1.\cr
Defaults to \code{c(0.8, 0.8)} if \code{logscale=TRUE} or to \code{c(-0.2, -0.2)}
if \code{logscale=FALSE}.
  }
  \item{theta2}{
Vector; contains upper bioequivalence limit for each of the two TOSTs.\cr
If not given \verb{theta2} will be calculated as \code{1/theta1} if \code{logscale=TRUE}\cr
or as \verb{-theta1} if \code{logscale=FALSE}.
  }
  \item{CV}{
Vector of coefficient of variations (given as as ratio, e.g. 0.2 for 20\%).\cr
In case of cross-over studies this is the within-subject CV, \cr
in case of a parallel-group design the CV of the total variability.\cr
In case of \code{logscale=FALSE} CV is assumed to be the respective standard 
deviation.
  }
  \item{rho}{
Correlation between the two PK metrics (\emph{e.g.}, AUC and Cmax) under consideration.
This is defined as correlation between the estimator of the treatment difference of
PK metric one and the estimator of the treatment difference of PK metric two.
}
  \item{design}{
Character string describing the study design.\cr
See \code{known.designs()} for designs covered in this package.
  }
  \item{setseed}{
Logical; if \verb{TRUE}, the default, a seed of 1234567 is set.
}
  \item{robust}{
Defaults to \verb{FALSE}. With that value the usual degrees of freedom will be used.\cr
Set to \verb{TRUE} will use the degrees of freedom according to the \sQuote{robust} evaluation
(aka Senn\enc{’}{'}s basic estimator). These df are calculated as \code{n-seq}.\cr
See \code{known.designs()$df2} for designs covered in this package.\cr
Has only effect for higher-order crossover designs.
  }
  \item{print}{
If \code{TRUE} (default) the function prints its results.\cr 
If \code{FALSE} only the result list will be returned. 
  }
  \item{details}{
If \code{TRUE} the design characteristics and the steps during
sample size calculations will be shown. \cr 
Defaults to \code{FALSE}.
  }
  \item{imax}{
Maximum number of steps in sample size search. \cr 
Defaults to 100.
  }
  \item{nsims}{
Number of studies to simulate. Defaults to 1E5.
  }
}
\details{
The sample size is calculated via iterative evaluation of power of the 2 TOSTs.\cr
Start value for the sample size search is taken from a large sample approximation
(1 TOST) according to Zhang, modified.\cr
The sample size is bound to 4 as minimum.
}
\value{
A list with the input and results will be returned.\cr
The element name \verb{"Sample size"} contains the total sample size.
}
\note{
If both \verb{theta0} are near the acceptance limits then the starting value may not
be a good approximation resulting in a lot of iteration steps; \verb{imax} may need
to be increased to obtain the required sample size.\cr\cr
}
\section{Warning}{
The function does not vectorize properly.\cr
If you need sample sizes with varying CVs f.i. use for-loops or the apply-family.
}
\references{
Phillips KF.\cr 
\emph{Power for Testing Multiple Instances of the Two One-Sided Tests Procedure}\cr
Int J Biostat. 2009;5(1):Article 15. \doi{10.2202/1557-4679.1169}

Hua SY, Xu S, D\enc{’}{'}Agostino RB Sr.\cr
\emph{Multiplicity adjustments in testing for bioequivalence}\cr
Stat Med. 2015;34(2):215--31. \doi{10.1002/sim.6247}

Lang B, Fleischer F.\cr
\emph{Letter to the Editor: Comments on \sQuote{Multiplicity adjustments in testing for bioequivalence}}\cr
Stat Med. 2016;35(14):2479--80. \doi{10.1002/sim.6488}

Zhang P.\cr
\emph{A Simple Formula for Sample Size Calculation in Equivalence Studies}\cr
J Biopharm Stat. 2003;13(3):529--538. \doi{10.1081/BIP-120022772}
}
\author{
Benjamin Lang & Detlew Labes
}
\seealso{
  \code{\link{power.2TOST}, \link{known.designs}}
}
\examples{
# Sample size for 2x2x2 cross-over design, intra-subject CV = 30\% and assumed
# ratios of 0.95 for both parameters, and correlation 0.9 between parameters
# (using all the other default values)
# Should give n=44 with power=0.80684
sampleN.2TOST(theta0 = rep(0.95, 2), CV = rep(0.3, 2), rho = 0.9)

# Sample size for a parallel group design,
# evaluation on the original (untransformed) scale
# BE limits 80 ... 120\% = -20\% ... +20\% of reference,
# assumed true BE ratio 0.95\% = -5\% to reference mean for both parameters,
# total CV=20\% for both parameters, and correlation 0.9 between parameters
# should give n=54 with power=0.8149
sampleN.2TOST(logscale=FALSE, theta0 = rep(-0.05, 2), CV = c(0.2, 0.2), 
              rho = 0.9, design = "parallel")
}
