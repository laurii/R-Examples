
VarExpl.multlcmm <- function(x,values)
{
 if(missing(x)) stop("The model should be specified")
 if (!inherits(x, "multlcmm")) stop("use only with \"multlcmm\" objects")
 if(missing(values)) values <- data.frame("intercept"=1)
 if (!inherits(values, "data.frame")) stop("values should be a data.frame object")
 if(any(is.na(values))) stop("values should not contain any missing values")


 if(x$conv==1 | x$conv==2 | x$conv==3)
 {
  ny <- length(x$Ynames)
  res <- matrix(0,nrow=ny,ncol=x$ng)

  names.random <- x$Xnames[which(x$idea0==1)]
  name.cor <- NULL
  if(x$N[7]>0) name.cor <- x$Xnames[which(x$idcor0==1)]

  if(!is.null(names.random) | !is.null(name.cor))
  {
   names.values <- unique(c(names.random,name.cor))   #contient I(T^2))

   vars <- unique(c(all.vars(x$call$random),all.vars(x$call$cor)))
   if(!all(vars %in% colnames(values))) stop(paste(c("values should give a value for each of the following covariates: ","\n",vars,collapse=" ")))

   ### pour les facteurs

   #cas ou une variable du dataset est un facteur
   olddata <- eval(x$call$data)
   for(v in setdiff(vars,"intercept"))
   {
    if(is.factor(olddata[,v]))
    {
     mod <- levels(olddata[,v])
     if (!(levels(as.factor(values[,v])) %in% mod)) stop(paste("invalid level in factor", v))
     values[,v] <- factor(values[,v], levels=mod)
    }
   }

   #cas ou on a factor() dans l'appel
   call_random <- x$call$random
   z <- all.names(call_random)
   ind_factor <- which(z=="factor")
   if(length(ind_factor))
   {
    nom.factor <- z[ind_factor+1]
    for (v in nom.factor)
    {
     mod <- levels(as.factor(olddata[,v]))
     if (!all(levels(as.factor(values[,v])) %in% mod)) stop(paste("invalid level in factor", v))
     values[,v] <- factor(values[,v], levels=mod)
    }
   }
   call_random <- gsub("factor","",call_random)

   if(!is.null(name.cor)) values1 <- model.matrix(formula(paste("~",paste(call_random[2],name.cor,sep="+"))),data=values)
   else values1 <- model.matrix(formula(call_random),data=values)

   if(colnames(values1)[1]=="(Intercept)") colnames(values1)[1] <- "intercept"

   if(nrow(values1)>1) warning("only the first line of values is used")
   var.random <- values1[1,names.random]
   var.cor <- values1[1,name.cor]

   nea <- sum(x$idea0==1)
   VarU <- matrix(0,nea,nea)
   if(x$N[4]>0)
   {
    if(nea==(x$N[4]+1))
    {
     diag(VarU) <- c(1,x$best[x$N[3]+1:x$N[4]])
    }
    else
    {
     VarU[upper.tri(VarU,diag=TRUE)] <- c(1,x$best[x$N[3]+1:x$N[4]])
     VarU <- t(VarU)
     VarU[upper.tri(VarU,diag=TRUE)] <- c(1,x$best[x$N[3]+1:x$N[4]])
    }
   }
   else
   {
    VarU[1,1] <- 1
   }
   numer <- t(var.random) %*% VarU %*% var.random
   if(x$ng>0)
   {
    nw <- rep(1,x$ng)
    if(x$N[5]>0) nw <- c((x$best[x$N[3]+x$N[4]+1:x$N[5]])^2,1)
    numer <- numer * nw
   }

   Corr <- 0
   if(x$N[7]>0)
   {
    if(x$N[7]==1)
    {
     Corr <- (x$best[sum(x$N[3:5])+1])^2 * var.cor
    }
    if(x$N[7]==2)
    {
     Corr <- (x$best[sum(x$N[3:5])+2])^2
    }
   }
   numer<- numer + Corr
   for(k in 1:ny)
   {
    denom <- numer
    denom <- denom + (x$best[x$N[3]+x$N[4]+x$N[5]+x$N[7]+k])^2  #erreur de mesure
    if(x$N[6]>0) denom <- denom + (x$best[x$N[3]+x$N[4]+x$N[5]+x$N[6]+x$N[7]+k])^2  #intercept aleatoire specif
   
    
    res[k,] <- as.numeric(numer/denom *100)
   }
  }

  rownames(res) <- paste("%Var",x$Ynames,sep="-")
  colnames(res) <- paste("class",1:x$ng,sep="")
 }
 else
 {
  cat("Output can not be produced since the program stopped abnormally. \n")
  res <- NA
 }


 return(res)
}


VarExpl <- function(x,values) UseMethod("VarExpl")
