###############################################################################################
## Testing for Stationarity : 
## Bandyopadhyay, S., & Rao, S. S. (2017). A test for stationarity for irregularly spaced spatial data. Journal of the Royal Statistical Society. Series B (Statistical Methodology), 79(1), 95–123.
###############################################################################################
print("***************************************************")
print("")
rm(list = ls())
args = commandArgs(trailingOnly=TRUE)
file_path = args[1]
setwd(file_path)

library(MASS)
library(fields)


##########################
## SOURCING OTHER FILES ##
##########################

source("src/R_scripts/code-data/A-hat-fn.r")

source("src/R_scripts/code-data/v-fn.r")

source("src/R_scripts/code-data/r-grd-fn.r")

R.GRD.list = r.grd.fn(1:5)

r1 = R.GRD.list[[1]]
r2 = R.GRD.list[[2]]
r3 = R.GRD.list[[3]]
r4 = R.GRD.list[[4]]
r5 = R.GRD.list[[5]]

r.grd = rbind(r1,r2,r3,r4,r5)


L1 = length(c(R.GRD.list[[1]]))

L2 = length(c(R.GRD.list[[2]]))


set.seed(100)
u.vec = rep(0, 10000)

for(i in c(1:10000))
  
{
  
  t1 = matrix(rnorm(L1),ncol=2)
  
  t2 = rnorm(L2)
  
  
  v2 = sd(c(t2))
  
  t12.std = t1/v2
  
  u.vec[i] = max(apply(t12.std^2,1,sum))
}


a.coeff.fn = function(dat.vec, loc.mat)
{
  
  lam.1 = max(loc.mat[,1])- min(loc.mat[,1])
  lam.2 = max(loc.mat[,2])- min(loc.mat[,2])
  lam.vec = c(lam.1, lam.2)
  
  n = length(dat.vec)                                                  # The number of observations
  trun.val = 0.5*floor(sqrt(n))                                        # this is te term 'a' according to our paper
  # We take a = 0.5*\sqrt{n}
  
  
  ave.space = sqrt(lam.1*lam.2)/sqrt(n)
  
  
  v.vec = seq(-ave.space, ave.space, length = 5)
  v.vec = v.vec+c(0,0,0.001,0,0)
  
  v.grd.list = list(x = v.vec, y = v.vec)
  v.grd = make.surface.grid(v.grd.list)
  
  # ind.v keeps only the one image of the coordinates, not the mirror image.
  ind.v = c(1,2,3,4,5,6,7,8,9,10,13,14,15)
  
  v.grd = v.grd[ind.v,]
  
  ###################################
  # Calculation of the coefficients #
  ###################################
  
  A.1 = A.hat.fn(lam.vec = lam.vec, loc.mat = loc.mat, dat.vec = dat.vec, r.mat = r1, v.mat = v.grd, a.val = trun.val, mean.corr = T, nugget.rm = T)
  A.2 = A.hat.fn(lam.vec = lam.vec, loc.mat = loc.mat, dat.vec = dat.vec, r.mat = r2, v.mat = v.grd, a.val = trun.val, mean.corr = T, nugget.rm = T)
  A.3 = A.hat.fn(lam.vec = lam.vec, loc.mat = loc.mat, dat.vec = dat.vec, r.mat = r3, v.mat = v.grd, a.val = trun.val, mean.corr = T, nugget.rm = T)
  A.4 = A.hat.fn(lam.vec = lam.vec, loc.mat = loc.mat, dat.vec = dat.vec, r.mat = r4, v.mat = v.grd, a.val = trun.val, mean.corr = T, nugget.rm = T)
  A.5 = A.hat.fn(lam.vec = lam.vec, loc.mat = loc.mat, dat.vec = dat.vec, r.mat = r5, v.mat = v.grd, a.val = trun.val, mean.corr = T, nugget.rm = T)
  
  A.test.stat = A.1
  A.se.est = A.2
  
  sd.est = sd(c(A.se.est))
  
  T.std = round(A.test.stat/sd.est,2)
  
  val = max(apply(T.std^2,1,sum))
  # print(paste("T(S,S'): ",val, sep = ""))
  
  ## - p-value calculations - ##
  
  p.val = mean(u.vec > val)
  
  return(p.val)
}

count = 0
for(i in 1:100){
  loc.mat = as.matrix(read.csv(paste0("stationary_test/LOC_",i,".csv")
                               , header = F))
  dat.vec = read.csv(paste0("stationary_test/Z_",i,".csv"), 
                     header = F)
  dat.vec = dat.vec$V1
  
  p.val = a.coeff.fn(dat.vec,loc.mat)
  if(p.val > 0.05){
    count = count + 1
  }
}
accuracy1 = count/100

count = 0
for(i in 1:100){
  loc.mat = as.matrix(read.csv(paste0("nonstationary_test/LOC_",i,".csv")
                               , header = F))
  dat.vec = read.csv(paste0("nonstationary_test/Z_",i,".csv"), 
                     header = F)
  dat.vec = dat.vec$V1
  
  p.val = a.coeff.fn(dat.vec,loc.mat)
  if(p.val < 0.05){
    count = count + 1
  }
}
accuracy2 = count/100
print("Test of Stationarity for the stationary and non-stationary test datasets 
      based on the test statistic defined in Bandyopadhyay, S., & Rao, S. S. (2017).")
print("We calculate the accuracy by checking whether the p-value is greater than 0.05 or not.")
print("")
print(paste("Stationary test dataset Accuracy :", accuracy1,"%"))
print(paste("Non-stationary test dataset Accuracy :", accuracy2,"%"))
print("")
print("***************************************************")
