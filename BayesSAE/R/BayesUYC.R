BayesUYC <-
function(theta, beta, y, X, b, phi, n, betaprior, Sqsigmaprior, Recsigmaprior, betatype, thetatype, Sqsigmatype)
{
     m <- length(theta)
     p <- length(beta)
     if (thetatype == 1)
          theta = log(theta)
     else
          theta = log(theta / (1 - theta))
     theta <- c(theta, rnorm((n-1)*m))
     beta <- c(beta, rnorm((n-1)*p))
     ai <- Recsigmaprior[1:m]
     bi <- Recsigmaprior[(m+1):(2*m)]
     ni <- Recsigmaprior[(2*m+1):(3*m)]
     Sqsigma <- rgamma(n*m, shape = ai+(ni+1)/2, rate = 1)
     s <- rep(0, m)
     if (Sqsigmatype == 0){
          a0 <- Sqsigmaprior[1]
          b0 <- Sqsigmaprior[2]
          Sqsigmav <- 1.0 / rgamma(n, shape = a0 + m / 2, rate = 1)
          result <- .C("BayesUYC", as.double(theta), as.double(beta), as.double(Sqsigmav), 
               as.double(Sqsigma), as.double(y), as.double(X), as.double(b), as.double(phi), as.integer(n),
               as.integer(m), as.integer(p), as.double(betaprior), as.double(b0), as.double(c(bi, ni)), 
               as.integer(betatype), as.integer(thetatype), as.integer(Sqsigmatype), as.integer(s))
     }
     else{
          Sqsigmav <- 1.0 / rgamma(n, shape = m / 2 - 1, rate = 1)
          result <- .C("BayesUYC", as.double(theta), as.double(beta), as.double(Sqsigmav), 
               as.double(Sqsigma), as.double(y), as.double(X), as.double(b), as.double(phi), as.integer(n),
               as.integer(m), as.integer(p), as.double(betaprior), as.double(Sqsigmaprior), as.double(c(bi, ni)), 
               as.integer(betatype), as.integer(thetatype), as.integer(Sqsigmatype), as.integer(s))

     }
     if(thetatype == 1)
          result[[1]] <- exp(array(result[[1]], c(m, n)))
     else
          result[[1]] <- 1 / (1 + exp(-array(result[[1]], c(m, n))))
     result[[2]] <- array(result[[2]], c(p, n))
     result[[4]] <- 1.0 / array(result[[4]], c(m, n))
     MCMCsample <- list(theta = result[[1]], beta = result[[2]], sigv = result[[3]], 
         sig2 = result[[4]], theta.rate = result[[17]], type = "UYC")
     MCMCsample
}
