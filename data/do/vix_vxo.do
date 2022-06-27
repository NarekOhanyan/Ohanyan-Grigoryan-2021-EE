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

* =============================== Import VIX data ==============================

import delimited "${path}/data/in/VIXCLS.csv", clear
* Generating date from date string
gen date_ = mdy(real(substr(date,6,2)),real(substr(date,9,2)),real(substr(date,1,4)))
tsset date_, daily
gen quarter = qofd(date_)
collapse (mean) vixcls, by(quarter)
rename quarter date
tsset date, quarterly

rename vixcls VIX

save "${path}/data/tmp/Data_VIX.dta",replace

* =============================== Import VXO data ==============================

import delimited "${path}/data/in/VXOCLS.csv", clear
* Generating date from date string
gen date_ = mdy(real(substr(date,6,2)),real(substr(date,9,2)),real(substr(date,1,4)))
tsset date_, daily
gen quarter = qofd(date_)
collapse (mean) vxocls, by(quarter)
rename quarter date
tsset date, quarterly

rename vxocls VXO

save "${path}/data/tmp/Data_VXO.dta",replace
