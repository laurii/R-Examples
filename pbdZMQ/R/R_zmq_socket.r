#' Socket Functions
#' 
#' Socket functions
#' 
#' \code{zmq.socket()} initials a ZMQ socket given a ZMQ context \code{ctx} and
#' a socket \code{type}. See \code{\link{ZMQ.ST}()} for the possible values of
#' \code{type}. ZMQ defines several patterns for the socket type and utilize
#' them to communicate in different ways including request-reply,
#' publish-subscribe, pipeline, exclusive pair, and naive patterns.
#' 
#' \code{zmq.close()} destroys the ZMQ socket.
#' 
#' \code{zmq.bind()} binds the socket to a local endpoint and then accepts
#' incoming connections on that endpoint. See \code{endpoint} next for details.
#' 
#' \code{zmq.connect()} connects the socket to a remote endpoint and then
#' accepts outgoing connections on that endpoint. See \code{endpoint} next for
#' details.
#' 
#' \code{endpoint} is a string consisting of a transport :// followed by an
#' address. The transport specifies the underlying protocol to use. The address
#' specifies the transport-specific address to bind to.  pbdZMQ/ZMQ provides
#' the following transports: \tabular{ll}{ Transport \tab Usage \cr \code{tcp}
#' \tab unicast transport using TCP \cr \code{ipc} \tab local inter-process
#' communication transport \cr \code{inproc} \tab local in-process
#' (inter-thread) communication transport \cr \code{pgm,epgm} \tab reliable
#' multicast transport using PGM } *** warning: \code{epgm} is not turned on by
#' default in the pbdZMQ's internal ZeroMQ library. \cr *** warning: \code{ipc}
#' is not supported in Windows system.
#' 
#' \code{zmq.setsockopt()} is to set/change socket options.
#'
#' \code{zmq.getsockopt()} is to get socket options and returns
#' \code{option.value}.
#' 
#' @param ctx 
#' a ZMQ context
#' @param type 
#' a socket type
#' @param socket 
#' a ZMQ socket
#' @param endpoint 
#' a ZMQ socket endpoint
#' @param option.name 
#' an option name to the socket
#' @param option.value 
#' an option value to the option name
#' @param MC 
#' a message control, see \code{\link{ZMQ.MC}()} for details
#' 
#' @return \code{zmq.socket()} returns an R external pointer (\code{socket})
#' generated by ZMQ C API pointing to a socket if successful, otherwise returns
#' an R \code{NULL} and sets \code{errno} to the error value, see ZeroMQ manual
#' for details.
#' 
#' \code{zmq.close()} destroys the socket reference/pointer (\code{socket}) and
#' returns 0 if successful, otherwise returns -1 and sets \code{errno} to the
#' error value, see ZeroMQ manual for details.
#' 
#' \code{zmq.bind()} binds the socket to specific \code{endpoint} and returns 0
#' if successful, otherwise returns -1 and sets \code{errno} to the error
#' value, see ZeroMQ manual for details.
#' 
#' \code{zmq.connect()} connects the socket to specific \code{endpoint} and
#' returns 0 if successful, otherwise returns -1 and sets \code{errno} to the
#' error value, see ZeroMQ manual for details.
#' 
#' \code{zmq.setsockopt()} sets/changes the socket option and returns 0 if
#' successful, otherwise returns -1 and sets \code{errno} to the error value,
#' see ZeroMQ manual for details.
#'
#' \code{zmq.getsockopt()} returns the value of socket option,
#' see ZeroMQ manual for details.
#'
#' @author Wei-Chen Chen \email{wccsnow@@gmail.com}.
#' 
#' @references ZeroMQ/4.1.0 API Reference:
#' \url{http://api.zeromq.org/4-1:_start}
#' 
#' Programming with Big Data in R Website: \url{http://r-pbd.org/}
#' 
#' @examples
#' \dontrun{
#' ### Using request-reply pattern.
#' 
#' ### At the server, run next in background or the other windows.
#' library(pbdZMQ, quietly = TRUE)
#' 
#' context <- zmq.ctx.new()
#' responder <- zmq.socket(context, .pbd_env$ZMQ.ST$REP)
#' zmq.bind(responder, "tcp://*:5555")
#' zmq.close(responder)
#' zmq.ctx.destroy(context)
#' 
#' 
#' ### At a client, run next in foreground.
#' library(pbdZMQ, quietly = TRUE)
#' 
#' context <- zmq.ctx.new()
#' requester <- zmq.socket(context, .pbd_env$ZMQ.ST$REQ)
#' zmq.connect(requester, "tcp://localhost:5555")
#' zmq.close(requester)
#' zmq.ctx.destroy(context)
#' }
#' 
#' @keywords programming
#' @seealso \code{\link{zmq.ctx.new}()}, \code{\link{zmq.ctx.destroy}()}.
#' @rdname a1_socket
#' @name Socket Functions
NULL



