\encoding{utf-8}
\name{power.RSABE2L.sdsims}
\alias{power.RSABE2L.sdsims}
\alias{power.RSABE2L.sds}
\title{
(Empirical) Power of BE Decision via Reference Scaled ABE
}
\description{
These function performs the power calculation of the BE decision via 
the reference scaled ABE based on \bold{subject data} simulations.
Implemented are the methods ABEL, Hyslop and \sQuote{exact} as described in the 
references.\cr
The estimation method of the key statistics needed to perform the \acronym{RSABE} decision 
is the usual \acronym{ANOVA}.
}
\usage{
power.RSABE2L.sdsims(alpha = 0.05, theta1, theta2, theta0, CV, n, 
                     design = c("2x3x3", "2x2x4", "2x2x3"), design_dta=NULL,
                     SABE_test="exact", regulator, nsims = 1e+05, 
                     details = FALSE, setseed = TRUE, progress)
}
\arguments{
  \item{alpha}{
Type I error probability, significance level. Conventionally mostly set to 0.05.
}
  \item{theta1}{
Conventional lower \acronym{ABE} (Average Bioequivalence) limit to be applied
in the mixed procedure if \code{CVsWR <= CVswitch}. Also lower limit for the point
estimate constraint.\cr
Defaults to 0.8 if not given explicitly.
}
  \item{theta2}{
Conventional upper \acronym{ABE} limit to be applied in the mixed procedure if 
\code{CVsWR <= CVswitch}. Also upper limit for the point estimate constraint.\cr
Defaults to 1.25 if not given explicitly.
}
  \item{theta0}{
\sQuote{True} or assumed bioequivalence ratio. \cr
Defaults to 0.90 according to the two Laszlos if not given explicitly.
}
  \item{CV}{
Coefficient(s) of variation as ratio.\cr
If \code{length(CV) = 1} the same CV is assumed for Test and Reference.\cr
If \code{length(CV) = 2} the CV for Test must be given in \verb{CV[1]} and for 
Reference in \verb{CV[2]}.
}
  \item{n}{
Number of subjects under study.\cr
May be given as vector. In that case it is assumed that n contains the number
of subjects in the sequence groups.\cr
If \verb{n} is given as single number (total sample size) and this number is not 
divisible by the number of sequences of the design an unbalanced design is 
assumed. A corresponding message is thrown (showing the numbers of subjects 
in sequence groups).\cr
Attention! In case of the \verb{"2x2x3"} (TRT|RTR) design the order of sample sizes
per sequence is important if given as vector. \verb{n[1]} is for sequence group
'TRT' and \verb{n[2]} is for sequence group 'RTR'. 
}
  \item{design}{
Design of the study to be planned.\cr
\verb{"2x3x3"} is the partial replicate design (TRR|RTR|RRT).\cr
\verb{"2x2x4"} is the full replicate design with 2 sequences and 4 periods (TRTR|RTRT).\cr
\verb{"2x2x3"} is the 3-period design with sequences TRT|RTR.\cr
Defaults to \verb{design="2x3x3"}.
}
  \item{design_dta}{
Alternatively to using the arguments \verb{design} and \verb{n} the design may 
be defined via a data.frame with columns \verb{subject, sequence, period} and
\verb{tmt}. This feature is experimental in the sense that the data.frame is
not checked for complying with the assumed structure.\cr
If you use the argument \verb{design_dta} you don\enc{’}{'}t need to specify the arguments
\verb{design} and \verb{n}.\cr
The default \code{design_dta=NULL} means that \verb{design} and \verb{n} are used
for the internal construction of the design data.frame.
}
  \item{SABE_test}{
This argument specifies the test method to be used for the reference scaled
\acronym{ABE} decision.\cr
Default is the \verb{"exact"} ncTOST method of the two Laszlos. Other choices are \verb{"ABEL"},
\verb{"hyslop"} and \verb{"fda"}. See Details.
}
  \item{regulator}{
Regulatory settings for the widening of the BE acceptance limits.\cr
May be given as character \verb{"EMA"} or as an object of
class 'regSet' (see \code{\link{reg_const}}).\cr
Defaults to \code{regulator="EMA"} if missing.\cr
This argument may be given also in lower case if given as character.\cr\cr
If given as object of class 'regSet' the component \code{est_method} can not be \verb{"ISC"}. 
}
  \item{nsims}{
Number of simulations to be performed to obtain the empirical power.
Defaults to 100,000 = 1e+05.\cr
If simulations are aimed for empirical alpha \code{nsims=1e+06} is recommended.
}
  \item{details}{
If set to \verb{TRUE} the computational time is shown as well as the components
for the BE decision.\cr
\verb{p(BE-RSABE)} is the probability of a positive outcome of the \acronym{SABE} test.\cr
\verb{p(BE-PE)} is the probability that the point estimate is within
\verb{theta1} ... \verb{theta2}.\cr
\verb{p(BE-ABE)} is the simulated probability for the conventional \acronym{ABE} test.
}
  \item{setseed}{
Simulations are dependent on the starting point of the (pseudo) random number 
generator. To avoid differences in power for different runs a \verb{set.seed()} 
is issued if \code{setseed=TRUE}, the default. 
}
  \item{progress}{
Should a progressbar be shown? Defaults to \verb{TRUE} if missing and \code{nsims >5e5}.
}
}
\details{
The methods rely on the analysis of log-transformed data, \emph{i.e.}, assumes a 
log-normal distribution on the original scale.\cr\cr
The data.frame with columns \verb{subject, sequence, period} and \verb{tmt} 
necessary for evalution of simulated subject data is constructed internally from 
the arguments \verb{design} and \verb{n} or may be given user defined via the argument 
\verb{design_dta}. The last option is usefull if missing data have to be considered
or if designs have to be evaluated which are not in the list of argument 
\verb{design}.\cr\cr
The estimation method for obtaining the statistics necessary to perform the
reference scaled ABE decision is the usual \acronym{ANOVA} with effects treatment, period,
sequence and subject within sequence for the evaluation of all data and period,
sequence and subject within sequence for the evaluation of the Reference formulation
data only.\cr\cr
The SABE tests implemented are:\cr
\tabular{ll}{
\verb{"exact"} \tab - 'exact' based method of the two Laszlos (see references, 
called there ncTOST)\cr
\verb{"ABEL"} \tab - Average bioequivalence with expanding limits\cr
\verb{"hyslop"} \tab - BE decision via the linearized RSABE criterion and its 
upper 95\% CI\cr
\verb{"fda"} \tab - Hyslop with an additional bias correction term as implemented 
in the \acronym{SAS} code of the \acronym{FDA} Guidance on Progesterone.
}
}
\value{
Returns the value of the (empirical) power if argument \code{details=FALSE}.\cr\cr
Returns a named vector if argument \code{details=TRUE}.\cr
\verb{p(BE)} is the power, \verb{p(BE-RSABE)} is the power of using the reference
scaled \acronym{ABE} alone, and \verb{p(BE-pe)} is the power of the criterion
'point estimat within acceptance range' alone. \verb{p(BE-ABE)} is the power of
the conventional \acronym{ABE} test given for comparative purposes.
}
\references{
FDA. \emph{Draft Guidance on Progesterone}\cr
Recommended Apr 2010. Revised Feb 2011. 
\href{http://www.fda.gov/downloads/Drugs/GuidanceComplianceRegulatoryInformation/Guidances/UCM209294.pdf}{download}

\enc{Tóthfalusi}{Tothfalusi} L, \enc{Endrényi}{Endrenyi} L.\cr
\emph{An Exact Procedure for the Evaluation of Reference-Scaled Average
Bioequivalence}\cr
AAPS J. 2016;18(2):476--89. \doi{10.1208/s12248-016-9873-6}.

\enc{Tóthfalusi}{Tothfalusi} L, \enc{Endrényi}{Endrenyi} L.\cr
\emph{Algorithms for evaluating reference scaled average bioequivalence: power, 
bias, and consumer risk}\cr
Stat Med. 2017;36(27):4378--4390. \doi{10.1002/sim.7440}
}
\author{
D. Labes
}
\note{
The function is relatively slow. The run-time for 1 Mio. simulations 
is between ~ 1 up to 6 minutes for n=12 or n=120 and 1 Mio. sim\enc{’}{'}s
(see the call under examples) on a machine with an Intel core i7 processor.\cr
Thus be patient and go for a cup of coffee if you use this function with higher 
sample sizes and aim for estimating the type 1 error!
}
\seealso{
\code{\link{power.RSABE}, \link{reg_const}}
}
\examples{
# Not run due to timing policy of CRAN
\dontrun{
# pure EMA settings without mixed procedure, cap on widening and PE constraint
# as in the reference from 2017
reg           <- reg_const("EMA")
reg$CVswitch  <- 0
reg$CVcap     <- Inf
reg$pe_constr <- FALSE
reg$name      <- "EMA pure"
power.RSABE2L.sds(CV=0.4, n=12, theta0=exp(0.05), design="2x2x4",
                  regulator=reg, nsims=50000)
# should give:
# [1] 0.46504 (compared to 47.1\% in the 2017 reference)}
}
