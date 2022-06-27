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

* =============================== Import VIX data ==============================

import delimited "${path}/stata/data/in/VIXCLS.csv", clear
* Generating date from date string
gen date_ = mdy(real(substr(date,6,2)),real(substr(date,9,2)),real(substr(date,1,4)))
tsset date_, daily
gen quarter = qofd(date_)
collapse (mean) vixcls, by(quarter)
rename quarter date
tsset date, quarterly

rename vixcls VIX

save "${path}/stata/data/tmp/Data_VIX.dta",replace

* =============================== Import VXO data ==============================

import delimited "${path}/stata/data/in/VXOCLS.csv", clear
* Generating date from date string
gen date_ = mdy(real(substr(date,6,2)),real(substr(date,9,2)),real(substr(date,1,4)))
tsset date_, daily
gen quarter = qofd(date_)
collapse (mean) vxocls, by(quarter)
rename quarter date
tsset date, quarterly

rename vxocls VXO

save "${path}/stata/data/tmp/Data_VXO.dta",replace
