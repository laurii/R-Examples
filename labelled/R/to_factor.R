#' Convert input to a factor.
#'
#' The base function \code{\link[base]{as.factor}} is not a generic, but this variant
#' is. By default, \code{to_factor} is a wrapper for \code{\link[base]{as.factor}}.
#' Please note that \code{to_factor} differs slightly from \code{\link[haven]{as_factor}}
#' method provided by \code{haven} package.
#'
#' @param x Object to coerce to a factor.
#' @param ... Other arguments passed down to method.
#' @export
to_factor <- function(x, ...) {
  UseMethod("to_factor")
}

#' @export
to_factor.factor <- function(x, ...) {
  x
}

#' @rdname to_factor
#' @export
to_factor.default <- function(x, ...) {
  as.factor(x)
}

#' @rdname to_factor
#' @param levels What should be used for the factor levels: the labels, the values or labels prefixed with values?
#' @param ordered \code{TRUE} for ordinal factors, \code{FALSE} (default) for nominal factors.
#' @param missing_to_na Should defined missing values be converted to `NA`?
#' @param nolabel_to_na Should values with no label be converted to `NA`?
#' @param sort_levels How the factor levels should be sorted? (see Details)
#' @param decreasing Sould levels be sorted in decreasing order?
#' @details
#'   If some values doesn't have a label, automatic labels will be created, except if
#'   \code{nolabel_to_na} is \code{TRUE}.
#'
#'   If \code{sort_levels == 'values'}, the levels will be sorted according to the values of \code{x}.
#'   If \code{sort_levels == 'labels'}, the levels will be sorted according to labels' names.
#'   If \code{sort_levels == 'none'}, the levels will be in the order the value labels are defined
#'   in \code{x}. If some labels are automatically created, they will be added at the end.
#'   If \code{sort_levels == 'auto'}, \code{sort_levels == 'none'} will be used, except if some
#'   values doesn't have a defined label. In such case,  \code{sort_levels == 'values'} will
#'   be applied.
#' @examples
#' v <- labelled(c(1,2,2,2,3,9,1,3,2,NA), c(yes = 1, no = 3, "don't know" = 9), c(FALSE, FALSE, TRUE))
#' to_factor(v)
#' to_factor(v, missing_to_na = FALSE, nolabel_to_na = TRUE)
#' to_factor(v, 'p')
#' to_factor(v, sort_levels = 'v')
#' to_factor(v, sort_levels = 'n')
#' to_factor(v, sort_levels = 'l')
#'
#' x <- labelled(c('H', 'M', 'H', 'L'), c(low = 'L', medium = 'M', high = 'H'))
#' to_factor(x, ordered = TRUE)
#' @export
to_factor.labelled <- function(x, levels = c("labels", "values",
  "prefixed"), ordered = FALSE, missing_to_na = FALSE, nolabel_to_na = FALSE,
  sort_levels = c("auto", "none", "labels", "values"), decreasing = FALSE,
  ...) {
  levels <- match.arg(levels)
  sort_levels <- match.arg(sort_levels)
  if (missing_to_na)
    x <- missing_to_na(x)
  if (nolabel_to_na)
    x <- nolabel_to_na(x)
  labels <- val_labels(x)
  allval <- unique(x)
  allval <- allval[!is.na(allval)]
  nolabel <- sort(allval[!allval %in% labels])
  # if there are some values with no label
  if (length(nolabel) > 0) {
    names(nolabel) <- nolabel
    levs <- c(labels, nolabel)
  } else {
    levs <- labels
  }

  if (sort_levels == "auto" & length(nolabel) > 0)
    sort_levels <- "values"
  if (sort_levels == "labels")
    levs <- levs[order(names(levs), decreasing = decreasing)] else if (sort_levels == "values")
    levs <- sort(levs, decreasing = decreasing)

  if (levels == "labels")
    labs <- names(levs) else if (levels == "values")
    labs <- unname(levs) else if (levels == "prefixed")
    labs <- paste0("[", levs, "] ", names(levs))
  levs <- unname(levs)
  factor(x, levels = levs, labels = labs, ordered = ordered,
    ...)
}
