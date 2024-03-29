#' @include partition.R S4classes.R
NULL

#' Get s-attributes.
#' 
#' Structural annotations (s-attributes) of a corpus capture metainformation for
#' regions of tokens. The `s_attributes()`-method offers high-level access to
#' the s-attributes present in a `corpus` or `subcorpus`, or the values of
#' s-attributes in a `corpus`/`partition`.
#' 
#' Importing XML into the Corpus Workbench (CWB) turns elements and element
#' attributes into so-called "s-attributes". There are two basic uses of the
#' `s_attributes()`-method: If the argument `s_attribute` is `NULL` (default),
#' the return value is a `character` vector with all s-attributes present in a
#' corpus.
#' 
#' If `s_attribute` denotes a specific s-attribute (a length-one character
#' vector), the values of the s-attributes available in the `corpus`/`partition`
#' are returned. if the s-attribute does not have values, `NA` is returned and a
#' warning message is issued.
#' 
#' If argument `unique` is `FALSE`, the full sequence of the s_attributes is
#' returned, which is a useful building block for decoding a corpus.
#' 
#' If argument `s_attributes` is a character providing several s-attributes, the
#' method will return a `data.table`. If `unique` is `TRUE`, all unique
#' combinations of the s-attributes will be reported by the `data.table`.
#' 
#' If the corpus is based on a nested XML structure, the order of items on the
#' `s_attribute` vector matters. The method for `corpus` objects will take the
#' first s-attribute as the benchmark and assume that further s-attributes are
#' XML ancestors of the node. 
#'
#' @param .Object A `corpus`, `subcorpus`, `partition` object, or a `call`. A
#'   corpus can also be specified by a length-one `character` vector.
#' @param s_attribute The name of a specific s-attribute.
#' @param unique A `logical` value, whether to return unique values.
#' @param regex A regular expression passed into `grep` to filter return value
#'   by applying a regex.
#' @param ... To maintain backward compatibility, if argument `sAttribute`
#'   (deprecated) is used. If `.Object` is a `remote_corpus` or
#'   `remote_subcorpus` object, the three dots (`...`) are used to pass
#'   arguments. Hence, it is necessary to state the names of all arguments to be
#'   passed explicity.
#' @return A character vector (s-attributes, or values of s-attributes).
#' @exportMethod s_attributes
#' @docType methods
#' @examples 
#' use("polmineR")
#' @rdname s_attributes-method
#' @name s_attributes
setGeneric("s_attributes", function(.Object, ...) standardGeneric("s_attributes"))


#' @rdname s_attributes-method
#' @aliases s_attributes,character-method
#' @examples 
#' 
#' s_attributes("GERMAPARLMINI")
#' s_attributes("GERMAPARLMINI", "date") # dates of plenary meetings
#' s_attributes("GERMAPARLMINI", s_attribute = c("date", "party"))  
setMethod("s_attributes", "character", function(.Object, s_attribute = NULL, unique = TRUE, regex = NULL, ...){
  if ("sAttribute" %in% names(list(...))){
    lifecycle::deprecate_warn(
      when = "0.8.7", 
      what = "s_attributes(sAttribute)",
      with = "s_attributes(s_attribute)"
    )
    s_attribute <- list(...)[["sAttribute"]]
  }
  s_attributes(.Object = corpus(.Object), s_attribute = s_attribute, unique = unique, regex = regex, ...)
})


