summary.gamsel <-
  function (object, label=FALSE,...) 
{
  alphas=object$alphas
  betas=object$betas
  p=dim(alphas)[1]
  degrees=object$degrees
  maxvars = p
  col.end = 0.7
  colours = c(rainbow(n = maxvars, end = col.end, v = 0.9), 
    rainbow(n = (p - maxvars), start = col.end + 0.1, s = 0.25))
  lambda=object$lambda
  
  lambda.max = max(lambda)
  lambda.min = min(lambda[lambda>0.001])
  nzlines=function(lambda,alpha,...){
    if(any(abs(alpha)>0)){
      num_lambda <- length(lambda)
      start=max(1,min(seq(num_lambda)[abs(alpha)>0])-1)
      whichnz=seq(from=start,to=num_lambda)
      if (length(whichnz)>1){
        lines(lambda[whichnz], alpha[whichnz],...)
      }
    }
    invisible()
  }
  plot(0, type = "n", xlab = expression(lambda), ylab = expression(alpha), 
       xlim = c(lambda.max * 1.05, lambda.min * (0.9-.1*label)), ylim = range(alphas), main = "Linear Components",  log = "x")
  abline(h=0,lty=3)
  for (j in 1:maxvars) {
    nzlines(lambda,alphas[j,], col = colours[j], lwd = 2, type = "l", pch = "", cex = 0)
  }
  if(label)text(rep(lambda.min*.85,maxvars),alphas[,length(lambda)],labels=seq(maxvars),col=colours,cex=0.6)
  nbetas=dim(betas)[1]   
  counter=rep(1:maxvars,degrees)
  counter=diag(maxvars)[counter,]
  nbeta=sqrt(t(counter)%*%(betas^2))
  betamax=max(nbeta)
  plot(0, type = "n", xlab = expression(lambda), ylab = expression(paste("||",beta,"||")), 
       xlim = c(lambda.max * 1.05, lambda.min * (0.9-.1*label)), ylim = c(0,1.05 * betamax), main = "Non-linear Components",  log = "x")
  abline(h=0,lty=3)
  for (j in 1:maxvars) {
    nzlines(lambda,nbeta[j,], col = colours[j], lwd = 2, type = "l", pch = "")
        
  }
  if(label)text(rep(lambda.min*.85,maxvars),nbeta[,length(lambda)],labels=seq(maxvars),col=colours,cex=0.6)

}
