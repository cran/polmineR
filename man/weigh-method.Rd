% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/weigh.R
\docType{methods}
\name{weigh}
\alias{weigh}
\alias{weigh,TermDocumentMatrix-method}
\alias{weigh,DocumentTermMatrix-method}
\alias{weigh,count-method}
\alias{weigh,count_bundle-method}
\title{Apply Weight to Matrix}
\usage{
weigh(.Object, ...)

\S4method{weigh}{TermDocumentMatrix}(.Object, method = "tfidf")

\S4method{weigh}{DocumentTermMatrix}(.Object, method = "tfidf")

\S4method{weigh}{count}(.Object, with)

\S4method{weigh}{count_bundle}(.Object, with, progress = TRUE)
}
\arguments{
\item{.Object}{A \code{matrix}, or a \code{count}-object.}

\item{...}{further parameters}

\item{method}{The kind of weight to apply.}

\item{with}{A \code{data.table} used to weigh p-attributes. A column 'weight' with term weights is
required, and columns with the p-attributes of \code{.Object} for matching.}

\item{progress}{Logical, whether to show a progress bar.}
}
\description{
Apply Weight to Matrix
}
\examples{
\dontrun{
library(data.table)
if (require("zoo") && require("devtools")){

# Source in function 'get_sentiws' from a GitHub gist
gist_url <- path(
  "gist.githubusercontent.com",
  "PolMine",
  "70eeb095328070c18bd00ee087272adf",
  "raw",
  "c2eee2f48b11e6d893c19089b444f25b452d2adb",
  "sentiws.R"
 )
  
devtools::source_url(sprintf("https://\%s", gist_url))
SentiWS <- get_sentiws()

# Do the statistical word context analysis
use("GermaParl")
options("polmineR.left" = 10L)
options("polmineR.right" = 10L)
df <- context("GERMAPARL", query = "Islam", p_attribute = c("word", "pos")) \%>\%
  partition_bundle(node = FALSE) \%>\% 
  set_names(s_attributes(., s_attribute = "date")) \%>\%
  weigh(with = SentiWS) \%>\%
  summary()

# Aggregate by year
df[["year"]] <- as.Date(df[["name"]]) \%>\% format("\%Y-01-01")
df_year <- aggregate(df[,c("size", "positive_n", "negative_n")], list(df[["year"]]), sum)
colnames(df_year)[1] <- "year"

# Use shares instead of absolute counts 
df_year$negative_share <- df_year$negative_n / df_year$size
df_year$positive_share <- df_year$positive_n / df_year$size

# Turn it into zoo object, and plot it
Z <- zoo(
  x = df_year[, c("positive_share", "negative_share")],
  order.by = as.Date(df_year[,"year"])
)
plot(
  Z, ylab = "polarity", xlab = "year",
  main = "Word context of 'Islam': Share of positive/negative vocabulary",
  cex = 0.8,
  cex.main = 0.8
)

# Note that we can uses the kwic-method to check for the validity of our findings
words_positive <- SentiWS[weight > 0][["word"]]
words_negative <- SentiWS[weight < 0][["word"]]
kwic("GERMAPARL", query = "Islam", positivelist = c(words_positive, words_negative)) \%>\%
  highlight(lightgreen = words_positive, orange = words_negative) \%>\%
  tooltips(setNames(SentiWS[["word"]], SentiWS[["weight"]]))
  
}
}
}
