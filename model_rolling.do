* ==============================================================================
* Section 6: Robustness of the model
* ------------------------------------------------------------------------------
*
* This do-file
*
* - replicates Figures 4-5 of Ohanyan & Grigoryan (2020)
*
* - uses files
*	/stata/data/tmp/estimation_rolling.dta
*
* - saves files
*	/stata/log/do_model_rolling `c(current_date)'.smcl
*
* - saves figures
*	/stata/figure/rolling_m_b_`var1'.`format'
*	/stata/figure/rolling_v_b_`var2'.`format'
*
* 	where
*		`var1' = {AR,PCPIX_t1,Output_gap_t1}
*		`var2' = {PCPI_t1,PCPIX_t1,Output_gap_t1,VIX}
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
log using "${path}/stata/log/model_rolling `c(current_date)'.smcl", replace

* Defining a global for Greenspan's period
global Greenspan "date>=tq(1987q3) & date<=tq(2005q4)"

* Defining a variance estimation method
global vce vce(robust)

cd "${path}/stata/"

* ==============================================================================

use "${path}/stata/data/out/Data.dta",clear

* Replacig missing VIX with VXO (uses old methodology)
replace VIX = VXO if missing(VIX)

* ================================== Greenspan =================================

arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) ${vce} 

rolling _b _se, window(40) saving("${path}/stata/data/tmp/estimation_rolling.dta",replace): ///
arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) ${vce}

* ==============================================================================

*preserve

use "${path}/stata/data/tmp/estimation_rolling.dta", clear
gen date = round((start+end)/2)
tsset date, quarterly

rename _stat_1 FF_A_b_AR1
rename _stat_2 FF_A_b_AR2
rename _stat_9 HET_b_VIX
rename _stat_11 FF_A_se_AR1
rename _stat_12 FF_A_se_AR2
rename _stat_19 HET_se_VIX 

gen FF_A_b_AR = FF_A_b_AR1 + FF_A_b_AR2

label var FF_A_b_AR "Fed funds rate"
label var FF_A_b_AR1 "Fed funds rate t-1"
label var FF_A_b_AR2 "Fed funds rate t-2"
label var FF_A_b_PCPIX_t1 "Core inflation"
label var FF_A_b_Output_gap_t1 "Output gap"
label var HET_b_PCPI_t1 "Headline inflation"
label var HET_b_PCPIX_t1 "Core inflation"
label var HET_b_Output_gap_t1 "Output gap"
label var HET_b_VIX "VIX"

label var FF_A_se_AR1 "SE Fed funds rate t-1"
label var FF_A_se_AR2 "SE Fed funds rate t-2"
label var FF_A_se_PCPIX_t1 "SE Core inflation"
label var FF_A_se_Output_gap_t1 "SE Output gap"
label var HET_se_PCPI_t1 "SE Headline inflation"
label var HET_se_PCPIX_t1 "SE Core inflation"
label var HET_se_Output_gap_t1 "SE Output gap"
label var HET_se_VIX "SE VIX"

replace FF_A_b_PCPIX_t1 = FF_A_b_PCPIX_t1 / ( 1 - FF_A_b_AR)
replace FF_A_b_Output_gap_t1 = FF_A_b_Output_gap_t1 / ( 1 - FF_A_b_AR)

* -------------------------------- Mean equation -------------------------------

