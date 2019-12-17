## ---- eval = TRUE--------------------------------------------------------
library(polmineR)

## ---- eval = FALSE-------------------------------------------------------
#  gparl <- corpus("GERMAPARL", server = "52.24.44.232")

## ---- eval = FALSE-------------------------------------------------------
#  is(gparl)

## ---- eval = FALSE-------------------------------------------------------
#  size(gparl)

## ---- eval = FALSE-------------------------------------------------------
#  s_attributes(gparl)

## ---- eval = FALSE-------------------------------------------------------
#  gparl2006 <- subset(gparl, year == "2006")

## ---- eval = FALSE-------------------------------------------------------
#  is(gparl2006)

## ---- eval = FALSE-------------------------------------------------------
#  count(gparl, query = "Integration")

## ---- eval = FALSE-------------------------------------------------------
#  count(gparl2006, query = "Integration")

## ---- render = knit_print, message = FALSE, eval = FALSE-----------------
#  kwic(gparl, query = "Islam", left = 15, right = 15, meta = c("speaker", "party", "date"))

## ---- render = knit_print, message = FALSE, eval = FALSE-----------------
#  kwic(gparl2006, query = "Islam", left = 15, right = 15, meta = c("speaker", "party", "date"))

