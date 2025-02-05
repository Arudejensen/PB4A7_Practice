******************************************************************************************
* name: summative.do
* description: replicate of Hansen's (2015) paper "Punishment and deterrence: Evidence from drunk driving"
* last updated: January 27, 2025
******************************************************************************************

capture log close
clear
cd /Users/annajensen/Desktop/Summative
capture log using Summative.log, replace
use Data, clear

/* Install necessary packages
ssc install gtools
ssc install binscatter
ssc install rddensity
net install lpdensity, from("https://raw.githubusercontent.com/nppackages/lpdensity/master/stata/") replace
ssc install rdrobust
ssc install cmogram */

* Generate treatment variable DUI
gen dui = 0
replace dui = 1 if bac1 >= 0.08 & bac1 ~= .

* Generate centred BAC variable
gen bac_centredcentred = bac1 - 0.08

********************************************************
* Q1: Assumption checks
********************************************************

* Discrete histogram for BAC
histogram bac1, discrete ///
xtitle(Blood Alcohol Content, size(huge)) ///
ytitle(Density, size(huge)) ///
note("Discrete histogram", size(vlarge)) ///
xline(0.08) color(red%30)

graph save dis_hist.gph, replace

* Continious histogram for BAC
histogram bac1, bins(450) ////
xtitle(Blood Alcohol Content, size(huge)) /// 
ytitle(Density, size(huge)) ///
note("Continuous histogram", size(vlarge)) ///
xline(0.08) color(red%30)

graph save con_hist.gph, replace

* Combined histograms
graph combine dis_hist.gph con_hist.gph, col(2) ysize(2.5)

* McCrary density test at the 0.08 cutoff 
rddensity bac1, c(0.08) ///
plot graph_opt(xtitle(Blood Alcohol Content) ytitle(Density) legend(off))

* Covariant balance tests
rdrobust aged bac_centredcentred, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05)
rdrobust male bac_centredcentred, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05)
rdrobust white bac_centredcentred, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05)
rdrobust acc bac_centredcentred, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05)

* RDplots for covariant balance test of age
rdplot aged bac_centred if bac_centred>=-0.05 & bac_centred<=0.05, ///
masspoints(off) p(1) c(0) h(0.05) ///
graph_options(title("Age") ///
ytitle(Mean recidivism) xtitle(Blood Alcohol Content) legend(off))

graph save cov_aged.gph, replace

* RDplots for covariant balance test of gender
rdplot male bac_centred if bac_centred>=-0.05 & bac_centred<=0.05, ///
masspoints(off) p(1) c(0) h(0.05) ///
graph_options(title("Male") ///
ytitle(Mean recidivism) xtitle(Blood Alcohol Content) legend(off))

graph save cov_male.gph, replace

* RDplots for covariant balance test of race
rdplot white bac_centred if bac_centred>=-0.05 & bac_centred<=0.05, ///
masspoints(off) p(1) c(0) h(0.05) ///
graph_options(title("White") ///
ytitle(Mean recidivism) xtitle(Blood Alcohol Content) legend(off))

graph save cov_white.gph, replace

* RDplots for covariant balance test of accidents at the scene
rdplot acc bac_centred if bac_centred>=-0.05 & bac_centred<=0.05, ///
masspoints(off) p(1) c(0) h(0.05) ///
graph_options(title("Accident at the scene") ///
ytitle(Mean recidivism) xtitle(Blood Alcohol Content) legend(off))

graph save cov_acc.gph, replace

* Combined RDplots for coviariant balance tests
graph combine cov_aged.gph cov_male.gph cov_white.gph cov_acc.gph, col(2) row(2)

********************************************************
* Q2: Main results
********************************************************

* Local linear RDD with original bandwidth (0.03 to 0.13)
rdrobust recidivism bac_centred, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc)

* Local linear RDD with modified bandwidth (0.05 to 0.11)
rdrobust recidivism bac_centred, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.03) covs(white male aged acc)

* RDplot for local linear RDD with original bandwidth (0.03 to 0.13)
rdplot recidivism bac_centred ///
if bac_centred >= -0.05 & bac_centred <= 0.05, ///
masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc) ///
graph_options(title("Bandwidth ∈ [0.03, 0.13]", size(huge)) ///
ytitle(Mean recidivism, size(vlarge)) ///
xtitle(Blood Alcohol Content, size(vlarge)) legend(off))

