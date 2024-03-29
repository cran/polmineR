% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/S4classes.R
\docType{class}
\name{slice}
\alias{slice}
\alias{slice-class}
\alias{aggregate,slice-method}
\title{Virtual class slice.}
\usage{
\S4method{aggregate}{slice}(x)
}
\arguments{
\item{x}{An object of a class belonging to the virtual class \code{slice}, i.e. a
\code{partition} or \code{regions} object.}
}
\description{
The classes \code{subcorpus} and \code{partition} can be used to define
subcorpora. Unlike the \code{subcorpus} class, the \code{partition} class may
include statistical evaluations. The virtual class \code{slice} is a
mechanism to define methods for these classes without making \code{subcorpus}
the superclass of \code{partition}.
}
\details{
The method \code{aggregate} will deflate the matrix in the slot \code{cpos},
i.e. it checks for each new row in the matrix whether it increments the end
of the previous region (by 1), and ensure that the cpos matrix defines
disjoined regions.
}
\examples{
P <- new(
  "partition",
  cpos = matrix(data = c(1:10, 20:29), ncol = 2, byrow = TRUE),
  stat = data.table::data.table()
)
P2 <- aggregate(P)
P2@cpos
}
