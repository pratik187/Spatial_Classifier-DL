rm(list = ls())
args = commandArgs(trailingOnly=TRUE)
file_path = args[1]
setwd(file_path)

library(geoR)
library(MASS)
library(fields)
mainDir <- "."
subDir <- "stationary_data/"
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)

mainDir <- "."
subDir <- "nonstationary_data/"
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)

mainDir <- "."
subDir <- "stationary_test/"
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)

mainDir <- "."
subDir <- "nonstationary_test/"
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)
# Generating stationary data 
num_sim = 10000
## Stationary Matern
set.seed(12345567)
x <- seq(0,1, length.out = 10)
y <- seq(0,1, length.out = 10)
d1 <- expand.grid(x = x, y = y)
m <- as.matrix(dist(d1))
s = seq(0.6,1.2,length.out = 100)
nu = seq(0.4,1,length.out = 100)
a = seq(0.02,0.4,length.out = 100)

for(i in 1:num_sim){
a1 = sample(a,1)
s1 = sample(s,1)
nu1 = sample(nu,1)
matern_cov = s1^2*matern(m,a1,nu1)
sim = mvrnorm(1,rep(0,100),matern_cov)

write.table(d1, file = paste0("stationary_data/LOC_",i,".csv"), sep = ",", 
            col.names = FALSE, row.names = F)
write.table(sim, file = paste0("stationary_data/Z_",i,".csv"), sep = ",", 
            col.names = FALSE, row.names = F)
}


## Generating nonstationary_data


co_ords = data.frame(X = d1$x, Y = d1$y)    # data frame of the co-ordinates
N = 100
# function for spatial range
lambda = function(u){
  return(0.04*exp(sin(0.5*pi*u[1])+sin(0.5*pi*u[2])))
} 
# vec_lam = rep(NA,100)
# for(i in 1:100){
#   vec_lam[i] = lambda(unlist(d1[i,]))
# }
# quilt.plot(d1$x,d1$y,vec_lam, nx = 10, ny = 10)
# function for partial sill

vec_sig = rep(NA,100)
sigma = function(u){
  return((0.33 * exp(-(u[1]+u[2]))) + 0.8)
} 
for(i in 1:100){
  vec_sig[i] = sigma(unlist(d1[i,]))
}

nu_vec = seq(0.4,1,length.out = 100)
a = seq(0.02,0.4,length.out = 100)
# quilt.plot(d1$x,d1$y,vec_sig, nx = 10, ny = 10)

# Function for smoothness 
# vec_nu = rep(NA,100)
nu = function(u){
  return(0.7 * exp(-0.5*(u[1]+u[2])) + 0.2)
}    
# for(i in 1:100){
#   vec_nu[i] = nu(unlist(d1[i,]))
# }
# quilt.plot(d1$x,d1$y,vec_nu, nx = 10, ny = 10)


# non stationary matern cov function

NS_matern = function(u1, u2){
  cap_sigma_i = lambda(u1)*diag(2)
  cap_sigma_j = lambda(u2)*diag(2)
  term1 = sigma(u1)*sigma(u2)*(sqrt(lambda(u1)))*(sqrt(lambda(u2)))
  
  term2 = 2/(lambda(u1)+lambda(u2))
  
  neuij = (nu(u1) + nu(u2))/2
  # neuij = 0.95
  Qij = term2* (((u1[1]-u2[1])^2) + ((u1[2]-u2[2])^2))
  prod1 = 2*sqrt(neuij * Qij)
  term3 = matern(prod1, 1, neuij)
  
  return(term1*term2*term3)
}            

# generating the matrix of order N X N 

NS_Cov_matrix = matrix(, nrow = N, ncol = N)

for(i in 1:N){
  for(j in i:N){
    u1 <- unlist(co_ords[i,],use.names = FALSE)
    u2 <- unlist(co_ords[j,],use.names = FALSE)
    
    value = NS_matern(u1,u2)
    NS_Cov_matrix[i,j] <- value
    NS_Cov_matrix[j,i] <- value
    
  }
  if(i %% 50 == 0){
    print("######################################")
    print(paste0("row ", i," is complt"))
    print("######################################")
  }
}  

for(i in 1:num_sim){
  if(i <= 8000){
    sim = mvrnorm(1,rep(0,N),NS_Cov_matrix)
  }
  else{
    a1 = sample(a,1)
    nu1 = sample(nu_vec,1)
    cov = matern(m,a1,nu1)
    sim = mvrnorm(1,rep(0,N),cov)
    sim = (vec_sig)^2 * sim
  }
  
  
  write.table(d1, file = paste0("nonstationary_data/LOC_",i,".csv"), sep = ",", 
              col.names = FALSE, row.names = F)
  write.table(sim, file = paste0("nonstationary_data/Z_",i,".csv"), sep = ",", 
              col.names = FALSE, row.names = F)
}




#### test sets #########

# spherical covariance 
num_sim = 100

a = seq(0.08,0.5,length.out = num_sim)
s = seq(0.6,1.2,length.out = num_sim)

for(sim in 1:num_sim){
  a1 = sample(a,1)
  s1 = sample(s,1)
  m1 = m/a1
  m1[m1>=1] = 0
  C = (s1^2)*(1 - (3/2)*m1 + (1/2)*m1^3)
  for(i in 1:N){
    for(j in 1:N){
      if(i!=j & C[i,j] == s1^2) C[i,j] = 0
    }
  }
  
  simulation = mvrnorm(1,rep(0,N),C)
  # quilt.plot(d1$x,d1$y, simulation, main =
  #              "variable 1", nx = 10, ny = 10)
  write.table(d1, file = paste0("stationary_test/LOC_",sim,".csv"), sep = ",", 
              col.names = FALSE, row.names = F)
  write.table(simulation, file = paste0("stationary_test/Z_",sim,".csv"), sep = ",", 
              col.names = FALSE, row.names = F)
}

## variance nonstationarity
num_sim = 100
sigma = function(u){
  return((0.33 * exp(-(u[1]+u[2]))) + 0.8)
} 
sigma_vec = rep(NA, 100)
for(i in 1:100){
  sigma_vec[i] = sigma(unlist(d1[i,]))
}

a = seq(0.08,0.5,length.out = num_sim)


for(sim in 1:num_sim){
  a1 = sample(a,1)
  s1 = 1
  m1 = m/a1
  m1[m1>=1] = 0
  C = s1*(1 - (3/2)*m1 + (1/2)*m1^3)
  for(i in 1:N){
    for(j in 1:N){
      if(i!=j & C[i,j] == s1) C[i,j] = 0
    }
  }
  
  simulation = mvrnorm(1,rep(0,N),C)
  simulation = (sigma_vec)^2 * simulation
  # quilt.plot(d1$x,d1$y, simulation, main =
  #              "variable 1", nx = 10, ny = 10)
  write.table(d1, file = paste0("nonstationary_test/LOC_",sim,".csv"), sep = ",",
              col.names = FALSE, row.names = F)
  write.table(simulation, file = paste0("nonstationary_test/Z_",sim,".csv"), sep = ",",
              col.names = FALSE, row.names = F)
}










