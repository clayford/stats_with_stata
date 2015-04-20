* CH 8 - FITTING CURVES
* BAND REGRESSION

cd "C:\Users\jcf2d\Documents\stata_materials\data"
use missile

* show curve that traces how the median of CEP changes with year
* bands(8) - divide plot into 8 equal width bands
graph twoway mband CEP year, bands(8) ///
|| scatter CEP year ///
|| , ytitle("Circular error probable, miles") legend(off)

* separate plots for each country
graph twoway mband CEP year, bands(8) ///
|| scatter CEP year ///
|| , ytitle("Circular error probable, miles")
by(country, legend(off) note(""))

* we can add band regression curves to any scatterplot by overlaying an mband/mspline

* LOWESS SMOOTHING
* lowess = locally weighted scatterplot smoothing

graph twoway lowess CEP year if country == 0, bwidth(.4) ///
|| scatter CEP year ///
|| , legend(off) ytitle("circular error probable, miles")
* the closer bandwidth is to 1, the greater degree of smoothing

* lowess for exploratory time series smoothing
use ice, clear
graph twoway lowess sulfate year, bwidth(.05) clwidth(thick) ///
|| line sulfate year, clpattern(solid) ///
|| , ytitle("SO4 ion concentration, ppb") ///
legend(label(1 "lowess smoothed") label(2 "raw data"))


* study the rough and smooth series separately
lowess sulfate year, bwidth(.05) gen(smooth)
label variable smooth "SO4 ion concentration (smoothed)"
gen rough = sulfate - smooth
label variable rough "SO4 ion concentration (rough)"

* now show in graphs
graph twoway line smooth year, ylabel(0(50)150) xtitle("") ///
ytitle("Smoothed") text(20 1540 "Renaissance") ///
text(20 1900 "Industrialization") ///
text(90 1860 "Great depression 1929") ///
text(150 1935 "oil embargo 1973") saving(fig08_05a, replace)

graph twoway line rough year, ylabel(0(50)150) xtitle("") ///
ytitle("Rough") text(75 1630 "Awu 1640", orientation(vertical)) ///
text(120 1770 "Laki 1783", orientation(vertical)) ///
text(90 1805 "Tambora 1815", orientation(vertical)) ///
text(65 1902 "Katmai 1912", orientation(vertical)) ///
text(80 1960 "Hekla 1970", orientation(vertical)) ///
yline(0) saving(fig08_05b, replace)

graph combine fig08_05a.gph fig08_05b.gph, rows(2)

* REGRESSION WITH TRANSFORMED VARIABLES 1
* by subjecting one or more underlying vars to nonlinear transformation, and then
* including the tranformed vars in a linear regression, we implicitly fit a 
* curvlinear model to the underlying data

use tornado, clear
graph twoway scatter avlost year ///
|| lfit avlost year, clpattern(solid) ///
|| , ytitle("Average number of lives lost") ///
xlabel(1920(10)1990) ///
xtitle("") legend(off) ylabel(0(1)7) yline(0)

* regression line predicts negative deaths in later years
* the relationship becomes linear and heteroskedasticity vanishes if we work
* instead with logarithms of the average number of lives lost

generate loglost = ln(avlost)
label variable loglost "ln(avlost)"
regress loglost year
predict yhat2
label variable yhat2 "ln(avlost) = 126.56 - .06year"
label variable loglost "ln(avlost)"
graph twoway scatter loglost year ///
|| mspline yhat2 year, clpattern(solid) bands(50) ///
|| , title("Natural log(average lives lost)") ///
xlabel(1920(10)1990) xtitle("") legend(off) ylabel(-4(1)2) ///
yline(0)

* return predicted values to their natural units by inverse transformation
replace yhat2 = exp(yhat2)

* graphin these inverse-transformed predicted values reveals
* the curvlinear regression model
graph twoway scatter avlost year ///
|| mspline yhat2 year, clpattern(solid) bands(50) ///
|| , ytitle("Avg number of lives lost") xlabel(1920(10)1990) ///
xtitle("") legend(off) ylabel(0(1)7) yline(0)

* using box-cox to fit curvlinear models
boxcox avlost year, model(lhs) nolog /*nolog = supress log LH after each iteration*/
* /theta = -0.056; optimal parameter Box-Cox parameter
* Note: box-cox assumes normal iid errors

* REGRESSION WITH TRANSFORMED VARIABLES - 2
* multiple regression example
use nations, clear