twoway (tsline FF_A_b_AR , lcolor(navy) lwidth(thick) yscale(range(0 1.1) titlegap(3)) yline(0)), ttitle("") tlabel(, labsize(vlarge) format(%tqCY)) tmtick(##5) ytitle({&rho}, size(huge) orientation(horizontal)) ylabel(#4, angle(vertical) labsize(vlarge)) /*title("`: var label FF_A_b_AR'")*/ legend(off) scheme(s1mono) name(FF_A_b_AR,replace) //  
graph export "${path}/stata/figure/rolling_m_b_AR.pdf", as(pdf) replace
graph export "${path}/stata/figure/rolling_m_b_AR.eps", as(eps) preview(on) replace

twoway (tsline FF_A_b_PCPIX_t1, lcolor(navy) lwidth(thick) yscale(range(0 2.1) titlegap(3)) yline(0)), ttitle("") tlabel(, labsize(vlarge) format(%tqCY)) tmtick(##5) ytitle({&phi}{sub:{&pi}}, size(huge) orientation(horizontal)) ylabel(#4, angle(vertical) labsize(vlarge)) /*title("`: var label FF_A_b_PCPIX_t1'")*/ legend(off) scheme(s1mono) name(FF_A_b_PCPIX_t1,replace) // yline(0) 
graph export "${path}/stata/figure/rolling_m_b_PCPIX_t1.pdf", as(pdf) replace
graph export "${path}/stata/figure/rolling_m_b_PCPIX_t1.eps", as(eps) preview(on) replace

twoway (tsline FF_A_b_Output_gap_t1, lcolor(navy) lwidth(thick) yscale(range(0 1.1) titlegap(3)) yline(0)), ttitle("") tlabel(, labsize(vlarge) format(%tqCY)) tmtick(##5) ytitle({&phi}{sub:x}, size(huge) orientation(horizontal)) ylabel(#4, angle(vertical) labsize(vlarge)) /*title("`: var label FF_A_b_Output_gap_t1'")*/ legend(off) scheme(s1mono) name(FF_A_b_Output_gap_t1,replace) // yline(0) 
graph export "${path}/stata/figure/rolling_m_b_Output_gap_t1.pdf", as(pdf) replace
graph export "${path}/stata/figure/rolling_m_b_Output_gap_t1.eps", as(eps) preview(on) replace

* ------------------------------ Variance equation -----------------------------

twoway (tsline HET_b_PCPI_t1, lcolor(navy) lwidth(thick)), yscale(titlegap(3)) ttitle("") tlabel(, labsize(vlarge) format(%tqCY)) tmtick(##5) yline(0) ytitle({&delta}{sub:{&pi}}{sup:h}, size(huge) orientation(horizontal)) ylabel(#4, angle(vertical) labsize(vlarge)) /* title("`: var label HET_b_PCPI_t1'") */ legend(off) scheme(s1mono) name(HET_b_PCPI_t1,replace) // yline(0) 
graph export "${path}/stata/figure/rolling_v_b_PCPI_t1.pdf", as(pdf) replace
graph export "${path}/stata/figure/rolling_v_b_PCPI_t1.eps", as(eps) preview(on) replace

twoway (tsline HET_b_PCPIX_t1, lcolor(navy) lwidth(thick)), yscale(titlegap(3)) ttitle("") tlabel(, labsize(vlarge) format(%tqCY)) tmtick(##5) tmtick(##5) yline(0) ytitle({&delta}{sub:{&pi}}{sup:c}, size(huge) orientation(horizontal)) ylabel(#4, angle(vertical) labsize(vlarge)) /* title("`: var label HET_b_PCPIX_t1'") */ legend(off) scheme(s1mono) name(HET_b_PCPIX_t1,replace) // yline(0) 
graph export "${path}/stata/figure/rolling_v_b_PCPIX_t1.pdf", as(pdf) replace
graph export "${path}/stata/figure/rolling_v_b_PCPIX_t1.eps", as(eps) preview(on) replace

twoway (tsline HET_b_Output_gap_t1, lcolor(navy) lwidth(thick)), yscale(titlegap(3)) ttitle("") tlabel(, labsize(vlarge) format(%tqCY)) tmtick(##5) yline(0) ytitle({&delta}{sub:x}, size(huge) orientation(horizontal)) ylabel(#4, angle(vertical) labsize(vlarge)) /* title("`: var label HET_b_Output_gap_t1'") */ legend(off) scheme(s1mono) name(HET_b_Output_gap_t1,replace) // yline(0) 
graph export "${path}/stata/figure/rolling_v_b_Output_gap_t1.pdf", as(pdf) replace
graph export "${path}/stata/figure/rolling_v_b_Output_gap_t1.eps", as(eps) preview(on) replace

twoway (tsline HET_b_VIX, lcolor(navy) lwidth(thick)), yscale(titlegap(3)) ttitle("") tlabel(, labsize(vlarge) format(%tqCY)) tmtick(##5) yline(0) ytitle({&delta}{sub:v}, size(huge) orientation(horizontal)) ylabel(#4, angle(vertical) labsize(vlarge)) /* title("`: var label HET_b_VIX'") */ legend(off) scheme(s1mono) name(HET_b_VIX,replace) // yline(0) 
graph export "${path}/stata/figure/rolling_v_b_VIX.pdf", as(pdf) replace
graph export "${path}/stata/figure/rolling_v_b_VIX.eps", as(eps) preview(on) replace

* ==============================================================================

log close