#' @importFrom fs path
#' @importFrom cli cli_alert_warning
#' @rdname s_attributes-method
#' @examples
#' s_attributes(corpus("GERMAPARLMINI"))
setMethod("s_attributes", "corpus", function(.Object, s_attribute = NULL, unique = TRUE, regex = NULL, ...){
  
  if ("sAttribute" %in% names(list(...))){
    lifecycle::deprecate_warn(
      when = "0.8.7", 
      what = "s_attributes(sAttribute)",
      with = "s_attributes(s_attribute)"
    )
    s_attribute <- list(...)[["sAttribute"]]
  }
  
  if (is.null(s_attribute)){
    s_attrs <- corpus_s_attributes(
      corpus = .Object@corpus,
      registry = .Object@registry_dir
    )
    return(s_attrs)
  } else {
    if (length(s_attribute) == 1L){
      if (!s_attribute %in% s_attributes(.Object)){
        stop(
          sprintf(
            "The s-attribute '%s' is not defined for corpus '%s'.",
            s_attribute, .Object@corpus
          )
        )
      }
      avs_file <- path(.Object@data_dir, paste(s_attribute, "avs", sep = "."))
      if (!file.exists(avs_file)){
        cli_alert_warning(
          "s-attribute {.var {s_attribute}} does not have values, returning NA"
        )
        return(NA_character_)
      }
      avs_file_size <- file.info(avs_file)[["size"]]
      avs <- readBin(con = avs_file, what = character(), n = avs_file_size)
      Encoding(avs) <- .Object@encoding
      if (.Object@encoding != encoding())
        avs <- as.nativeEnc(avs, from = .Object@encoding)
      
      if (unique){
        return(avs)
      } else {
        avx_file <- fs::path(.Object@data_dir, paste(s_attribute, "avx", sep = "."))
        avx_file_size <- file.info(avx_file)[["size"]]

        avx <- readBin(
          avx_file, 
          what = integer(),
          size = 4L,
          n = avx_file_size / 4L,
          endian = "big"
        )
        avx_matrix <- matrix(avx, ncol = 2, byrow = TRUE)

        y <- avs[match(avx_matrix[, 2], unique(avx_matrix[, 2]))]
        
        if (!is.null(regex)) y <- grep(regex, y, value = TRUE)
        return(y)
      }
    } else if (length(s_attribute) > 1L){
      # This is a simple check whether s_attributes are nested: If attribute sizes
      # are identical, it is not nested.
      s_attr_sizes <- sapply(
        s_attribute,
        function(s_attr)
          cl_attribute_size(
            corpus = .Object@corpus, registry = .Object@registry_dir,
            attribute = s_attr, attribute_type = "s"
          )
      )
      if (length(unique(s_attr_sizes)) == 1L){
        y <- data.table(
          sapply(
            s_attribute,
            function(s_attr)
              s_attributes(.Object, s_attribute = s_attr, unique = FALSE))
        )
      } else {
        dt <- s_attribute_decode(
          corpus = .Object@corpus, s_attribute = s_attribute[1],
          data_dir = .Object@data_dir,
          encoding = .Object@encoding,
          method = "R" # this is usually the fastest option
        )
        setDT(dt)
        dt[, "struc" := 0L:(nrow(dt) - 1L)]
        setcolorder(dt, "struc")
        y <- s_attributes(
          dt,
          corpus = .Object@corpus, s_attribute = s_attribute[-1L]
        )
      }
      
      if (isTRUE(unique)) y <- unique(y)
      return( y )
    }
  }
})


