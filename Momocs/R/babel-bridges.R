##### Simple bridges between R classes

# shp methods -------------
#' Converts a list of coordinates to a matrix of coordinates.
#'
#' Converts a \code{list} with x and y components to a two-columns
#' (colnamed) \code{matrix} of coordinates. Also, if l is a list with a single matrix, then l[[1]] is returned.
#'
#' @usage l2m(l)
#' @param l \code{list} with x and y coordinates as components.
#' @return \code{matrix} of (x; y) coordinates.
#' @seealso \link{m2l}.
#' @examples
#' data(wings)
#' l <- m2l(wings[1])
#' l
#' m <- l2m(l)
#' m
#' @family bridges functions
#' @export
l2m <- function(l) {
  if (length(l) == 1 && is.shp(l[[1]]))
    return(l[[1]])
    m <- cbind(l$x, l$y)
    colnames(m) <- c("x", "y")
    return(m)
}

#' Converts a list of coordinates to an array of coordinates
#'
#' l2a converts a list of \code{k} matrices with \code{m} rows
#' and \code{n} columns matrices to a \code{m x n x k} array.
#'
#' May be useful to communicate with other morphometrics packages that use
#' array of coordinates when handling configurations of landmarks.
#'
#' @usage l2a(l)
#' @param l \code{list} of matrices of the same dimension.
#' @return an array of coordinates.
#' @family bridges functions
#' @examples
#' data(wings)
#' l <- wings$coo
#' l
#' a <- l2a(l)
#' a
#' @family bridges functions
#' @export
l2a <- function(l) {
    .check(length(unique(sapply(l, length))) == 1,
           "matrices in list must have the same dimensions")
    nr <- nrow(l[[1]])
    nc <- 2
    ni <- length(l)
    a <- array(unlist(l), dim = c(nr, nc, ni), dimnames = list(1:nr,
        c("x", "y"), names(l)))
    return(a)
}

#' Converts an array of coordinates to a list of matrices
#'
#' Converts a \code{m x n x k} array of coordinates to a list of
#' \code{k} matrices with \code{m} rows and \code{n} columns matrices.
#'
#' May be useful to communicate with other morphometrics packages that use
#' array of coordinates when handling configurations of landmarks.
#'
#' @usage a2l(a)
#' @param a \code{array} of coordinates.
#' @return \code{list} with 2-cols matrices of (x; y) coordinates.
#' @examples
#' data(wings)
#' l <- wings$coo
#' l
#' a <- l2a(l)
#' a
#' @family bridges functions
#' @export
a2l <- function(a) {
    .check(is.array(a) & length(dim(a)==3),
          "An array of dimension 3 must be provided")
    k <- dim(a)[3]
    l <- list()
    for (i in 1:k) {
        l[[i]] <- a[, , i]
    }
    return(l)
}

#' Converts an array of coordinates to a matrix
#'
#' All the individuals (the 3rd dimension of the array) becomes rows, and
#' columns are (all the) x coordinates and (all the) y coordinates, so that we have
#' x1, x2, ..., xn, y1, y2, ..., yn columns. Rows and colums are named anyway.
#'
#' Used in landmarks methods, e.g. for multivariate analysis after a Procrustes alignment.
#'
#' @param a \code{array} of (x; y) coordinates.
#' @return matrix (see above).
#' @seealso \link{m2a} the reverse function.
#' @examples
#' data(wings)
#' a <- l2a(wings$coo)
#' a
#' @family bridges functions
#' @export
a2m <- function(a) {
    # ugly
    m <- sapply(a, as.numeric)
    nc <- dim(a)[1]
    m <- matrix(m, nrow = dim(a)[3], ncol = nc * 2, byrow = TRUE)
    colnames(m) <- paste0(rep(c("x", "y"), each = nc), 1:nc)
    if (!is.null(dimnames(a))) {
        rownames(m) <- dimnames(a)[[3]]
    }
    return(m)
}

#' Converts a matrix of coordinates to an array of coordinates
#'
#' Converts a matrix arranged with the individuals (the 3rd dimension of the array) as rows,
#' and (all) x coordinates and (all) y coordinates as columns, into an array built as follows:
#' nb.of.landmarks x 2 (x; y) x nb.of.individuals.
#'
#' Used in landmarks methods.
#'
#' @param m a matrix (see above).
#' @return an array (see above).
#' @seealso \link{a2m} the reverse function.
#' @examples
#' data(wings)
#' m <- a2m(l2a(wings$coo))
#' m2a(m)
#' @family bridges functions
#' @export
m2a <- function(m) {
    # ugly
    a <- array(NA,
               dim = c(ncol(m)/2, 2, nrow(m)),
               dimnames = list(1:(ncol(m)/2), c("x", "y"), rownames(m)))
    for (i in 1:nrow(m)) {
        a[, , i] <- matrix(m[i, ], ncol = 2)
    }
    return(a)
}