graph save rd_main_0.05.gph, replace

* RDplot for local linear RDD with modified bandwidth (0.05 to 0.11)
rdplot recidivism bac_centredcentred  ///
if bac_centredcentred >= -0.03 & bac_centredcentred <= 0.03, ///
masspoints(off) p(1) c(0) h(0.03) covs(white male aged acc) ///
graph_options(title("Bandwidth ∈ [0.05, 0.11]", size(huge)) ///
ytitle(Mean recidivism, size(vlarge))  ///
xtitle(Blood Alcohol Content, size(vlarge)) legend(off))

graph save rd_main_0.03.gph, replace

* Combined RDplots of main results
graph combine rd_main_0.05.gph rd_main_0.03.gph, ysize(3.5)

********************************************************
* Q3: Donut hole regressions
********************************************************

* Generate donut
capture drop donut
gen donut = 0
replace donut = 1 if bac_centredcentred >= -0.001 & bac_centredcentred <= 0.001

* Bandwidth of 0.05

* Donut hole regression with rectangular kernel
rdrobust recidivism bac_centredcentred if donut == 0, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc)

* Donut hole regression with epanechnikov kernel
rdrobust recidivism bac_centredcentred if donut == 0, ///
kernel(epanechnikov) masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc)

* Donut hole regression with triangular kernel
rdrobust recidivism bac_centredcentred if donut == 0, ///
kernel(triangular) masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc)

*Bandwidth of 0.03

* Donut hole regression with rectangular kernel
rdrobust recidivism bac_centredcentred if donut == 0, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.03) covs(white male aged acc)

* Donut hole regression with epanechnikov kernel
rdrobust recidivism bac_centredcentred if donut == 0, ///
kernel(epanechnikov) masspoints(off) p(1) c(0) h(0.03) covs(white male aged acc)

* Donut hole regression with triangular kernel
rdrobust recidivism bac_centredcentred if donut == 0, ///
kernel(triangular) masspoints(off) p(1) c(0) h(0.03) covs(white male aged acc)

* RDplot of donut hole regression with rectangular kernel and 0.05 bandwidht
rdplot recidivism bac_centredcentred ///
if bac_centredcentred >= -0.05 & bac_centredcentred <= 0.05 & donut == 0, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05) ///
covs(white male aged acc) ///
graph_options(title("Rectangular", size(huge)) ///
ytitle([0.03, 0.13], size(huge)) ///
xtitle(Blood Alcohol Content, size(large)) legend(off))

graph save donut_uni_5.gph, replace

* RDplot of donut hole regression with epanechnikov kernel
rdplot recidivism bac_centredcentred ///
if bac_centredcentred >= -0.05 & bac_centredcentred <= 0.05 & donut == 0, ///
kernel(epanechnikov) masspoints(off) p(1) c(0) h(0.05) ///
covs(white male aged acc) ///
graph_options(title("Epanechnikov", size(huge)) ///
xtitle(Blood Alcohol Content, size(large)) legend(off))

graph save donut_epa_5.gph, replace

* RDplot of donut hole regression with triangular kernel
rdplot recidivism bac_centredcentred ///
if bac_centredcentred >= -0.05 & bac_centredcentred <= 0.05 & donut == 0, ///
kernel(triangular) masspoints(off) p(1) c(0) h(0.05) ///
covs(white male aged acc) ///
graph_options(title("Triangular", size(huge)) ///
xtitle(Blood Alcohol Content, size(large)) legend(off))

graph save donut_tri_5.gph, replace

* RDplot of donut hole regression with rectangular kernel and 0.03 bandwidht
rdplot recidivism bac_centredcentred ///
if bac_centredcentred >= -0.03 & bac_centredcentred <= 0.03 & donut == 0, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.03) ///
covs(white male aged acc) ///
graph_options(ytitle([0.05, 0.11], size(huge)) ///
xtitle(Blood Alcohol Content, size(large)) legend(off))

graph save donut_uni_3.gph, replace

