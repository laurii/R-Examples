#' Predicting drug sensitivity with binary drug-target interaction data using modified maximization and minimization rules
#' 
#' A function to predict the drug sensitivity with binary drug-target interaction data using the 
#' modified maximization and minimization rules
#' 
#' @param drug_target_profile the drug-target interaction data. See \code{\link{timma}}.
#' @param sens a drug sensitivity vector.
#' @param loo a logical value indicating whether to use the leave-one-out cross-validation in the model
#' selection process. By default, loo = TRUE. 
#' @return A list containing the following components:
#' \item{dummy}{the predicted efficacy for target combinations}
#' \item{error}{the prediction errors}
#' \item{prediction}{predicted drug sensitivity}
#' @author Liye He \email{liye.he@@helsinki.fi} 
#' @examples
#' data(tyner_interaction_binary)
#' data(tyner_sensitivity)
#' results<-timmaBinary1(tyner_interaction_binary[, 1:6], tyner_sensitivity[,1])

timmaBinary1 <- function(drug_target_profile, sens, loo = TRUE) {
    # parameter 1: drug_target_profile, drug with selected target profile parameter 2: sens, the actual
    # efficacy for the drugs parameter 3: loo, flag for applying Leave-one-out or not
    
    # drug number
    drug_number <- nrow(as.matrix(drug_target_profile))
    # number of targets in the cancer specific target set
    target_number <- ncol(as.matrix(drug_target_profile))
    
    # get all possible gray code decimal dec_graycode<-graycode2(target_number) rows<-dec_graycode[[1]]
    # cols<-dec_graycode[[2]]
    
    # prof<-unique(drug_target_profile)
    
    # IM_d<-array(NA, dim=c(rows, cols, drug_number)) IM_subset<-array(Inf, dim=c(rows, cols, drug_number))
    # IM_subset<-arrayinfcpp(rows, cols, drug_number) IM_superset<-array(-Inf, dim=c(rows, cols, drug_number))
    # IM_superset<-arrayminfcpp(rows, cols, drug_number) index for the drug drug_index<-rep(0,drug_number)
    drug_target_profile <- matrix(drug_target_profile, nrow = drug_number, ncol = target_number)
    prof <- unique(drug_target_profile)
    dec_prof <- apply(prof, 1, function(x) strtoi(paste(x, collapse = ""), base = 2))
    dec <- apply(drug_target_profile, 1, function(x) strtoi(paste(x, collapse = ""), base = 2))
    # for identical
    col_num <- length(dec_prof)
    # index for the drug
    identical_idx <- sapply(dec, function(x) which(dec_prof == x))
    IM_d <- array(NA, dim = c(drug_number, col_num))
    IM_subset <- array(Inf, dim = c(drug_number, col_num))
    IM_superset <- array(-Inf, dim = c(drug_number, col_num))
    # IM_d<-apply(1:drug_number, function(x,y,z) { y[x,z[x]]=})
    for (i in 1:drug_number) {
        # get the decimal dec<-strtoi(paste(drug_target_profile[i,],collapse=''),base=2)
        IM_d[i, identical_idx[i]] <- 1 * sens[i]
        # temp_matrix<-IM_d[,,i] temp_matrix[drug_index[i]]<-1*sens[i] IM_d[,,i]<-temp_matrix
        
        # get the binary set: superset and subset
        bin_set <- binarySet(drug_target_profile[i, ])
        # ismember function R version: match subset_index<-match(bin_set@subset, dec_graycode[[3]])
        subset_index <- dec_prof %in% bin_set$subset
        IM_subset[i, subset_index] <- sens[i]
        
        superset_index <- dec_prof %in% bin_set$superset
        IM_superset[i, superset_index] <- sens[i]
        
    }
    # M_d<-apply(IM_d, MARGIN=c(1, 2), sum, na.rm=TRUE)/apply(IM_d,MARGIN=c(1,2), function(x){sum(!is.na(x))})
    M_d <- sumcpp1(IM_d, drug_number, col_num)
    # M_d<-apply(IM_d,2, sum, na.rm=T)/apply(IM_d, 2, function(x) {sum(!is.na(x))})
    # min_subset<-apply(IM_subset, 2, min) min_index<-apply(IM_subset, 2, which.min)
    # max_superset<-apply(IM_superset, 2, max) max_index<-apply(IM_superset, 2, which.max)
    maxval <- maxcpp1(IM_superset, drug_number, col_num)
    minval <- mincpp1(IM_subset, drug_number, col_num)
    min_subset <- minval$min
    min_index <- minval$min_idx
    max_superset <- maxval$max
    max_index <- maxval$max_idx
    
    
    
    # find cell which needs maximization averaging
    cell <- is.nan(M_d) & is.finite(max_superset)  # is.nan or is.na????????
    cell <- which(cell == TRUE)
    if (length(cell) != 0) {
        for (i in cell) {
            # row<-((i-1) %% rows) + 1 col<-floor((i-1) / rows)+1
            
            # the drug sets that are the subset of the cell
            drug_sub_cell <- !is.infinite(IM_superset[, i])
            # the drug index which achieves max sensitivity
            index <- max_index[i]
            # the dec of the drug with max sensitivity
            dec_maxsens <- identical_idx[index]
            
            # find the supersets of S(index,:) in S that has smaller sensitivity
            supersets_small <- IM_subset[, dec_maxsens] < max_superset[i]
            
            # find common item with drug_sub_cell and supersets_small
            common_cell <- which(drug_sub_cell & supersets_small)
            
            if (length(common_cell) != 0) {
                # max averaging
                k <- 1
                for (j in common_cell) {
                  max_superset[i] <- (max_superset[i] * k + sens[j])/(k + 1)
                  k <- k + 1
                }
            }
        }
    }
    
    cell2 <- is.nan(M_d) & is.finite(min_subset)
    cell2 <- which(cell2 == TRUE)
    if (length(cell2) != 0) {
        for (i in cell2) {
            # row<-((i-1) %% rows) + 1 col<-floor((i-1) / rows)+1 the drug sets that are the superset of the cell
            drug_sub_cell <- !is.infinite(IM_subset[, i])
            # the drug index which achieves min sensitivity
            index <- min_index[i]
            
            # the dec of the drug with min sensitivity
            dec_minsens <- identical_idx[index]
            
            # find the subsets of S(index,:) in S that has higher sensitivity
            subsets_small <- IM_superset[, dec_minsens] > min_subset[i]
            # find common item with drug_sub_cell and supersets_small
            if (length(subsets_small) == 0) {
                common_cell2 <- vector("numeric")
            } else {
                common_cell2 <- which(drug_sub_cell & subsets_small)
            }
            if (length(common_cell2) != 0) {
                # min averaging
                k <- 1
                for (j in common_cell2) {
                  min_subset[i] <- (min_subset[i] * k + sens[j])/(k + 1)
                  k <- k + 1
                }
            }
        }
    }
    
    M <- M_d
    
    M[cell] <- (max_superset[cell] + 1)/2
    M[cell2] <- (min_subset[cell2] + 0)/2
    
    
    # cels that not only have lower boundery and also have upper boundary
    average_index <- intersect(cell, cell2)
    M[average_index] <- (max_superset[average_index] + min_subset[average_index])/2
    
    # predicted error
    error_predict <- rep(NA, drug_number)
    # predicted efficacy
    pred <- rep(NA, drug_number)
    if (loo == FALSE) {
        pred <- M[identical_idx]
        error_predict <- abs(pred - sens)
        
    } else {
        for (i in 1:drug_number) {
            # remove drug i, namely remove the i-th row
            
            # get the dim info dim_IMd<-dim(IM_d) dim_IMd[3]<-dim_IMd[3]-1
            dim_IMd <- c(drug_number - 1, col_num)
            
            IM_d_loo <- array(IM_d[-i, ], dim = dim_IMd)
            IM_subset_loo <- array(IM_subset[-i, ], dim = dim_IMd)
            # IM_subset_loo<-newArray(IM_subset[,,-i], dim_IMd[1], dim_IMd[2], dim_IMd[3])
            IM_superset_loo <- array(IM_superset[-i, ], dim = dim_IMd)
            # IM_superset_loo<-newArray(IM_superset[,,-i], dim_IMd[1], dim_IMd[2], dim_IMd[3])
            sens_loo <- sens[-i]
            drug_idx_loo <- identical_idx[-i]
            
            # M_d_loo<-apply(IM_d_loo, 2, sum, na.rm=TRUE)/apply(IM_d_loo,2, function(x){sum(!is.na(x))})
            M_d_loo <- sumcpp1(IM_d_loo, drug_number - 1, col_num)
            M_loo <- M_d_loo
            # min_subset_loo<-apply(IM_subset_loo, c(1,2), min) min_index_loo<-apply(IM_subset_loo, c(1,2), which.min)
            # max_superset_loo<-apply(IM_superset_loo, c(1,2), max) max_index_loo<-apply(IM_superset_loo, c(1,2),
            # which.max)
            
            maxval <- maxcpp1(IM_superset_loo, drug_number - 1, col_num)
            minval <- mincpp1(IM_subset_loo, drug_number - 1, col_num)
            min_subset_loo <- minval$min
            min_index_loo <- minval$min_idx
            max_superset_loo <- maxval$max
            max_index_loo <- maxval$max_idx
            
            
            cell <- is.nan(M_d_loo) & is.finite(max_superset_loo)
            cell <- which(cell == TRUE)
            
            cell2 <- is.nan(M_d_loo) & is.finite(min_subset_loo)
            cell2 <- which(cell2 == TRUE)
            
            # does the removed drug need max averaging j_max<-which(cell==drug_index[i])
            j_max <- which(cell == identical_idx[i])
            # does the removed drug need min averaging j_min<-which(cell2==drug_index[i])
            j_min <- which(cell2 == identical_idx[i])
            
            if (length(j_max) != 0 && length(j_min) == 0) {
                # index for the cell
                cell_index <- cell[j_max]
                
                # row<-((cell_index-1) %% rows) + 1 col<-floor((cell_index-1) / rows)+1
                
                drug_sub_cell <- !is.infinite(IM_superset_loo[, cell_index])
                # the drug index which achieves max sensitivity
                index <- max_index_loo[cell_index]
                
                # the index of the dec of the drug with max sensitivity
                dec_maxsens <- drug_idx_loo[index]
                
                # find the supersets of S(index,:) in S that has smaller sensitivity
                supersets_small <- IM_subset_loo[, dec_maxsens] < max_superset_loo[cell_index]
                
                # find common item with drug_sub_cell and supersets_small
                common_cell <- which(drug_sub_cell & supersets_small)
                # cat(common_cell,'\n') max averaging
                if (length(common_cell) != 0) {
                  k <- 1
                  for (j in common_cell) {
                    max_superset_loo[cell_index] <- (max_superset_loo[cell_index] * k + sens_loo[j])/(k + 
                      1)
                    k <- k + 1
                  }
                }
                
                pred[i] <- (max_superset_loo[identical_idx[i]] + 1)/2
                
                
                error_predict[i] <- abs(pred[i] - sens[i])
                
            } else if (length(j_max) == 0 && length(j_min) != 0) {
                cell2_index <- cell2[j_min]
                
                drug_sub_cell <- !is.infinite(IM_subset_loo[, cell2_index])
                
                index <- min_index_loo[cell2_index]
                dec_minsens <- drug_idx_loo[index]
                
                # find the supersets of S(index,:) in S that has smaller sensitivity
                supersets_small <- IM_superset_loo[, dec_minsens] > min_subset_loo[cell2_index]
                # find common item with drug_sub_cell and supersets_small
                common_cell <- which(drug_sub_cell & supersets_small)
                if (length(common_cell) != 0) {
                  # max averaging
                  k <- 1
                  for (j in common_cell) {
                    min_subset_loo[cell2_index] <- (min_subset_loo[cell2_index] * k + sens_loo[j])/(k + 
                      1)
                    k <- k + 1
                  }
                }
                
                pred[i] <- (min_subset_loo[identical_idx[i]] + 0)/2
                
                
                error_predict[i] <- abs(pred[i] - sens[i])
            } else if (length(j_max) != 0 && length(j_min) != 0) {
                
                
                cell_index <- cell[j_max]
                
                # row<-((cell_index-1) %% rows) + 1 col<-floor((cell_index-1) / rows)+1
                
                drug_sub_cell <- !is.infinite(IM_superset_loo[, cell_index])
                # the drug index which achieves max sensitivity
                index <- max_index_loo[cell_index]
                
                # the dec of the drug with max sensitivity
                dec_maxsens <- drug_idx_loo[index]
                
                # find the supersets of S(index,:) in S that has smaller sensitivity
                supersets_small <- IM_subset_loo[, dec_maxsens] < max_superset_loo[cell_index]
                
                # find common item with drug_sub_cell and supersets_small
                common_cell <- which(drug_sub_cell & supersets_small)
                # cat(common_cell,'\n') max averaging
                if (length(common_cell) != 0) {
                  k <- 1
                  for (j in common_cell) {
                    max_superset_loo[cell_index] <- (max_superset_loo[cell_index] * k + sens_loo[j])/(k + 
                      1)
                    k <- k + 1
                  }
                }
                
                cell2_index <- cell2[j_min]
                
                drug_sub_cell <- !is.infinite(IM_subset_loo[, cell2_index])
                
                index <- min_index_loo[cell2_index]
                dec_minsens <- drug_idx_loo[index]
                
                # find the supersets of S(index,:) in S that has smaller sensitivity
                supersets_small <- IM_superset_loo[, dec_minsens] > min_subset_loo[cell2_index]
                # find common item with drug_sub_cell and supersets_small
                common_cell <- which(drug_sub_cell & supersets_small)
                if (length(common_cell) != 0) {
                  # max averaging
                  k <- 1
                  for (j in common_cell) {
                    min_subset_loo[cell2_index] <- (min_subset_loo[cell2_index] * k + sens_loo[j])/(k + 
                      1)
                    k <- k + 1
                  }
                }
                
                
                pred[i] <- (max_superset_loo[identical_idx[i]] + min_subset_loo[identical_idx[i]])/2
                error_predict[i] <- abs(pred[i] - sens[i])
                
            } else {
                # length(j_max)==0 && length(j_min)==0
                pred[i] <- M_loo[identical_idx[i]]
                error_predict[i] <- abs(pred[i] - sens[i])
            }
        }
        
    }
    return(list(dummy = M, error = error_predict, prediction = pred))
} 
