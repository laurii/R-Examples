#' Lagged Differences with equal length
#' 
#' Often when creating lagged differences, it is awkward that the differences
#' vector is shorter than the original.  \code{ediff} pads with \code{NA}s to
#' make its output the same length as the input.
#' 
#' @seealso \code{\link{diff}} since 
#' \code{ediff} is a thin wrapper around \code{\link{diff}}.
#' 
#' @param x a numeric vector or a matrix containing the values to be differenced
#' @param lag an integer indicating which lag to use
#' @param differences an integer indicating the order of the difference
#' @param pad one of \code{"head"}, \code{"tail"}, or \code{"symmetric"}.  
#' indicating where the \code{NA} padding should be added to the result.
#' @param frontPad logical indicating whether padding is on the front (head) or 
#' back (tail) end. This exists for backward compatibility. New code should use
#' \code{pad} instaed.
#' @param \dots further arguments to be passed to or from methods
#' @examples
#' ediff(1:10)
#' ediff(1:10, 2)
#' ediff(1:10, 2, 2)
#' x <- cumsum(cumsum(1:10))
#' ediff(x, lag = 2)
#' ediff(x, differences = 2)
#' ediff(x, differences = 2, pad="symmetric")
#' ediff(.leap.seconds)
#' if (require(mosaicData)) {
#' Men <- subset(SwimRecords, sex=="M")
#' Men <- mutate(Men, change=ediff(time), interval=ediff(year))
#' head(Men) 
#' }
#' @export

ediff <- function(x, lag=1, differences=1, pad=c("head","tail","symmetric"), 
                  frontPad, ...) {
  pad <- match.arg(pad)
  res <- diff(x, lag=lag, difference=differences, ...)
  p1 <- max(ceiling(lag*differences / 2), ceiling(nrow(x) / 2))
  p2 <- max(floor(lag*differences / 2), floor(nrow(x) / 2))
  if (p1 != p2 && pad == "symmetric") {
    warning("padding not quite symmetric since lag * differences is odd")
  }
  
  if (is.matrix(res)) {
    pad1 <- matrix(NA,
                   nrow=p1,
                   ncol=ncol(res))
    pad1 <- matrix(NA,
                   nrow=p2,
                   ncol=ncol(res))
    FUN <- rbind
  } else {
    pad1 <- rep(NA, p1)
    pad2 <- rep(NA, p2)
    FUN <- c
  }
  res <- switch(pad,
         head = FUN(pad1, pad2, res),
         tail = FUN(res, pad1, pad2),
         symmetric = FUN(pad1, res, pad2)
  )
  res
}
  
