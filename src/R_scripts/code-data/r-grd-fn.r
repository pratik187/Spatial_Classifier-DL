# THE FOLLOWING FUNCTIONS ARE WRITTEN IN ORDER TO GENERATE THE r GRID #
# AND THE v GRID.

######################################
## - Creating r grid for the test - ##
######################################

r.grd.fn = function(r)

{

R.list = list()

# The following loop will give different r grid values #
# corresponding to A.hat[r.grd[1]], .. , A.hat[r.grd[k]]
# where, k = length of r vector

for (rr in 1:length(r))

    {

    range1 = r[rr]
    range3 = range1-1

    r.grd.list = list(x = -range1:range1, y = 0:range1)
    r.grd.all = make.surface.grid(r.grd.list)

    ord.norm.full = order(sqrt(r.grd.all[,1]^2+ r.grd.all[,2]^2))
    r.grd.all = r.grd.all[ord.norm.full,]

    x.ref.val = -range1:0
    y.ref.val = 0

    ind1.1 = which(r.grd.all[,1]%in%x.ref.val)
    ind2.1 = which(r.grd.all[,2]%in%y.ref.val)
    ind.1 = intersect(ind1.1,ind2.1)

    r.grd.all = r.grd.all[-ind.1,]

    x.range =  -range3:range3
    y.range =   0:range3

    ind1.se = which(r.grd.all[,1]%in%x.range)
    ind2.se = which(r.grd.all[,2]%in%y.range)
    ind.se = intersect(ind1.se,ind2.se)

    if(length(ind.se)>0){r.grd = r.grd.all[-ind.se,]}else{r.grd = r.grd.all}

    R.list[[rr]] = r.grd

    }

return(R.list)

}

# Example: In our simulation study we considered r = c(1,2) where
# A.hat[r.grd[1]] was used for the calculation of the test statistic, and
# A.hat[r.grd[2]] was used for the calculation of the standard error.

# R.GRD.list = r.grd.fn(c(1,2))




















