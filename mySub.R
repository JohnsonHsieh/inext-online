summary.Ind <- function(dat){
  Fun <- function(x){
    n <- sum(x)
    fk <- sapply(1:10, function(k) sum(x==k))
    f1 <- fk[1]
    f2 <- fk[2]
    Sobs <- sum(x>0)
    f0hat <- ifelse(f2>0, f1^2/(2*f2), f1*(f1-1)/2)
    Shat <- Sobs + round(f0hat, 2)
    Chat <- round(1 - f1/n*(n-1)*f1/((n-1)*f1+2*max(f2,0)),4)
    c(n, Sobs, Shat, Chat, fk)
  }
  out <- t(apply(as.matrix(dat), 2, Fun))
  colnames(out) <- c("n", "Sobs", "Shat", "Chat", paste("f",1:10, sep=""))
  t(as.data.frame(t(out)))
}


summary.Sam <- function(dat){
  Fun <- function(x){
    T <- x[1]
    x <- x[-1]
    U <- sum(x)
    Qk <- sapply(1:10, function(k) sum(x==k))
    Q1 <- Qk[1]
    Q2 <- Qk[2]
    Sobs <- sum(x>0)
    f0hat <- (T-1)/T*ifelse(Q2>0, Q1^2/(2*Q2), Q1*(Q1-1)/2)
    Shat <- Sobs + round(f0hat, 2)
    Chat <- round(1 - Q1/U*(T-1)*Q1/((T-1)*Q1+2*max(Q2,0)),4)
    c(T, U, Sobs, Shat, Chat, Qk)
  }
  out <- apply(as.matrix(dat), 2, Fun)
  colnames(out) <- c("T", "U", "Sobs", "Shat", "Chat", paste("Q",1:10, sep=""))
  t(as.data.frame(t(out)))
  
}

##
##
###########################################
## SubFunction of plot confidence band.
## Input is x, a vector of mean
## Input is LCL, a vector of lower bound
## Input is UCL, a vector of upper bound
## Output, plot a confidence band
##
##
conf.reg=function(x,LCL,UCL,...) polygon(c(x,rev(x)),c(LCL,rev(UCL)), ...)

##
##
###########################################
## Function of estimating individual-based "bootstrap community" in order to obtain estimated bootstrap s.e.
## Input is Spec, a vector of species abundances
## Output, a vector of estimated relative abundance
##
##
EstiBootComm.Ind <- function(Spec)
{
  Sobs <- sum(Spec > 0)   #observed species
  n <- sum(Spec)		  	#sample size
  f1 <- sum(Spec == 1) 	#singleton 
  f2 <- sum(Spec == 2) 	#doubleton
  a <- ifelse(f1 == 0, 0, (n - 1) * f1 / ((n - 1) * f1 + 2 * f2) * f1 / n)
  b <- sum(Spec / n * (1 - Spec / n) ^ n)
  w <- a / b  			#adjusted factor for rare species in the sample
  f0.hat <- ceiling(ifelse(f2 == 0, (n - 1) / n * f1 * (f1 - 1) / 2, (n - 1) / n * f1 ^ 2/ 2 / f2))	#estimation of unseen species via Chao1
  Prob.hat <- Spec / n * (1 - w * (1 - Spec / n) ^ n)					#estimation of relative abundance of observed species in the sample
  Prob.hat.Unse <- rep(2 * f2/((n - 1) * f1 + 2 * f2), f0.hat)		#estimation of relative abundance of unseen species in the sample
  return(c(Prob.hat, Prob.hat.Unse))									#Output: a vector of estimated relative abundance
}

##
##
###########################################
## Estimation of interpolation and extrapolation of individual-based richness
## Input is x, a vector of species abundances
## Input is m, a integer vector of rarefaction/extrapolation sample size
## Output, a vector of estimated interpolation and extrapolation function of richness
##
##

D0hat.Ind <- function(x, m){
  x <- x[x > 0]
  n <- sum(x)
  Sub <- function(m){
    if(m <= n){
      Fun <- function(x){
        if(x <= (n - m)) exp(lgamma(n - x + 1) + lgamma(n - m + 1) - lgamma(n - x - m + 1) - lgamma(n + 1))
        else 0
      }
      sum(1 - sapply(x, Fun))
    }
    else {
      Sobs <- sum(x > 0)
      f1 <- sum(x == 1)
      f2 <- sum(x == 2)
      f0.hat <- ifelse(f2 > 0, f1^2 /(2 * f2), f1 * (f1 - 1) / 2)
      ifelse(f1 ==0, Sobs ,Sobs + f0.hat * (1 - (1 - f1 / (n * f0.hat + f1)) ^ (m - n)))	
    }
  }
  sapply(m, Sub)
}


