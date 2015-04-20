* CH 3 - GRAPHICS
* HISTOGRAMS
cd "C:\Users\jcf2d\Documents\stata_materials\data"

use states, clear
describe
histogram college, frequency title("Figure 3.1")
* with adjustments
histogram college, frequency title("Figure 3.2") xlabel(12(2)34) ///
ylabel(0(2)12) ytick(1(2)13) start(12) width(2)

histogram college, frequency title("Figure 3.3") xlabel(12(2)34) ///
ylabel(0(2)12) ytick(1(2)13) start(12) width(2) addlabel norm gap(15)

* histograms by region
histogram college, by(region) percent bin(8)
* include a 5th "total" histogram
histogram college, percent bin(8) by(region, total)

* SCATTERPLOTS
graph twoway scatter waste metro
* with triangles
graph twoway scatter waste metro, msymbol(T)
* with purple squares
graph twoway scatter waste metro, msymbol(S) mcolor(purple)

* scatterplot with symbol size proportional to third variable
graph twoway scatter waste metro [fweight = pop], msymbol(Oh)

sunflower waste metro

* scatterplot with labels for west region
graph twoway scatter waste metro if region==1, mlabel(state)

* scatterplot for each region
graph twoway scatter waste metro, by(region) ///
ylabel(, format(%3.0f)) xlabel(, format(%3.0f))

* matrix 
graph matrix miles metro income waste, half msymbol(Oh) 
* half option means include only the lower triangular part, msymbol(oh) plots small
* hollow circles

* LINE PLOTS
use cod, clear
* time plot showing Canadian and total landings, both against year
graph twoway line cod canada year
* make changes: 
graph twoway line cod canada year, legend(label (1 "all nations") ///
label(2 "Canada") position(2) ring(0) rows(2)) ytitle("")
* position(2) = place at 2 o'clock
* ring(0) = place within plot space
* rows(2) = make legend have two rows

* connect lines in stairstep fashion
graph twoway line TAC year, connect(stairstep)
* with improvements:
graph twoway line TAC year, connect(stairstep) xtitle("") ///
xtick(1960(2)2000) ytitle("Thousands of tons") ///
ylabel(0(100)800, angle(horizontal)) clpattern(dash)

* same as above with three groups and more options
graph twoway line cod canada TAC year, connect(line line stairstep) ///
clpattern(solid longdash dash) xtitle("") ///
xtick(1960(2)2000) ytitle("Thousands of tons") ///
ylabel(0(100)800, angle(horizontal)) ///
legend(label (1 "all nations") label(2 "Canada") label(3 "TAC") ///
position(2) ring(0) rows(3))

* CONNECTED-LINE PLOTS
graph twoway connected bio year
* restrict the range of years
graph twoway connected bio cod year if year > 1977 & year < 1999, ///
msymbol(T Oh) clpattern(dash solid) xlabel(1978(2)1996) ///
xtick(1979(2)1997) ytitle("Thousands of tons") xtitle("") ///
ylabel(0(500)2500, angle(horizontal)) ///
legend(label(1 "Estimated biomass") label(2 "Total landings") ///
position(2) rows(2) ring(0))

* OTHER TWOWAY PLOT TYPES
* area plot of cod landings
graph twoway area cod canada year, ytitle("")
* light gray version of area plot
graph twoway area cod canada year, ytitle("") bcolor(gs12 gs14)

* new data set
use gulf, clear

* spike plot
graph twoway spike maxarea winter if winter > 1963, base (173) ///
yline(173) ylabel(40(20)220, angle(horizontal)) ///
xlabel(1965(5)2000)
* base(173) sets base of spike plot; 173 is the mean of maxarea

* using lowess regression to smooth the time series
graph twoway lowess maxarea winter if winter > 1963, bwidth(.4) ///
yline(173) ylabel(40(20)220, angle(horizontal)) xlabel(1965(5)2000)
* bwidth option specifies a curve based on smoothed data points that are calculated
* from weighted regressions within a moving band containing 40% of the sample

* rangle plot
graph twoway rcap minarea maxarea winter if winter > 1963, ///
ylabel(0(20)220, angle(horizontal)) ///
ytitle("Ice area, 1000^km^2") xlabel(1965(5)2000)

* BOX PLOTS
use states, clear
graph box college, over(region) yline(19.1) /*19.1 = 50-state median*/
* control appearance, shading and details
graph hbox energy, over(region, sort(1)) yline(320) ///
intensity(30) marker(1, mlabel(state) mlabpos(12))

* PIE CHARTS
* skip

* BAR CHARTS
* compare summary statistics
use statehealth, clear
* median percent of pop'n inactive in leisure time
graph bar (median) inactive, over(region) blabel(bar) ///
bar(1, bcolor(gs10))
* blabel(bar) labels the bar heights

* add 2nd variable
graph bar (median) inactive overweight, over(region) blabel(bar, size(medium)) ///
bar(1, bcolor(gs10)) bar(2, bcolor(gs7))

* horizontal bar
graph hbar (mean) motor, over(income2) over (region) yline(17.2)
ytitle("Mean motor-vehicle related fatalities/100,000")

* stacked bars
use AKethnic, clear
graph bar (sum) nonnativ aleut indian eskimo, over(comtyp) stack

* redraw above with better legend and axis labels
#delimit ; 
graph bar (sum) nonnativ aleut indian eskimo, 
over(comtyp, relabel(1 "Village < 1000" 2 "Towns 1000 - 10,000" 
3 "Cities > 10000")) 
legend(rows(4) order(4 3 2 1) position(11) ring(0) 
label(1 "Non-native") label(2 "Aleut") label(3 "Indian") label(4 "Eskimo")) 
stack ytitle(Population) ylabel(0(100000)300000) ytick(50000(100000)350000);
#delimit cr

* SYMMETRY AND QUANTILE PLOTS
use states, clear
* symmetry plot - all points will be on the diagonal line of dist'm symmetrical
symplot energy

* quantile plot
quantile energy

* quantile-normal plot (aka normal probability plot)
* compare quantiles of a variable's distribution with quantiles of a theoretical
* normal dist'n having the same mean and SD
qnorm energy, grid

* quantile-quantile plots (aka QQ plots)
* compare quantiles of two empirical distributions; 
* if identical, points will lie on diagonal line
qqplot msat vsat

* see "help graph export" for writing do files that will create many graphs