* RDplot of donut hole regression with epanechnikov kernel
rdplot recidivism bac_centredcentred ///
if bac_centredcentred >= -0.03 & bac_centredcentred <= 0.03 & donut == 0, ///
kernel(epanechnikov) masspoints(off) p(1) c(0) h(0.03) ///
covs(white male aged acc) ///
graph_options(xtitle(Blood Alcohol Content, size(large)) legend(off))

graph save donut_epa_3.gph, replace

* RDplot of donut hole regression with triangular kernel
rdplot recidivism bac_centredcentred ///
if bac_centredcentred >= -0.03 & bac_centredcentred <= 0.03 & donut == 0, ///
kernel(triangular) masspoints(off) p(1) c(0) h(0.03) ///
covs(white male aged acc) ///
graph_options(xtitle(Blood Alcohol Content, size(large)) legend(off))

graph save donut_tri_3.gph, replace

* Combine RDplots of donut hole regressions
graph combine donut_uni_5.gph donut_epa_5.gph donut_tri_5.gph ///
donut_uni_3.gph donut_epa_3.gph donut_tri_3.gph

********************************************************
* Q4: Local polynomial regressions
********************************************************

* Bandwidths of 0.05

* Local polynomial regression with uniform kernel without donut
rdrobust recidivism bac_centred, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(uniform) masspoints(off) p(2) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(uniform) masspoints(off) p(3) c(0) h(0.05) covs(white male aged acc)

* Local polynomial regressions with rectangular kernel with donut
rdrobust recidivism bac_centred if donut == 0, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(uniform) masspoints(off) p(2) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(uniform) masspoints(off) p(3) c(0) h(0.05) covs(white male aged acc)

* Local polynomial regression with epanechinikov kernel without donut
rdrobust recidivism bac_centred, ///
kernel(epanechnikov) masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(epanechnikov) masspoints(off) p(2) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(epanechnikov) masspoints(off) p(3) c(0) h(0.05) covs(white male aged acc)

* Local polynomial regressions with epanechinikov kernel with donut
rdrobust recidivism bac_centred if donut == 0, ///
kernel(epanechnikov) masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(epanechnikov) masspoints(off) p(2) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(epanechnikov) masspoints(off) p(3) c(0) h(0.05) covs(white male aged acc)

* Local polynomial regression with triangular kernel without donut
rdrobust recidivism bac_centred, ///
kernel(triangular) masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(triangular) masspoints(off) p(2) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(triangular) masspoints(off) p(3) c(0) h(0.05) covs(white male aged acc)

* Local polynomial regression with triangular kernel with donut
rdrobust recidivism bac_centred if donut == 0, ///
kernel(triangular) masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(triangular) masspoints(off) p(2) c(0) h(0.05) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(triangular) masspoints(off) p(3) c(0) h(0.05) covs(white male aged acc)

* RDplots of polynomials with uniform kernel and 0.05 bandwidths

* RDplot of local linear RDD with adjusted bandwidths without donut hole
rdplot recidivism bac_centred if bac_centred >= -0.05 & bac_centred <= 0.05, ///
masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc) ///
graph_options(title("Without donut", size(medium)) ///
ytitle("Linear", size(medium)) ///
xtitle(Blood Alcohol Content) legend(off)) 

graph save rd_pol1.gph, replace

* RDplot of local linear RDD with adjusted bandwidths with donut hole
rdplot recidivism bac_centred ///
if bac_centred >= -0.05 & bac_centred <= 0.05 & donut == 0, ///
masspoints(off) p(1) c(0) h(0.05) covs(white male aged acc) ///
graph_options(title("With donut", size(medium)) ///
xtitle(Blood Alcohol Content) legend(off))

graph save rd_pol2.gph, replace
 
* RDplot of local quadratic RDD with adjusted bandwidths without donut hole
rdplot recidivism bac_centred if bac_centred >= -0.05 & bac_centred <= 0.05, ///
masspoints(off) p(2) c(0) h(0.05) covs(white male aged acc) ///
graph_options(ytitle("Quadratic", size(medium)) ///
xtitle(Blood Alcohol Content) legend(off))
 
graph save rd_pol3.gph, replace

* RDplot of local quadratic RDD with adjusted bandwidths with donut hole
rdplot recidivism bac_centred ///
if bac_centred >= -0.05 & bac_centred <= 0.05 & donut == 0, ///
masspoints(off) p(2) c(0) h(0.05) covs(white male aged acc) ///
graph_options(xtitle(Blood Alcohol Content) legend(off))

