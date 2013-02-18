#### Note
* t is sample size which is splited by K knots between 1 and endpoint e. 
 Note that K is the number of knots (number of rows) you set in sidebar, 
 and e is the endpoint sample size for extrapolation; default K is 40 and e is double reference sample size.
* St is the estimated rarefaction/prediction richness function with sample size t
* Ct is the estimated rarefaction/prediction sample coverage function with sample size t
* St.LCL and St.UCL is 95% bootstrap confidence lower and upper limits for St
* Ct.LCL and Ct.UCL is 95% bootstrap confidence lower and upper limits for Ct