#' @title Missing Value Imputation by Last Observation Carried Forward
#' 
#' @description Replaces each missing value with the most recent present value prior to it
#'  (Last Observation Carried Forward- LOCF). Optionally this can also be done starting from the back of the series
#'  (Next Observation Carried Backward - NOCB).
#'  
#' @param x Numeric Vector (\code{\link{vector}}) or Time Series (\code{\link{ts}}) object in which missing values shall be replaced
#' @param option Algorithm to be used. Accepts the following input:
#' \itemize{
#'    \item{"locf" - for Last Observation Carried Forward}
#'    \item{"nocb" - for Next Obervation Carried Backward}
#'    }
#'    
#' @param na.remaining Method to be used for remaining NAs.
#' \itemize{
#'    \item{"keep" - to return the series with NAs}
#'    \item{"rm" - to remove remaining NAs}
#'    \item{"mean" - to replace remaining NAs by overall mean}
#'    \item{"rev" - to perform nocb / locf from the reverse direction}
#'    }
#' @return Vector (\code{\link{vector}}) or Time Series (\code{\link{ts}}) object (dependent on given input at parameter x)
#' 
#' @details Replaces each missing value with the most recent present value prior to it
#'  (Last Observation Carried Forward- LOCF). This can also be done from the reverse direction -starting from the back
#'  (Next Observation Carried Backward - NOCB). Both options have the issue, that NAs at the beginning 
#'  (or for nocb at the end) of the time series can not be imputed (since there is no last value to 
#'  be carried forward present yet). In this case there are remaining NAs in the imputed time series.
#'  Since this only concerns very few values at the beginning of the series,
#'   na.remaining offers some quick solutions to get a series without NAs back.
#' 
#' @author Steffen Moritz
#' @seealso  \code{\link[imputeTS]{na.interpolation}},
#' \code{\link[imputeTS]{na.kalman}},
#'  \code{\link[imputeTS]{na.ma}}, \code{\link[imputeTS]{na.mean}},
#'  \code{\link[imputeTS]{na.random}}, \code{\link[imputeTS]{na.replace}},
#'  \code{\link[imputeTS]{na.seadec}}, \code{\link[imputeTS]{na.seasplit}}
#'  
#' @examples
#' #Prerequisite: Create Time series with missing values
#' x <- ts(c(NA,3,4,5,6,NA,7,8))
#' 
#' #Example 1: Perform LOCF
#' na.locf(x)
#' 
#' #Example 2: Perform NOCF
#' na.locf(x, option = "nocb")
#' 
#' #Example 3: Perform LOCF and remove remaining NAs
#' na.locf(x, na.remaining = "rm")
#' 
#' @import stats
#' @export


na.locf <- function(x, option ="locf",  na.remaining = "rev" ) {
  
  data <- x
  
  #Check for wrong input 
  data <- precheck(data)
  
  #if no missing data, do nothing
  if(!anyNA(data)) {
    return(data)
  }
  
  ##
  ## Imputation Code
  ##
  
  ## option - what kind of imputation to perform
  #Last observation carried forward
  if (option == "locf") {
    for (i in 2:length(data)) {
      if (is.na(data[i])) {
        data[i] <- data[i-1]
      }
    }
  }
  #Next observation carried backward
  else if (option == "nocb") {
    for (i in (length(data)-1):1) {
      if (is.na(data[i])) {
        data[i] <- data[i+1]
      }
    }
  }
  #Wrong input
  else {
    stop("Wrong parameter 'option' given. Value must be either 'locf' or 'nocb'.")
  }
  
  
  
  ##na.remaining - what to do with remaining NAs after imputation
  
  #keep NAs untouched
  if (na.remaining == "keep") {
    return(data)
  }
  #Remove all NAs
  else if(na.remaining == "rm"){
    return(na.remove(data))
  }
  #Replace NAs with overall mean
  else if(na.remaining == "mean") {
    return(na.mean(data))
  }
  #Perform locf/nocb from opposite direction
  else if(na.remaining == "rev") {
    if(option =="locf") {
      return(na.locf(data, option ="nocb"))
    }
    else{
      return(na.locf(data))
    }
  }  
  #Wrong Input
  else {
    stop("Wrong parameter 'na.remaining' given. Value must be either 'keep', 'rm', 'mean' or 'rev'.") 
  }
  
  return(data)
}