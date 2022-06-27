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

* ================================ Import RGDP data =============================

* Merge two parts
import excel "${path}/stata/data/in/gRGDP_1967_1984.xlsx", sheet("gRGDP_1967_1984") firstrow clear
save `part1'
import excel "${path}/stata/data/in/gRGDP_1985_Last.xlsx", sheet("gRGDP_1985_Last") firstrow clear
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
replace Date = subinstr(Date,"gRGDP_","",.)

* Generating date from Date string
gen date = mdy(real(substr(Date,5,2)),real(substr(Date,7,2)),real(substr(Date,1,4)))
tsset date, daily
gen quarter = qofd(date)
drop date Date
rename quarter date

* Get average projections by quarters
collapse (mean) q*, by(date)
tsset date, quarterly

* =================== Extracting RGDP projections from the data =================

* Defining globals for from t-4 to t+4
global RGDP_t_4 q1966_1
global RGDP_t_3 q1966_2
global RGDP_t_2 q1966_3
global RGDP_t_1 q1966_4
global RGDP_t   q1967_1
global RGDP_t1  q1967_2
global RGDP_t2  q1967_3
global RGDP_t3  q1967_4
global RGDP_t4  q1968_1

* Extracting diagonal elements as projections
foreach a in "t_4" "t_3" "t_2" "t_1" "t" "t1" "t2" "t3" "t4" {
	* Importing variables q* to Mata
	putmata RGDP_`a' = (q*),replace
	* Extracting diagonal elements
	mata: RGDP_`a'_d = diagonal(RGDP_`a') 
	`end'
	* Extracting variable from Mata matrix
	getmata RGDP_`a' = RGDP_`a'_d,replace
	* Rounding the numbers
	gen RGDP_`a'_r = round(RGDP_`a', .01)
	drop RGDP_`a'
	rename RGDP_`a'_r RGDP_`a'
	* Dropping observations sequentially
	drop ${RGDP_`a'}
}
* Dropping the raw data
drop q*

save "${path}/stata/data/tmp/Data_RGDP_pr.dta",replace
