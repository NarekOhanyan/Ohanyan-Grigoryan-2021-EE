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

* =============================== Import UR data ==============================

import delimited "${path}/data/in/TWEXMPA.csv", clear
* Generating date from date string
gen date_ = mdy(real(substr(date,6,2)),real(substr(date,9,2)),real(substr(date,1,4)))
tsset date_, daily
gen quarter = qofd(date_)
collapse (mean) twexmpa, by(quarter)
rename quarter date
tsset date, quarterly

gen ln_reer = ln(twexmpa)
gen d_ln_reer = 100*d.ln_reer

save "${path}/data/tmp/Data_REER.dta",replace
