* CH1 - DATA MANAGEMENT
* create a Stat-format data set

cd "C:\Users\jcf2d\Documents\stata_materials\data"


* first save and clear open data set, example:
save "whitemt2.dta", replace
clear

* CREATING NEW DATASET
* open data editor and manually enter values
edit
rename var2 pop
label variable pop "Population in 1000s, 1995"
* save dataset
save canada00
*overwrite earler version: save, replace

describe /*properties of dataset*/
list /*list records*/
summarize

* give variables descriptive names
rename var1 place
rename var3 unemp
rename var4 mlife
rename var5 flife

* add labels to dataset and variables
label data "Canadian dataset 00"
label variable place "Place name"
label variable unemp "% 15+ population unemployed, 1995"
label variable mlife "Male life expectancy years"
label variable flife "Female life expectancy years"

* save changes to disk
save, replace

* to open dataset later on: use canada00

* correlation
correlate unemp mlife flife

* sort dataframe by population, ascending
sort pop

* set order of variables within dataset 
*order of appear in columns from left to right
order place unemp mlife flife pop

* open data editor to only work on certain variables
edit place mlife flife
*or
edit place unemp if pop > 100


*SPECIFYING SUBSETS OF DATA: in and if qualifiers
* show first 10 records
list in 1/10
* show 4 most populous places
sort pop
list place pop in -4/l /*that's an L, not #1*/
* leave Canada out of summary; two ways
summarize if pop < 20000
summarize if place != "Canada"

* summarize just the 10 Canadian provinces
summarize unemp mlife flife if pop > 100 & pop < 20000

* () allow us to specify precedence
list if unemp < 9 | (mlife >= 75.4 & flife >= 81.4)

* in sort and if operations, missing values treated as large positive numbers
* example
sort unemp
list if unemp > 15
* sometimes need to deal with missing values explicitly
list if unemp > 15 & unemp < .

* can use missing() function to screen out missing values
summarize mlife flife if missing(unemp)==0

* drop variables from data in memory
drop mlife flife
* drop obs 12/13
drop in 12/13

use canada0, clear
* subset 10 provinces
drop if place == "Canada" | pop < 100

* keep certain variables
keep place pop unemp
keep if place != "Canada" & pop >= 100

* none of these changes affect disk files until we save the data.
* TWO OPTIONS
*(1) write over the old dataset: save, replace
*(2) save with a new name: save newname (saves to working directory)

* GENERATING AND REPLACING VARIABLES
* use generate and replace commands
use canada1, clear
* create new variable and give it a label
generate gap = flife - mlife
label variable gap "Female-male life expectancy gap"
describe gap
list place mlife flife gap
* change display format of gap to rounded off version
format gap %4.1f /*4 numerals wide with one digit to right of decimal*/

* formats
* %w.dg - general numeric format
* %w.df - fixed numeric format
* %w.de - exponential numeric format
* calculations are unaffected by display formats

* replace changes values of an existing variable
* create categorical variable to indicate type (province, territory, country)
use canada2, clear
generate type = 1
replace type = 2 if place == "Yukon" | place == "Northwest Territories"
replace type = 3 if place == "Canada"
label variable type "Province, territory or nation"
label values type typelbl
label define typelbl 1 "Province" 2 "Territory" 3 "Nation"
list place flife mlife gap type
* labeling the values of a categorical variable requires two commands:
* (1) label define specifies what labels go with numbers
* (2) label values specifies to which variables these labels apply

* MISSING VALUE CODES
use Granite_06_10s, clear
tab novint
* same as before without value labels
tab novint, nolabel
summarize novint
* need to replace the 98 and 99 values with missing

generate novint2 = novint
* recode 98 and 99 as separate extended missing values
mvdecode novint2, mv(98=.a \ 99=.b)
tabulate novint2, miss

label variable novint2 "Interest in Nov Election, v.2"
label values novint2 novint2
label define novint2 1 "Extremely interested" 2 "Very interested" ///
3 "somewhat interested" 4 "Not very interested" ///
.a "don't know" .b "No answer"
tabulate novint2, miss
summ novint2

* designate values of 97, 98, 99 as missing for more than one variable
mvdecode novint edlevel hincome favbush , mv(97=. \ 98=.a \ 99=.b)
summarize /*note the missing values are no longer in the summaries*/

