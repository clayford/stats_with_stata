* CH 13 - TIME SERIES
* Statistics with Stata (Hamilton)
* SMOOTHING
* smooting methods
cd "C:\Users\jcf2d\Documents\stata_materials\data"
use MILwater.dta

* convert month, day, year information into a single numerical index of time
* number of days elapsed since Jan 1, 1960
generate date = mdy(month, day, year)
list in 1/5

* identify date as the time index variable
* tsset = time series set; %td = daily display
tsset date, format(%td)
list in 1/5

* simple plot of water against date
graph twoway line water date

* special time series command
graph twoway tsline water, ylabel(300(100)900) ttitle("") ///
tlabel(01jan1983 01mar1983 01may1983 01jul1983, grid) ///
ttick(01feb1983 01apr1983 01jun1983 01aug1983)

* moving average of span 3
generate water3a = (water[_n-1] + water[_n] + water[_n+1])/3

* same as before using the ma function of egen
* the nomiss option requests shorter, uncentered moving average in the tails
egen water3b = ma(water), nomiss t(3)

* smoothing tools available through tssmooth commands
* calculate moving averages of span 3
tssmooth ma water3c = water, window(1 1 1)

* 5 day moving average of water use
tssmooth ma water5 = water, window(2 1 2)
graph twoway tsline water5, clwidth(thick) ///
|| tsline water, clwidth(thin) clpattern(solid)

* moving averages have little resistance to outliers
* the tssmooth nl command performs outlier-resistant nonlinear smoothing
tssmooth nl water5r = water, smoother(5) /*medians of span 5*/

* another smoother
tssmooth nl water4r = water, smoother(4253h,twice)

graph twoway tsline water4r, clwidth(thick) ///
|| tsline water, clwidth(thin) clpattern(solid)

* calculate difference between data and smoothed data and then graph residuals
generate rough = water - water4r
label variable rough "Residuals from 4235h, twice"
graph twoway tsline rough, ttitle("") ///
tlabel(01jan1983 01feb1983 01mar1983 01apr1983 ///
01may1983 01jun1983 01jul1983 01aug1983, grid format(%tdmd))

* these smoothing techniques make most sense when observations are equally spaced in time
* FURTHER TIME PLOT EXAMPLES
use atlantic.dta, clear
describe
* define as yearly time series data
tsset year, yearly
list year fylltemp wNAO if tin(1950,1955) /*tin = times in*/
list year fylltemp wNAO if twithin(1950,1955) /*twithin = exclude two endpoints*/

* new var containing smoothed values
tssmooth nl fyll4 = fylltemp, smoother(4235h, twice)

* raw temps shown as spike-plot deviations from the mean (1.67)
graph twoway spike fylltemp year, base(1.67) yline(1.67) ///
|| line fyll4 year, clpattern(solid) ///
|| , ytitle("Fylla Bank temperature, degrees C") ///
ylabel(0(1)3) xtitle("") xtick(1955(10)1995) legend(off)

* smoothed values of the NAO
tssmooth nl wNAO4 = wNAO, smoother(4253h, twice)

graph twoway line fyll4 year, yaxis(1) ///
ylabel(0(1)3, angle(horizontal) nogrid axis(1)) ///
ytitle("Fylla Bank temperature, degrees C", axis(1)) ///
|| line wNAO4 year, yaxis(2) ytitle("Winter NAO index", axis(2)) ///
ylabel(-3(1)3, angle(horizontal) axis(2)) yline(0, axis(2)) ///
|| , xtitle("") xlabel(1950(10)2000, grid) xtick(1955(5)1995) ///
legend(label(1 "Fylla temperature") label(2 "NAO Index") ///
cols(1) position(5) ring(0))


* LAGS, LEADS, DIFFERENCES
* create variable equal to previous year's NAO value
generate wNAO_1 = wNAO[_n-1]
* same thing using lag operator
generate wNAO_1 = L.wNAO
* generate lag 2 values
generate wNAO_2 = L2.wNAO
list year wNAO wNAO_1 wNAO_2 if tin(1950,1954)

