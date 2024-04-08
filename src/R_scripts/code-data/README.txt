A test for stationarity for irregularly spaced spatial data
S. Bandyopadhyay and S. Subba Rao
J. R. Statist. Soc. B, 79 (2017), 95 -- 123


The code requires the prior installation and loading of the R packages `MASS' and `fields' (in R, go to Packages -> Install package(s)..., follow the instructions, and then issue the command library(MASS), library(fields)).

The code is deliberately kept simple so that it is hopefully easy to understand and use. Please do let us know (email: sob210@lehigh.edu) if you make any modifications or improvements to it or if you have any questions. 

Also please refer all use of the code. 

The main function is 'analysis.r' which the user should use.

##############################################################################
THIS 'README.TXT' GIVES DETAILED DESCRIPTION OF DIFFERENT FILES IN THE FOLDER.
##############################################################################

1. analysis.r: This file has the functions which calculates the test statistics for a given data. The functions plot the standardized A.hat or v coefficents over the r grid. It also reports \mathcal{T_{S, S'}} and \mathcal{V_{S, S'}} along with the correspnding p values.

We have sourced all other functions in the folder in this file.


2. A-hat-fn.r: This function is written for the particular g() function used in the paper. This function calculates the entire test statistic matrix of dimension Kx2 where K is the number of r grid points. The first (second) column gives the real (imaginary) A.hat values for the entire r. grid.

The function is written in way that the user can calculate the A.hat with or without the nugget term. However, in our simulation study and real data example, we looked at A.hat without the nugget term and the DFT's are calculated with mean corrected data.


3. v-fn.r: This code calculates the test statistic v. Here we have written the whole function v in a matrix from for the entire r grid values. It returns a Kx2 matrix of v hat values, where K is the number of r grid points.  The first (second) column gives the real (imaginary) v values for the entire r grid.


4. r-grd-fn.r: This code is written in order to generate r grid. In the paper, we took r[[1]] to calculate our test statistic and r[[2]] values were used to estimate the s.e.


Suhasini Subba Rao
Department of Statistics
Blocker Building
Texas A&M University
College Station
TX 77843-3143
USA

E-mail: suhasini@stat.tamu.edu
