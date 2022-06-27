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

* =========================== Import Real GDP gap data =========================

import excel "${path}/stata/data/in/ROUTPUTQvQd.xlsx", sheet("ROUTPUT") firstrow clear

qui destring ROUTPUT*, replace ignore(`"#N/A"')

gen date = yq(real(substr(DATE,1,4)),real(substr(DATE,-1,1)))
tsset date, quarterly
drop DATE

merge 1:1 date using "${path}/stata/data/tmp/Data_RGDP_pr.dta", nogenerate

*drop if date < tq(1967q1)
drop ROUTPUT65Q4-ROUTPUT66Q4

foreach var of varlist ROUTPUT* {
	if real(substr("`var'",8,2)) > 50 {
		local new_var_name = "Y19" + substr("`var'",8,4)	
	}
	if real(substr("`var'",8,2)) < 50 {
		local new_var_name = "Y20" + substr("`var'",8,4)	
	}
	rename `var' `new_var_name'
}

rename RGDP_t RGDP_t0
replace Y1996Q1 = L1.Y1996Q1*(1 + RGDP_t_1[197]/100) if date == tq(1995q4)

gen t = _n
gen t2 = t^2
foreach lead of num 0/4 {
	gen Output_gap_dt_t`lead' = .
}
foreach var of varlist Y* {
	local year = substr("`var'",2,4)
	local quarter = substr("`var'",-1,1)
	local date = "`year'" + "q" + "`quarter'"
	local row = tq(`date') - date[1] + 1
	foreach lead of num 0/4 {
		replace `var' = L.`var'*(1 + RGDP_t`lead'[`row']/100) if date == tq(`date')+`lead'
	}
	gen log_var = ln(`var')
	qui reg log_var t t2 if date < tq(`date') & date > tq(`date')-51
/*	if _rc != 0 {
		local row = `row' - 1
		qui reg `var' t t2 in 1/`row'
		local row = `row' + 1
	}		
*/	predict residuals if date >= tq(`date'), res
	foreach lead of num 0/4 {
		replace Output_gap_dt_t`lead' = 100*residuals[`row'+`lead'] if date == tq(`date')
	}
	drop log_var residuals
}

drop Y* RGDP* t*
keep if tin(1967q1,2012q4)

save "${path}/stata/data/tmp/Data_Output_gap_dt_pr.dta",replace
