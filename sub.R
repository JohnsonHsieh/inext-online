
myplot1 <- function(out) {
  temp1 <- matrix(0, ncol=2, nrow=length(out))
  temp2 <- matrix(0, ncol=2, nrow=length(out))
  data <- list()
  for(i in seq_along(out)){
    if(ncol(out[[i]])==3){
      data[[i]] <- out[[i]][,1:2]
      temp1[i,] <- range(data[[i]][,1])
      temp2[i,] <- range(data[[i]][,2])
    } else {
      data[[i]] <- out[[i]][,1:4]
      temp1[i,] <- range(data[[i]][,1])
      temp2[i,] <- range(data[[i]][,2:4])
    }
  }
  range.x <- range(temp1)
  range.y <- range(temp2)
  if(input$data_type == 'ind') xlab="Number of individuals"
  if(input$data_type == 'sam') xlab="Number of samples"
  plot(1, type="n", xlim=range.x, ylim=range.y, xlab=xlab, ylab="Richness")
  for(i in seq_along(out)){
    par(new=TRUE, pch=16)
    plot.iNEXT(data[[i]], axes=FALSE, xlab="", ylab="", xlim=range.x, ylim=range.y, col=i)
    
  }
}



myplot2 <- function(out) {
  temp1 <- matrix(0, ncol=2, nrow=length(out))
  temp2 <- matrix(0, ncol=2, nrow=length(out))
  data <- list()
  for(i in seq_along(out)){
    if(ncol(out[[i]])==3){
      data[[i]] <- out[[i]][,c(1,3)]
      temp1[i,] <- range(data[[i]][,1])
      temp2[i,] <- range(data[[i]][,2])
    } else {
      data[[i]] <- out[[i]][,c(1,5:7)]
      temp1[i,] <- range(data[[i]][,1])
      temp2[i,] <- range(data[[i]][,2:4])
    }
  }
  range.x <- range(temp1)
  range.y <- range(temp2)
  if(input$data_type == 'ind') xlab="Number of individuals"
  if(input$data_type == 'sam') xlab="Number of samples"
  plot(1, type="n", xlim=range.x, ylim=range.y, xlab=xlab, ylab="Sample coverage")
  for(i in seq_along(out)){
    par(new=TRUE, pch=16)
    plot.iNEXT(data[[i]], axes=FALSE, xlab="", ylab="", xlim=range.x, ylim=range.y, col=i)
    
  }
}

myplot3 <- function(out){
  temp1 <- matrix(0, ncol=2, nrow=length(out))
  temp2 <- matrix(0, ncol=2, nrow=length(out))
  data <- list()
  for(i in seq_along(out)){
    if(ncol(out[[i]])==3){
      data[[i]] <- out[[i]][,c(3,2)]
      temp1[i,] <- range(data[[i]][,1])
      temp2[i,] <- range(data[[i]][,2])
    } else {
      data[[i]] <- out[[i]][,c(5,2:4)]
      temp1[i,] <- range(data[[i]][,1])
      temp2[i,] <- range(data[[i]][,2:4])
    }
  }
  
  range.x <- range(temp1)
  range.y <- range(temp2)
  plot(1, type="n", xlim=range.x, ylim=range.y , xlab="Sample coverage", ylab="Richness")
  for(i in seq_along(out)){
    par(new=TRUE, pch=16)
    plot.iNEXT(data[[i]], axes=FALSE, xlab="", ylab="",  xlim=range.x, ylim=range.y , col=i)
    if(ncol(data[[i]])==4){
      conf.reg(data[[i]][,1], data[[i]][,3], data[[i]][,4], col=adjustcolor(i, 0.25), border=NA)
    }
  }
}