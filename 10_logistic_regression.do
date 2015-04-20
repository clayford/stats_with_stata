* CH 10 LOGISTIC REGRESSION
cd "C:\Users\jcf2d\Documents\stata_materials\data"

* SPACE SHUTTLE DATA
use shuttle.dta, clear

list flight-temp, sepby(year)

generate date = mdy(month, day, year)
format %td date
label variable date "Date (days since 1/1/60)"

tabulate distress
tabulate distress, nolabel /*see underlying numeric codes*/

generate any = distress
replace any = 1 if distress == 2
label variable any "Any thermal distress"

tabulate distress any, miss /*be sure missing values handled correctly*/

logit any date
* L = ln[P(any = 1)/P(any = 0)]

predict Phat
label variable Phat "Predicted P (distress >= 1)"
graph twoway connected Phat date, xtitle("Launch Date") sort

display exp(_b[date])
display exp(_b[date])^100

* logistic fits the same model as logit, but output table displays odds ratios
* rather than coefficients

* USING LOGISTIC REGRESSION

logistic any date
* number in the odds ratio column of the logistic output are amounts by which
* the odds favoring y= are multiplies with each one-unit increase in that variable.

* classification table
estat class

logistic any date temp
estat class

* compare nested models with lrtest
* first estimate a full model and store
logistic any date temp
estimates store full
* next estimate reduced model
quietly logistic any date
lrtest full /*tests the recent model against the model previously saved*/

* chisq = -2(ln L1 - ln L0)
* L0 = first model with all x vars
* L1 = second nested model

* CONDITIONAL EFFECTS PLOTS
quietly logit any date temp
summarize date, detail
adjust date = `r(p25)', gen(Phat1) pr
summarize date, detail
adjust date = `r(p75)', gen(Phat2) pr

graph twoway mspline Phat1 temp, bands(50) ///
|| mspline Phat2 temp, bands(50) lpattern(dash) ///
|| , ytitle("Prob of thermal distress") ///
ylabel(0(.2)1, grid) xlabel(, grid) ///
||, legend(off)

* DIAGNOSTIC STATISTICS AND PLOTS
quietly logistic any date temp
predict Phat3
label variable Phat3 "Predicted Probability"
predict dX2, dx2
label variable dX2 "Change in Pearson chi-squared"
predict dB, dbeta
label variable dB "Influence"
predict dD, ddeviance
label variable dD "Change in Deviance"

* Fig 10.3
graph twoway scatter dX2 Phat3
* Fig 10.4
graph twoway scatter dX2 Phat3 ///
|| scatter dX2 Phat3 if dX2 > 2, mlabel(flight) mlabsize(medsmall) ///
||, legend(off)
list flight any date temp dX2 Phat3 if dX2 > 2
* Fig 10.5
graph twoway scatter dD Phat3, msymbol(i) mlabposition(0) mlabel(flight) ///
mlabsize(small)
* Fig 10.6
graph twoway scatter dD Phat3 [aweight = dB], msymbol(oh)

* LOGISTIC REGRESSION WITH ORDERED-CATEGORY Y
ologit distress date temp, nolog
* store model
estimates store date_temp
quietly ologit distress date
estimates store no_temp
lrtest no_temp date_temp
* confirm date should be in model
quietly ologit distress temp
estimates store no_date
lrtest no_date date_temp

* ordered logit model estimates a score, S, for each observation as a linear 
* function of date and temp

* P(distress="none") = (1 + exp(-cut1 + S))^-1
* P(distress="1 or 2") = (1 + exp(-cut2 + S))^-1 - (1 + exp(-cut1 + S))^-1
* P(distress="3 plus") = 1 - (1 + exp(-cut2 + S))^-1


quietly ologit distress date temp
predict none onetwo threeplus
describe none onetwo threeplus

list flight none onetwo threeplus if flight == 25

* MULTINOMIAL LOGISTIC REGRESSION
* aka polytomous logit regression
use NWarctic.dta, clear
tabulate life, plot
tabulate life kotz, column chi2
* mlogit can replicate this simple analysis
mlogit life kotz, nolog base(1) rrr
* base(1) = category 1 is base outcome
* rrr = show relative risk ratios