graph save rd_pol4.gph, replace

* RDplot of local cubic RDD with adjusted bandwidths without donut hole
rdplot recidivism bac_centred if bac_centred >= -0.05 & bac_centred <= 0.05, ///
masspoints(off) p(3) c(0) h(0.05) covs(white male aged acc) ///
graph_options(ytitle("Cubic", size(medium)) ///
xtitle(Blood Alcohol Content) legend(off)) 
 
graph save rd_pol5.gph, replace

* RDplot of local cubic RDD with adjusted bandwidths with donut hole
rdplot recidivism bac_centred ///
if bac_centred >= -0.05 & bac_centred <= 0.05 & donut == 0, ///
masspoints(off) c(0) h(0.05) p(3) covs(white male aged acc) ///
graph_options(xtitle(Blood Alcohol Content) legend(off))

graph save rd_pol6.gph, replace

* Combined RDplots of results with rectangular kernel and adjusted bandwidth
graph combine rd_pol1.gph rd_pol2.gph rd_pol3.gph ///
rd_pol4.gph rd_pol5.gph rd_pol6.gph, col(2) row(3) xsize(5)

* Bandwidth of 0.03

* Local polynomial regression with uniform kernel without donut
rdrobust recidivism bac_centred, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(uniform) masspoints(off) p(2) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(uniform) masspoints(off) p(3) c(0) h(0.03) covs(white male aged acc)

* Local polynomial regressions with rectangular kernel with donut
rdrobust recidivism bac_centred if donut == 0, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(uniform) masspoints(off) p(2) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(uniform) masspoints(off) p(3) c(0) h(0.03) covs(white male aged acc)

* Local polynomial regression with epanechinikov kernel without donut
rdrobust recidivism bac_centred, ///
kernel(epanechnikov) masspoints(off) p(1) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(epanechnikov) masspoints(off) p(2) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(epanechnikov) masspoints(off) p(3) c(0) h(0.03) covs(white male aged acc)

* Local polynomial regressions with epanechinikov kernel with donut
rdrobust recidivism bac_centred if donut == 0, ///
kernel(epanechnikov) masspoints(off) p(1) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(epanechnikov) masspoints(off) p(2) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(epanechnikov) masspoints(off) p(3) c(0) h(0.03) covs(white male aged acc)

* Local polynomial regression with triangular kernel without donut
rdrobust recidivism bac_centred, ///
kernel(triangular) masspoints(off) p(1) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(triangular) masspoints(off) p(2) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(triangular) masspoints(off) p(3) c(0) h(0.03) covs(white male aged acc)

* Local polynomial regression with triangular kernel with donut
rdrobust recidivism bac_centred if donut == 0, ///
kernel(triangular) masspoints(off) p(1) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(triangular) masspoints(off) p(2) c(0) h(0.03) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(triangular) masspoints(off) p(3) c(0) h(0.03) covs(white male aged acc)

********************************************************
* Q4a: Optimal bandwidth
********************************************************

* Check the optimal bandwidth with rdbwselect
rdbwselect recidivism bac_centredcentred, ///
kernel(uniform) p(1) bwselect(msetwo) c(0)

* Cmograms with linear regression line and original bandwith
cmogram recidivism bac_centred ///
if bac_centred >= -0.05 & bac_centred <= 0.05, ///
cut(0) con(white male aged acc) scatter line(0) lfitci ///
graphopts(ytitle(Mean recidivism) xtitle(Blood Alcohol Level) ///
note("Linear", size(medium))) ///
title(Bandwidth ∈ [0.03, 0.13])

graph save cmo1.gph, replace

* Cmograms with linear regression line and adjusted bandwith
cmogram recidivism bac_centred ///
if bac_centred >= -0.02 & bac_centred <= 0.03, ///
cut(0) con(white male aged acc) scatter line(0) lfitci ///
graphopts(ytitle(Mean recidivism) xtitle(Blood Alcohol Level) ///
note("Linear", size(medium))) ///
title(Bandwidth ∈ [0.06, 0.11])

graph save cmo2.gph, replace