save Granite_06_10s2, replace

* USING FUNCTIONS
* functions for use with generate or replace
* example: generate loginc = ln(income)
* see "help math functions" for complete list
* see "help density functions" for complete list of probability functions
* see "help dates and times" for date-related functions
* see "help string functions" for string-related functions

* display can serve as on-screen calculator
display 2+3
display log10(10^83)
display invttail(120,.025) * 34.1/sqrt(975)

use canada1.dta

* display, generate and replace have direct access to Stata's statistical results:
summarize unemp
display r(mean)
* use result to create variable
gen unempDEV = unemp - r(mean)
summ unemp unempDEV

* to see a complete list of the names and values currently saved:
return list

* EGEN
* Stata provides a variable creation command, egen ("extensions to generate").
* which has its own set of functions to accomplish tasks not easily done by
* generate
egen zscore = std(unemp)
egen avglife = rowmean(mlife flife)

* see "help egen" for complete list of egen functions

* CONVERTING BETWEEN NUMERIC AND STRING FORMATS
use canada3, clear
list place type /*type is numeric variable*/
list place type, nolabel /*see underlying numbers*/

* create a labeled numeric variable
encode place, gen(placenum)

* create string variable using values of labeled numeric value
decode type, gen(typestr)

list place placenum type typestr, nolabel

summarize place placenum type typestr

* to convert string variables to numeric counterparts, use real
* can also use destring to convert string variables to numeric

* CREATING NEW CATEGORICAL AND ORDINAL VARIABLES
tabulate type

* create dummy variables (each category is new var with 0/1 coding)
tabulate type, generate(type)
describe
list place type type1-type3

summarize unemp if type!=3
* drop Canada record
drop if type==3

* create a dummy variable named unemp2 with 0 when unemp < mean(unemp)
* and 1 when unemp >= mean(unemp)
generate unemp2=0 if unemp < 12.26
replace unemp2=1 if unemp >= 12.26 & unemp < .

* group values of a measurement variable
generate unemp3 = autocode(unemp, 3, 5, 20)
* group values into 3 equal width groups over interval from 5 to 20

list unemp unemp2 unemp3

* USING EXPLICIT SUBSCRIPTS WITH VARIABLES
* when Stata has data in memorty, it also defines certain system variables
* that describe those data.
* _N = total number of observation
* _n = observation number

generate caseID = _n
* creating and saving unique case id numbers that store the order of observations
* at an early stage of dataset development can facilitate later data mgmt.

* explicit subscripts
use canada1.dta, clear
display pop[6]
display pop[12]

* define difprice = change in price since previous day
* generate difprice = price - price[_n-1]

* IMPORTING DATA FROM OTHER PROGRAMS
* possible to copy and paste blocks of data into data editor
* if first value in column is number, stata treats column as numeric
* same with text;
* Stata will usually recognize column headers when copying and pasting

* read ASCII file with infile
* infile var-list using filename.raw
infile str30 place pop unemp mlife flife using canada.raw, clear
* clear option drops any data from memory
* str30 = string var with as many as 30 characters
* precede string var names with str#

* once data read in, use compress to ensure no variable takes up more space than
* it needs.
describe
compress
describe

* save as Stata data set
save canada01

* read in CSV or tab-delimited files
insheet var-list using filename.dat, tab
insheet var-list using filename.csv, comma names

* read in fixed-width data
infix year 1-4 wood 5-8 mines 9-14 CPI 15-18 using nfresour.raw, clear
list
* see "help infiling" for more commands for fixed-width imports

* export data as ASCII
outfile using canada66


* COMBINING TWO OR MORE STATA FILES
* can combine datasets in two ways: (1) append (2) merge
use newf1.dta, clear
describe
list

use newf2
describe
list
***** append *****
* combine datasets using append, with newf2 already in memory
append using newf1
list
* notice jobless occurs in newf2 but not newf1
* sort by year
sort year
list
save newf3, replace

***** merge *****
use newf4
list
* merge newf3 and newf4
* to merge, both datasets must be sorted on key variable
sort year
list

merge year using newf3 /*old syntax*/