#' @rdname s_attributes-method
#' @examples
#' p <- partition("GERMAPARLMINI", date = "2009-11-10")
#' s_attributes(p)
#' s_attributes(p, "speaker") # get names of speakers
setMethod(
  "s_attributes", "slice",
  function (.Object, s_attribute = NULL, unique = TRUE, ...) {
    if ("sAttribute" %in% names(list(...))){
      lifecycle::deprecate_warn(
        when = "0.8.7", 
        what = "s_attributes(sAttribute)",
        with = "s_attributes(s_attribute)"
      )
      s_attribute <- list(...)[["sAttribute"]]
    }
    if (is.null(s_attribute)){
      return(
        corpus_s_attributes(.Object@corpus, registry = .Object@registry_dir)
      )
    } else {
      if (length(s_attribute) == 1L){
        avs_file <- path(.Object@data_dir, paste(s_attribute, "avs", sep = "."))
        if (!file.exists(avs_file)){
          cli_alert_warning(
            "s-attribute {.var {s_attribute}} does not have values, returning NA"
          )
          return(NA_character_)
        }

        # Checking whether the xml is flat / whether s_attribute is in .Object@s_attribute_strucs 
        # is necessary because there are scenarios when these slots are not defined.
        xml_is_flat <- if (length(.Object@xml) > 0L){
          if (.Object@xml == "flat") TRUE else FALSE
        } else {
          FALSE
        }
        s_attr_strucs <- if (length(.Object@s_attribute_strucs) > 0L) if (.Object@s_attribute_strucs == s_attribute) TRUE else FALSE else FALSE
        if (xml_is_flat && s_attr_strucs){
          len1 <- cl_attribute_size(
            corpus = .Object@corpus, registry = .Object@registry_dir,
            attribute = .Object@s_attribute_strucs, attribute_type = "s"
          )
          len2 <- cl_attribute_size(
            corpus = .Object@corpus, registry = .Object@registry_dir,
            attribute = s_attribute, attribute_type = "s"
          )
          if (len1 != len2){
            stop(
              "XML is stated to be flat, but s_attribute_strucs hat length ", len1,
              " and s_attribute length ", len2
            )
          }
          retval <- cl_struc2str(
            corpus = .Object@corpus, registry = .Object@registry_dir,
            s_attribute = s_attribute, struc = .Object@strucs
          )
          if (unique) retval <- unique(retval)
        } else {
          cpos_vector <- ranges_to_cpos(.Object@cpos)
          strucs <- cl_cpos2struc(
            corpus = .Object@corpus, registry = .Object@registry_dir,
            s_attribute = s_attribute, cpos = cpos_vector
          )
          strucs <- unique(strucs)
          # filtering out negative struc values is necessary, because RcppCWB
          # will complain about negative values
          strucs <- strucs[which(strucs >= 0L)]
          retval <- cl_struc2str(
            corpus = .Object@corpus,  registry = .Object@registry_dir,
            s_attribute = s_attribute, struc = strucs
          )
          if (unique) retval <- unique(retval)
        }
        Encoding(retval) <- .Object@encoding
        retval <- as.nativeEnc(retval, from = .Object@encoding)
        Encoding(retval) <- encoding()
        return(retval)
      } else if (length(s_attribute) > 1L){
        tab_data <- sapply(
          s_attribute,
          USE.NAMES = TRUE,
          function(x){
            strucs <- if (.Object@xml == "nested"){
              cl_cpos2struc(
                corpus = .Object@corpus,
                registry = .Object@registry_dir,
                s_attribute = x,
                cpos = .Object@cpos[,1]
              )
            } else {
              .Object@strucs
            }
            str <- cl_struc2str(
              corpus = .Object@corpus, registry = .Object@registry_dir,
              s_attribute = x, struc = strucs
            )
            Encoding(str) <- .Object@encoding
            str <- as.nativeEnc(str, from = .Object@encoding)
            Encoding(str) <- encoding()
            str
          }
        )
        
        # Checking for the number of rows in the region matrix is necessary to avoid that 
        # the table is transposed if nrow(tab_data) == 1
        tab <- if (nrow(.Object@cpos) > 1L)
          data.table(tab_data)
        else
          data.table(matrix(tab_data, nrow = 1L))
        
        if (isTRUE(unique)) tab <- unique(tab)
        return( tab )
      }
    }
  }
)

#' @rdname s_attributes-method
setMethod("s_attributes", "partition", function (.Object, s_attribute = NULL, unique = TRUE, ...)
  callNextMethod()
)


#' @rdname s_attributes-method
setMethod("s_attributes", "subcorpus", function (.Object, s_attribute = NULL, unique = TRUE, ...)
  callNextMethod()
)