* regress fylltemp on wNAO with predictors from one, two, three years earlier
regress fylltemp wNAO L1.wNAO L2.wNAO L3.wNAO if tin(1973,1997)
* equivalent
regress fylltemp L(0/3).wNAO if tin(1973,1997)
* Durbin-Watson test for autocorrelated errors
estat dwatson /*d between 0 - 4; 2 = no autocorrelation; less than 1 maybe bad*/
* auto-correlated errors invalidate the usual OLS CI and tests

* CORRELOGRAMS
* a correlogram graphs correlation versus lags
corrgram fylltemp, lags(9)
* The Q stats test a series of null hypotheses that all autocorrelations up to
* and including each lag are 0. NULL = no significant autocorrelation.
ac fylltemp, lags(9) /*correlogram*/
pac fylltemp, yline(0) lags(9) ciopts(bstyle(outline)) /*graph of partial ac*/
* both suggest an AR(1) process

* Cross correlograms help explore relationships between two time series
xcorr wNAO fylltemp if tin(1973,1997), lags(9) xlabel(-9(1)9, grid)

* see cross-correlation coefficients (table option)
xcorr wNAO fylltemp if tin(1973,1997), lags(9) table

* ARIMA MODELS
* Autoregressive integrated moving average (ARIMA) models
* ARMA(1,1) model
arima y, ar(1) ma(1)
* or
arima y, arima(1,0,1)

*ARIMA(2,1,1) model
arima y, arima(1/2,1,1)

* Phillip-Peron test. ARIMA modeling assumes our series is stationary, that is
* its mean and variance do not change with time.
* We can test for "unit root" (a nonstationary AR(1) process in which rho=1 
* The Phillip-Peron tests for unit root (NULL = unit root)
pperron fylltemp, lag(3)
* this rejects null of a unit root

* Dickey-Fuller GLS test
dfgls fylltemp, notrend maxlag(3)

* AR(1) model
arima fylltemp, arima(1,0,0) nolog /*nolog prevents display of no iteration log*/


* extraxt AR(1) coefficient and SE
display [ARMA]_b[L1.ar]
display [ARMA]_se[L1.ar]

* test whether residuals appear to be uncorrelated
predict fyllres, resid /*save residuals to fyllres variable*/
corrgram fyllres, lags(15) /*correlogram to evaluate autocorrelation among residuals*/
* no evidence of autocorrelation

* Portmanteau test for white noise
wntestq fyllres, lags(15)

* by these criteria, AR(1) model appears adequate

* fit an AR(1) model with wNAO as predictor for specific time range: 
arima fylltemp wNAO if tin(1973,1997), ar(1) nolog
predict fyllhat /*predicted values*/
label variable fyllhat "predicted temperature"
predict fyllres2 if tin(1973,1997), resid
corrgram fyllres2, lags(9)

* graph model's predicted values
graph twoway line fylltemp year if tin(1973, 1997) ///
|| line fyllhat year if tin(1973,1997) ///
|| , ylabel(.5(.5)2.5, angle(horizontal) format(%2.1f)) ///
ytitle("Degrees C") xlabel(1975(5)1995, grid) xtitle("") ///
legend(label(1 "observed temperature") ///
label(2 "model prediction") position(5) ring(0) col(1))

* ARMAX MODELS
use whitemt2.dta, clear
describe
list in 1/5 /*see first 5 rows*/
tsset edate, daily

* model disturbances as regular and multiplicative "seasonal" 1st-order
* autoregressive and moving-average processes
arima visits day1 day3 day4 day5 day6 day7 L1.mtdepth L1.mtfall ///
L2.mtfall L1.bosdepth L1.bosfall L2.bosfall, arima(1,0,1) sarima(1,0,1,7)

* are residuals significantly different from white noise out to lag 14?
predict e1, resid
corrgram e1, lags(14)
* No

* simplified model
* drops day4 (Wed) and lag-2 snow depth effects (L2.mtdepth & L2.bosdepth)
arima visits day1 day3 day5 day6 day7 L1.mtdepth L1.mtfall ///
L1.bosdepth L1.bosfall, nolog arima(1,0,1) sarima(1,0,1,7) vce(robust)

predict yhat
replace yhat=0 if yhat<0 /*replace negative predictions with 0*/

predict e2, resid
corrgram e2, lag(14)
* no significant auto-correlation is found