* Among Kotzebue students:
* P(leave AK)/P(same) = (36/93) / (17/93) = 2.1176
* Among other students:
* P(leave AK)/P(same) = (11/166) / (75/166) = 0.1466
* odds favoring "leave AK" over "same area" are 14 times higher for Kotzebue:
* 2.1176/0.1466 = 14.4385
* This multiplier, ratio of two odds, equals the relative risk ratio (14.4385)
* displayed by mlogit

mlogit life kotz ties, nolog base(1) rrr

* likelihood ratio tests evaluate the overall effect of each predictor
estimates store full
quietly mlogit life kotz
estimates store no_ties
lrtest no_ties full

quietly mlogit life ties
estimates store no_kotz
lrtest no_kotz full

* simply the sample by keeping only thos observations with nonmissing values:
keep if !missing(life, kotz, ties) /*not necessary, just example*/

quietly mlogit life kotz ties
predict PleaveAK, outcome(3)
label variable PleaveAK "P(life=3|kotz, ties)"
* tabulate predicted probabilities for each value of the dependent variable
table life, contents(mean PleaveAK) row

* Conditional effects plots
mlogit life kotz ties, nolog base(1)
* the following commands calculate predicted logits, and then the probabilities
* needed for conditional effect plots
generate L2villag = 0.206402 + 0.794884*0 - 0.7334513*ties
generate L2kotz = 0.206402 + 0.794884*1 - 0.7334513*ties
generate L3villag = -2.115025 + 2.697733*0 - 1.468537*ties
generate L3kotz = -2.115025 + 2.697733*1 - 1.468537*ties

* same as above using access commands
generate L2v = [2]_b[_cons] + [2]_b[kotz]*0 + 2[2]_b[ties]*ties
generate L2k = [2]_b[_cons] + [2]_b[kotz]*1 + 2[2]_b[ties]*ties
generate L3v = [3]_b[_cons] + [3]_b[kotz]*0 + 2[3]_b[ties]*ties
generate L3k = [3]_b[_cons] + [3]_b[kotz]*1 + 2[3]_b[ties]*ties

* calculate predicted probabilities
generate P1villag = 1/(1 + exp(L2villag) + exp(L3villag))
label variable P1villag "same area"

generate P2villag = exp(L2villag)/(1 + exp(L2villag) + exp(L3villag))
label variable P2villag "other Alaska"

generate P3villag = exp(L3villag)/(1 + exp(L2villag) + exp(L3villag))
label variable P3villag "leave Alaska"

generate P1kotz = 1/(1 + exp(L2kotz) + exp(L3kotz))
label variable P1kotz "same area"

generate P2kotz = exp(L2kotz)/(1 + exp(L2kotz) + exp(L3kotz))
label variable P1kotz "other Alaska"

generate P3kotz = exp(L3kotz)/(1 + exp(L2kotz) + exp(L3kotz))
label variable P1kotz "leave Alaska"

* Fig 10.7
graph twoway mspline P1villag ties, bands(50) lpattern(dash) ///
|| mspline P2villag ties, bands(50) ///
|| mspline P3villag ties, bands(50) lpattern(dot) ///
|| , xlabel(-3(1)3) ylabel(0(.2)1) yline(0 1) xline(0) ///
legend(order(3 2 1) position(12) ring(0) label(1 "same area") ///
label(2 "elsewhere Alaska") label(3 "leave Alaska") cols(1)) ///
ytitle("Probability")

* Fig 10.8
graph twoway mspline P1kotz ties, bands(50) lpattern(dash) ///
|| mspline P2kotz ties, bands(50) ///
|| mspline P3kotz ties, bands(50) lpattern(dot) ///
|| , xlabel(-3(1)3) ylabel(0(.2)1) yline(0 1) xline(0) ///
legend(order(3 2 1) position(12) ring(0) label(1 "same area") ///
label(2 "elsewhere Alaska") label(3 "leave Alaska") cols(1)) ///
ytitle("Probability")









