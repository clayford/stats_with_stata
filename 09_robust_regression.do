* CH 9 - ROBUST REGRESSION
* REGRESSION WITH IDEAL DATA

cd "C:\Users\jcf2d\Documents\stata_materials\data"
use robust1.dta

* OLS
regress y1 x
predict yhat1o
* Fig 9.1
graph twoway scatter y1 x ///
|| line yhat1o x, clpattern(solid) sort ///
|| , ytitle("y1 = 10 + 2*x + e1") legend(order(2) ///
label(2 "OLS line") position(11) ring(0) cols(1))

* robust regression; iteratively reweighted least squares
rreg y1 x
* slightly larger standard errors

* quantile regression (L1-type estimator)
qreg y1 x
* even larger standard errors; givel ideal data, qreg is least efficient of 
* the three estimators

* Y OUTLIERS
regress y2 x
predict yhat2o
label variable yhat2o "OLS line (regress)"
* robust regression
rreg y2 x, nolog genwt(rweight2) 
/*nolog = don't print iteration log; genwt() = save robust weights as variable*/
predict yhat2r
label variable yhat2r "robust regression (rreg)"
* Fig 9.2
graph twoway scatter y2 x ///
|| line yhat2o x, clpattern(solid) sort ///
|| line yhat2r x, clpattern(longdash) sort ///
|| ,ytitle("y2 = 10 + 2*x + e2") ///
legend(order(2 3) position(1) ring(0) cols(1) margin(sides))

predict resid2r, resid
list y2 x resid2r rweight2
* residuals near 0 produce weights near 1;
* obs too influential are set aside and set to missing

* regress with analytical weights
regress y2 x [aweight = rweight2]

* quantile regression
qreg y2 x, nolog

* quantile regression with bootstrapping to estimate SE
bsqreg y2 x, rep(50)

* X OUTLIERS (LEVERAGE)
* obs 2 has high leverage
* both regress and qreg track this outlier
regress y3 x3
predict yhat3o
label variable yhat3o "OLS regression (regress)"

qreg y3 x3, nolog
predict yhat3q
label variable yhat3q "median regression (qreg)"

rreg y3 x3
predict yhat3r
label variable yhat3r "robust regression (rreg)"

* Fig 9.3
graph twoway scatter y3 x3 ///
|| line yhat3o x3, clpattern(solid) sort ///
|| line yhat3r x3, clpattern(longdash) sort ///
|| line yhat3q x3, clpattern(shortdash) sort , ///
ytitle("y3 = 10 + 2*x + e3") legend(order(4 3 2) position(5) ///
ring(0) cols(1) margin(sides)) ylabel(-30(10)30)
* notice that regress and qreg are not robust against leverage (x-outliers)
* rreg sets aside obs with Cook's D greater than 1

* ASSYMMETRICAL ERROR DISTRIBUTIONS
* variable e4 has a skewed and outlier-filled dist'n
regress y4 x
predict yhat4o
label variable yhat4o "OLS regression (regress)"
rreg y4 x, nolog
predict yhat4r
label variable yhat4r "robust regression (rreg)"
* when entire distribution is skewed, rreg will downweight mostly one side,
* resulting in biased y-intercept estimates

* true line
generate y = 10 + 2*x
label variable y "true model"
 
 * Fig 9.4
graph twoway scatter y4 x ///
|| line y x, clpattern(solid) sort ///
|| line yhat4o x, clpattern(longdash) sort ///
|| line yhat4r x, clpattern(shortdash) sort , ///
ytitle("y3 = 10 + 2*x + e4") legend(order(4 3 2) position(11) ///
ring(0) cols(1) margin(sides)) ylabel(5(5)25)
 
* ROBUST ANALYSIS OF VARIANCE

use faculty.dta, clear
* table with means in the cells
table gender rank, contents(mean pay)

anova pay rank gender rank#gender
* effect-coded variables
tabulate gender female
tabulate rank assoc
tab rank full

* create interaction terms
generate femassoc = female*assoc
generate femfull = female*full

* duplicate previous anova using regression
regress pay assoc full female femassoc femfull
* regress followed by the appropriate test commands obtains exactly the same
* R^2 and F test results that we found using anova. Predicted values from this
* regression equal the mean salaries.
test assoc full
test female
test femassoc femfull

predict predpay1
label variable predpay1 "OLS predicted salary"
table gender rank, contents(mean predpay1)

* robust analysis of variance
rreg pay assoc full female femassoc femfull, nolog
test assoc full
test female
test femassoc femfull
* rreg downweights several outliers, mainly high paid male full profs

* see robust means
predict predpay2
label variable predpay2 "Robust predicted salary"
table gender rank, contents(mean predpay2)
* salary gap among asst and full profs appears smaller with robust means.


* use qreg to test differences between medians
qreg pay assoc full female femassoc femfull, nolog
test assoc full
test female
test femassoc femfull
predict predpay3
label variable predpay3 "Median predicted salary"
table gender rank, contents(median predpay3)
* compare to medians in each subgroup
table gender rank, contents(median pay)
* qreg allows us to fit models analogous to N-way anova or ancova, but
* involving .5 quantiles or approx medians instead of means.

*  FURTHER RREG AND QREG APPLICATIONS
* get CI for mean of a single variable
ci pay, level(90)
regress pay, level(90)
* robust mean with 90% CI
rreg y, level(90)

* compare two means
regress pay gender
* robust version
rreg pay gender
* qreg version, analyze first quantile and third quantiles
qreg pay gender, quant(.25)
qreg pay gender, quant(.75)

* ROBUST ESTIMATES OF VARIANCE - 1
* estimate standard errors without relying on IID assumption
* use sandwich estimator
* This is OLS regression with robust standard errors
use robust2.dta, clear
regress y8 x
predict yhat1o
* Fig 9.5
graph twoway scatter y8 x ///
|| line yhat1o x, clpattern(solid) sort

regress y8 x, vce(robust) /*does not include anova SS*/

* ROBUST ESTIMATES OF VARIANCE - 2
* vce(cluster clustervar)
* allows us to relax IID assumption in limited way, when errors are correlated
* within subgroups or clusters of the data
use attract.dta, clear
* data as 204 obs, but represents only 51 individual participants
* reasonable to assume disturbances were correlated across the 
* repetitions by each individual.

* viewing each participant's four rating sessions as a cluster should yield
* more realistic standard error estimates

regress ratefem bac gender genbac, vce(cluster id)
* note: genbac is an interaction
regress ratemal bac gender genbac, vce(cluster id)
