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

* ============================= Import GDP gap data ============================

import excel "${path}/data/in/Greenbook_Output_Gap_Web.xlsx", sheet("Output Gap") cellrange(A3:U207) clear

drop A B
replace C = "Date" in 1

* Rename the variables
foreach var of varlist _all {
	replace `var' = subinstr(`var',"T","t",.) in 1
	replace `var' = subinstr(`var',"-","_",.) in 1
	replace `var' = subinstr(`var',"+","",.) in 1
	local new_var_name = `var'[1]
	rename `var' `new_var_name'
}
drop in 1
destring t*, replace

* Generating Date from string dates
gen date = yq(real(substr(Date, 1,4)),real(substr(Date, -1,1)))

* Get average projections by quarters
collapse (mean) t*, by(date)
rename t* Output_gap_t*
tsset date, quarterly

save "${path}/data/tmp/Data_Output_gap_pr.dta",replace
