* CH 6 - LINEAR REGRESSION ANALYSIS
* THE REGRESSION TABLE

cd "C:\Users\jcf2d\Documents\stata_materials\data"
log using ch6_log
use states, clear

* OLS regression
regress csat expense


* display labels in regression output using estout package
eststo: quietly regress csat expense
esttab, label


regress csat expense, level(99)
* repeat results with 90% CI
regress, level(90)

* MULTIPLE REGRESSION
regress csat expense percent income high college
* get standardized regression coefficients (beta weights)
regress csat expense percent income high college, beta

* PREDICTED VALUES AND RESIDUALS
regress csat percent

* create a new var containing predicted y values
predict yhat
label variable yhat "Predicted mean SAT score"
* cretae another new var containing the residuals
predict e, resid
label variable e "Residual"

sort e
* five lowest residuals
list state percent csat yhat e in 1/5
* five hihest residuals
list state percent csat yhat e in -5/l /*lower-case L*/

* predict has a lot of options, such as dfits, hat, rstudent, cooksd...
predict D, cooksd
predict h, hat

* BASIC GRAPHS FOR REGRESSION
* draw simple regression line
graph twoway lfit csat percent
* draw simple regression line over scatterplot
graph twoway lfit csat percent ///
|| scatter csat percent ///
|| , ytitle("Mean composite SAT score") legend(off)

* residual versus predicted values plot
rvfplot, yline(0)
* by-hand alternatve
graph twoway scatter e yhat, yline(0)

* confidence interval
* get SE for confidence interval for predicted values
predict SE, stdp

* graph the confidence band using lfitci
* stdp = conditional-mean confidence band
graph twoway lfitci csat percent, stdp ///
|| scatter  csat percent, msymbol(0) ///
|| , ytitle("mean composite SAR score") legend(off) ///
title("confidence bands for conditional means (stdp)")

* prediction interval
* get SE for prediction interval for predicted values
predict SEyhat, stdf

* graph the prediction band using lfitci
* stdf = conditional-y prediction band
* predicting value instead of mean; wider band
graph twoway lfitci csat percent, stdf ///
|| scatter  csat percent, msymbol(0) ///
|| , ytitle("mean composite SAR score") legend(off) ///
title("confidence bands for conditional means (stdp)")

* CORRELATIONS
* correlate obtains pearson product-moment correlation
* automatically drops records with missing data
correlate csat expense percent income high college
* pairwise correlations for all available obs
* includes t-test probabilities for null that each correlation = 0
pwcorr csat expense percent income high college, sig star(.05)

* adjust significance level to take multiple comparisons into account
* using Sidak method; Bonferroni also available
pwcorr csat expense percent income high college, sidak sig star(.05)

* matrix of variances and covariances
correlate csat expense percent income high college, covariance

* after regression analysis, this displays covariance matrix of coefficients
* sometimes used to diagnose multicollinearity

regress csat expense percent income high college
estat vce /*covariance matrix - default*/
estat vce, cor /*correlation matrix*/

* scatterplot matrix
graph matrix csat expense percent income high college, ///
half msymbol(+) maxis(ylabel(none) xlabel(none))

* exclude records with missing values
graph matrix csat expense percent income high college if ///
!missing(csat, expense, income, high, college)

* create dataset with with obs that have no missing values
keep if !missing(csat, expense, income, high, college)
save nmvstate

* another way
drop if missing(csat, expense, income, high, college) == 1
save nmvstate, replace
* NOTE: original data set has no missing obs, so these last two commands do nothing

* rank-based correlations
* good for measuring associations between ordinal vars or as outlier-resistant
* alternative to pearson correlation
spearman csat expense

* Kendalls'a tau-a and tau-b correlations; does both a and b
* use on small- to medium-sized datasets
ktau csat expense

* HYPOTHESIS TESTS
* two types appear in regress output tables
* (1) Overall F test: null - coefficients on all the model's x variables = 0
* (2) individual t tests: null - coefficient on each variable = 0
* can also do user-specified F tests

