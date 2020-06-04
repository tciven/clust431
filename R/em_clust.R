
#'
#' IMplements EM algorithm for clustering data based on multivariate normal distributions
#'
#' @param dat dataframe to perform clustering on
#' @param k number of clusters
#'
#' @return A list object with the p, probabilities of the ith datapoint belonging to the jth group,
#' mu, a dataframe of the centers of the k multivariate normal sources, and sigma, the covariance matrices
#' of each of the mvn sources
#'
#' @import dplyr
#' @import mvtnorm
#' @import FNN
#'
#' @export
#'

em_clust <- function(dat, k){

    datl <- nrow(dat)
    datw <- ncol(dat)

    stpts <- sample(1:datl, k)

    centers <- dat[stpts,]

    probmat <- matrix(1/k, datl, k)

    conprob <- matrix(0, datl, k)

    covsamps <- list()
    covs <- list()

    tol <- .01

    cendiff <- 1

    for (cv in 1:k){
        neighbors <- get.knnx(dat, centers[cv,], datl %/% k)

        covsamps[[cv]] <- dat[neighbors$nn.index, ]

        covs[[cv]] <- cov(covsamps[[cv]])
    }


    dat <- as.matrix(dat)

    while (cendiff > tol) {

        for (j in 1:k){
            conprob[,j] <- dmvnorm(dat, t(centers[j,]), covs[[j]])
        }

        for (j in 1:k){
            probmat[,j] <- conprob[,j] * probmat[,j] / (conprob[,j] * probmat[,j] + rowSums(conprob[,-j] * probmat[,-j]))
        }

        oldcenters <- centers
        centers <- t(probmat) %*% dat / colSums(probmat)

        cendiff <- sum((abs(centers - oldcenters))) / length(centers)

        for (j in 1:k){
            cendat <- dat
            covs[[j]] <- matrix(0, datw, datw)

            for (l in 1:datl){
                cendat[l,] <- dat[l,] - centers[j,]
                covs[[j]] <- covs[[j]] + probmat[l,j] * cendat[l,] %*% t(cendat[l,])
            }

            covs[[j]] <- covs[[j]] / sum(probmat[,j])

        }
    }

    group <- apply(probmat, 1, which.max)

    return(list(group = group, p = probmat, mu = data.frame(centers), sigma = covs))

}

