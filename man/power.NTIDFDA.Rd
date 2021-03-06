\encoding{utf-8}
\name{power.NTIDFDA}
\alias{power.NTIDFDA}
\title{
(Empirical) Power for BE decision via FDA method for NTIDs
}
\description{
This function performs the power calculation of the BE decision via 
the FDA method for narrow therapeutic index drugs (NTID's) by simulations.
The study design could be the full replicate design 2x2x4 with 4-periods or the
2x2x3 replicate design with sequences TRT|RTR.
}
\usage{
power.NTIDFDA(alpha = 0.05, theta1, theta2, theta0, CV, n, design=c("2x2x4", "2x2x3"), 
              nsims = 1e+05, details = FALSE, setseed = TRUE)
}
\arguments{
  \item{alpha}{
Type I error probability, significance level. Conventionally mostly set to 0.05.
}
  \item{theta1}{
Conventional lower ABE limit to be applied in the FDA procedure.\cr
Defaults to 0.8 if not given explicitly.
}
  \item{theta2}{
Conventional upper ABE limit to be applied in the FDA procedure.\cr
Defaults to 1.25 if not given explicitly.
}
  \item{theta0}{
'True' or assumed bioequivalence ratio. \cr
Attention! Defaults here to 0.975 if not given explicitly. The value was chosen 
nearer to 1 because the potency (contents) settings for NTID's are tightened 
by the FDA.
}
  \item{CV}{
Coefficient(s) of variation as ratio.\cr
If \code{length(CV) = 1} the same CV is assumed for Test and Reference.\cr
If \code{length(CV) = 2} the CV for Test must be given in CV[1] and for 
Reference in CV[2].
}
  \item{n}{
Number of subjects under study.\cr
May be given as vector. In that case it is assumed that n contains the number
of subjects per sequence groups.\cr
Attention! In case of the 2x2x3 (TRT|RTR) design the order of n's important 
if given as vector. n[1] is for sequence group 'TRT' and n[2] is for 
sequence group 'RTR'.\cr\cr 
If n is given as single number (total sample size) and this number is not 
divisible by the number of sequences of the design an unbalanced design is assumed.
A corresponding message is thrown showing the numbers of subjects in the sequence groups.
}
  \item{design}{
Design of the study to be planned.\cr
2x2x4 is the full replicate design with 2 sequences and 4 periods.\cr
2x2x3 is the 3-period replicate design with sequences TRT|RTR.\cr
Defaults to \code{design="2x2x4"}.
}
  \item{nsims}{
Number of simulations to be performed to obtain the empirical power.
Defaults to 100 000 = 1e+5.
}
  \item{details}{
If set to \code{TRUE} the computational time is shown as well as the components
for the BE decision.\cr
p(BE-ABE) is the simulated probability for the conventional ABE test.
p(BE-sABEc) is the probability that the 95\% CI of the ABE criterion is <0.\cr
p(BE-sratio) is the probability that the ratio of sWT/sWR is <= 2.5.\cr
}
  \item{setseed}{
Simulations are dependent on the starting point of the (pseudo) random number 
generator. To avoid differences in power for different runs a \code{set.seed(123456)} 
is issued if \code{setseed=TRUE}, the default. 
}
}
\details{
The linearized scaled ABE criterion is calculated according to the SAS code
given in the FDA Warfarin guidance. For deciding BE the study must pass 
that criterion, the conventional ABE test and additional the test that the 
ratio of sWT/sWR is <= 2.5.\cr\cr
The simulations are done via the distributional properties of the statistical
quantities necessary for deciding BE based on these method.\cr
Details can be found in a document "Implementation_scaledABE_sims" located in 
the doc subdirectory of the package.
}
\value{
Returns the value of the (empirical) power if argument \code{details=FALSE}.\cr\cr
Returns a named vector if argument \code{details=TRUE}.\cr
p(BE) is the power, p(BE-sABEc) is the power of the BE test via scaled ABE criterion alone,
p(BE-ABE) is the power of the conventional ABE test alone and p(BE-sratio)
is the power of the criterion 'ratio of sWT/sWR is <= 2.5' alone.
}
\references{
FDA \emph{Draft Guidance on Warfarin Sodium}\cr
Recommended Dec 2012. \href{www.fda.gov/downloads/Drugs/GuidanceComplianceRegulatoryInformation/Guidances/UCM201283.pdf}{download}

Yu LX et al.\cr
\emph{Novel bioequivalence approach for narrow therapeutic index drugs}\cr
Clin Pharmacol Ther. 2015;97(3):286--91. \doi{10.1002/cpt.28}

Jiang W et al.\cr
\emph{A Bioequivalence Approach for Generic Narrow Therapeutic Index Drugs: Evaluation of the Reference-Scaled Approach and Variability Comparison Criterion}\cr
AAPS J. 2015;17(4):891--901. \doi{10.1208/s12248-015-9753-5}

\enc{Endrényi}{Endrenyi} L, \enc{Tóthfalusi}{Tothfalusi} L.\cr
\emph{Determination of Bioequivalence for Drugs with Narrow Therapeutic Index: 
Reduction of the Regulatory Burden}\cr
J Pharm Pharm Sci. 2013;16(5):676--82. \href{https://ejournals.library.ualberta.ca/index.php/JPPS/article/viewFile/20900/15927}{free download}
}
\author{
D. Labes
}
\note{
The FDA method is described for the ABE limits 0.8 ... 1.25 only. Setting theta1,
theta2 to other values may not be reasonable and is not tested.\cr\cr
The results for the design "2x2x3" are to be considered as experimental since
at present not thorougly tested.
}
\seealso{
\code{\link{sampleN.NTIDFDA}}\cr
and \code{\link{power.HVNTID}}, \code{\link{sampleN.HVNTID}} for NTIDs with
high variability
}
\examples{
# using the all defaults:
# GMR=0.975, theta1=0.8, theta2=1.25, 100 000 sims
# and a CV of 0.1 (= 10\%) with 12 subjects, balanced
power.NTIDFDA(CV=0.1, n=12)
# should give a power of 0.62553
}