#' @rdname s_attributes-method
#' @details If `.Object` is a `context` object, the s-attribute value for the
#'   first corpus position of every match is returned in a character vector.
#'   If the match is outside a region of the s-attribute, `NA` is returned.
setMethod("s_attributes", "context", function (.Object, s_attribute = NULL){
  dt <- slot(.Object, "cpos")
  dt_min <- dt[dt[["position"]] == 0]
  setorderv(dt_min, cols = "cpos", order = 1L)
  cpos <- dt_min[, list(cpos = .SD[["cpos"]][1]), by = "match_id"][["cpos"]]
  strucs <- cl_cpos2struc(
    corpus = .Object@corpus,
    s_attribute = s_attribute,
    registry = .Object@registry_dir,
    cpos = cpos
  )
  s_attr <- cl_struc2str(
    corpus = .Object@corpus,
    s_attribute = s_attribute,
    struc = strucs
  )
  Encoding(s_attr) <- .Object@encoding
  as.nativeEnc(s_attr, from = .Object@encoding)
})




#' @docType methods
#' @rdname s_attributes-method
setMethod("s_attributes", "partition_bundle", function(.Object, s_attribute, unique = TRUE, ...){

  if ("sAttribute" %in% names(list(...))){
    lifecycle::deprecate_warn(
      when = "0.8.9", 
      what = "s_attributes(sAttribute)",
      with = "s_attributes(s_attribute)"
    )
    s_attribute <- list(...)[["sAttribute"]]
  }
  
  strucs <- lapply(.Object@objects, slot, "strucs")
  f <- unlist(
    mapply(
      rep,
      x = seq_along(strucs),
      times = sapply(strucs, length, USE.NAMES = FALSE)
    ),
    recursive = FALSE
  )
  values <- cl_struc2str(
    corpus = .Object@corpus,
    s_attribute = s_attribute,
    struc = unlist(strucs, recursive = TRUE),
    registry = .Object@registry_dir
  )
  Encoding(values) <- .Object@encoding
  values <- as.nativeEnc(values, from = .Object@encoding)
  retval <- split(x = values, f = f)
  if (unique) retval <- lapply(retval, unique)
  names(retval) <- names(.Object@objects)
  retval
})


#' @details If `.Object` is a `call` or a `quosure` (defined in the rlang
#'   package), the `s_attributes`-method will return a `character` vector with
#'   the s-attributes occurring in the call. This usage is relevant internally
#'   to implement the `subset` method to generate a `subcorpus` using
#'   non-standard evaluation. Usually it will not be relevant in an interactive
#'   session.
#' @rdname s_attributes-method
#' @param corpus A `corpus`-object or a length one character vector
#'   denoting a corpus.
#' @examples
#' 
#' # Get s-attributes occurring in a call
#' s_attributes(quote(grep("Merkel", speaker)), corpus = "GERMAPARLMINI")
#' s_attributes(quote(speaker == "Angela Merkel"), corpus = "GERMAPARLMINI")
#' s_attributes(quote(speaker != "Angela Merkel"), corpus = "GERMAPARLMINI")
#' s_attributes(
#'   quote(speaker == "Angela Merkel" & date == "2009-10-28"),
#'   corpus = "GERMAPARLMINI"
#' )
#' 
#' # Get s-attributes from quosure
#' s_attributes(
#'   rlang::new_quosure(quote(grep("Merkel", speaker))),
#'   corpus = "GERMAPARLMINI"
#' )
#' @importFrom RcppCWB corpus_s_attributes
setMethod("s_attributes", "call", function(.Object, corpus){
  s_attrs <- s_attributes(corpus)
  s_attrs <- if (is.character(corpus)){
    corpus_s_attributes(corpus = corpus, registry = corpus_registry_dir(corpus))
  } else {
    corpus_s_attributes(
      corpus = corpus@corpus,
      registry = corpus@registry_dir
    )
  }
  # for the following recursive function,
  # see http://adv-r.had.co.nz/Expressions.html
  get_s_attrs <- function(x){
    if (is.call(x)){
      y <- lapply(x, get_s_attrs)
    } else if (is.symbol(x)){
      char <- deparse(x)
      if (char %in% s_attrs){
        y <- char
      } else {
        if (!exists(char)){
          warning(
            sprintf(
              "expression includes undefined symbol that is not a s-attribute: %s",
              char
            )
          )
        }
        y <- NULL
      }
    } else {
      y <- NULL
    }
    unlist(y)
  }
  
  get_typeof <- function(x){
    if (is.call(x)){
      evaluated <- try(eval(x), silent = TRUE)
      if (is.vector(evaluated)){
        y <- unique(unlist(lapply(x, get_typeof)))
      } else {
        y <- lapply(x, get_typeof)
      }
    } else if (is.symbol(x)){
      y <- NULL
    } else {
      y <- typeof(x)
    }
    unlist(y)
  }
  
  s_attrs <- get_s_attrs(.Object)
  types <- get_typeof(.Object)
  
  if (length(s_attrs) != length(types)){
    cli_alert_info("Cannot map s-attributes and types")
    return(unique(s_attrs))
  }
  dt <- unique(data.table(s_attrs, types))
  setNames(dt[[1]], dt[[2]])
})


