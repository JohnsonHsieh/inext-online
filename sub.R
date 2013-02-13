
myplot1 <- function(out) {
  temp1 <- matrix(0, ncol=2, nrow=length(out))
  temp2 <- matrix(0, ncol=2, nrow=length(out))
  for(i in seq_along(out)){
    temp1[i,] <- range(out[[i]]$D0.hat[,1])
    temp2[i,] <- range(out[[i]]$D0.hat[,-c(1, ncol(out[[i]]$D0.hat))])
  }
  range.x <- range(temp1)
  range.y <- range(temp2)
  plot(1, type="n", xlim=range.x, ylim=range.y, xlab="Number of individuals", ylab="Richness")
  for(i in seq_along(out)){
    par(new=TRUE, pch=16)
    plot.iNEXT(out[[i]]$D0.hat, axes=FALSE, xlab="", ylab="", xlim=range.x, ylim=range.y, col=i)
  }
}


myplot2 <- function(out) {
  temp1 <- matrix(0, ncol=2, nrow=length(out))
  temp2 <- matrix(0, ncol=2, nrow=length(out))
  for(i in seq_along(out)){
    temp1[i,] <- range(out[[i]]$C.hat[,1])
    temp2[i,] <- range(out[[i]]$C.hat[,-1])
  }
  range.x <- range(temp1)
  range.y <- range(temp2)
  plot(1, type="n", xlim=range.x, ylim=range.y, xlab="Number of individuals", ylab="Sample coverage")
  for(i in seq_along(out)){
    par(new=TRUE, pch=16)
    plot.iNEXT(out[[i]]$C.hat, axes=FALSE, xlab="", ylab="",  xlim=range.x, ylim=range.y, col=i)
  }
}

myplot3 <- function(out){
  temp1 <- matrix(0, ncol=2, nrow=length(out))
  temp2 <- matrix(0, ncol=2, nrow=length(out))
  myout <- list()
  for(i in seq_along(out)){
    temp <- out[[i]]$D0.hat
    temp[,1] <- temp[,ncol(temp)]
    temp1[i,] <- range(temp[,1])
    temp2[i,] <- range(temp[,-c(1,ncol(temp))])
    myout[[i]] <- temp
  }
  range.x <- range(temp1)
  range.y <- range(temp2)
  plot(1, type="n", xlim=range.x, ylim=range.y , xlab="Sample coverage", ylab="Richness")
  for(i in seq_along(out)){
    par(new=TRUE, pch=16)
    plot.iNEXT(myout[[i]], axes=FALSE, xlab="", ylab="",  xlim=range.x, ylim=range.y , col=i)
  }
}