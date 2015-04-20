* CH 7 - REGRESSION DIAGNOSTICS
* SAT SCORE REGRESSION REVISITED

cd "C:\Users\jcf2d\Documents\stata_materials\data"
log using ch7_log
use states, clear

generate percent2 = percent^2
regress csat percent percent2 high

* do a scatterplot matrix
graph matrix percent percent2 high csat, half msymbol(+)

* omitted variables test: null - model has no omitted variables
estat ovtest

* heteroskedasticity test for assumption of constant error variance
* examines whether squared standardized residuals are linearly related to y-hat
* null - constant variance
estat hettest
* rejected null means our SE and hypothesis tests may be invalid

* DIAGNOSTIC PLOTS
predict yhat3 /*predicted values*/
predict e3, resid /*residuals*/
graph twoway scatter e3 yhat, yline(0) /*residuals vs predicted*/

* another way
rvfplot, yline(0)

* graph residuals vs predictor high
rvpplot high

* added-variable plots (aka partial regresion leverage plot, 
* adjusted partial residual plots, or adjusted variable plots)
* added-variable plots help to unconver obs exherting disproportionate influence
* on the regression model
avplot high /*just for high*/
avplots /*for all predictors*/

* NOTE: high-leverage observations show up in added-variable plots as points 
* horizontally distant from the rest of the data.

* include observation labels
avplot high, mlabel(state)

* leverage versus squared residuals plot
* graphs leverage (hat matrix diagonals) against the residuals squared
* the lines mark the means of leverage and squared residuals
lvr2plot, mlabel(state) mlabsize(medsmall)

* Leverage tells us how much potential for influencing the regression an 
* observation has, based on its particular combination of x values

* Utah stands out as one obs that is both ill fit and potentially influential
* see its values
list csat yhat3 percent high e3 if state == "Utah"

* regress without Utah
regress csat percent percent2 high if state != "Utah"

* DIAGNOSTIC CASE STATISTICS
* Standardized and studentized residuals help identify outliers
* Studentized residuals correspond to the t stat we would obtain by including 
* in the regression a dummy predictor coded 1 for that observation and 0 for all others
* Thus they test whether a particular obs significantly shifts the y intercept

* hat natrix diagonals measure leverage, ie potential to influence regression coefs
* obs have high leverage when their x values are unusual

* DFBETAs indicate by hown many standard errors the coef on x1 would change if 
* observation i were dropped from the regression

* Cook's D, Welsh's distance and DFITS all sumamrize how much observation i
* influences the regression model as a whole, or equivalently how much observation i
* influences the set of predicted values

* COVRATIO measures the influence of the ith observation on the estimated SEs

* run a bunch of post-regression diagnostics
quietly regress csat percent percent2 high
predict standard, rstandard
predict student, rstudent
predict h, hat
predict D, cooksd
predict DFITS, dfits
predict W, welsch
predict COVRATIO, covratio
dfbeta

describe standard - _dfbeta_3
* see min and max so we can check whether any are large enough to cause concern
summarize standard - _dfbeta_3

* the student diagnostic has max = 2.337; is it significant?
* check if |t| is significant at alpha/n
display 0.05/51 /*alpha/n = 0.0009*/
display 2*ttail(47, 2.337) /*P(|t| > 2.337) = 0.02*/
* 0.02 > 0.0009, so fail to reject null of not significant

* see 5 most influential obs as measured by Cook's D
sort D
list state yhat3 e3 D DFITS W in -5/l

* one way to display influence grahically
* symbols in residual vs predicted plot are gives sizes proportional to values of
* Cook's D
graph twoway scatter e3 yhat3 [aweight = D], msymbol(oh) yline(0)

* Cook's D, Welsch's distance and DFITS are closely related

* DFBETAs indicate how much each obs influences each regression coefficient
graph box _dfbeta_1 _dfbeta_2 _dfbeta_3, legend(cols(3)) ///
	marker(1, mlabel(state)) marker(2, mlabel(state)) ///
	marker(3, mlabel(state))

* set aside all states that move any coefficient by half a standard error
* ie, absolute DFBETAs of .5 or more
regress csat percent percent2 high if abs(_dfbeta_1) < .5 & ///
	abs(_dfbeta_2) < .5 & abs(_dfbeta_3) < .5
	
* sample sized adjusted cutoffs for model with K coefficients based on n obs
* leverage: h > 2K/n
* Cook's D > 4/n
* DFITS > 2*sqrt(K/n)
* Welsch's W > 3*sqrt(K)
* DFBETA > 2/sqrt(n)
* |COVRATIO - 1| >= 3k/N

* MULTICOLLINEARITY
* If perfect multicollinearity exists among predictors, regression equations
* lack unique solutions

* when we add a predictor that is strongly related to predictors already in
* the model, symptoms of trouble include
* - substatially higher standard errors
* - unexpected changes in coefficient magnitudes or signs
* - nonsignificant coefficients despite a high R^2

* quick check of multicollinearity
quietly regress csat percent percent2 high
estat vif
* a low value of 1/VIF indicates potential trouble

quietly regress csat percent percent2 high
display _se[percent]

quietly regress csat percent high
display _se[percent]

* Note: with percent2 in model, the SE of percent is 3x higher

* Guidelines for the presence of multicollinearity
* - largest VIF is greater than 10
* - mean VIF is considerably larger than 1

* "centering" often succeeds in reducing multicollinearity in polynomial
* or interaction-effect models
* subtracting the mean creates a new variable centered on 0 and much less
* correlated with its own squared values
* By reducing multicollinearity, centering often (but not always) yields more
* precise coefficient estimates with lower standard errors

* center percent and percent2
summarize percent
generate Cpercent = percent - r(mean)
generate Cpercent2 = Cpercent^2
correlate Cpercent Cpercent2 percent percent2 high csat
* Note: Cpercent and Cpercent2 are only moderately correlated

regress csat Cpercent Cpercent2 high
* estimate precision is improved

* check variance inflation factors again
estat vif
* less cause for concern

* another diagnostic for multicollinearity
* matrix of correlations betweene estimated coefficients
estat vce, correlation
* high correlations between pairs of coefficients on predictor variables indicate
* possible collinearity problems

* coefficient's var-covar matrix from which SEs are derived
estat vce, covariance

log close