* using Stata 13 syntax
use newf3, replace
list
use newf4
list

merge 1:1 year using newf3 
list

* see "help merge" for good examples and options

* TRANSPOSING, REHSHAPING OR COLLAPSING DATA
use growth1, clear
describe
list
* growth for each year stored as a separate variable

* transpose data
xpose, clear varname
list
correlate v1-v5 in 2/5

* reshape from wide to long format
use growth1, clear
list
* reshape to long format
reshape long grow, i(provinc2) j(year)
* long = put into long form
* grow = new variable to store values
* i(provinc2) = identify observations; remains a column in long data set
* j(year) = name for column storing wide-format column headers
list
list, sepby(provinc2) /*add lines separating provinces*/

label data "Eastern Canadian growth--long"
label variable grow "population growth in 1000s"
save growth2, replace

graph twoway connected grow year if provinc2 < 4, yline(0) by(provinc2)

* reshape from long to wide format
use growth3, clear
list, sepby(provinc2)
* convert to wide
reshape wide grow, i(provinc2) j(year)
list

* create aggregated dataset of statistics
use growth3, clear
list, sepby(provinc2)
* aggregate the different growth years into a mean growth rate
collapse (mean) grow, by(provinc2)
list

* more elaborate example
collapse (sum) births deaths (mean) meaninc=income ///
	(median) medinc=income, by(provinc2)
	
* create a new dataset containing all summarize statistics describing growth
* in each Canadian province
use growth3, clear
statsby, by(provinc2): summarize grow
describe
list

* dataset containing only mean growth for each province
use growth3, clear
statsby meangrow = r(mean), by(provinc2): summarize grow
list

* statsby can also make a dataset of results from regression models or other analyses
use growth3, clear
statsby _b _se, by(provinc2): regress grow year
list
* see "help statsby" for more examples


* USING WEIGHTS
use nfschool
describe
list, sep(3)
tabulate univers year
* variable count gives frequencies
tabulate univers year [fweight = count]

* add options asking for a table with column percentages (col), 
* no cell frequencies (nof), and a chi-square test of indepdendence
tabulate univers year [fw = count], col nof chi2


* CREATING RANDOM DATA AND RANDOM SAMPLES
* create a var called randnum with random 16-digit values over the interval [0,1)
generate randnum = uniform()

* create a dataset from scratch containing 10 obs
clear
set obs 10
set seed 12345 /*make reproducible*/
generate randnum = uniform()
list

* create var sampled from [0,428)
generate newvar = 428 * uniform()
* same, but only integers
generate newvar2 = 1 + int(428 * uniform())

* simulate 1000 throws of a 6-sided die
clear
set obs 1000
generate roll = 1 + int(6 * uniform())
tabulate roll

* simulate 1000 thows of a pair of 6-sided dice
generate dice = 2 + int(6 *uniform()) + int(6 * uniform())
tabulate dice

* create a new 5000 obs dataset with var called index containing values 1-5000
set obs 5000
generate index = _n
summarize

* create a dataset with 2000 obs and 2 vars: z from N(0,1) and x from N(500,75)
clear 
set obs 2000
generate z = invnormal(uniform())
generate x = 500 + 75*invnormal(uniform())
summarize

* form a lognormal variable
generate v = exp(invnormal(uniform()))
* form a lognormal variable based on a N(100,15) 
generate w = exp(100 + 15*invnormal(uniform()))

* simulate draws from an exponential dist'n with mean and SD = 3
generate y = -3 * ln(uniform())

* generate sample from chi-square 1 dist'n
generate X1 = (invnormal(uniform()))^2

* generate sample from chi-square 2 dist'n
generate X2 = (invnormal(uniform()))^2 + (invnormal(uniform()))^2 

* easier way to simulate normal draws
clear 
drawnorm z, n(5000)
summ

* create dataset with three vars from Normal dist'n with correlation
mat C = (1, .4, -.8 \ .4, 1, 0 \ -.8, 0, 1)
drawnorm x1 x2 x3, means(0,100,500) sds(1,15,75) corr(C)
summarize x1-x3

correlate x1-x3

* discard all but a 10% random sample
sample 10

* add criteria
* sample 10 if age < 26

* select random sample of a particular size
* sample 90, count









