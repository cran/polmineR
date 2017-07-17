% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as.VCorpus_method.R
\docType{methods}
\name{as.VCorpus,partitionBundle-method}
\alias{as.VCorpus,partitionBundle-method}
\title{Coerce partitionBundle to VCorpus.}
\usage{
\S4method{as.VCorpus}{partitionBundle}(x)
}
\arguments{
\item{x}{a partitionBundle object}
}
\description{
Coerce partitionBundle to VCorpus.
}
\examples{
\dontrun{
use("polmineR.sampleCorpus")
P <- partition("PLPRBTTXT", text_date = "2009-11-10")
PB <- partitionBundle(P, sAttribute = "text_speaker")
VC <- as.VCorpus(PB)
}
}