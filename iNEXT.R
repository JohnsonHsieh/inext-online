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
  colnames(out) <- c("n", "S.obs", "S.hat", "C.hat", paste("f",1:10, sep=""))
  as.data.frame(out, row.names="")
}


summary.Sam <- function(dat){
  Fun <- function(x){
    nT <- x[1]
    x <- x[-1]
    U <- sum(x)
    Qk <- sapply(1:10, function(k) sum(x==k))
    Q1 <- Qk[1]
    Q2 <- Qk[2]
    Sobs <- sum(x>0)
    f0hat <- (nT-1)/nT*ifelse(Q2>0, Q1^2/(2*Q2), Q1*(Q1-1)/2)
    Shat <- Sobs + round(f0hat, 2)
    Chat <- round(1 - Q1/U*(nT-1)*Q1/((nT-1)*Q1+2*max(Q2,0)),4)
    out <- c(nT, U, Sobs, Shat, Chat, Qk)
    #colnames(out) <- c("T", "U", "Sobs", "Shat", "Chat", paste("Q",1:10, sep=""))
    out
  }
  out <- t(apply(as.matrix(dat), 2, Fun))
  colnames(out) <- c("T", "U", "S.obs", "S.hat", "C.hat", paste("Q",1:10, sep=""))
  as.data.frame(out)
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
conf.reg=function(x,LCL,UCL,...) {
  x <- sort(x)
  LCL <- sort(LCL)
  UCL <- sort(UCL)
  polygon(c(x,rev(x)),c(LCL,rev(UCL)), ...)
}


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
  n <- sum(Spec)        #sample size
  f1 <- sum(Spec == 1)   #singleton 
  f2 <- sum(Spec == 2) 	#doubleton
  A <- (n-1)*f1/((n-1)*f1+2*max(f2,0))
  a <- ifelse(f1 == 0, 0, (n - 1) * f1 / ((n - 1) * f1 + 2 * f2) * f1 / n)
  b <- sum(Spec / n * (1 - Spec / n) ^ n)
  w <- a / b  			#adjusted factor for rare species in the sample
  f0.hat <- ceiling(ifelse(f2 == 0, (n - 1) / n * f1 * (f1 - 1) / 2, (n - 1) / n * f1 ^ 2/ 2 / f2))	#estimation of unseen species via Chao1
  Prob.hat <- Spec / n * (1 - w * (1 - Spec / n) ^ n)					#estimation of relative abundance of observed species in the sample
  #Prob.hat.Unse <- rep(2 * f2/((n - 1) * f1 + 2 * f2), f0.hat)		#estimation of relative abundance of unseen species in the sample
  Prob.hat.Unse <- rep(f1/n*A/f0.hat, f0.hat)  	#estimation of relative abundance of unseen species in the sample
  return(c(Prob.hat, Prob.hat.Unse))									#Output: a vector of estimated relative abundance
}


##
##
###########################################
## Function of estimating sample-based "bootstrap community" in order to obtain estimated bootstrap s.e.
## Input is Spec, a vector of species abundances
## Input is T, number of samples
## Output, a vector of estimated detection probability
##
##
EstiBootComm.Sam <- function(Spec)
{
  nT <- Spec[1]
  Spec <- Spec[-1]
  Sobs <- sum(Spec > 0) 	#observed species
  Q1 <- sum(Spec == 1) 	#singleton 
  Q2 <- sum(Spec == 2) 	#doubleton
  A <- (nT-1)*Q1/((nT-1)*Q1+2*max(Q2,0))
  a <- ifelse(Q1 == 0, 0, (nT - 1) * Q1 / ((nT - 1) * Q1 + 2 * Q2) * Q1 / nT)
  b <- sum(Spec / nT * (1 - Spec / nT) ^ nT)
  w <- a / b  			#adjusted factor for rare species in the sample
  Q0.hat <- ceiling(ifelse(Q2 == 0, (nT - 1) / nT * Q1 * (Q1 - 1) / 2, (nT - 1) / nT * Q1 ^ 2/ 2 / Q2))	#estimation of unseen species via Chao2
  Prob.hat <- Spec / nT * (1 - w * (1 - Spec / nT) ^ nT)					#estimation of detection probability of observed species in the sample
  #Prob.hat.Unse <- rep(2 * Q2/((nT - 1) * Q1 + 2 * Q2), Q0.hat)		#estimation of detection probability of unseen species in the sample
  Prob.hat.Unse <- rep(Q1/nT*A/Q0.hat, Q0.hat)  	#estimation of detection probability of unseen species in the sample
  return(c(Prob.hat,  Prob.hat.Unse))									#Output: a vector of estimated detection probability
}


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


