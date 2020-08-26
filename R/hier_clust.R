#'
#' Helper function to get row and column from dist matrix
#'
#' @param distmax dataframe to perform clustering on
#' @param nrowx number of rows in x
#'
#' @return loc of min
#'
#'
#'
#'


getminfromdistmat <- function(distmat, nrowx){
    mymin <- min(distmat)
    minpos <- which.min(distmat)
    minrow <- 0
    mincol <- 0
    iter = 1

    for (i in 1:(nrowx-1)){
        for (j in (i+1):nrowx){
            if (iter == minpos) {
                minrow <- j
                mincol <- i
            }
            iter = iter + 1
        }

    }
    return(c(minrow, mincol))
}

#'
#' Implements hierarchical clustering
#'
#' @param dat dataframe to perform clustering on
#' @param k number of clusters
#'
#' @return list of size k of strings with groups in them lol
#'
#' @import dplyr
#'
#' @export
#'

hier_clust <- function(dat, k){
    nd <- nrow(dat)


    dat$grp <- paste(1:nd)


    clusdat <- dat

    while (nrow(clusdat) > k){
        dd <- dist(clusdat[,-ncol(clusdat)])

        ndd <- nrow(clusdat)

        locs <- getminfromdistmat(dd, ndd)

        frowstr <- clusdat$grp[locs[1]]
        strowstr <- clusdat$grp[locs[2]]

        newstr <- paste(frowstr, strowstr, sep = ", ")

        myavg <- data.frame(t(colSums(clusdat[locs,-ncol(clusdat)]) / 2))

        newclus <- cbind(myavg, grp = newstr)

        clusdat <- clusdat[-locs,]

        clusdat <- rbind(newclus,clusdat)
    }

    return(clusdat$grp)

}


