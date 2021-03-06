# clgeo_Clean.R
# -------------
# Author: Emmanuel Blondel <emmanuel.blondel1 at gmail.com>
# Created: 2014-09-23
#
#' @title clgeo_Clean
#' 
#' @description
#' Function to clean a spatial data collection 
#'
#' @author
#' Emmanuel Blondel \email{emmanuel.blondel1@@gmail.com}
#'
#' @param sp object extending the \code{\link[sp]{Spatial-class}}
#' as defined in \pkg{sp}
#' @param errors.only an object of class \code{vector} giving the types of errors
#' for which the output should bounded. Default value is NULL (\emph{i.e.} the output
#' will include features for which both errors and errors were raised.). At now, this
#' argument accepts the error type \code{"ORPHANED_HOLE"}.
#' @param print.log Indicates wether the clean logs have to be printed. Default 
#' value is FALSE.
#' @return an object extending the \code{\link[sp]{Spatial-class}}
#' as defined in \pkg{sp}, with cleaned geometries.
#'
#' @examples
#'  require(maptools)
#'  file <- system.file("extdata", "example.shp", package = "cleangeo")
#'  sp <- readShapePoly(file)
#'  
#'  sp.clean <- clgeo_Clean(sp)
#'  report.clean <- clgeo_CollectionReport(sp.clean)
#'  clgeo_SummaryReport(report.clean)
#'
#' @aliases clgeo_Clean
#' 
#' @keywords geometry validity summary clean
#' 
#'
clgeo_Clean <- function(sp, errors.only = NULL, print.log = FALSE){
  
  report <- clgeo_CollectionReport(sp)
  nv <- clgeo_SuspiciousFeatures(report, errors.only)

  fixed.sp <- SpatialPolygons(
    Srl = lapply(1:length(sp), function(x){
      polygon <- slot(sp, "polygons")[[x]]
      ID <- slot(polygon, "ID")
      if(!all(is.na(nv))){
        if(x %in% nv){          
          polygons <- slot(polygon, "Polygons")
          poly.nb <- length(polygons)
          removedHoles <- 0
          for(i in 1:poly.nb){
            #if we found an orphaned hole, we remove it
            if(slot(polygons[[i]], "hole")
               & dim(unique(slot(polygons[[i]], "coords")))[1] < 3){
              
              if(removedHoles == 0 & print.log){
                print(paste("Cleaning orphaned holes at index ", x, sep=""))
              }
              
              polygons[[i - removedHoles]] <- NULL
              removedHoles <- removedHoles + 1
              slot(polygon, "Polygons") <- polygons
            }
          }
          
          polygon <- SpatialPolygons(Srl = list(polygon))
          
          #testing validity after removing holes
          isValid <- report[x,]$valid
          if(removedHoles > 0){
            if(print.log){
              print(paste("Checking geometry validity at index ", x, sep=""))
            }
            
            slot(polygon, "polygons") <- lapply(slot(polygon, "polygons"),
                                                checkPolygonsHoles)
            isValid <- gIsValid(polygon)
          }
          
          #test clean geometry validity
          if(is.null(errors.only) && !isValid){
            if(print.log){
              print(paste("Cleaning geometry at index ", x, sep=""))
            }
            polygon <- gBuffer(polygon, id = ID, width = 0)
          }
          polygon <- polygon@polygons[[1]]
        }
      }
      
      #index integrity
      slot(polygon, "ID") <- ID
      
      return(polygon)
    }),
    proj4string = CRS(proj4string(sp))
  )
  
  if(class(sp) == "SpatialPolygonsDataFrame"){
    sp.df <- as(sp, "data.frame")
    row.names(sp.df) <- sapply(slot(fixed.sp,"polygons"), slot, "ID")
    fixed.sp <- SpatialPolygonsDataFrame(Sr = fixed.sp, data = sp.df)
  }
  
  return(fixed.sp)
}