D0hat.Sam <- function(y, t){
  nT <- y[1]
  y <- y[-1]
  y <- y[y > 0]
  U <- sum(y)
  Sub <- function(t){
    if(t <= nT){
      Fun <- function(y){
        if(y <= (nT - t)) exp(lgamma(nT - y + 1) + lgamma(nT - t + 1) - lgamma(nT - y - t + 1) - lgamma(nT + 1))
        else 0
      }
      sum(1 - sapply(y, Fun))
    }
    else {
      Sobs <- sum(y > 0)
      Q1 <- sum(y==1)
      Q2 <- sum(y==2)
      A <- ifelse(Q2 > 0, (nT-1)*Q1/((nT-1)*Q1+2*Q2), (nT-1)*Q1/((nT-1)*Q1+2))
      C.hat <- 1 - Q1 / U * A
      Q0.hat <- ifelse(Q2 > 0, Q1^2 /(2 * Q2), Q1 * (Q1 - 1) / 2)
      ifelse(Q1 ==0, Sobs ,Sobs + Q0.hat * (1 - (1 - Q1 / (nT * Q0.hat + Q1)) ^ (t - nT)))  
    }
  }
  sapply(t, Sub)
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
## Estimation of sample-based sample coverage function
## Input is y, a vector of species incidence-based frequency
## Input is T, number of samples
## Input is t, a integer vector of rarefaction/extrapolation sample size
## Output, a vector of estimated sample coverage function
##
##
Chat.Sam <- function(Spec, t){
  nT <- Spec[1]
  y <- Spec[-1]
  y <- y[y>0]
  U <- sum(y)
  Q1 <- sum(y == 1)
  Q2 <- sum(y == 2)
  A <- ifelse(Q2 > 0, (nT-1)*Q1/((nT-1)*Q1+2*Q2), (nT-1)*Q1/((nT-1)*Q1+2))
  Sub <- function(t){
    if(t < nT) out <- 1 - sum(y / U * exp(lchoose(nT - y, t) - lchoose(nT - 1, t)))
    if(t == nT) out <- 1 - Q1 / U * A
    if(t > nT) out <- 1 - Q1 / U * A^(t - nT + 1)
    out
  }
  sapply(t, Sub)		
}


##
##
###############################################
## Main program for individual-based data
## Input is Spec, a vector of species abundances
## Input is endpoint, a endpoint for extrapolation, default is double the reference sample size
## Input is Knots, a number of knots of computation, default is 40
## Input is rd, rounds the values to the specified number of decimal places, default is tens (-1) and other suggested argument is units (0) or hundreds (-2)
## Input is sd, calculate bootstrap standard error and 95% confidence interval; default is TRUE
## Input is nboot, the number of bootstrap resampling times, default is 200
## Output, a list of interpolation and extrapolation Hill number with order 0, 1, 2 and sample coverage 
##
##
iNEXT.Ind <- function(Spec, endpoint=2*sum(Spec), Knots=40, se=TRUE, nboot=50)
{
  n <- sum(Spec)  	  	#sample size
  m <- c(floor(seq.int(1, sum(Spec)-1, length=floor(Knots/2)-1)), sum(Spec), floor(seq.int(sum(Spec)+1, to=endpoint, length=floor(Knots/2))))
  m <- c(1, m[-1])      
  D0.hat <- D0hat.Ind(Spec, m)
  C.hat <- Chat.Ind(Spec, m)
  if(se==TRUE & nboot > 0)
  {
    Prob.hat <- EstiBootComm.Ind(Spec)
    Abun.Mat <- rmultinom(nboot, n, Prob.hat)
    
    error.0 <-  qnorm(0.975) * apply(apply(Abun.Mat, 2, function(x) D0hat.Ind(x, m)), 1, sd, na.rm=TRUE)
    left.0  <- D0.hat - error.0
    right.0 <- D0.hat + error.0
    
    
    error.C <-  qnorm(0.975) * apply(apply(Abun.Mat, 2, function(x) Chat.Ind(x, m)), 1, sd, na.rm=TRUE)
    left.C  <- C.hat - error.C
    right.C <- C.hat + error.C
    
    
    out.0 <- cbind("m"=m, "D0.hat"=D0.hat, "95%LCL"=left.0, "95%UCL"=right.0, "C.hat"=C.hat)
    out.C <- cbind("m"=m, "C.hat"=C.hat, "95%LCL"=left.C, "95%UCL"=right.C)
    out <- data.frame(m, D0.hat, left.0, right.0, C.hat, left.C, right.C)
    colnames(out) <- c("m", "Sm", "Sm.LCL", "Sm.UCL", "Cm", "Cm.LCL", "Cm.UCL")
  }
  else
  {
    #out <- list("D0.hat"=cbind("m"=m, "D0.hat"=D0.hat, "C.hat"=C.hat), "C.hat"=cbind("m"=m, "C.hat"=C.hat))
    out <- data.frame("m"=m, "Sm"=D0.hat, "Cm"=C.hat)
  }
  return(out)
}


##
##
###############################################
## Main program for individual-based data
## Input is Spec, a vector of species incidence-based frequency
## Input is T, number of samples
## Input is endpoint, a endpoint for extrapolation, default is double the reference sample size
## Input is Knots, a number of knots of computation, default is 40
## Input is rd, rounds the values to the specified number of decimal places, default is units (0) and other suggested argument is tens (-1) or hundreds (-2)
## Input is sd, calculate bootstrap standard error and 95% confidence interval; default is TRUE
## Input is nboot, the number of bootstrap resampling times, default is 200
## Output, a list of interpolation and extrapolation Hill number with order 0, 1, 2 and sample coverage 
##
##
iNEXT.Sam <- function(Spec, endpoint=2*Spec[1], Knots=40, se=TRUE, nboot=50)
{
  nT <- Spec[1]
  t <- c(floor(seq.int(1, nT-1, length=floor(Knots/2)-1)), nT, floor(seq.int(nT+1, to=endpoint, length=floor(Knots/2))))
  t <- c(1, t[-1])
  D0.hat <- D0hat.Sam(Spec, t) 
  C.hat <- Chat.Sam(Spec, t)
  if(se==TRUE & nboot > 0)
  {
    Prob.hat <- EstiBootComm.Sam(Spec)
    Abun.Mat <- t(sapply(Prob.hat, function(p) rbinom(nboot, nT, p)))
    Abun.Mat <- matrix(c(rbind(nT, Abun.Mat)),ncol=nboot)
    
    error.0 <-  qnorm(0.975) * apply(apply(Abun.Mat, 2, function(y) D0hat.Sam(y, t)), 1, sd, na.rm=TRUE)
    left.0  <- D0.hat - error.0
    right.0 <- D0.hat + error.0
    
    
    error.C <-  qnorm(0.975) * apply(apply(Abun.Mat, 2, function(y) Chat.Sam(y, t)), 1, sd, na.rm=TRUE)
    left.C  <- C.hat - error.C
    right.C <- C.hat + error.C
    
    
    #out.0 <- cbind("t"=t, "D0.hat"=D0.hat, "95%LCL"=left.0, "95%UCL"=right.0, "C.hat"=C.hat)
    #out.C <- cbind("t"=t, "C.hat"=C.hat, "95%LCL"=left.C, "95%UCL"=right.C)
    #out <- list("D0.hat"=out.0, "C.hat"=out.C)
    out <- data.frame(t, D0.hat, left.0, right.0, C.hat, left.C, right.C)
    colnames(out) <- c("t", "St", "St.LCL", "St.UCL", "Ct", "Ct.LCL", "Ct.UCL")
  }
  else
  {
    #out.0 <- cbind("t"=t, "D0.hat"=D0.hat, "C.hat"=C.hat)
    #out.C <- cbind("t"=t, "C.hat"=C.hat)
    #out <- list("D0.hat"=out.0, "C.hat"=out.C)
    out <- data.frame("t"=t, "St"=D0.hat, "Ct"=C.hat)
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
  plot(0, type="n", xlim=xlim, ylim=ylim, xlab=xlab, ylab=ylab,...)
  if(ncol(out) == 4){
    conf.reg(out[,1], out[,3], out[,4], col=adjustcolor(col, 0.25), border=NA)
  }
  lines(Inte, lty=1, lwd=2, col=col)
  lines(Extr, lty=2, lwd=2, col=col)
  points(Inte[ref,], pch=16, cex=1.5, col=col)
}

##
##
###########################################
## Example individual-based data, spiders abundance data collected by Sackett et al. (2011)
##
##
#Girdled <- c(46, 22, 17, 15, 15, 9, 8, 6, 6, 4, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
#Logged <- c(88, 22, 16, 15, 13, 10, 8, 8, 7, 7, 7, 5, 4, 4, 4, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)

##
##
###########################################
## Example sample-based data, tropical ant species data collected by Longino and Colwell (2011)
## Note that first cell is number of total samples, and others are species incidence-based frequency.
##

## 50m
y50 <- c(599,rep(1,49),rep(2,23),rep(3,18),rep(4,14),rep(5,9),rep(6,10),rep(7,4),
         rep(8,8),rep(9,6),rep(10,2),rep(11,1),12,12,13,13,rep(14,5),15,15,
         rep(16,4),17,17,17,18,18,19,19,20,20,20,21,22,23,23,25,27,27,29,30,30,
         31,33,39,40,43,46,46,47,48,51,52,52,56,56,58,58,61,61,65,69,72,77,79,82,
         83,84,86,91,95,97,98,98,106,113,124,126,127,128,129,129,182,183,186,195,
         222,236,263,330)

##500m
y500 <- c(230,rep(1,71),rep(2,34),rep(3,12),rep(4,14),rep(5,9),rep(6,11),rep(7,8),
          rep(8,4),rep(9,7),rep(10,5),rep(11,2),12,12,12,13,13,13,13,14,14,15,
          16,16,17,17,17,17,18,19,20,21,21,23,24,25,25,25,26,27,30,31,31,32,32,
          33,34,36,37,38,38,38,38,39,39,41,42,43,44,45,46,47,49,52,52,53,54,56,
          60,60,65,73,78,123,131,133)

##1070m
y1070 <- c(150,rep(1,28),rep(2,16),rep(3,13),rep(4,3),rep(5,1),rep(6,3),rep(7,6),
           rep(8,1),rep(9,1),rep(10,1),rep(11,4),12,12,12,13,13,13,13,14,15,
           16,16,16,16,18,19,19,21,22,23,24,25,25,25,26,30,31,31,31,32,34,36,
           38,39,43,43,45,45,46,54,60,68,74,80,96,99)
##1500m
y1500 <- c(200,rep(1,13),rep(2,4),rep(3,2),rep(4,2),rep(5,4),rep(6,2),rep(9,4),
           rep(11,2),rep(17,2),18,19,23,23,24,25,25,25,29,30,32,33,43,50,53,
           73,74,76,79,113,144)

##2000m
y2000=c(200,1,2,2,3,4,8,8,13,15,19,23,34,59,80)


##
saveList2csv <- function(out, file) {
  for (i in seq_along(out)){
    write.table(names(out)[i], file=file, sep=",", dec=".", 
                quote=FALSE, col.names=FALSE, row.names=FALSE, append=TRUE)  #writes the name of the list elements
    write.table(out[[i]], file=file, sep=",", dec=".", quote=FALSE, 
                col.names=NA, row.names=TRUE, append=TRUE)  #writes the data.frames
  }
}

##
##
##
###############################################
## Estimation of individual-based sample coverage function
## Input is x, a vector of species abundances
## Input is m, a integer vector of rarefaction/extrapolation sample size
## Output, a vector of estimated sample coverage function
##
##
InvChat.Ind <- function(x, sc)
{
  x <- x[x>0]
  n <- sum(x)
  f1 <- sum(x == 1)
  f2 <- sum(x == 2)
  A <- ifelse(f2 > 0, (n-1)*f1/((n-1)*f1+2*f2), (n-1)*f1/((n-1)*f1+2))
  Chat <- 1 - f1/n*A
  Sub <- function(sc){
    if(Chat == 1) {
      mhat <- n
    } else if(sc < Chat) {
      f <- function(m) { 1-sum(x / n * exp(lchoose(n - x, m)-lchoose(n - 1, m))) - sc}
      #f <- function(m) { 1-sum(x / n * exp(mylbeta(n - m, m)-mylbeta(n - m - x + 1, m))) - sc}
      mhat <- ceiling (uniroot(f, lower=1, upper=n-1)$root)      
    } else {
      mhat <- ceiling (log((1-sc)*n/f1)/log(A) - 1 + n)
    } 
    mhat
  }
  options(warn=-1)
  out <- sapply(sc, Sub)    
  options(warn=1)
  out
}

InvChat.Sam <- function(Spec, sc)
{
  nT <- Spec[1]
  y <- Spec[-1]
  y <- y[y>0]
  U <- sum(y)
  Q1 <- sum(y == 1)
  Q2 <- sum(y == 2)
  A <- ifelse(Q2 > 0, (nT-1)*Q1/((nT-1)*Q1+2*Q2), (nT-1)*Q1/((nT-1)*Q1+2))
  Chat <- 1 - Q1/U*A
  if(Chat == 1){
    t <- nT  
  } else if(Chat > sc){
    t <- which.min(abs(Chat.Sam(Spec,1:nT)-sc))
  } else {
    t <- ceiling (log((1-sc)*U/Q1)/log(A) - 1 + nT)
  }
  t
}


library(compiler)
iNEXT.Ind <- cmpfun(iNEXT.Ind)
iNEXT.Sam <- cmpfun(iNEXT.Sam)