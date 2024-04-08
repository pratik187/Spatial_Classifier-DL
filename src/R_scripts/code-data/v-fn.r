#############################################################
# This code calculates the test statistic v                 #

# HERE WE HAVE WRITTEN THE WHOLE FUNCTION v IN A MATRIX FORM #
# FOR THE ENTIRE R.GRID VALUES. IT RETURNS A Kx2 MATRIX OF v #
# VALUES.

########################################################################


v.fn = function(lam.vec, loc.mat, dat.vec, r.mat, mean.corr = F)
                   {
                   if(mean.corr==T)
                   {
                   dat.vec = dat.vec -mean(dat.vec)
                   }

                   tmp.loc.mat = cbind(loc.mat[,1]/lam.vec[1], loc.mat[,2]/lam.vec[2])

                   v.mat.real = diag(abs(dat.vec))%*%cos(2*pi*(tmp.loc.mat%*%t(r.mat)))
                   v.hat.real = apply(v.mat.real, 2, mean)
                   v.mat.imag = diag(-abs(dat.vec))%*%sin(2*pi*(tmp.loc.mat%*%t(r.mat)))
                   v.hat.imag = apply(v.mat.imag, 2, mean)

                   return(cbind(v.hat.real, v.hat.imag))
                   }

