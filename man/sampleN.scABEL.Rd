\encoding{utf-8}
\name{sampleN.scABEL}
\alias{sampleN.scABEL}
\title{
Sample size estimation for BE decision via scaled (widened) BE acceptance limits
}
\description{
These functions performs the Sample size estimation via power calculations of the 
BE decision via scaled (widened) BE acceptance limits, based on simulations.
}
\usage{
sampleN.scABEL(alpha = 0.05, targetpower = 0.8, theta0, theta1, theta2, CV, 
               design = c("2x3x3", "2x2x4", "2x2x3"), regulator, nsims = 1e+05, 
               nstart, imax=100, print = TRUE, details = TRUE, setseed = TRUE)
}
\arguments{
  \item{alpha}{
Type I error probability. Per convention mostly set to 0.05.
}
  \item{targetpower}{
Power to achieve at least. Must be >0 and <1.\cr
Typical values are 0.8 or 0.9.
}
  \item{theta0}{
'True' or assumed bioequivalence ratio. \cr
Defaults to 0.90 according to the \emph{"Two Laszlos"} if not given explicitly.
}
  \item{theta1}{
Conventional lower ABE limit to be applied in the mixed procedure if 
CVsWR <= CVswitch.\cr
Also Lower limit for the point estimate constraint.\cr
Defaults to 0.8 if not given explicitly.
}
  \item{theta2}{
Conventional upper ABE limit to be applied in the mixed procedure if 
CVsWR <= CVswitch. Also upper limit for the point estimate constraint.\cr
Defaults to 1.25 if not given explicitly.
}
  \item{CV}{
Coefficient(s) of variation as ratio.\cr
If \code{length(CV) = 1} the same CV is assumed for Test and Reference.\cr
If \code{length(CV) = 2} the CV for Test must be given in CV[1] and for 
Reference in CV[2].
}
  \item{design}{
Design of the study to be planned.\cr
2x3x3 is the partial replicate design (TRR|RTR|RRT).\cr
2x2x3 is the 3-period replicate design (TRT|RTR).\cr
2x2x4 is the full replicate design with 2 sequences and 4 periods.\cr
Defaults to \code{design="2x3x3"}
}
  \item{regulator}{
Regulatory settings for the widening of the BE acceptance limits.\cr
May be given as character from the choices "EMA", "HC", "FDA" or as an object of
class 'regSet' (see \code{\link{reg_const}}).\cr
Defaults to \code{regulator="EMA"} if missing.\cr
This argument may be given also in lower case if given as character.\cr\cr
The former \code{regulator="ANVISA"} is no longer allowed. Use "EMA" since 
ANVISA now recommends the use of EMA regulatory settings. 
}
  \item{nsims}{
Number of simulations to be performed to obtain the (empirical) power.
The default value 100 000 = 1e+5 is usually sufficient. Consider to rise 
this value if theta0<=0.85 or >=1.25. But see the warning section.
}
  \item{nstart}{
Set this to a start for the sample size search if a previous run failed.\cr
After reworking the start n in version 1.1-05 seldom needed.
}
  \item{imax}{
Maximum number of steps in sample size search. Defaults to 100.
}
  \item{print}{
If TRUE (default) the function prints its results.
}
  \item{details}{
If set to \code{TRUE}, the default, the steps during sample size search are shown.
}
  \item{setseed}{
Simulations are dependent on the starting point of the (pseudo) random number 
generator. To avoid differences in power for different runs a \code{set.seed(123456)} 
is issued if \code{setseed=TRUE}, the default. 
}
}
\details{
The simulations are done via the distributional properties of the statistical
quantities necessary for deciding BE based on widened ABEL. For more details see
a description in the doc subdirectory of the package.\cr\cr
Function \code{sampleN.scABEL()} is based on power calculations via simulations 
using the distributional characteristics of the 'key' statistics obtained from 
the EMA recommended evaluation via ANOVA if \code{regulator="EMA"} or if the
regulator component \code{est_method} is set to "ANOVA" if regulator is an object 
of class 'regSet'.\cr
Otherwise the simulations are based on the distributional characteristis of the 
'key' statistics obtained from evaluation via intra-subject contrasts (ISC), 
as recommended by the FDA.\cr\cr
Function \code{sampleN.scABEL2()} is soleyly based on power calculations via 
simulation using the distributional characteristics of the 'key' statistics 
obtained from evaluation via ISC. This function is deprecated.
}
\value{
Returns a data.frame with the input settings and sample size results.\cr
The "Sample size" column contains the total sample size.\cr
The "nlast" column contains the last n value. May be useful for restarting.
}
\references{
\enc{Tóthfalusi}{Tothfalusi} L, \enc{Endrényi}{Endrenyi} L.\cr
\emph{Sample Sizes for Designing Bioequivalence Studies for Highly Variable Drugs}\cr
J Pharm Pharmaceut Sci. 2011;15(1):73--84. \href{http://ejournals.library.ualberta.ca/index.php/JPPS/article/download/11612/9489}{free download}
}
\author{
D. Labes
}
\note{
We are doing the sample size estimation only for balanced designs since the 
break down of the total subject number in case of unbalanced sequence groups
is not unique. Moreover the formulas used are only for balanced designs.\cr\cr
In case of \code{regulator="FDA"} the sample size is only approximate since
the BE decision method is not exactly what is expected by the FDA. But the \emph{"Two
Laszlos"} state that the scABEL method should be 'operational' equivalent to the
FDA method. Thus the sample size should be comparable.\cr
Consider in case of \code{regulator="FDA"} to use the function 
\code{sampleN.RSABE()}.\cr\cr
In case of \code{regulator="HC"} the underlying power is only approximative 
since the Health Canada recommends as evaluation method a mixed model approach. 
But this could only implemented via subject data simulations which were very 
time consuming.\cr\cr
The minimum sample size is n=6, even if the power is higher than the intended 
targetpower.
}

\section{Warning }{
The sample size estimation for very extreme theta0 (<0.83 or >1.21) may be very 
time consuming and will eventually also fail since the start values chosen are 
not really reasonable in that ranges. This is especially true in the range around 
CV = 0.3 and regulatory constant according to FDA.\cr
If you really need sample sizes in that range be prepared to restart the sample 
size estimation via the argument nstart.\cr
Since the dependence of power from n is very flat in the mentioned region you may 
also consider to adapt the number of simulations not to tap in the simulation 
error trap.\cr\cr
See also the Warning section of the function \code{power.scABEL()} concerning
the power value agreement to those obtained from simulations via subject data.\cr\cr
\code{sampleN.scABEL2()} is deprecated and will be removed in future. A corresponding
warning is thrown if this function is used.
}

\seealso{
\code{\link{power.scABEL}}, \code{\link{power.RSABE}}, \code{\link{sampleN.RSABE}},
\code{\link{reg_const}}
}
\examples{
# using all the defaults:
# partial replicate design, targetpower=80\%,
# true assumed ratio = 0.90, 1E+5 simulated studies
# ABE limits, PE constraint 0.8 - 1.25
# EMA regulatory settings
sampleN.scABEL(CV=0.3)
# should result in a sample size n=54, power=0.8159
#
# now with former (inofficial) ANVISA settings, CVswitch=40\%
# (now ANVISA uses the same settings as EMA)
reg <- reg_const("USER", r_const=0.76, CVswitch=0.4, CVcap=0.5)
reg$name <- "Old ANVISA"
sampleN.scABEL(CV=0.3, regulator=reg)
# should result in n=60, power=0.8101

# for the full replicate design, target power = 90\%
# true assumed ratio = 0.9, FDA regulatory settings
# sims based on evalaution via ISC
sampleN.scABEL(CV=0.4, targetpower=0.9, theta0=0.9, design="2x2x4", regulator="FDA")
# should result in a sample size n=32, power=0.9125
}
