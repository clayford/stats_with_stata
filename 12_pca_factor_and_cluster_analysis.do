*  CH 12 PRINCIPAL COMPONENTS, FACTOR AND CLUSTER ANALYSIS
cd "C:\Users\jcf2d\Documents\stata_materials\data"

use planets.dta, clear
* PRINCIPAL COMPONENTS
* to obtain principal components factors
factor rings logdsun - logdense, pcf
* equivalent:
factor rings logdsun - logdense, pcf mineigen(1)
* scree plot
screeplot, yline(1)

* ROTATION
* two types of rotation
* varimax: uncorrelated factors or components (default)
* promax: allows correlated factors or components; choose a number <= 4;
* higher the number, the greater the degree of interfactor correlation;
* promax(3) is default.
rotate
* for oblique promax rotation (allowing correlated factors)
rotate, promax

* visualize rotation results
loadingplot, factors(2) yline(0) xline(0)

* FACTOR SCORES
* factor scores are linear composites, formed by standardizing each variable
* to zero mean and unit variance, and then weighting with factor score coefficients
* and summing to each factor
predict f1 f2
label variable f1 "Large size/many satellites"
label variable f2 "far out/low density"
list planet f1 f2
summarize f1 f2
* factor scores are measured in units of standard deviations from their means
correlate f1 f2 /*promax permits correlations between factors*/

* scatterplot of the obs' factor scores
scoreplot, mlabel(planet) yline(0) xline(0)

* varimax yields uncorrelated factor scores
quietly factor rings logdsun - logdense, pcf
quietly rotate
quietly predict varimax1 varimax2
correlate varimax1 varimax2
* once created by predict, factor scores can be treated like any other variable.

* PRINCIPAL FACTORING
* principal factoring explains intervariable correlations

factor rings logdsun - logdense, ipf /*iterated communalties*/
* using ipf we must decide how many factors to retain

factor rings logdsun - logdense, ipf factor(2)

* MAXIMUM LIKELIHOOD FACTORING
* provides formal hypothesis tests that help in determining the appropriate
* number of factors

factor rings logdsun - logdense, ml nolog factor(1)
* output contains two tests:
*   LR test: independent vs. saturated: 
* tests whether a no-factor model fits the observed correlation matrix
* low prob indicates a no-factor model is too simple
*   LR test:    1 factor vs. saturated:  
* tests whether ther current 1-factor model fits worse than a saturated model
* low prob suggests one factor is too simple

* is two factor model better?
factor rings logdsun - logdense, ml nolog factor(2)
* LR test:   2 factors vs. saturated:  chi2(4)  =    6.72 Prob>chi2 = 0.1513
* implies 2-factor model is not worse than a perfect fit model

* CLUSTER ANALYSIS 1
egen zrings = std(rings)
egen zlogdsun = std(logdsun)
egen zlograd = std(lograd)
egen zlogmoon = std(logmoon)
egen zlogmass = std(logmass)
egen zlogdens = std(logdens)
summ zrings - zlogdens

* hierarchical cluster analysis with average linkage
cluster averagelinkage zrings zlogdsun zlograd zlogmoon zlogmass zlogdens ///
, L2 name(L2avg)
* Fig 12.4
cluster dendrogram, label(planet) ylabel(0(1)5)

cluster generate plantype = groups(3), name(L2avg)
label variable plantype "Planet Type"
list planet plantype

* save data
save, replace

* CLUSTER ANALYSIS 2

use nations.dta, clear

* range standardization
summarize pop
return list /*see stored results*/
generate rpop = pop/(r(max) - r(min))
label variable rpop "Range-standardized population"

quietly summ birth, detail
generate rbirth = pop/(r(max) - r(min))
label variable rbirth "Range-standardized birth rate"

quietly summ infmort, detail
generate rinfmort = pop/(r(max) - r(min))
label variable rinfmort "Range-standardized infmort"

* .... not doing the rest




