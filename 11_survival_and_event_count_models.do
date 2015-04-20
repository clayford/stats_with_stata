* CH 11 - SURVIVAL AND EVENT-COUNT MODELS
* SURVIVAL TIME DATA

cd "C:\Users\jcf2d\Documents\stata_materials\data"
infile case time aids age using aids.raw, clear
* label the variables
label variable case "Case ID number"
label variable time "months since HIV diagnosis"
label variable aids "developed aids symptomes"
label variable age "age in years"
label data "AIDS (Selvin 1995:453)"
compress
* identify time and censoring variables
stset time, failure(aids) id(case)
* save aids1
stdescribe
* time at risk
sum time
di r(sum)

* summary stats
stsum
* about a 50% chance of developing aids with 81 months of HIV diagnosis

* summary stats by sex (if var present)
* stsum, by(sex)


* COUNT-TIME DATE
* Count-time data on disk drives
use diskdriv.dta, clear

* specify a count-time dataset
* time, number-of-failures, number-censored
ctset hours failures censored
* convert to survival time format
* cttost = count-time to survival-time 
* defines a set of frequency weights (w)
cttost
stsum

* KAPLAN-MEIER SURVIVOR FUNCTIONS
use aids, clear
* already stset

* KM curve
sts graph

* 234 smokers attempting to quit
* days = how many days elapsed between quitting and starting again
use smoking1.dta, clear
stset days, failure(smoking)
stsum, by(sex)
* KM curves
sts graph, by(sex)
* test for equality of survivor functions (log-rank test)
sts test sex

* COX PROPORTIONAL HAZARD MODELS
use aids, clear
* already stset

stcox age, nolog
* ratio of hazards: 1.0845
* a person of age a + 1 is about 8.5% more likely to develop aids than a person 
* at age a

* for 5 year difference in age
di exp(_b[age])^5
* hazard is about 50% higher

* derive variable for age in 5-year units
gen age5 = age/5
label variable age5 "age in 5-year units"
stcox age5, nolog noshow

* cox model with multiple independent variables
use heart.dta, clear
* already stset
describe patient - ab
stdescribe

stcox weight sbp chol cigs ab, noshow nolog
* after estimating model, stcox can generate new vars holding the estimated
* baseline cumulative hazard and survivor functions.
* baseline means all x vars equal to 0, so
* first center variables:

sum patient - ab
replace weight = weight - 120
replace sbp = sbp - 105
replace chol = chol - 340
sum patient - ab

* to create new variables holding the baseline survivor and cum haz function
* estimates, repeat regression with basesurv() and basechaz() options
stcox weight sbp chol cigs ab, noshow nolog basesurv(survivor) basechaz(hazard)

* graph baseline survivor function
* person with weight = 120, chol = 340, sbp = 105
graph twoway line survivor time, connect (stairstep) sort
* note the y axis (ranges from 0.96 to 1)

* same baseline survivor function obtained another way
sts graph, adjustfor(weight sbp chol cigs ab)
* Notice y axis is scaled from 0 to 1

* graph baseline cumulative hazard against time
graph twoway connected hazard time, connect(stairstep) sort msymbol(Oh)

* Cox regression estimates the baseline survivor function empirically without
* reference to any theoretical distribution

* EXPONENTIAL AND WEIBULL REGRESSION
* alternative parametric approach that assumes survival times follow a known
* theoretical distribution

* If failures occur independently, with a constant hazard, then survival times 
* follow an exponential dist.

* Weibull allows failure rates to increase or decrease smoothly over time
use aids, clear

* create a new variable called "S" that contains the estimated KM function
sts gen S = S
gen logS = ln(S)
* graph ln(S(t)) versus time
graph twoway scatter logS time, ///
  ylabel(-.8(.1)0, format(%2.1f) angle(horizontal))
* exponential regression  
streg age, dist(exponential) nolog noshow
* the hazard of anm HIV-positive individual developing aids increases about 
* 7.4% with each yar of age.

* after streg, stcurve draws a graphs of the models' cum haz, survival or 
* haz functions.
* graph survival function at age 26
stcurve, survival at(age=26)

* graph survival curves at 26 and 50
stcurve, survival at1(age=26) at2(age=50)

* other stcurve graphs: hazard and cumhaz

* Weibull should be linear in a plot of ln(-ln(S(t)) versus ln(t)
generate loglogS = ln(-ln(S))
generate logtime = ln(time)
graph twoway scatter loglogS logtime, ylabel(,angle(horizontal))
* looks linear; previous exponential model probably adequate, but here's Weibull
* for illustration
streg age, dist(weibull) noshow nolog
* contains info on shape parameter p
* p = 1; hazard does not change with time
* p > 1; hazard increases with time
* p < 1; hazard decreases with time

* POISSON REGRESSION
use oakridge.dta, clear
summarize
* does death rate increase with exposure to radiation?
poisson deaths rad, nolog exposure(pyears) irr
* irr = exp(beat)
* death rate increases about 24% with each increase in radiation category

* goodness of fit test comparing poisson predictions with observed counts
poisgof
* model's predictions significantly different from the actual counts

* include age as a predictor
poisson deaths rad age, nolog exposure(pyears) irr

* rad and age treates as continuous variables
* create dummy variables
tabulate rad, gen(r)
poisson deaths r2-r8 age, nolog exposure(pyears) irr

* or better yet, just do this:
poisson deaths i.rad age, nolog exposure(pyears) irr


* combine r7 and r8 to simplify model
* first test whether coefficients for r7 and r8 are different (null: same)
test r7 = r8
* generate a new dummy variable which equals 1 if either r7 or r8 equals 1:
gen r78 = (r7 | r8)

poisson deaths r2-r6 r78 age, nolog exposure(pyears) irr

* GENERALIZED LINEAR MODELS
use states, clear
regress csat expense
* same with glm
glm csat expense, link(identity) family(gaussian)

* with bootstrap standard errors
glm csat expense, link(identity) family(gaussian) vce(bstrap)

* logistic regression
use shuttle0, clear
glm any date, link(logit) family(bernoulli) eform vce(jknife)

* poisson regression
use oakridge, clear
glm deaths i.rad age, family(poisson) link(log) lnoffset(pyears) eform
