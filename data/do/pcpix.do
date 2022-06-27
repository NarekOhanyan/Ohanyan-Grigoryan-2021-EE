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
global path "INSERT-PATH-HERE"

cd "${path}"

tempfile part1 part2

* ============================ Import Core CPI data ============================

* Merge two parts
import excel "${path}/data/in/gPCPIX_1967_1984.xlsx", sheet("gPCPIX_1967_1984") firstrow clear
save `part1'
import excel "${path}/data/in/gPCPIX_1985_Last.xlsx", sheet("gPCPIX_1985_Last") firstrow clear
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
replace Date = subinstr(Date,"gPCPIX_","",.)

* Generating date from Date string
gen date = mdy(real(substr(Date,5,2)),real(substr(Date,7,2)),real(substr(Date,1,4)))
tsset date, daily
gen quarter = qofd(date)
drop date Date
rename quarter date

* Drop missing values
drop q1966_1-q1984_4
drop if date <= tq(1985q4)

* Get average projections by quarters
collapse (mean) q*, by(date)
tsset date, quarterly
 
* ================ Extracting Core CPI projections from the data ===============

* Defining globals for from t-4 to t+4
global PCPIX_t_4 q1985_1
global PCPIX_t_3 q1985_2
global PCPIX_t_2 q1985_3
global PCPIX_t_1 q1985_4
global PCPIX_t   q1986_1
global PCPIX_t1  q1986_2
global PCPIX_t2  q1986_3
global PCPIX_t3  q1986_4
global PCPIX_t4  q1987_1

* Extracting diagonal elemens as projections
foreach a in "t_4" "t_3" "t_2" "t_1" "t" "t1" "t2" "t3" "t4" {
	* Importing variables q* to Mata
	putmata PCPIX_`a' = (q*),replace
	* Extracting diagonal elements
	mata: PCPIX_`a'_d = diagonal(PCPIX_`a') 
	`end'
	* Extracting variable from Mata matrix
	getmata PCPIX_`a' = PCPIX_`a'_d,replace
	* Rounding the numbers
	gen PCPIX_`a'_r = round(PCPIX_`a', .01)
	drop PCPIX_`a'
	rename PCPIX_`a'_r PCPIX_`a'
	* Dropping observations sequentially
	drop ${PCPIX_`a'}
}
* Dropping the raw data
drop q*

save "${path}/data/tmp/Data_PCPIX_pr.dta",replace