#' Converts a matrix of coordinates to a data.frame
#'
#' Converts a \code{m x 2} matrix of coordinates named data.frame.
#'
#' @param m a matrix (see above).
#' @return a data.frame (see above).
#' @seealso \link{m2d} the reverse function.
#' @examples
#' data(wings)
#' m2d(wings[3])
#' @family bridges functions
#' @export
m2d <- function(m){
  m <- coo_check(m)
  df <- data.frame(x=m[, 1], y=m[, 2])
  df
}

#' Converts a matrix of coordinates to a list of coordinates.
#'
#' Converts a matrix of (x; y) coordinates to a list with
#' x and y components.
#'
#' @usage m2l(m)
#' @param m a two-columns \code{matrix} of x and y coordinates.
#' @return a \code{list} with x and y components.
#' @seealso \link{l2m}.
#' @examples
#' data(wings)
#' l <- m2l(wings[1])
#' l
#' m <- l2m(l)
#' m
#' @family bridges functions
#' @export
m2l <- function(m) {
  return(list(x = m[, 1], y = m[, 2]))
}

#' Converts a matrix of coordinates into a list of matrices
#'
#' Used internally to hanle coo and cur in \code{Ldk} objects but may be
#' useful elsewhere
#' @param m \code{matrix}, typically of (x; y) coordinates
#' @param index \code{numeric}, the number of coordinates for every slice.
#' @examples
#' m2ll(wings[1], c(6, 4, 3, 5))
#' @family bridges functions
#' @export
m2ll <- function(m, index=NULL){
  # no slicing case, we return a matrix
  if (is.null(index))
    return(m)
  # slicing case, we slices
  .check(sum(index)==nrow(m),
         "nrow(m) and sum(index) must match")
  start <- cumsum(c(1, index[-length(index)]))
  end   <- cumsum(index)
  ll <- vector("list", length(start))
  for (i in seq_along(start)){
    ll[[i]] <- m[start[i]:end[i], ]
  }
  return(ll)
}

# as_df methods ------------------

#' Converts Momocs objects to data.frames
#'
#' Used in particular for ggplot2 compatibility.
#' @param x an object, typically a Momocs class
#' @return a data.frame
#' @examples
#' data(bot)
#' head(as_df(bot))
#' bot.f <- efourier(bot, 10)
#' head(as_df(bot.f))
#' bot.p <- PCA(bot.f)
#' head(as_df(bot.p))
#' bot.l <- LDA(bot.p, "type")
#' head(as_df(bot.l))
#' @family bridges functions
#' @export
as_df <- function(x){
  UseMethod("as_df")
}

#' @export
as_df.Coo <- function(x){
  df_coo <- ldply(x$coo, data.frame)
  colnames(df_coo) <- c("id", "x", "y")
  # if a $fac is present
  if (is.fac(x)) {
    df_fac <- as_data_frame(x$fac)
    n <- group_by(df_coo, id) %>% summarize(n = n())
    i <- 1:nrow(df_fac)
    i_n <- rep(i, times=n$n)
    df_coo <- bind_cols(df_coo, df_fac[i_n, ])
  }
  df_coo
}

#' @export
as_df.Coe <- function(x){
  df_coe <- melt(x$coe)
  colnames(df_coe) <- c("id", "coefficient", "value")
  # if a $fac is present
  if (is.fac(x)) {
    df_fac <- as_data_frame(x$fac)
    n <- group_by(df_coe, id) %>% summarize(n = n())
    i <- 1:nrow(df_fac)
    i_n <- rep(i, times=n$n)
    df_coe <- bind_cols(df_coe, df_fac[i_n, ])
  }
  df_coe
}

#' @export
as_df.TraCoe <- function(x){
  df_coe <- as.data.frame(x$coe)
  # if a $fac is present
  if (is.fac(x)) {
    return(dplyr::bind_cols(x$fac, df_coe))
  } else {
    return(df_coe)
  }
}

#' @export
as_df.PCA <- function(x){
  df <- bind_cols(data.frame(.id=rownames(x$x)),
                  x$fac,
                  as.data.frame(x$x))
  #as_data_frame(df)
  df
}

#' @export
as_df.LDA <- function(x){
  fac <- data.frame(fac=x$fac)
  df <- bind_cols(fac, as.data.frame(x$x))
  #as_data_frame(df)
  df
}


##### end bridges
