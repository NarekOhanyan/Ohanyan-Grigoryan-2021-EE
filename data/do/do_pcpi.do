* ==============================================================================
* 
* ==============================================================================

clear
set more off
set type double
graph drop _all
macro drop _all
program drop _all

* Defining a global for current path
if c(username) == "Narek" {
	global path "E:/Drive/my drive/private/research/rules-vs-discretion/files/estimation"
}
if c(username) == "apple" {
	global path "/Users/apple/Dropbox/Discretion_vs_Committment/RECENT VERSION"
}

cd "${path}"

tempfile part1 part2

* ================================ Import CPI data =============================

* Merge two parts
import excel "${path}/stata/data/in/gPCPI_1967_1984.xlsx", sheet("gPCPI_1967_1984") firstrow clear
save `part1'
import excel "${path}/stata/data/in/gPCPI_1985_Last.xlsx", sheet("gPCPI_1985_Last") firstrow clear
save `part2'
use `part1'
merge 1:1 Date using `part2', nogenerate

* Take transpose of the data
xpose, clear varname promote

* Rename the variables
foreach var of varlist v* {
	local f = subinstr(string(`var'[1]),".","_",.)
	local new_var_name = "q" + "`f'"
	rename `var' `new_var_name'
}
local new_var_name = _varname[1]
rename _varname `new_var_name'
drop in 1
replace Date = subinstr(Date,"gPCPI_","",.)

* Generating date from Date string
gen date = mdy(real(substr(Date,5,2)),real(substr(Date,7,2)),real(substr(Date,1,4)))
tsset date, daily
gen quarter = qofd(date)
drop date Date
rename quarter date

* Drop missing values
drop q1966_1-q1978_3
drop if date <= tq(1979q3)

* Get average projections by quarters
collapse (mean) q*, by(date)
tsset date, quarterly

* =================== Extracting CPI projections from the data =================

* Defining globals for from t-4 to t+4
global PCPI_t_4 q1978_4
global PCPI_t_3 q1979_1
global PCPI_t_2 q1979_2
global PCPI_t_1 q1979_3
global PCPI_t   q1979_4
global PCPI_t1  q1980_1
global PCPI_t2  q1980_2
global PCPI_t3  q1980_3
global PCPI_t4  q1980_4

* Extracting diagonal elements as projections
foreach a in "t_4" "t_3" "t_2" "t_1" "t" "t1" "t2" "t3" "t4" {
	* Importing variables q* to Mata
	putmata PCPI_`a' = (q*),replace
	* Extracting diagonal elements
	mata: PCPI_`a'_d = diagonal(PCPI_`a') 
	`end'
	* Extracting variable from Mata matrix
	getmata PCPI_`a' = PCPI_`a'_d,replace
	* Rounding the numbers
	gen PCPI_`a'_r = round(PCPI_`a', .01)
	drop PCPI_`a'
	rename PCPI_`a'_r PCPI_`a'
	* Dropping observations sequentially
	drop ${PCPI_`a'}
}
* Dropping the raw data
drop q*

save "${path}/stata/data/tmp/Data_PCPI_pr.dta",replace
