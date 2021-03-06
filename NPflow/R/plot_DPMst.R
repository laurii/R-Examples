#'Plot of a Dirichlet process mixture of skew t-distribution partition
#'
#'@param z data matrix \code{d x n} with \code{d} dimensions in rows
#'and \code{n} observations in columns.
#'
#'@param c allocation vector of length \code{n} indicating which observation belongs to which
#'clusters.
#'
#'@param alpha current value of the DP concentration parameter.
#'
#'@param U_SS a list containing \code{"xi"}, \code{"psi"}, \code{"S"}, and \code{"df"}.
#'
#'@param i current MCMC iteration number.
#'
#'@param dims2plot index vector, subset of \code{1:d} indicating which dimensions should be drawn.
#'Default is all of them.
#'
#'@param ellipses a logical flag indicating whethe ellipses should be drawn around clusters. Default
#'is \code{TRUE} if only 2 dimensions are plotted, \code{FALSE} otherwise.
#'
#'@param gg.add
#'A list of instructions to add to the ggplot2 instruction. See \code{\link[ggplot2]{+.gg}}.
#'Default is \code{list(theme())}, which adds nothing to the plot.
#'
#'@param nbsim_dens number of simulated points used for computing clusters density contours in 2D
#'plots. Default is \code{1000} points.
#'
#'@param nice logical flag changing the plot looks. Default is \code{FALSE}.
#'
#'@author Boris Hejblum
#'
#'@import ggplot2
#'@import reshape2
#'@importFrom truncnorm rtruncnorm
#'@importFrom stats dnorm pnorm rgamma rnorm
#'
#' @export