##
##
###############################################
## Estimation of individual-based sample coverage function
## Input is x, a vector of species abundances
## Input is m, a integer vector of rarefaction/extrapolation sample size
## Output, a vector of estimated sample coverage function
##
##
Chat.Ind <- function(x, m)
{
  x <- x[x>0]
  n <- sum(x)
  f1 <- sum(x == 1)
  f2 <- sum(x == 2)
  A <- ifelse(f2 > 0, (n-1)*f1/((n-1)*f1+2*f2), (n-1)*f1/((n-1)*f1+2))
  Sub <- function(m){
    if(m < n) out <- 1-sum(x / n * exp(lchoose(n - x, m)-lchoose(n - 1, m)))
    if(m == n) out <- 1-f1/n*A
    if(m > n) out <- 1-f1/n*A^(m-n+1)
    out
  }
  sapply(m, Sub)		
}

##
##
###############################################
## Main program for individual-based data
## Input is Spec, a vector of species abundances
## Input is endpoint, a endpoint for extrapolation, default is double the reference sample size
## Input is Knots, a number of knots of computation, default is 40
## Input is se, calculate bootstrap standard error and 95% confidence interval; default is TRUE
## Input is nboot, the number of bootstrap resampling times, default is 200
## Output, a list of interpolation and extrapolation Hill number with order 0, 1, 2 and sample coverage 
##
##
iNEXT.Ind <- function(Spec, endpoint=2*sum(Spec), Knots=40, se=TRUE, nboot=200)
{
  n <- sum(Spec)		  	#sample size
  m <- c(round(seq(1, sum(Spec)-1, length=floor(Knots/2)-1)), sum(Spec), round(seq(sum(Spec)+1, endpoint, length=floor(Knots/2))))
  m <- c(1, m[-1])      
  D0.hat <- D0hat.Ind(Spec, m)
  C.hat <- Chat.Ind(Spec, m)
  if(se==TRUE)
  {
    Prob.hat <- EstiBootComm.Ind(Spec)
    Abun.Mat <- rmultinom(nboot, n, Prob.hat)
    
    error.0 <-  qnorm(0.975) * apply(apply(Abun.Mat, 2, function(x) D0hat.Ind(x, m)), 1, sd, na.rm=TRUE)
    left.0  <- D0.hat - error.0
    right.0 <- D0.hat + error.0
    
    
    error.C <-  qnorm(0.975) * apply(apply(Abun.Mat, 2, function(x) Chat.Ind(x, m)), 1, sd, na.rm=TRUE)
    left.C  <- C.hat - error.C
    right.C <- C.hat + error.C
    
    
    out.0 <- cbind("m"=m, "D0.hat"=D0.hat, "Norm.CI.Low"=left.0, "Norm.CI.High"=right.0, "C.hat"=C.hat)
    out.C <- cbind("m"=m, "C.hat"=C.hat, "Norm.CI.Low"=left.C, "Norm.CI.High"=right.C)
    out <- list("D0.hat"=out.0, "C.hat"=out.C)
  }
  else
  {
    out <- list("D0.hat"=cbind("m"=m, "D0.hat"=D0.hat, "C.hat"=C.hat))
  }
  return(out)
}

##
##
###########################################
## Function of drawing figure
## input is out, a data frame of interpolation and extrapolation output. First column is the vector for x-axis, second column is for y-axis, and last two columns are pointwise confidence interval.
##
##
plot.iNEXT <- function(out, xlab=colnames(out)[1], ylab=colnames(out)[2], xlim=range(out[,1]), ylim=range(out[,-1]), col=1, ...)
{
  ref <- floor(nrow(out)/2)
  Inte <- as.data.frame(out[1:ref, ])
  Extr <- as.data.frame(out[ref:nrow(out), ])
  Mat <- rbind(Inte, Extr)
  
  if(ncol(Mat) < 4)
  {
    plot(0, type="n", xlim=xlim, ylim=ylim, xlab=xlab, ylab=ylab,...)
    lines(Inte, lty=1, lwd=2, col=col)
    lines(Extr, lty=2, lwd=2, col=col)
    points(Inte[ref,], pch=16, cex=1.5)		
  }
  
  else
  {
    conf.reg=function(x,LCL,UCL,...) polygon(c(x,rev(x)),c(LCL,rev(UCL)), ...)	#SubFunction of plot confidence band.
    plot(0, type="n", xlim=xlim, ylim=ylim, xlab=xlab, ylab=ylab,...)
    conf.reg(Mat[,1], Mat$Norm.CI.Low, Mat$Norm.CI.High, col=adjustcolor(col, 0.25), border=NA)
    lines(Inte, lty=1, lwd=2, col=col)
    lines(Extr, lty=2, lwd=2, col=col)
    points(Inte[ref,], pch=16, cex=1.5, col=col)
  }
}


###############################################################
#
# MHmakeRandomString(n, length)
# function generates a random string random string of the
# length (length), made up of numbers, small and capital letters

RandomString <- function(lenght=12)
{
  randomString <- paste(sample(c(0:9, letters, LETTERS), lenght, replace=TRUE), collapse="")
  randomString <- paste(randomString,".RData", sep="")
  return(randomString)
}
