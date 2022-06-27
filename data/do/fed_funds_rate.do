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

* ============================ Import Fed Funds data ===========================

import delimited "${path}/stata/data/in/FEDFUNDS.csv", clear
* Generating date from date string
gen date_ = mdy(real(substr(date,6,2)),real(substr(date,9,2)),real(substr(date,1,4)))
tsset date_, daily
gen quarter = qofd(date_)
collapse (last) ff_e = fedfunds (mean) ff_a = fedfunds, by(quarter)
rename quarter date
tsset date, quarterly

rename ff_a FF_A
rename ff_e FF_E

save "${path}/stata/data/tmp/Data_FF.dta",replace