plot_DPMst <- function(z, c, i="", alpha="?", U_SS,
                       dims2plot=1:nrow(z),
                       ellipses=ifelse(length(dims2plot)<3,TRUE,FALSE),
                       gg.add=list(theme()), nbsim_dens=1000, nice=FALSE){

    mean_sn01 <- (stats::dnorm(0)-stats::dnorm(Inf))/(stats::pnorm(Inf)-stats::pnorm(0))

    z <- z[dims2plot,]


    n <- ncol(z)
    p <- nrow(z)
    m <- numeric(n) # number of observations in each cluster
    m[unique(c)] <- table(c)[as.character(unique(c))]

    fullCl <- which(m!=0)

    U_xi2plot=sapply(U_SS, "[[", "xi")
    U_psi2plot=sapply(U_SS, "[[", "psi")
    U_Sigma2plot=lapply(U_SS, "[[", "S")
    U_nu2plot=lapply(U_SS, "[[", "df")
    U_SS2plot <- U_SS
    U_mu2plot <- U_xi2plot + U_psi2plot*mean_sn01
    rownames(U_mu2plot) <- rownames(z)
    zClusters <- factor(c, levels=as.character(fullCl), ordered=TRUE)

    expK <- ifelse(is.numeric(alpha), round(alpha*(digamma(alpha+n)-digamma(alpha))), NA)
    alpha2print <- ifelse(is.numeric(alpha), formatC(alpha, digits=2), alpha)


    if(p>2){
        zDplot <- melt(cbind.data.frame("ID"=as.character(1:n),
                                        t(z),
                                        "Cluster"=zClusters
        ),
        id.vars=c("ID", "Cluster"),
        variable.name = "dimensionX",
        value.name="X"
        )
        zDplotfull <- zDplot
        zDplotfull$Y <- zDplot$X
        zDplotfull$dimensionY <- zDplot$dimensionX

        lev <- as.character(1:length(levels(zDplot$dimensionX)))
        for(l in 2:length(lev)){
            move <- which(as.numeric(zDplot$dimensionX)<l)
            zDplottemp <- rbind.data.frame(zDplot[-move,], zDplot[move,])
            zDplottemp$Y <- zDplot$X
            zDplottemp$dimensionY <- zDplot$dimensionX
            zDplotfull <- rbind.data.frame(
                zDplotfull, zDplottemp)
        }

        UDplot <- melt(cbind.data.frame(t(U_mu2plot),
                                        "Cluster"=factor(as.character(fullCl),
                                                         levels=as.character(fullCl),
                                                         ordered=TRUE)
        ),
        id.vars=c("Cluster"),
        variable.name = "dimensionX",
        value.name="X"
        )
        UDplotfull <- UDplot
        UDplotfull$Y <- UDplotfull$X
        UDplotfull$dimensionY <- UDplotfull$dimensionX

        lev <- levels(UDplotfull$dimensionX)
        for(l in 2:length(lev)){
            move <- which(as.numeric(UDplotfull$dimensionX)<l)
            UDplottemp <- rbind.data.frame(UDplotfull[-move,], UDplotfull[move,])
            UDplottemp$Y <- UDplotfull$X
            UDplottemp$dimensionY <- UDplotfull$dimensionX
            UDplotfull <- rbind.data.frame(
                UDplotfull, UDplottemp)
        }

        p <- (ggplot(zDplotfull)
              + facet_grid(dimensionY~dimensionX, scales="free")
              + geom_point(aes_string(x="X", y="Y", colour="Cluster", order="Cluster"),
                           data=zDplotfull, alpha=1, size=2/(0.3*log(n)))
              #               + geom_polygon(aes_string(x="X", y="Y", fill="Cluster", colour="Cluster", order="Cluster"),
              #                              data=ellipse95, size=0.5, linetype=2, colour="black", alpha=.3)
              + geom_point(aes_string(x="X", y="Y", colour="Cluster", order="Cluster"),
                           data=UDplotfull, shape=22, size=5/(0.3*log(n)))
              + ggtitle(paste(n, " obs.",
                              "\niteration ", i, " : ",
                              length(fullCl)," clusters",
                              "\nexpected number of clusters: ", expK,
                              " (alpha = ", alpha2print, ")",
                              sep=""))
        )
    }else{
        z2plot <- cbind.data.frame("D1"=z[1,],"D2"=z[2,],"Cluster"=zClusters)
        U2plot <- cbind.data.frame("D1"=U_mu2plot[1,],
                                   "D2"=U_mu2plot[2,],
                                   "Cluster"=factor(as.character(fullCl),
                                                    levels=as.character(fullCl),
                                                    ordered=TRUE)
        )
        xi2plot <- cbind.data.frame("D1"=U_xi2plot[1,],
                                    "D2"=U_xi2plot[2,],
                                    "Cluster"=factor(as.character(fullCl),
                                                     levels=as.character(fullCl),
                                                     ordered=TRUE)
        )
        U2plot$Center="sampled mean"
        xi2plot$Center="xi param"

        if(!nice){
            p <- (ggplot(z2plot)
                  + geom_point(aes_string(x="D1", y="D2", colour="Cluster", order="Cluster", fill="Cluster"), alpha=0.7,
                               data=z2plot, size=2/(0.3*log(n)))
                  + scale_alpha_continuous(guide=FALSE)
                  + scale_fill_discrete(guide=FALSE)
                  + scale_colour_discrete(guide=guide_legend(override.aes = list(size = 6, alpha=1)))
                  + ggtitle(paste(n, " obs.",
                                  "\niteration ", i, " : ",
                                  length(fullCl)," clusters",
                                  "\nexpected number of clusters: ", expK,
                                  " (alpha = ", alpha2print, ")",
                                  sep=""))
            )
            #empirical mean of the clusters
            zmean2plot<- cbind.data.frame(D1=tapply(X=z2plot[,1], INDEX=z2plot$Cluster, FUN=mean),
                                          D2=tapply(X=z2plot[,2], INDEX=z2plot$Cluster, FUN=mean)
            )
            zmean2plot <- cbind.data.frame(zmean2plot, Cluster=rownames(zmean2plot))
            zmean2plot$Center="observed mean"

        }else{
            p <- (ggplot(z2plot)
                  + geom_point(aes_string(x="D1", y="D2", colour="Cluster", order="Cluster", shape="Cluster", fill="Cluster"), alpha=0.65,
                               data=z2plot, size=2)
                  + scale_alpha_continuous(guide=FALSE)
            )
        }

        if(ellipses){
          simuDens <- NULL
          for(g in 1:length(fullCl)){
            glabel <- levels(zClusters)[g]
            #gind <- as.numeric(glabel)
            w <- stats::rgamma(n=nbsim_dens, shape=U_nu2plot[[g]]/2, rate=U_nu2plot[[g]]/2)
            ltnz <- truncnorm::rtruncnorm(n=nbsim_dens, a=0, sd=1/sqrt(w))
            eps <- t(sapply(w, function(a){matrix(stats::rnorm(2), ncol=2)%*%chol(U_Sigma2plot[[g]]/a)}))
            #eps <- matrix(NA, nrow=nbsim_dens, ncol=2)
            #for(i in 1:nbsim_dens){
            #    eps[i,] <- matrix(rnorm(2), ncol=2)%*%chol(U_Sigma2plot[[g]]/w[i])
            #}
            simuDenstemp <- data.frame("D1"=U_xi2plot[1,g]+U_psi2plot[1,g]*ltnz+eps[,1],
                                       "D2"=U_xi2plot[2,g]+U_psi2plot[2,g]*ltnz+eps[,2],
                                       "Cluster"=rep(glabel, nbsim_dens))
            simuDens <- rbind.data.frame(simuDens, simuDenstemp)
          }
          simuDens$Type <- "DensContour"
          p <- (p
                + stat_density2d(data=simuDens, aes_string(x="D1", y="D2", colour="Cluster", linetype="Type"))
                + scale_linetype_manual(values=c(1),
                                        labels=c("simulations derived\n from sampled parameters"),
                                        name="Density contour")
                + guides(linetype=guide_legend(override.aes = list(color="black")),
                         colour=guide_legend(override.aes = list(linetype=0, size=6, alpha=1, shape=15)))
          )
        }

        if(nice){
            if(length(unique(z2plot$Cluster)<5)){
                p <- (p
                      + scale_shape_manual(values=c(21:(20+length(unique(z2plot$Cluster)))))
                )
            }else{
                p <- (p
                      + scale_shape_manual(values=rep(21,length(unique(z2plot$Cluster))))
                )
            }
            p <- (p
                  + scale_colour_discrete(guide=guide_legend(override.aes = list(size = 4, alpha=0.8, linetype=0)))
            )
        }else{
          p <- (p + geom_point(aes_string(x="D1", y="D2", fill="Cluster", order="Cluster", shape="Center"),
                               data=zmean2plot, size=5)
                + geom_point(aes_string(x="D1", y="D2", fill="Cluster", order="Cluster", shape="Center"),
                             data=U2plot, size=5)
                + geom_point(aes_string(x="D1", y="D2", fill="Cluster", order="Cluster", shape="Center"),
                             data=xi2plot, size=5)
                + scale_shape_manual(values=c(24,22,23),
                                     breaks=c("observed mean", "sampled mean", "xi param"),
                                     labels=c("observed mean", "sampled mean", "xi param"),
                                     name="Center")
          )
        }
    }

    for (a in gg.add) {
        p <- p + a
    }

    print(p)
}
