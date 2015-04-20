* CH 15 - MULTILEVEL AND MIXED-EFFECTS MODELING
* REGRESSION WITH RANDOM INTERCEPTS

cd "C:\Users\jcf2d\Documents\stata_materials\data"
use election_2004i.dta, clear
describe
graph twoway scatter bush logdens, msymbol(Oh) ///
|| lfit bush logdens, lpattern(solid) lwidth(medthick)

* improved version of scatterplot
graph twoway scatter bush logdens [fw=votes], msymbol(Oh) ///
|| lfit bush logdens, lpattern(solid) lwidth(medthick) ///
|| , xlabel(-1 "0.1" 0 "1" 1 "10" 2 "100" 3 "1000" ///
4 "10,000", grid) legend(off) ///
xtitle("population oer square mile") ytitle("percent vote for GW Bush")

* estimate model containing only fixed effects
regress bush logdens minority colled

* fixed effect models assumes same intercept and slope characterizes all 3,054 counties
* allow each of the nine census divisions to have its own random intercept
* estimate a model with random intercepts for each census division by adding a random-effects part
* this allows intercepts to vary across regions
xtmixed  bush logdens minority colled || cendiv:

* random intercepts do not appear in the output
* LRT test in final line of output says random-intercept model offers significant improvement
* over a linear regression model with fixed effects only.

* get best linear unbiased predictions (BLUPs) of random effects
predict randint0, reffects
graph hbar (mean) randint0, over(cendiv) ///
ytitle("Random intercepts by census division")


predict randint0, reffects
graph hbar (median) randint0, over(cendiv) ///
ytitle("Random intercepts by census division")

* RANDOM INTERCEPTS AND SLOPES
* does slope vary across regions
graph twoway scatter bush logdens, msymbol(Oh) ///
|| lfit bush logdens, lpattern(solid) lwidth(medthick) ///
|| , xlabel(-1(1)4, grid) ytitle("Percent vote for GW Bush") ///
by(cendiv, legend(off) note(""))

* model with random slopes
xtmixed bush logdens minority colled || cendiv: logdens

* does thie new model improve upon first random intercept model 
quietly xtmixed bush logdens minority colled || cendiv:
estimates store A
quietly xtmixed bush logdens minority colled || cendiv: logdens
estimates store B
lrtest A B

* previous model assumes random intercepts and slopes are uncorrelated;
* we can allow nonzero covariance between the random effects
xtmixed bush logdens minority colled || cendiv: logdens, cov(unstructured)
estimates store C
lrtest B C
* results of LRT: model C is improvement over model B

* what are slopes relating votes to density for each census division?
predict randslo1 randint1, reffects
describe
table cendiv, contents(mean randslo1 mean randint1)

* the slope for each census division equals the fixed effects slope for the whole sample, 
* plus the random-effect slope for that division

* calculate slopes and graph
gen slope1 = randslo1 + _b[logdens]
graph hbar (mean) slope1, over(cendiv) ///
ytitle("change in % Bush vite, with each tenfold increase in density")

* MULTIPLE RANDOM SLOPES

* specify random coefficients on logdens, minority and colled
xtmixed bush logdens minority colled ///
|| cendiv: logdens minority colled
* save estimation results
estimates store full
* evaluate random coefficients on colled, then compare to full model
quietly xtmixed bush logdens minority colled ///
|| cendiv: logdens minority
estimates store nocolled
lrtest nocolled full

* do the same for logdens and minority
quietly xtmixed bush logdens minority colled ///
|| cendiv: minority colled
estimates store nologdens
lrtest nologdens full

quietly xtmixed bush logdens minority colled ///
|| cendiv: logdens colled
estimates store nominority
lrtest nominority full

* mixed modelling often focuses on fixed effects, with random effects included to represent 
* heterogeneity in the data.
* On the other hand, random effects may be quantities of interest.
* We can predict random effects and from these calculate total effects.

quietly xtmixed bush logdens minority colled ///
|| cendiv: logdens minority colled
predict relogdens reminority recolled re_cons, reffects
describe relogdens-re_cons
generate tecolled = recolled + _b[colled]
label variable tecolled "random + fixed effect of colled"
table cendiv, contents(mean recolled mean tecolled)
graph hbar (mean) tecolled, over(cendiv) ///
ytitle("Change in % Bush vote, per 1% increase in college graduates")

* if xtmixed fails to converge, the problem may be random coefficients that do not vaty much
* they should be dropped fromt the model

* NESTED LEVELS
* mixed effects can include more than one nested level
* the following specifies random intercepts and slopes on all three predictors 
* for each census division, and also random intercepts and slopes on percent
* college graduates, colled, for each state

xtmixed bush logdens minority colled ///
|| cendiv: logdens minority colled ///
|| state: colled

* LRT indicates this model fits better than the full model from earlier
estimates store state
lrtest full state

* as before, predict random effects, then use to calculate and graph total effects
predict re*, reffects
describe re1-re6
gen tecolled2 = re3 + re5 + _b[colled]
label variable tecolled2 "cendiv + state + fixed effect of % college grads"
graph hbox tecolled2, over(cendiv) yline(-.16) ///
marker(1, mlabel(state))


* CROSS-SECTIONAL TIME SERIES
use rural_Alaska, clear
xtmixed popt year0 year2 || areaname: year0 year2
* the coefficient on year0 is positive and the coefficient on year 2 is negative,
* indicative of a general trend towards slowing growth

* graph both predicted population and actual population to visualize details of 
* area-to-area variation

predict yhat, fitted

graph twoway scatter popt year, msymbol(Oh) ///
|| mspline yhat year, lpattern(solid) lwidth(medthick) ///
|| , by(areaname, note("") legend(off)) ///
ylabel(0(5)20, angle(horizontal)) xtitle("") ///
ytitle("population in 1000s") xlabel(1970(10)2000, grid)

* MIXED-EFFECTS LOGIT REGRESSION
use GSS_SwS1.dta, clear
describe
tab bush

* starting model: predict individual Bush votes from 3 fixed effects - 
* log of place size, minority, education - and random intercepts for each census division

xtmelogit bush logsize minority educ || cendiv:
* inclusion of random intercept improves over fixed-effects logit model (p = 0.0009)

* should we also specify random slope on logsize and an unstructured covariance matrix?

xtmelogit bush logsize minority educ ///
|| cendiv: logsize, covariance(unstructured)
estimates store A
* correlation between two random effects appears nonsignificant

* fit a random-slope-only model
xtmelogit bush logsize minority educ ///
|| cendiv: logsize, nocons
* does it fit better than previous model?
estimates store B
lrtest B A









