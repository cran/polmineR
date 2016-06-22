## ----setup, include=FALSE---------------------------------
options(width=60)

## ----require, echo=TRUE, results="tex", out.width=60, tidy=FALSE----
if (
  require(rcqp, quietly = T)
  && require(polmineR.sampleCorpus, quietly = T)
  ){
  execute <- TRUE
} else {
  execute <- FALSE
}

## ----load, echo=TRUE, results="tex", out.width=60, tidy=FALSE----
if (execute){
  library(polmineR)
  library(polmineR.sampleCorpus)
  use("polmineR.sampleCorpus")
}

## ----setDrillingControls, echo=TRUE, results="tex"--------
if (execute){
  # to view all options defined for polmineR 
  options()[grep("polmineR", names(options()))]
  
  # setting options
  options("polmineR.corpus" = "PLPRBTTXT")
  options("polmineR.left" = 15)
  options("polmineR.right" = 15)
  options("polmineR.mc" = FALSE)
}

## ----partitionInit, echo=TRUE, results="tex", tidy=FALSE----
if (execute){
  bt <- partition("PLPRBTTXT", text_type="speech")
  cdu <- partition(
    "PLPRBTTXT",
    text_type="speech", text_party="CDU_CSU"
    )
}

## ----showPartition, echo=TRUE, results="tex", tidy=FALSE----
if (execute){
  cdu
}

## ----partitionMethod, echo=TRUE, results="tex", tidy=FALSE----
if (execute){
  coalition <- partition(
    "PLPRBTTXT",
    text_type="speech", text_party=c("CDU_CSU", "FDP")
    )
}

## ----cluster, echo=TRUE, results="tex", tidy=FALSE, eval=FALSE, message=FALSE----
#  if (execute){
#    base <- partition("PLPRBTTXT", text_type="speech")
#    parties <- partitionBundle(
#      base, def=list(text_party=NULL),
#      pAttribute="word", progress=TRUE, verbose=FALSE
#      )
#    tdm <- as.TermDocumentMatrix(parties, col="count")
#    class(tdm) # to see what it is
#    show(tdm)
#    m <- as.matrix(tdm) # turn it into an ordinary matrix
#    m[c("Integration", "Zuwanderung", "Migration"),]
#  }

## ----context, echo=TRUE, results="tex", tidy=FALSE--------
if (execute){
  integration <- context(
     bt, "Integration", pAttribute="word",
    left=20, right=20
  )
  summary(integration)
}

## ----distributionReal, echo=TRUE, results="tex", message=FALSE, eval=FALSE, tidy=FALSE----
#  if (execute){
#  
#    # one query / one dimension
#    oneQuery <- dispersion(
#      bt, query = '"Gerechtigkeit"',
#      "text_party", progress = F
#    )
#  
#    # # multiple queries / one dimension
#    twoQueries <- dispersion(
#      bt,
#      c('"[eE]uro.*"', '"Br.ssel"'),
#      "text_party", progress = F
#    )
#  
#    # multiple queries / two dimensions
#    twoDim <- dispersion(
#      bt, query = '"Regierung"',
#      c("text_date", "text_party"), progress = F
#    )
#  
#  }

## ----keyness, echo=TRUE, results="tex", message=FALSE, tidy=FALSE----
if (execute){
  coalition <- enrich(coalition, pAttribute="word")
  bt <- enrich(coalition, pAttribute="word")
  vocabulary <- compare(coalition, bt, included=TRUE)
}

