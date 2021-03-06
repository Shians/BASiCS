% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BASiCS_DenoisedRates.R
\name{BASiCS_DenoisedRates}
\alias{BASiCS_DenoisedRates}
\title{Calculates denoised expression rates}
\usage{
BASiCS_DenoisedRates(Data, Chain, Propensities = FALSE)
}
\arguments{
\item{Data}{an object of class \code{\linkS4class{SingleCellExperiment}}}

\item{Chain}{an object of class \code{\linkS4class{BASiCS_Chain}}}

\item{Propensities}{If \code{TRUE}, returns underlying 
expression propensitites \eqn{\rho_{ij}}. 
Otherwise, denoised rates \eqn{\mu_i \rho_{ij}} are returned.
Default: \code{Propensities = FALSE}.}
}
\value{
A matrix of denoised expression rates (biological genes only)
}
\description{
Calculates normalised and denoised expression rates, by 
removing the effect of technical variation.
}
\details{
See vignette
}
\examples{

Data <- makeExampleBASiCS_Data(WithSpikes = TRUE)
## The N and Burn parameters used here are optimised for speed
## and should not be used in regular use.
## For more useful parameters,
## see the vignette (\\code{browseVignettes("BASiCS")})
Chain <- BASiCS_MCMC(Data, N = 1000, Thin = 10, Burn = 500, 
                     Regression = FALSE, PrintProgress = FALSE)

DR <- BASiCS_DenoisedRates(Data, Chain)

}
\seealso{
\code{\linkS4class{BASiCS_Chain}}
}
\author{
Catalina A. Vallejos \email{cnvallej@uc.cl}

Nils Eling \email{eling@ebi.ac.uk}
}
