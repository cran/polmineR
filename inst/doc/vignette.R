## ---- eval = FALSE-------------------------------------------------------
#  Sys.getenv("CORPUS_REGISTRY")

## ---- message = FALSE----------------------------------------------------
library(polmineR)

## ---- message = FALSE----------------------------------------------------
use("polmineR")

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("europarl.en", repo = "http://polmine.sowi.uni-due.de/packages")
#  install.packages("GermaParl", repo = "http://polmine.sowi.uni-due.de/packages")

## ---- eval = TRUE, message = FALSE---------------------------------------
corpus()

## ---- eval = FALSE, message = FALSE, results = 'hide'--------------------
#  options()[grep("polmineR", names(options()))]

## ------------------------------------------------------------------------
options("polmineR.left" = 15)
options("polmineR.right" = 15)
options("polmineR.mc" = FALSE)

## ---- eval = TRUE--------------------------------------------------------
kwic("REUTERS", "oil")
kwic("REUTERS", "oil", meta = "places")
kwic("REUTERS", "oil", meta = c("id", "places"))

## ---- eval = TRUE--------------------------------------------------------
kwic("REUTERS", '"OPEC.*"')
kwic("REUTERS", '"oil" "price.*"')

## ---- eval = TRUE--------------------------------------------------------
count("REUTERS", "Kuwait")
count("REUTERS", c("Kuwait", "USA", "Bahrain"))
count("REUTERS", c('"United" "States"', '"Saudi" "Arabia.*"'), cqp = TRUE)

## ---- eval = TRUE, message = FALSE---------------------------------------
oil <- dispersion("REUTERS", query = "oil", sAttribute = "id", progress = FALSE)
saudi_arabia <- dispersion(
  "REUTERS", query = '"Saudi" "Arabia.*"',
  sAttribute = "id", cqp = TRUE, progress = FALSE
  )

## ---- eval = TRUE--------------------------------------------------------
barplot(height = saudi_arabia[["count"]], names.arg = saudi_arabia[["id"]], las = 2)

## ---- eval = TRUE, message = FALSE---------------------------------------
oil <- cooccurrences("REUTERS", query = "oil")
sa <- cooccurrences("REUTERS", query = '"Saudi" "Arabia.*"', left = 10, right = 10)
top5 <- subset(oil, rank_ll <= 5)
as.data.frame(top5)

## ---- eval = TRUE, message = FALSE, results = 'hide'---------------------
kuwait <- partition("REUTERS", places = "kuwait", regex = TRUE)

## ---- eval = TRUE--------------------------------------------------------
kuwait

## ---- eval = TRUE, message = FALSE---------------------------------------
saudi_arabia <- partition("REUTERS", places = "saudi-arabia", regex = TRUE)
sAttributes(saudi_arabia, "id")

## ---- eval = TRUE, message = FALSE---------------------------------------
saudi_arabia <- partition("REUTERS", places = "saudi-arabia", regex = TRUE)
oil <- cooccurrences(saudi_arabia, "oil", pAttribute = "word", left = 10, right = 10)

## ---- eval = TRUE--------------------------------------------------------
df <- as.data.frame(oil)
df[1:5, c("word", "ll", "rank_ll")]

## ---- eval = TRUE--------------------------------------------------------
q1 <- dispersion(saudi_arabia, query = 'oil', "id", progress = FALSE)
q2 <- dispersion(saudi_arabia, query = c("oil", "barrel"), "id", progress = FALSE)

## ---- eval = TRUE, message = FALSE---------------------------------------
qatar <- partition("REUTERS", places = "saudi-arabia", regex = TRUE)
qatar <- enrich(qatar, pAttribute = "word")

qatar_features <- features(qatar, "REUTERS", included = TRUE)
y <- subset(qatar_features, rank_chisquare <= 10.83 & count_coi >= 5)
as.data.frame(y)[,c("word", "count_coi", "count_ref", "chisquare")]

## ---- eval = TRUE--------------------------------------------------------
articles <- partitionBundle("REUTERS", sAttribute = "id", progress = FALSE)
articles <- enrich(articles, pAttribute = "word", verbose = FALSE)
tdm <- as.TermDocumentMatrix(articles, col = "count", verbose = FALSE)
class(tdm) # to see what it is
show(tdm)
m <- as.matrix(tdm) # turn it into an ordinary matrix
m[c("oil", "barrel"),]

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("RcppCWB")

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("polmineR")

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("devtools")
#  devtools::install_github("PolMine/polmineR", ref = "dev")

## ---- eval = FALSE-------------------------------------------------------
#  use("polmineR")
#  corpus()

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("RcppCWB")

## ---- eval = FALSE-------------------------------------------------------
#  library(polmineR)
#  corpus()

## ----mac_install_polmineR_cran, eval = FALSE-----------------------------
#  install.packages("polmineR")

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("devtools") # unless devtools is already installed
#  devtools::install_github("PolMine/polmineR", ref = "dev")

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("RcppCWB")
#  install.packages("polmineR")

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("devtools")
#  devtools::install_github("PolMine/polmineR", ref = "dev")

## ---- eval = FALSE-------------------------------------------------------
#  library(polmineR)
#  use("polmineR")

## ---- eval = FALSE-------------------------------------------------------
#  Sys.setenv(CORPUS_REGISTRY = "C:/PATH/TO/YOUR/REGISTRY")

## ---- eval = TRUE--------------------------------------------------------
class(polmineR:::CQI)

## ---- eval = FALSE-------------------------------------------------------
#  unlockBinding(env = getNamespace("polmineR"), sym = "CQI")
#  assign("CQI", CQI.rcqp$new(), envir = getNamespace("polmineR"))
#  lockBinding(env = getNamespace("polmineR"), sym = "CQI")

## ---- eval = FALSE-------------------------------------------------------
#  install.packages("rcqp")

## ---- eval = FALSE-------------------------------------------------------
#  unlockBinding(env = getNamespace("polmineR"), sym = "CQI")
#  assign("CQI", CQI.Rcpp$new(), envir = getNamespace("polmineR"))
#  lockBinding(env = getNamespace("polmineR"), sym = "CQI")

## ---- eval = FALSE-------------------------------------------------------
#  devtools::install_github("PolMine/polmineR.Rcpp")
#  install.packages(pkgs = c("rJava", "xlsx", "tidytext"))

## ---- eval = FALSE-------------------------------------------------------
#  Sys.setenv(CORPUS_REGISTRY = "/PATH/TO/YOUR/REGISTRY/DIRECTORY")

## ---- eval = FALSE-------------------------------------------------------
#  Sys.getenv("CORPUS_REGISTRY")

## ---- eval = FALSE-------------------------------------------------------
#  CORPUS_REGISTRY="/PATH/TO/YOUR/REGISTRY/DIRECTORY"

## ---- eval = FALSE-------------------------------------------------------
#  ?Startup

