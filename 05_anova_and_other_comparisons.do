* CH 5 - ANOVA AND OTHER COMPARISON METHODS
* ONE-SAMPLE TESTS

log using ch5_log
cd "C:\Users\jcf2d\Documents\stata_materials\data"
use writing, clear

* one sample t test of null that mean = 10
ttest preS = 10

* the sign test (nonparametric counterpart)
signtest preS = 10

* compare means of post and pre
ttest postS = preS

* wilcoxon signed-rank test: assumes only that distributions are symmetrical and
* continuous
signrank postS = preS

* TWO-SAMPLE TESTS
use student2, clear
tabulate belong

* boxplot comparing median drink values
graph box drink, over(belong) ylabel(0(5)35) saving(fig05_01a)
* bar chart comparing means
graph bar (mean) drink, over(belong) ylabel(0(5)35) saving(fig05_01b)
graph combine fig05_01a.gph fig05_01b.gph, col(2) iscale(1.05)

* two-sample test
ttest drink, by(belong)

* same test without assumption of equal variance
ttest drink, by(belong) unequal

* nonparametric Mann-Whitney U test (aka Wilcoxon rank sum test)
* test null hypothesis of equal population medians
ranksum drink, by(belong)

* ONE-WAY ANOVA
* test for differences among means
oneway drink belong, tabulate
* tabulate option produces a table of means and standard deviations
* Bartlett's test for equal variance: null is equal variance

* with scheffe multiple comaprison test
oneway drink year, tabulate scheffe

* two-sample rank sum test, nonparametric alternative to one-way ANOVA
kwallis drink, by(year)

* TWO- AND N-WAY ANOVA
* two-way table of means
table belong gender, contents(mean drink) row col

* two-way factorial ANOVA
anova drink belong gender belong#gender

* two-way factorial ANOVA without interaction
anova drink belong gender 

* ANCOVA
* extends N-way ANOVA to encompass a mix of categorical and continuous x variables
anova drink belong gender c.gpa
* ANCOVA with regression output
anova drink belong gender belong#gender c.gpa
regress

* PREDICTED VALUES AND ERROR-BAR CHARTS
anova drink year
* calculate predicted means from the recent anova
predict drinkmean

* create rror-bar chart
label variable drinkmean "Mean drinking scale"
predict SEdrink, stdp /*stdp - calculates SE of the predicted means*/

serrbar drinkmean SEdrink year, scale(2) ///
addplot(line drinkmean year, clpattern(solid)) legend(off)

* error-bar for two-way factorial
anova aggress gender year gender#year
predict aggmean
label variable aggmean "Mean aggresive behavior scale"
predict SEagg, stdp
gen agghigh = aggmean + 2*SEagg
gen agglow = aggmean - 2*SEagg

graph twoway connected aggmean year ///
|| rcap agghigh agglow year ///  /*rcap = capped-spiked range plots*/
|| , by(gender, legend(off) note("")) ///
ytitle("Mean aggressive behavior scale")

log close
