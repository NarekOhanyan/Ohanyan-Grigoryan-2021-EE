* ==============================================================================
* Section 4: Data
* ------------------------------------------------------------------------------
*
* This do-file
*
* - replicates Table 1 and Figure 1 of Ohanyan & Grigoryan (2020)
*
* - uses files
*	/stata/data/out/Data.dta
*
* - saves files
*	/stata/tex/sumstat.tex
*	/stata/log/do_intro `c(current_date)'.smcl
*
* - saves figures
*	/stata/figure/graph_`var'.`format'
*
* 	where
*		`var' = {FF_A,PGDP_t1,PCPI_t1,PCPIX_t1,Output_gap_dt_t1,Output_gap_t1,VIX}
*		`format' = {pdf,eps}
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
log using "${path}/stata/log/intro `c(current_date)'.smcl", replace

* Defining a global for whole sample
global Full_Sample "date>=tq(1967q1) & date<=tq(2005q4)"

* Defining a global for pre-Volcker period
global Pre_Volcker "date>=tq(1967q1) & date<=tq(1979q2)"

* Defining a global for Volcker period
global Volcker "date>=tq(1979q3) & date<=tq(1987q2)"

* Defining a global for Greenspan's period
global Greenspan "date>=tq(1987q3) & date<=tq(2005q4)"

* Defining a variance estimation method
global vce vce(robust)

cd "${path}"

* ==============================================================================

use "${path}/stata/data/out/Data.dta",clear

* Replacing missing VIX with VXO (uses old methodology)
replace VIX = VXO if missing(VIX)

label var FF_A             "Fed funds rate"
label var PGDP_t           "GDP deflator"
label var PCPI_t           "Headline Inflation"
label var PCPIX_t          "Core inflation"
label var Output_gap_t     "Output gap"
label var Output_gap_dt_t0 "Output gap (detrended)"
label var VIX              "VIX volatility index"

keep if ${Full_Sample}

* ==============================================================================

* Figure 1: Time series of the main variables
foreach var in FF_A PGDP_t1 PCPI_t1 PCPIX_t1 Output_gap_dt_t1 Output_gap_t1 VIX {
	local ytitle
	local yscalerange
	if inlist("`var'","FF_A","Output_gap_dt_t1") {
		local ytitle "%"
	}
	if inlist("`var'","PGDP_t1","PCPI_t1","PCPIX_t1") {
		local yscalerange range(0 15)
	}
	twoway (tsline `var' if ${Full_Sample}, lcolor(navy) lwidth(thick) yline(0)), yscale(titlegap(3) `yscalerange') ttitle("") tlabel(1970q1(40)2000q4, labsize(huge) format(%tqCY)) tmtick(##5) ytitle("`ytitle'", size(huge) orientation(horizontal)) ylabel(#5, labsize(huge) angle(horizontal) format(%4.0f)) scheme(s1mono) name(graph_`var',replace)
	graph export "${path}/stata/figure/graph_`var'.pdf", as(pdf) replace
	graph export "${path}/stata/figure/graph_`var'.eps", as(eps) replace
}

* ============================ Summary Statistics ==============================

* Table 1: Descriptive statistics
estpost sum FF_A PGDP_t1 PCPI_t1 PCPIX_t1 Output_gap_dt_t1 Output_gap_t1 VIX if ${Full_Sample}
est store sum_stat
esttab sum_stat using "${path}/stata/tex/sumstat.tex", replace ///
mtitles("") ///
refcat(headroom "\textbf{\emph{Group 1}}" price "\textbf{\emph{Group 2}}", nolabel) ///
collabels(\multicolumn{1}{c}{{Mean}} \multicolumn{1}{c}{{Std.Dev.}} \multicolumn{1}{l}{{Obs}}) ///
cells("mean(fmt(2)) sd(fmt(2)) count(fmt(0))") label nonumber f noobs alignment(S) booktabs

* ========================= Mean and Variance test =============================

* T-test for equality of means for inflation measures
ttest PCPI_t1 == PCPIX_t1 if ~missing(PCPI_t1) & ~missing(PCPIX_t1)

* F-test for equality of variances for inflation measures
sdtest PCPI_t1 == PCPIX_t1 if ~missing(PCPI_t1) & ~missing(PCPIX_t1)

* Correlation between inflation measures
correlate PGDP_t1 PCPI_t1 PCPIX_t1

* Correlation between output measures
correlate Output_gap_dt_t1 Output_gap_t1

* ==============================================================================

log close