regress csat expense percent income high college
* test joint hypothesis that BOTH high and college have 0 effect 
quietly regress csat expense percent income high college
test high college
* such tests on subsets of coefficients are useful when 
* we have several conceptually related variables

* other applications of test
* duplicate overall F test
test expense percent income high college
* test whether a coefficient = 0
test income = 1
* test whether two coefficients are equal
test high = college
* test H_0: beta_3 = (beta_4 + beta_5)/100
test income = (high + college)/100

* DUMMY VARIABLES
* create four dummy variables from the four-category variable region
tabulate region, gen(reg)
describe reg1-reg4
tabulate reg1
tabulate reg2

* regressing csat on one dummy variable is equivalent to performing a two-sample 
* t test of whether mean csat is the same across catgories of reg2.
regress csat reg2
ttest csat, by(reg2)

* control for the percentage of students taking the test
regress csat reg2 percent

* if you define k dummay vars, can only use k-1 in regression;
* if you use all k, one will be dropped

* modelling interactions with dummy vars
* create a slope dummy var (interaction)
generate reg2perc = reg2 * percent
save states_new
* include interaction in regression
regress csat reg2 percent reg2perc

* an interaction implies the effect of one variable changes depending on the
* values of some other variable

* visualize results from a slope-and-intercept dummy variable regression
label define reg2 0 "other regions" 1 "Northeast"
label values reg2 reg2

graph twoway lfit csat percent ///
|| scatter csat percent ///
|| , by(reg2, legend(off) note("")) //
ytitle("Mean composite SAT score")

* AUTOMATIC CATEGORICAL-VARIABLE INDICATORS AND INTERACTIONS
* expand interactions command simplifies the jobs of expanding multiple-category
* variables into sets of dummy and interaction vars

use student2, clear
* year is four-category variable
* automatically create a set of three dummy vars for year
xi, prefix(ind) i.year
* by default xi omits the lowest value of the categorical variable

* xi can also create interaction terms
xi i.year*i.gender
describe _I*

* create interaction terms for categorical and numeric
xi i.year*drink

* the REAL convenience of xi is its ability to generate dummy variables
* and interactions automatically within a regression or other model-fitting command
xi: regress gpa drink i.year
xi: regress gpa i.year*drink
* after doing this, the new variables remain the dataset

* STEPWISE REGRESSION
use states_new, clear
* automatic backward elimination
stepwise, pr(.05): regress csat expense percent income college ///
high reg1 reg2 reg2perc reg3

* use pe(.05) to do forward inclusion

* the following specifies that the first term (x1) stay in model and not be removed
* stepwise, pr(.05) lockterm1: regress y x1 x2 x3

* the following specifies forward inclusion of any predictors found significant
* at the .10 level, but with vars x4, x5 and x6 treated as one unit, either entered
* or left out together
* stepwise, pe(.10): regress y x1 x2 x3 (x4 x5 x6)

* POLYNOMIAL REGRESSION
quietly regress csat reg2 percent reg2perc
rvfplot, yline(0)
* note residuals trending upward at both high and low predicted values

* polynomial regression often succeeds in fitting U or inverted-U shaped curves
* csat-percent relationship appears somewhat U-shaped:
graph twoway scatter csat percent

* generate a new var equal to percent squared
generate percent2 = percent^2
regress csat percent percent2
* get fitted values
predict yhat2
* graph resulting curve
graph twoway mspline yhat2 percent, bands(50) ///
|| scatter csat percent
|| , legend(off) ytitle("mean composite SAT score")

* another way
graph twoway qfit csat percent ///
|| scatter csat percent

* recheck assumptions
quietly regress csat percent percent2
rvfplot, yline(0)
* residuals look better

* BEWARE: polynomial regression results can sometimes be sample-specific,
* fitting one dataset well but generalizing poorly to other data

log close
