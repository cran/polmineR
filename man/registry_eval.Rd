% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/registry.R
\name{registry_get_name}
\alias{registry_get_name}
\alias{registry_get_id}
\alias{registry_get_home}
\alias{registry_get_info}
\alias{registry_get_encoding}
\alias{registry_get_p_attributes}
\alias{registry_get_s_attributes}
\alias{registry_get_properties}
\title{Evaluate registry file.}
\usage{
registry_get_name(corpus, registry = Sys.getenv("CORPUS_REGISTRY"))

registry_get_id(corpus, registry = Sys.getenv("CORPUS_REGISTRY"))

registry_get_home(corpus, registry = Sys.getenv("CORPUS_REGISTRY"))

registry_get_info(corpus, registry = Sys.getenv("CORPUS_REGISTRY"))

registry_get_encoding(corpus, registry = Sys.getenv("CORPUS_REGISTRY"))

registry_get_p_attributes(corpus, registry = Sys.getenv("CORPUS_REGISTRY"))

registry_get_s_attributes(corpus, registry = Sys.getenv("CORPUS_REGISTRY"))

registry_get_properties(corpus, registry = Sys.getenv("CORPUS_REGISTRY"))
}
\arguments{
\item{corpus}{name of the CWB corpus}

\item{registry}{directory of the registry (defaults to CORPUS_Registry environment variable)}
}
\description{
Functions to extract information from a registry file describing a corpus.
Several operations could be accomplished with the 'cwb-regedit' tool, the
functions defined here ensure that manipulating the registry is possible
without a full installation of the CWB.
}
\details{
An appendix to the 'Corpus Encoding Tutorial'
(https://cwb.sourceforge.io/files/CWB_Encoding_Tutorial.pdf) includes an
explanation of the registry file format.

\code{registry_get_encoding} will parse the registry file for a
corpus and return the encoding that is defined (corpus property "charset").
If parsing the registry does not yield a result (corpus property "charset"
not defined), the CWB standard encoding ("latin1") is assigned to prevent
errors. Note that \code{RcppCWB::cl_charset_name} is equivalent but is
faster as it uses the internal C representation of a corpus rather than
parsing the registry file.
}
\keyword{internal}
