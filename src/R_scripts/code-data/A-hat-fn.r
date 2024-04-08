#####################################################################
# This code calculates the test statistic A.hat with and w/o i = j  #
# terms and with the Dirichlet Kernel with \sum_{k=-a}^{a}          #

# Here we have written the whole function A.hat in a matrix form #
# for the r grid values                                          #

########################################################################

A.hat.fn = function(lam.vec,loc.mat,dat.vec,r.mat,v.mat,a.val, mean.corr = F, nugget.rm = F)
               {
                if(mean.corr==T)
                  {
                   dat.vec = dat.vec -mean(dat.vec)
                  }

                N = length(dat.vec)

                tmp.site.mat.1 = matrix(rep(loc.mat[,1], N), nrow = N, byrow = T)
                tmp.site.mat.2 = matrix(rep(loc.mat[,2], N), nrow = N, byrow = T)

                v.len = nrow(v.mat)

                a.tilde.real.vec = rep(0, nrow(r.mat))
                a.tilde.imag.vec = rep(0, nrow(r.mat))
                
                delta = 0.0001                                                  # This is something we need to consider
                                                                                # to get rid of some NA values.

                for (i in 1:v.len)
                    {
                     v.vec = v.mat[i,]

                     # Calculation of the Dirichlet Kernel part #

                     diff.site.mat.1 = 2*pi*(t(tmp.site.mat.1)-tmp.site.mat.1-v.vec[1])/lam.vec[1]
                     diff.site.mat.1[diff.site.mat.1==0] = delta
                     diff.site.mat.2 = 2*pi*(t(tmp.site.mat.2)-tmp.site.mat.2-v.vec[2])/lam.vec[2]
                     diff.site.mat.2[diff.site.mat.2==0] = delta

                     diri.kern.1 = (sin((a.val+1/2)*diff.site.mat.1)/sin(diff.site.mat.1/2))
                     diri.kern.2 = (sin((a.val+1/2)*diff.site.mat.2)/sin(diff.site.mat.2/2))

                     diri.kern = diri.kern.1*diri.kern.2

                     # Calculation of terms #

                     tmp.loc.mat = cbind(loc.mat[,1]/lam.vec[1], loc.mat[,2]/lam.vec[2])

                     z.star.real.mat = diag(dat.vec)%*%cos(2*pi*(tmp.loc.mat%*%t(r.mat)))
                     z.star.imag.mat = -diag(dat.vec)%*%sin(2*pi*(tmp.loc.mat%*%t(r.mat)))

                     for (j in 1: nrow(r.mat))
                           {
                             a.tilde.real = diri.kern*(dat.vec%*%t(z.star.real.mat[,j]))
                             if(nugget.rm == T)
                              {
                                a.tilde.real = (sum(a.tilde.real)-sum(diag(a.tilde.real)))/N^2
                              }
                             a.tilde.real.vec[j] = a.tilde.real.vec[j] + a.tilde.real

                             a.tilde.imag = diri.kern*(dat.vec%*%t(z.star.imag.mat[,j]))
                             if(nugget.rm == T)
                              {
                                a.tilde.imag = (sum(a.tilde.imag)-sum(diag(a.tilde.imag)))/N^2
                              }
                             a.tilde.imag.vec[j] = a.tilde.imag.vec[j] + a.tilde.imag

                           }
                      }
                return(cbind(a.tilde.real.vec, a.tilde.imag.vec))
                }




