# THE FOLLOWING CODE CALCULATES THE TEST STATISTICS FOR A GIVEN DATA #

rm(list=ls(all=TRUE))

# setwd("C:/Users/sob210/Google Drive/research/Stationary-Test/Revision-2/code-data")

# ----------------------- #

# Loading the necessary Packages #

library(MASS)
library(fields)


##########################
## SOURCING OTHER FILES ##
##########################

source("A-hat-fn.r")

source("v-fn.r")

source("r-grd-fn.r")

############# EXAMPLE:  ##################

######################################
## - Creating r grid for the test - ##
######################################

# Example: In our simulation study we considered r = c(1,2) where
# A.hat[r.grd[1]] was used for the calculation of the test statistic, and
# A.hat[r.grd[2]] was used for the calculation of the standard error.

# The higher order r values are calculated for plotting purpose


R.GRD.list = r.grd.fn(1:5)

r1 = R.GRD.list[[1]]
r2 = R.GRD.list[[2]]
r3 = R.GRD.list[[3]]
r4 = R.GRD.list[[4]]
r5 = R.GRD.list[[5]]

r.grd = rbind(r1,r2,r3,r4,r5)


###########################################################
## - The following is samples coming according to the  - ##
## - distribution as in (5) in Bandyopadhyay and Subba - ##
## - Rao (2015)                                        - ##
###########################################################


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


# THE FOLLOWING FUNCTION CALCULATES THE TEST STATISTICS FOR A GIVEN DATA #

###############################################
## SUMMARY FUNCTION CALCULATING a.tilde AND  ##
## v.hat COEFFICIENTS.                       ##
###############################################

## The following gives \mathcal{T_{S, S'}} with the corresponding p-value ##
## It also plots the standardized A.hat coefficients                ##


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
           
## The following gives \mathcal{v_{S}} with the corresponding p-value ##
## It also plots the standardized v.hat coefficients                  ##

           

v.coeff.fn = function(dat.vec, loc.mat)
           {

           lam.1 = max(loc.mat[,1])- min(loc.mat[,1])
           lam.2 = max(loc.mat[,2])- min(loc.mat[,2])
           lam.vec = c(lam.1, lam.2)

           n = length(dat.vec)                                                  # The number of observations
           
           
           ###################################
           # Calculation of the coefficients #
           ###################################

           v1 = v.fn(lam.vec = lam.vec, loc.mat = loc.mat, dat.vec = dat.vec, r.mat = r1, mean.corr = F)
           v2 = v.fn(lam.vec = lam.vec, loc.mat = loc.mat, dat.vec = dat.vec, r.mat = r2, mean.corr = F)
           v3 = v.fn(lam.vec = lam.vec, loc.mat = loc.mat, dat.vec = dat.vec, r.mat = r3, mean.corr = F)
           v4 = v.fn(lam.vec = lam.vec, loc.mat = loc.mat, dat.vec = dat.vec, r.mat = r4, mean.corr = F)
           v5 = v.fn(lam.vec = lam.vec, loc.mat = loc.mat, dat.vec = dat.vec, r.mat = r5, mean.corr = F)


           v.test.stat = v1
           v.se.est = v2
           
           sd.est = sd(c(v.se.est))

           V.std = round(v.test.stat/sd.est,2)

           val = max(apply(V.std^2,1,sum))
           print(paste("V(S,S'): ",val, sep = ""))

           ## - p-value calculations - ##

           p.val = mean(u.vec > val)
           print(paste("P-value for V(S,S') is ",p.val, sep = ""))


           # standardized A.hat plot #

           # The following was done to make the range of the plot according to normal quantiles #

           alpha.vec = c(0.1, 0.05, 0.025, 0.01)
           zz = round(qt(1-alpha.vec/2,15),2)
           zz = sort(c(-zz,0,zz))


           max1 = max(v.test.stat[,1]/sd.est)
           max2 = max(v.test.stat[,2]/sd.est)
           max.all = max(max1, max2)

           min1 = min(v.test.stat[,1]/sd.est)
           min2 = min(v.test.stat[,2]/sd.est)
           min.all = min(min1, min2)

           if(min.all<zz[1])
                      {
                      aa = seq(min.all, zz[1], length = 2)
                      aa = aa[-3]
                      }else{aa = NA}

           if (max.all>zz[length(zz)])
                      {
                      bb = seq(zz[length(zz)], max.all, length = 2)
                      bb = bb[-1]
                      }else{bb = NA}

           zz = c(aa, zz, bb)
           zz = round(zz[!is.na(zz)],2)
           
           V.all = rbind(v1,v2,v3,v4,v5)


           set.panel(1,2)
           quilt.plot(r.grd, round(V.all[,1]/sd.est,2), main = "Real standardized v coefficients", breaks = zz, lab.breaks = zz, col = rainbow(length(zz)-1), zlim = c(min(zz), max(zz)), xlim = c(-5.5, 5.5), ylim = c(-0.5, 5.5))
           quilt.plot(r.grd, round(V.all[,2]/sd.est,2), main = "Imaginary standardized v coefficients", breaks = zz, lab.breaks = zz, col = rainbow(length(zz)-1), zlim = c(min(zz), max(zz)), xlim = c(-5.5, 5.5), ylim = c(-0.5, 5.5))


           }


########################
## OZONE DATA Example ##
########################

data(ozone2)

# For example, we have taken the 16th day. We have detrended it using the
# following.

tmp = 16

# In the following we got rid of the missing values from the spatial data #

good = !is.na(ozone2$y[tmp,])

x = ozone2$lon.lat[good,]
y = ozone2$y[tmp, good]

fit = Tps(x,y)

y = fit$residual

# Since our test only works for a square/ rectangular region so we took the largest
# rectangle contained in the actual sampling region. We took out the corresponding
# locations and observations which are only in that rectangle. The following
# code gives us that subset of data.

ind1 = (x[,1]> -92)
ind1 = which(ind1 == TRUE)

ind2 = ((x[,2]>38)&(x[,2]<44))
ind2 = which(ind2 == TRUE)

ind = intersect(ind1, ind2)

x.new = x[ind,]
y.new = y[ind]

######################################
## THIS IS THE DATASET TO WORK WITH ##
######################################

site = x.new
dat.vec = y.new



############################################
## Getting standardized a.tilde plot and  ##
## \mathcal{T_{S, S'}} with the p value   ##
############################################
           
a.coeff.fn(dat.vec, site)

############################################
## Getting standardized v.hat plot and    ##
## \mathcal{V_{S, S'}} with the p value   ##
############################################

v.coeff.fn(dat.vec, site)