* Cmograms with quadratic regression line and original bandwith
cmogram recidivism bac_centred ///
if bac_centred >= -0.05 & bac_centred <= 0.05, ///
cut(0) con(white male aged acc) scatter line(0) qfitci ///
graphopts(ytitle(Mean recidivism) xtitle(Blood Alcohol Level) ///
note("Quadratic", size(medium)))

graph save cmo3.gph, replace

* Cmograms with quadratic regression line and adjusted bandwith
cmogram recidivism bac_centred ///
if bac_centred >= -0.02 & bac_centred <= 0.03, ///
cut(0) con(white male aged acc) scatter line(0) qfitci ///
graphopts(ytitle(Mean recidivism) xtitle(Blood Alcohol Level) ///
note("Quadratic", size(medium)))

graph save cmo4.gph, replace

* Combined cmogram of observations with original and adjusted bandwiths
graph combine cmo1.gph cmo2.gph cmo3.gph cmo4.gph

* Rerun analyses with adjusted bandwidth 

* Local polynomial regression with uniform kernel without donut
rdrobust recidivism bac_centred, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.02 0.03) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(uniform) masspoints(off) p(2) c(0) h(0.02 0.03) covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(uniform) masspoints(off) p(3) c(0) h(0.02 0.03) covs(white male aged acc)

* Local polynomial regressions with uniform kernel with donut
rdrobust recidivism bac_centred if donut == 0, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.02 0.03) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(uniform) masspoints(off) p(2) c(0) h(0.02 0.03) covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(uniform) masspoints(off) p(3) c(0) h(0.02 0.03) covs(white male aged acc)

* Local polynomial regression with epanechinikov kernel without donut
rdrobust recidivism bac_centred, ///
kernel(epanechnikov) masspoints(off) p(1) c(0) h(0.02 0.03) ///
covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(epanechnikov) masspoints(off) p(2) c(0) h(0.02 0.03) ///
covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(epanechnikov) masspoints(off) p(3) c(0) h(0.02 0.03) ///
covs(white male aged acc)

* Local polynomial regressions with epanechinikov kernel with donut
rdrobust recidivism bac_centred if donut == 0, ///
kernel(epanechnikov) masspoints(off) p(1) c(0) h(0.02 0.03) ///
covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(epanechnikov) masspoints(off) p(2) c(0) h(0.02 0.03) ///
covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(epanechnikov) masspoints(off) p(3) c(0) h(0.02 0.03) ///
covs(white male aged acc)

* Local polynomial regression with triangular kernel without donut
rdrobust recidivism bac_centred, ///
kernel(triangular) masspoints(off) p(1) c(0) h(0.02 0.03) ///
covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(triangular) masspoints(off) p(2) c(0) h(0.02 0.03) ///
covs(white male aged acc)

rdrobust recidivism bac_centred, ///
kernel(triangular) masspoints(off) p(3) c(0) h(0.02 0.03) ///
covs(white male aged acc)

* Local polynomial regression with triangular kernel with donut
rdrobust recidivism bac_centred if donut == 0, ///
kernel(triangular) masspoints(off) p(1) c(0) h(0.02 0.03) ///
covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(triangular) masspoints(off) p(2) c(0) h(0.02 0.03) ///
covs(white male aged acc)

rdrobust recidivism bac_centred if donut == 0, ///
kernel(triangular) masspoints(off) p(3) c(0) h(0.02 0.03) ///
covs(white male aged acc)

********************************************************
* Q5: Heterogeneous treatment effects by subgroup 
********************************************************

* Effect in males
rdrobust recidivism bac_centredcentred if male == 1, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05) covs(white aged acc)

* Effect in females
rdrobust recidivism bac_centredcentred if male == 0, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05) covs(white aged acc)

* Effect in white
rdrobust recidivism bac_centredcentred if white == 1, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05) covs(male aged acc)

* Effect in none white
rdrobust recidivism bac_centredcentred if white == 0, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05) covs(male aged acc)

* Effect in aged under 40
rdrobust recidivism bac_centredcentred if aged <= 40, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05) covs(male white acc)

* Effect in aged over 40
rdrobust recidivism bac_centredcentred if aged > 40, ///
kernel(uniform) masspoints(off) p(1) c(0) h(0.05) covs(male white acc)
