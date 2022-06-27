* ==============================================================================
* Section 4: Data
* ------------------------------------------------------------------------------
*
* This do-file
*
* - prepared data for the reults of Ohanyan & Grigoryan (2020)
*
* - uses files
*	/stata/data/in/
*
* - saves files
*	/stata/data/out/Data.dta
*	/stata/data/out/Data.xlsx
*	/stata/data/out/Data_v13.dta
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
if c(username) == "Narek" {
	global path "E:/Drive/my drive/private/research/rules-vs-discretion/files/estimation"
}
if c(username) == "apple" {
	global path "/Users/apple/Dropbox/Discretion_vs_Committment/RECENT VERSION"
}

* Save logs
capture log close
log using "${path}/stata/log/do_data `c(current_date)'.smcl", replace

cd "${path}"

* ==============================================================================

do "${path}/stata/data/do/do_fed_funds_rate.do"
do "${path}/stata/data/do/do_vix_vxo.do"
do "${path}/stata/data/do/do_pgdp.do"
do "${path}/stata/data/do/do_pcpi.do"
do "${path}/stata/data/do/do_pcpix.do"
do "${path}/stata/data/do/do_rgdp.do"
do "${path}/stata/data/do/do_output_gap_dt.do"
do "${path}/stata/data/do/do_output_gap.do"
do "${path}/stata/data/do/do_unrate.do"
do "${path}/stata/data/do/do_reer.do"
do "${path}/stata/data/do/do_gs1_gs5_gs10.do"

* =============================== Merge the data ===============================

use "${path}/stata/data/tmp/Data_FF.dta",clear

merge 1:1 date using "${path}/stata/data/tmp/Data_VIX.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_VXO.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_PGDP_pr.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_PCPI_pr.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_PCPIX_pr.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_RGDP_pr.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_Output_gap_dt_pr.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_Output_gap_pr.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_UNRATE.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_REER.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_GS1.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_GS5.dta", nogenerate
merge 1:1 date using "${path}/stata/data/tmp/Data_GS10.dta", nogenerate

* ========================== Generating some variables =========================

gen GSslope = GS10 - GS1

foreach a in "t_4" "t_3" "t_2" "t_1" "t" "t1" "t2" "t3" "t4" {

gen CS_`a' = PCPI_`a' - PCPIX_`a'

}

* ====================== Organizing and formatting the data ====================

order date, first

tsset date, quarterly

* Labeling the data
do "${path}/stata/data/do/labels.do"

* Displaying all variables except Date
ds date, not
global vars `r(varlist)'
recast double $vars
format %10.2f $vars

* Keeping only the observations for which projections are available
* keep if date>=tq(1985q1)

* =============================== Saving the data ==============================

save "${path}/stata/data/out/Data.dta", replace
saveold "${path}/stata/data/out/Data_v13.dta", replace version(13)

export excel using "${path}/stata/data/out/Data.xlsx", sheet("data") firstrow(variables) replace

* ==============================================================================

log close
