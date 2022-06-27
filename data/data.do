* ==============================================================================
* Section 4: Data
* ------------------------------------------------------------------------------
*
* This do-file
*
* - prepared data for the reults of Ohanyan & Grigoryan (2020)
*
* - uses files
*	/data/in/
*
* - saves files
*	/data/out/Data.dta
*	/data/out/Data.xlsx
*	/data/out/Data_v13.dta
*
* ------------------------------------------------------------------------------
* Authors: N. Ohanyan, A. Grigoryan
* Last modified: 8 May, 2020
* ==============================================================================

clear
set more off
set type double
graph drop _all
macro drop _all
program drop _all

* Defining a global for current path
global path "INSERT-PATH-HERE"

* Save logs
capture log close
log using "${path}/log/data `c(current_date)'.smcl", replace

cd "${path}"

* ==============================================================================

do "${path}/data/do/fed_funds_rate.do"
do "${path}/data/do/vix_vxo.do"
do "${path}/data/do/pgdp.do"
do "${path}/data/do/pcpi.do"
do "${path}/data/do/pcpix.do"
do "${path}/data/do/rgdp.do"
do "${path}/data/do/output_gap_dt.do"
do "${path}/data/do/output_gap.do"
do "${path}/data/do/unrate.do"
do "${path}/data/do/reer.do"
do "${path}/data/do/gs1_gs5_gs10.do"

* =============================== Merge the data ===============================

use "${path}/data/tmp/Data_FF.dta",clear

merge 1:1 date using "${path}/data/tmp/Data_VIX.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_VXO.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_PGDP_pr.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_PCPI_pr.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_PCPIX_pr.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_RGDP_pr.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_Output_gap_dt_pr.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_Output_gap_pr.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_UNRATE.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_REER.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_GS1.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_GS5.dta", nogenerate
merge 1:1 date using "${path}/data/tmp/Data_GS10.dta", nogenerate

* ========================== Generating some variables =========================

gen GSslope = GS10 - GS1

foreach a in "t_4" "t_3" "t_2" "t_1" "t" "t1" "t2" "t3" "t4" {

gen CS_`a' = PCPI_`a' - PCPIX_`a'

}

* ====================== Organizing and formatting the data ====================

order date, first

tsset date, quarterly

* Labeling the data
do "${path}/data/do/labels.do"

* Displaying all variables except Date
ds date, not
global vars `r(varlist)'
recast double $vars
format %10.2f $vars

* Keeping only the observations for which projections are available
* keep if date>=tq(1985q1)

* =============================== Saving the data ==============================

save "${path}/data/out/Data.dta", replace
saveold "${path}/data/out/Data_v13.dta", replace version(13)

export excel using "${path}/data/out/Data.xlsx", sheet("data") firstrow(variables) replace

* ==============================================================================

log close
