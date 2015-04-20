* CH 4 - SUMMARY STATS AND TABLES

* SUMMARY STATS FOR MEASUREMENT VARIABLES
cd "C:\Users\jcf2d\Documents\stata_materials\data"
use VTtown, clear

* mean, median, sd of variable lived
summarize lived
summarize lived, detail

* tabstat - more flexible alternative to summarize
tabstat lived, stats(mean range skewness)

* with a by(varname) option, tabstat constructs a table containing summary stats
* for each value of varname
tabstat lived, stats(mean sd median iqr n) by(gender)

* 99% CI
ci lived, level(99)

* EXPLORATORY DATA ANALYSIS
* stem-and-leaf plot
stem lived
stem lived, lines(5) /*control number of lines per initial digit*/

* use order stats to dissect a distribution
lv lived

* NORMALITY TESTS AND TRANSFORMATIONS
* Skewness/Kurtosis tests for Normality
sktest lived

* create a new variable equal to square root of lived
generate srlived = lived ^ 0.5
generate srlived = sqrt(lived)

* create a new variable equal to natural log of lived
generate loglived = ln(lived)

* the ladder command combines the ladder of powers with sktest for normality
use states, clear
ladder energy
* reciprocal inverse transformation best resembles a normal dist'n

* visual version of ladder
gladder energy

* quantile-normal plots for ladder of powers transformations
qladder energy, scale(1.25) ylabel(none) xlabel(none)

* Box-Cox transformation
* bcskew0 finds a value for lambda such that y^lambda has approx 0 skewness
* find transformed variable benergy
bcskew0 benergy = energy, level(95)
* result: L = -1.246 
* benergy = (energy^-1.246 - 1) / (-1.246)

* FREQUENCY TABLES AND TWO-WAY CROSS TABS
use VTtown, clear
tabulate meetings

* two-way cross tab
tabulate meetings kids

* tabulate has a lot of options, such as cell, chi2, column, exact, taub
* example: only column percentages and a chi-square test of idependence
tabulate meetings kids, column chi2

* using tabi - immediate tabulation
* type cell frequencies with table rows separated by \
tabi 52 54 \ 11 36, column chi2

* MULTIPLE TABLES AND MULTI-WAY CROSS-TABULATIONS

tab1 meetings gender kids
tab1 gender-school

* create multiple two-way tables
tab2 meetings gender kids

* form multi-way contigency tables with a by prefix
by contam, sort: tabulate meetings kids, nofreq col chi2

* four-way cross tab of gender by contam by meetings by kids
by gender contam, sort: tabulate meetings kids, column chi2

* better way to produce multi-way tables
table meetings, contents(freq)
* two-way table
table meetings kids, contents(freq)
* using a third categorical variable forms supercolumns of a three-way table
table meetings kids contam, contents(freq)
* four-way example
table meetings kids contam, contents(freq) by(gender)

* TABLES OF MEANS, MEDIANS AND OTHER SUMMARY STATS
* tabulate means of lived within categories of meetings
tabulate meetings, summ(live)

* two-way table of means
tabulate meetings kids, sum(lived) means

* one-way table showing means of lived within categories of meetings
table meetings, contents(mean lived)

* two-way table of means
table meetings kids, contents(mean lived)

* two-way table with both means and medians
table meetings kids, contents(mean lived median lived)

* USING FREQUENCY WEIGHTS
use sextab2, clear
list in 1/5

* create a cross-tab of lifepart by gender
tabulate lifepart gender [fweight = count]

* same table with column percentages instead of frequencies
tabulate lifepart gender [fweight = count], column nof

* NOTE: sampling or probability weights do not work with tabulate

list school enroll msat
summarize msat
* weight msat score by enrollment
summarize msat [fweight = enroll]




















