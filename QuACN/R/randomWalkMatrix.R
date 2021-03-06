randomWalkMatrix <- function(g) {
  stopifnot(.validateGraph(g))
  adj.mat <- adjacencyMatrix(g) 
  n_nodes <- nrow(adj.mat)
  RanWalk_Mat <- matrix(0, nrow=n_nodes, ncol=n_nodes, byrow=TRUE)
  deg.vec <- graph::degree(g) 
  for(i in 1:n_nodes) {
    for(j in 1:n_nodes) {
      if(adj.mat[i,j] != 0) {
        RanWalk_Mat[i,j] <- 1/deg.vec[j]
      }
    }
  }
  RanWalk_Mat
}
