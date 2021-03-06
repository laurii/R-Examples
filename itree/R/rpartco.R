#ALG: itree copies this direclty from rpart,
# except for switch to not fetch parameters from global environment.
# it is INTERNAL, so we do not change the name to itree.

#SCCS @(#)rpartco.s	1.7 02/07/00
# Compute the x-y coordinates for a tree
rpartco <- function(tree, parms =  paste(".itree.parms", dev.cur(), sep = "."))
{

    frame <- tree$frame
    node <- as.numeric(row.names(frame))
    depth <- tree.depth(node)
    is.leaf <- (frame$var == '<leaf>')
    
    #alg 6/25/2013: here we check envir=itree_env, not .GlobalEnv
    if (exists(parms, envir=itree_env)) {  
		parms <- get(parms, envir=itree_env)
		uniform <- parms$uniform
		nspace <-parms$nspace
		minbranch <- parms$minbranch
    } else {
		uniform <- FALSE
		nspace <- -1
		minbranch <- .3
    }

    if(uniform)
        y <- (1 + max(depth) -depth) / max(depth,4)
    else {                    #make y- (parent y) = change in deviance
	y <- dev <- frame$dev
        temp <- split(seq(node), depth)     #depth 0 nodes, then 1, then ...
        parent <- match(floor(node/2), node)
        sibling <- match(ifelse(node %% 2, node - 1, node + 1), node)

	# assign the depths
     for(i in temp[-1L]) {
	    temp2 <- dev[parent[i]] - (dev[i] + dev[sibling[i]])
            y[i] <- y[parent[i]] - temp2
        }
	#
	# For some problems, classification & loss matrices in particular
	#   the gain from a split may be 0.  This is ugly on the plot.
	# Hence the "fudge" factor of  .3* the average step
	#
	fudge <-  minbranch * diff(range(y)) / max(depth)
        for(i in temp[-1L]) {
	    temp2 <- dev[parent[i]] - (dev[i] + dev[sibling[i]])
	    haskids <- !(is.leaf[i] & is.leaf[sibling[i]])
	    y[i] <- y[parent[i]] - ifelse(temp2<=fudge & haskids, fudge, temp2)
        }
	y <- y / (max(y))
    }

    # Now compute the x coordinates, by spacing out the leaves and then
    #   filling in
    x   <-  double(length(node))         #allocate, then fill it in below
    x[is.leaf] <- seq(sum(is.leaf))      # leaves at 1, 2, 3, ....
    left.child <- match(node * 2, node)
    right.child <- match(node * 2 + 1, node)

    # temp is a list of non-is.leaf, by depth
    temp <- split(seq(node)[!is.leaf], depth[!is.leaf])
    for(i in rev(temp))
        x[i] <- 0.5 * (x[left.child[i]] + x[right.child[i]])

    if (nspace < 0) return(list(x=x, y=y))

    #
    # Now we get fancy, and try to do overlapping
    #
    #  The basic algorithm is, at each node:
    #      1: get the left & right edges, by depth, for the left and
    #           right sons, of the x-coordinate spacing.
    #      2: find the minimal free spacing.  If this is >0, slide the
    #           right hand son over to the left
    #      3: report the left & right extents of the new tree up to the
    #           parent
    #   A way to visualize steps 1 and 2 is to imagine, for a given node,
    #      that the left son, with all its descendants, is drawn on a
    #      slab of wood.  The left & right edges, per level, give the
    #      width of this board.  (The board is not a rectangle, it has
    #      'stair step' edges). Do the same for the right son.  Now
    #      insert some spacers, one per level, and slide right hand
    #      board over until they touch.  Glue the boards and spacer
    #      together at that point.
    #
    #  If a node has children, its 'space' is considered to extend left
    #    and right by the amount "nspace", which accounts for space
    #    used by the arcs from this node to its children.  For
    #    horseshoe connections nspace usually is 1.
    #
    compress <- function(x, me, depth)
    {
        lson <- me + 1L
	if (is.leaf[lson]) left <- list(left=x[lson], right=x[lson],
                                        depth=depth+1L, sons=lson)
        else {
            left <- compress(x, me+1L, depth+1L)
            x <- left$x
        }

        rson <- me + 1L + length(left$sons)
	if (is.leaf[rson]) right <- list(left=x[rson], right=x[rson],
                                         depth=depth+1L, sons=rson)
	else {
            right <- compress(x, rson, depth+1L)
            x <- right$x
        }

	maxd <- max(left$depth, right$depth) - depth
        mind <- min(left$depth, right$depth) - depth

	# Find the smallest distance between the two subtrees
	#   But only over depths that they have in common
	# 1 is a minimum distance allowed
	slide <- min(right$left[1L:mind] - left$right[1L:mind]) - 1L
	if (slide > 0) { # slide the right hand node to the left
	    x[right$sons] <- x[right$sons] - slide;
	    x[me] <- (x[right$sons[1L]] + x[left$sons[1L]])/2
        } else slide <- 0

	# report back
        if (left$depth > right$depth) {
	    templ <- left$left
            tempr <- left$right
            tempr[1L:mind] <- pmax(tempr[1L:mind], right$right - slide)
        } else {
	    templ <- right$left  - slide
	    tempr <- right$right - slide
	    templ[1L:mind] <- pmin(templ[1L:mind], left$left)
        }

	list(x = x,
             left = c(x[me]- nspace*(x[me] -x[lson]), templ),
	     right = c(x[me]- nspace*(x[me] -x[rson]), tempr),
	     depth = maxd+ depth, sons=c(me, left$sons, right$sons))
    }
    x <- compress(x, 1L, 1L)$x

    #ALG 9/7/2012: x and y are in order of 'frame'
    list(x = x, y = y)
}