#' @rdname a1_socket
#' @export
zmq.socket <- function(ctx, type = .pbd_env$ZMQ.ST$REP){
  ret <- .Call("R_zmq_socket", ctx, type, PACKAGE = "pbdZMQ")
  ### Users are responsible to take care free and gc.
  # reg.finalizer(ret, zmq.close, TRUE)
  ret
}



#' @rdname a1_socket
#' @export
zmq.close <- function(socket){
  ret <- .Call("R_zmq_close", socket, PACKAGE = "pbdZMQ")
  invisible(ret)
}



#' @rdname a1_socket
#' @export
zmq.bind <- function(socket, endpoint, MC = .pbd_env$ZMQ.MC){
  ret <- .Call("R_zmq_bind", socket, endpoint, PACKAGE = "pbdZMQ")

  if(ret == -1){
    if(MC$stop.at.error){
      stop(paste("zmq.bind fails, ", endpoint, sep = ""))
      return(invisible(ret))
    }
    if(MC$warning.at.error){
      warning(paste("zmq.bind fails, ", endpoint, sep = ""))
      return(invisible(ret))
    }
  } else{
    return(invisible(ret))
  }
}



#' @rdname a1_socket
#' @export
zmq.connect <- function(socket, endpoint, MC = .pbd_env$ZMQ.MC){
  ret <- .Call("R_zmq_connect", socket, endpoint, PACKAGE = "pbdZMQ")

  if(ret == -1){
    if(MC$stop.at.error){
      stop(paste("zmq.connect fails, ", endpoint, sep = ""))
      return(invisible(ret))
    }
    if(MC$warning.at.error){
      warning(paste("zmq.connect fails, ", endpoint, sep = ""))
      return(invisible(ret))
    }
  } else{
    return(invisible(ret))
  }
}



#' @rdname a1_socket
#' @export
zmq.disconnect <- function(socket, endpoint, MC = .pbd_env$ZMQ.MC){
  ret <- .Call("R_zmq_disconnect", socket, endpoint, PACKAGE = "pbdZMQ")

  if(ret == -1){
    if(MC$stop.at.error){
      stop(paste("zmq.disconnect fails, ", endpoint, sep = ""))
      return(invisible(ret))
    }
    if(MC$warning.at.error){
      warning(paste("zmq.disconnect fails, ", endpoint, sep = ""))
      return(invisible(ret))
    }
  } else{
    return(invisible(ret))
  }
}



#' @rdname a1_socket
#' @export
zmq.setsockopt <- function(socket, option.name, option.value, MC = .pbd_env$ZMQ.MC){
  if(is.character(option.value)){
    option.type <- 0L
  } else if(is.integer(option.value)){
    option.type <- 1L
  } else{
    stop("Type of option.value is not implemented")
  }

  ret <- .Call("R_zmq_setsockopt", socket, option.name, option.value,
               option.type, PACKAGE = "pbdZMQ")

  if(ret == -1){
    if(MC$stop.at.error){
      stop(paste("zmq.setsockopt fails, ", option.value, sep = ""))
      return(invisible(ret))
    }
    if(MC$warning.at.error){
      warning(paste("zmq.setsockopt fails, ", option.value, sep = ""))
      return(invisible(ret))
    }
  } else{
    return(invisible(ret))
  }
}

#' @rdname a1_socket
#' @export
zmq.getsockopt <- function(socket, option.name, option.value, MC = .pbd_env$ZMQ.MC){
  if(is.character(option.value)){
    option.type <- 0L
  } else if(is.integer(option.value)){
    option.type <- 1L
  } else{
    stop("Type of option.value is not implemented")
  }

  ret <- .Call("R_zmq_getsockopt", socket, option.name, option.value,
               option.type, PACKAGE = "pbdZMQ")

  if(ret == -1){
    if(MC$stop.at.error){
      stop(paste("zmq.getsockopt fails, ", option.value, sep = ""))
      return(invisible(ret))
    }
    if(MC$warning.at.error){
      warning(paste("zmq.getsockopt fails, ", option.value, sep = ""))
      return(invisible(ret))
    }
  } else{
    return(invisible(option.value))
  }
}