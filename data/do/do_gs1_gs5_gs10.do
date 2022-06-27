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

* =============================== Import GS1 data ==============================

import delimited "${path}/stata/data/in/GS1.csv", clear
* Generating date from date string
gen date_ = mdy(real(substr(date,6,2)),real(substr(date,9,2)),real(substr(date,1,4)))
tsset date_, daily
gen quarter = qofd(date_)
collapse (mean) gs1, by(quarter)
rename quarter date
tsset date, quarterly

rename gs1 GS1

save "${path}/stata/data/tmp/Data_GS1.dta",replace

* =============================== Import GS5 data ==============================

import delimited "${path}/stata/data/in/GS5.csv", clear
* Generating date from date string
gen date_ = mdy(real(substr(date,6,2)),real(substr(date,9,2)),real(substr(date,1,4)))
tsset date_, daily
gen quarter = qofd(date_)
collapse (mean) gs5, by(quarter)
rename quarter date
tsset date, quarterly

rename gs5 GS5

save "${path}/stata/data/tmp/Data_GS5.dta",replace

* =============================== Import GS10 data =============================

import delimited "${path}/stata/data/in/GS10.csv", clear
* Generating date from date string
gen date_ = mdy(real(substr(date,6,2)),real(substr(date,9,2)),real(substr(date,1,4)))
tsset date_, daily
gen quarter = qofd(date_)
collapse (mean) gs10, by(quarter)
rename quarter date
tsset date, quarterly

rename gs10 GS10

save "${path}/stata/data/tmp/Data_GS10.dta",replace