#' @rdname s_attributes-method
#' @importFrom rlang quo_get_expr
setMethod("s_attributes", "quosure", function(.Object, corpus){
  s_attributes(quo_get_expr(.Object), corpus = corpus)
})

#' @rdname s_attributes-method
setMethod("s_attributes", "name", function(.Object, corpus){
  s_attrs <- s_attributes(corpus)
  s <- deparse(.Object)
  if (!s %in% s_attrs){
    warning(sprintf("'%s' is not a s-attribute, returning NULL", s))
    return(NULL)
  }
  s
})


#' @rdname s_attributes-method
setMethod("s_attributes", "remote_corpus", function(.Object, ...){
  ocpu_exec(fn = "s_attributes", corpus = .Object@corpus, server = .Object@server, restricted = .Object@restricted, .Object = as(.Object, "corpus"), ...)
})


#' @rdname s_attributes-method
setMethod("s_attributes", "remote_partition", function(.Object, ...){
  ocpu_exec(fn = "s_attributes", corpus = .Object@corpus, server = .Object@server, restricted = .Object@restricted, .Object = as(.Object, "partition"), ...)
})


#' @param registry The registry directory with the registry file defining
#'   `corpus`. If missing, the registry directory that can be derived using
#'   `RcppCWB::corpus_registry_dir()` is used.
#' @rdname s_attributes-method
#' @importFrom RcppCWB corpus_data_dir cl_charset_name s_attribute_decode
setMethod("s_attributes", "data.table", function(.Object, corpus, s_attribute, registry){
  
  if (missing(registry)) registry <- corpus_registry_dir(corpus)
  data_dir <- corpus_data_dir(corpus = corpus, registry = registry)
  charset <- cl_charset_name(corpus = corpus, registry = registry)

  y <- copy(.Object)
  
  if ("cpos" %in% colnames(y)){
    col <- "cpos"
  } else if ("cpos_left" %in% colnames(y)){
    col <- "cpos_left"
  } else {
    stop("colnames 'cpos' or 'cpos_left' expected to be present")
  }
  
  for (s_attr in s_attribute){
    strucs <- cl_cpos2struc(
      corpus = corpus, s_attribute = s_attr,
      cpos = y[[col]], registry = registry
    )
    idx <- strucs + 1L
    
    values <- s_attribute_decode(
      corpus = corpus, data_dir = data_dir,
      s_attribute = s_attr, encoding = charset, method = "R"
    )[["value"]]
    
    y[, (s_attr) := values[idx]]
  }
  y
})
