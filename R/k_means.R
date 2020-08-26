#'
#' Implements naive k means algorithm (optionally for first two principle componenets of a dataset)
#'
#' @param dat dataframe to perform clustering on
#' @param nk number of clusters
#' @param pca2 boolean whether or not to use pca
#'
#' @return A list object with groups by row, ss within, ss between, sstotal
#'
#' @import dplyr
#'
#' @export
#'


k_means <- function(dat, nk, pca2 = F) {

    if (pca2){
        dat <- data.frame((princomp(dat)$scores[,1:2]))
    }

    ndat <- nrow(dat)

    means <- dat[sample(ndat, nk),]

    dat$grp = 0

    iter = 0

    meandiff = 1

    while (meandiff > 0.01){
        iter = iter + 1

        for (j in 1:ndat){

            dists <- rep(0, nk)

            for (k in 1:nk){

                dists[k] <- sum((dat[j,-ncol(dat)] - means[k,])^2)

            }

            dat$grp[j] = which.min(dists)

        }

        oldmeans <- means

        means <- dat %>%
            group_by(grp) %>%
            arrange(grp) %>%
            summarize_all(mean) %>%
            select(-grp)

        meandiff <- sum((oldmeans - means)^2)
    }

    gm <- dat %>%
        select(-grp) %>%
        summarize_all(mean)

    sstotal <- sum(rowSums((dat[,-ncol(dat)] - as.list(gm))^2))

    sswithins <- rep(0, nk)

    for (l in 1:nk){

        sswithins[l] <- sum(rowSums((dat[dat[ncol(dat)] == l,-ncol(dat)] - as.list(means[l,]))^2))

    }

    tot.sswithin <- sum(sswithins)

    ssbetween <- sstotal - tot.sswithin

    return(list(means = means,
                assign = dat$grp,
                sstotal = sstotal,
                sswithin = sswithins,
                tot.sswithin = tot.sswithin,
                ssbetween = ssbetween,
                iter = iter))
}

