library(polmineR)
use("polmineR")
use(pkg = "RcppCWB", corpus = "REUTERS")
testthat::context("get_type")

test_that(
  "get_type_specialized",
  {
    expect_equal(get_type("GERMAPARLMINI"), "plpr")
    expect_equal(get_type(partition("GERMAPARLMINI", date = "2009-10-28")), "plpr")
    expect_equal(get_type(partition_bundle("GERMAPARLMINI", s_attribute = "date")), "plpr")
    expect_equal(get_type(corpus("GERMAPARLMINI")), "plpr")
    expect_equal(get_type(subset("GERMAPARLMINI", date = "2009-11-11")), "plpr")
  }
)

test_that(
  "get_type_default",
  {
    expect_equal(is.null(get_type("REUTERS")), TRUE)
    expect_equal(is.null(get_type(partition("REUTERS", places = "kuwait"))), TRUE)
    expect_equal(is.null(get_type(partition_bundle("REUTERS", s_attribute = "places"))), TRUE)
    expect_equal(is.null(get_type(corpus("REUTERS"))), TRUE)
    expect_equal(
      is.null(corpus("REUTERS") %>% split(s_attribute = "id") %>% get_type()),
      TRUE
    )
  }
)
