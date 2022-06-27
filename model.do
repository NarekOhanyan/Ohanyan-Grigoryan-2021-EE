* ==============================================================================
* Section 5: Estimation
* Section 6: Robustness of the model
* ------------------------------------------------------------------------------
*
* This do-file
*
* - replicates Tables 2-10 and Figures 2-3 of Ohanyan & Grigoryan (2020)
*
* - note: the estimated coefficients in the mean equation correspond to
*	values \hat{\beta_{`var'}} = (1-\rho)[\phi_{`var'}], therefore reaction
*	coefficients \phi_{`var'} are identified using the do-file
*	"/do/coef_ident.do" as
*	\phi_{`var'}=\hat{\beta_{`var'}}/(1-\hat{\rho})
*
* - uses files
*	/data/out/Data.dta
*
* - saves files
*	/log/do_model `c(current_date)'.smcl
*
* - saves figures
*	/figure/volatility_`sample'.`format'
*
* 	where
*		`var' = {\pi,x}
*		`sample' = {fullsample,greenspan}
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
global path "INSERT-PATH-HERE"

* Save logs
capture log close
log using "${path}/log/model `c(current_date)'.smcl", replace

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

use "${path}/data/out/Data.dta",clear

* Replacing missing VIX with VXO (uses old methodology)
replace VIX = VXO if missing(VIX)

do "${path}/do/coef_ident.do"

* ================================= Full Sample ================================

* Baseline model
qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${Full_Sample}, ${vce}
est store Full_Sample_baseline
coef_ident_1

* Extended model
qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${Full_Sample}, arch(1) garch(1) ${vce} 
est store Full_Sample_garch
coef_ident_1

* Extended model
qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${Full_Sample}, het(PGDP_t1 Output_gap_dt_t1) ${vce} 
est store Full_Sample_het
coef_ident_1

* Extended model
qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${Full_Sample}, arch(1) garch(1) het(PGDP_t1 Output_gap_dt_t1) ${vce} 
est store Full_Sample_garch_het
coef_ident_1

* Table 2: The estimation results of the model for the whole sample
est table Full_Sample_baseline Full_Sample_garch Full_Sample_het Full_Sample_garch_het, stat(N aic bic) star(0.1 0.05 0.01) b(%5.3f)

* ================================= Sub-Samples ================================

* Baseline model
qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${Pre_Volcker}, ${vce}
est store Pre_Volcker_baseline
coef_ident_1

* Extended model
qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${Pre_Volcker}, het(PGDP_t1 Output_gap_dt_t1) ${vce} 
est store Pre_Volcker_het
coef_ident_1

* ----------------------------------- Volcker ----------------------------------

* Baseline model
qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${Volcker}, ${vce}
est store Volcker_baseline
coef_ident_1

* Extended model
qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${Volcker}, het(PGDP_t1 Output_gap_dt_t1) ${vce} 
est store Volcker_het
coef_ident_1

* ---------------------------------- Greenspan ---------------------------------

* Baseline model
qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${Greenspan}, ${vce}
est store Greenspan_baseline
coef_ident_1

* Extended model
qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${Greenspan}, het(PGDP_t1 Output_gap_dt_t1) ${vce} 
est store Greenspan_het
coef_ident_1

* Table 3: The estimation results of the model for the subsamples
est table Pre_Volcker* Volcker* Greenspan*, stat(N aic bic) star(0.1 0.05 0.01) b(%5.3f)

* ================================== Greenspan =================================

* Baseline model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, ${vce}
est store baseline
coef_ident_2

* Extended model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPIX_t1 Output_gap_t1) ${vce} 
est store extended
coef_ident_2

* Table 4: The estimation results of the model for Alan Greenspan's era
est table baseline extended, stat(N aic bic) star(0.1 0.05 0.01) b(%5.3f)

* ------------------- Determinants of Greenspan's discretion -------------------

* Baseline model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, ${vce}
est store baseline
coef_ident_2

* Extended-1 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1) ${vce} 
est store extended_1
coef_ident_2

* Extended-2 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) ${vce} 
est store extended_2
coef_ident_2

* Table 5: The estimation results of the model with additional variance regressors for Alan Greenspan's era
est table baseline extended_1 extended_2, stat(N aic bic) star(0.1 0.05 0.01) b(%5.3f)

* ============================ Degree of Discretion ============================

* --------------------------------- Full Sample --------------------------------

gen res = .
gen sqrt_h = .
label var res "Residuals of the policy rule"
label var sqrt_h "Conditional standard deviation"

qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${Full_Sample}, het(PGDP_t1 Output_gap_dt_t1) arch(1) garch(1) ${vce} 
predict eps,res
predict h, var
replace res = eps if ${Full_Sample}
replace sqrt_h = sqrt(h) if ${Full_Sample}
drop eps h

twoway (tsline res, lcolor(navy) lwidth(medthick)) (tsline sqrt_h, lcolor(maroon) lwidth(thick)) if ${Full_Sample}, yline(0) yscale(range(-4 8)) ylabel(-4(2)8, angle(horizontal)) ttitle("") tlabel(, format(%tqCY)) tmtick(##5) title("") scheme(s1mono) name(volatility_fullsample,replace) // Volatility of policy shocks
graph export "${path}/figure/volatility_fullsample.eps", as(eps) preview(on) replace
graph export "${path}/figure/volatility_fullsample.pdf", as(pdf) replace

drop res sqrt_h

* --------------------------------- Sub-Samples --------------------------------
/*
gen res = .
gen sqrt_h = .
label var res "Residuals of the policy rule"
label var sqrt_h "Conditional standard deviation"

foreach subsample in Pre_Volcker Volcker Greenspan {
	qui arch FF_A l(1/2).FF_A PGDP_t1 Output_gap_dt_t1 if ${`subsample'}, het(PGDP_t1 Output_gap_dt_t1) ${vce} 
	predict eps,res
	predict h, var
	replace res = eps if ${`subsample'}
	replace sqrt_h = sqrt(h) if ${`subsample'}
	drop eps h
}

*twoway (tsline sqrt_eps2) (tsline sqrt_h, lwidth(medthick)) if ${Full_Sample}, tline(1979q3 1987q3, lcolor(black) lpattern(dot)) ttitle("") tlabel(, format(%tqCY)) title("Volatility of policy shocks") note(Note: Vertical lines represent Volcker's and Greenspan's appointment as the Fed Chairman, span margin(medium)) name(volatility_subsamples,replace)
twoway (tsline res, lcolor(navy) lwidth(medthick)) (tsline sqrt_h, lcolor(maroon) lwidth(thick)) if ${Full_Sample}, tline(1979q3 1987q3, lcolor(black) lpattern(dot)) yline(0) yscale(range(-6 4)) ylabel(-6(2)4, angle(horizontal)) ttitle("") tlabel(, format(%tqCY)) tmtick(##5) title("") scheme(s1mono) name(volatility_subsamples1,replace) // Volatility of policy shocks
graph export "${path}/figure/volatility_subsamples.eps", as(eps) preview(on) replace
graph export "${path}/figure/volatility_subsamples.pdf", as(pdf) replace

drop res sqrt_h
*/
* ---------------------------------- Greenspan ---------------------------------

gen res = .
gen sqrt_h = .
label var res "Residuals of the policy rule"
label var sqrt_h "Conditional standard deviation"

qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) ${vce} 

predict eps,res
label var eps "Residuals"
predict h, var
replace res = eps
replace sqrt_h = sqrt(h)

twoway (tsline res, lcolor(navy) lwidth(medthick)) (tsline sqrt_h, lcolor(maroon) lwidth(thick)) if ${Greenspan}, yline(0) ylabel(,angle(horizontal)) ttitle("") tlabel(, format(%tqCY)) tmtick(##5) title("") scheme(s1mono) name(volatility_greenspan,replace) // Volatility of policy shocks
graph export "${path}/figure/volatility_greenspan.eps", as(eps) preview(on) replace
graph export "${path}/figure/volatility_greenspan.pdf", as(pdf) replace

drop eps res h sqrt_h

* ---------------------------------- Greenspan ---------------------------------
/*
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) ${vce} 

predict eps,res

gen rb = _b[L1.FF_A]*d.l1.FF_A + _b[L2.FF_A]*d.l2.FF_A + _b[PCPIX_t1]*d.PCPIX_t1 + _b[Output_gap_t1]*d.Output_gap_t1
gen db = d.eps
*gen df = d.FF_A
gen df = rb+db

corr rb db
qui sum rb
scalar Var_rb = r(Var)
qui sum db
scalar Var_db = r(Var)

di "The contribution of rule-based component = " 100*Var_rb/(Var_rb+Var_db)
di "The contribution of discretionary component = " 100*Var_db/(Var_rb+Var_db)

label var df "Change of the Fed funds rate"
label var rb "Rule-based"
label var db "Discretionary"

*twoway (bar rb date if ${Greenspan}) (bar db date if ${Greenspan}) (line df date if ${Greenspan}, lcolor(black) lwidth(medthick)), ttitle("") tlabel(, format(%tqCY)) ytitle("%") name(g1,replace)
twoway (bar df date if ${Greenspan} & ((rb < 0 & db < 0) | (rb > 0 & db > 0)), lcolor(sand) fcolor(sand)) (bar rb date if ${Greenspan}, lcolor(maroon) fcolor(maroon)) (bar db date if ${Greenspan} & ((rb > 0 & db < 0) | (rb < 0 & db > 0)), lcolor(sand) fcolor(sand)) (line df date if ${Greenspan}, lcolor(black) lwidth(medthick)), yscale(titlegap(3)) ttitle("") tlabel(, format(%tqCY)) tmtick(##5) ytitle("%", orientation(horizontal)) yline(0) legend(order(2 "Rule-based" 3 "Discretionary" 4 "Change of the Fed funds rate")) scheme(s1mono) name(ffr_rb_db_decomposition,replace)
graph export "${path}/figure/ffr_rb_db_decomposition.pdf", as(pdf) replace
*/

* ============================== Robustness checks =============================

* Extended-1 model with CPIX in mean equation (for robustness)
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) ${vce} 
est store extended_2_PCPIX_t1
coef_ident_2

* Extended-2 model with CPI in mean equation (for robustness)
qui arch FF_A l(1/2).FF_A PCPI_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) ${vce} 
est store extended_2_PCPI_t1
coef_ident_2_1

* Extended-2 model with CPI and CPIX in mean equation (for robustness)
qui arch FF_A l(1/2).FF_A PCPI_t1 PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) ${vce} 
est store extended_2_PCPI_t1_PCPIX_t1
coef_ident_2_2

* Table 6: The estimation results of the models with headline and core inflation in the mean equation
est table extended_2_PCPIX_t1 extended_2_PCPI_t1 extended_2_PCPI_t1_PCPIX_t1, stat(N ll aic bic) star(0.1 0.05 0.01) b(%5.3f)

* --------------------------- Asymmetric (threshold) ----------------------------

gen dd_PCPIX_t1      = (PCPIX_t1     >=2)
gen dd_PCPI_t1       = (PCPI_t1      >=2)
gen dd_Output_gap_t1 = (Output_gap_t1>=0)

gen PCPIX_t1_p       = PCPIX_t1     *   dd_PCPIX_t1
gen PCPIX_t1_n       = PCPIX_t1     *(1-dd_PCPIX_t1)
gen PCPI_t1_p        = PCPI_t1      *   dd_PCPI_t1
gen PCPI_t1_n        = PCPI_t1      *(1-dd_PCPI_t1)
gen Output_gap_t1_p  = Output_gap_t1*   dd_Output_gap_t1
gen Output_gap_t1_n  = Output_gap_t1*(1-dd_Output_gap_t1)

* Extended model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) ${vce}
est store extended_2
coef_ident_2

* Extended model asymmetric
qui arch FF_A l(1/2).FF_A PCPIX_t1_p PCPIX_t1_n Output_gap_t1_p Output_gap_t1_n if ${Greenspan}, het(PCPI_t1_p PCPI_t1_n PCPIX_t1_p PCPIX_t1_n Output_gap_t1_p Output_gap_t1_n L.VIX) ${vce}
est store extended_2_1_as
coef_ident_2_as

test [FF_A]:PCPIX_t1_p      == [FF_A]:PCPIX_t1_n
test [FF_A]:Output_gap_t1_p == [FF_A]:Output_gap_t1_n
test [HET]:PCPI_t1_p        == [HET]:PCPI_t1_n
test [HET]:PCPIX_t1_p       == [HET]:PCPIX_t1_n
test [HET]:Output_gap_t1_p  == [HET]:Output_gap_t1_n

* Table 7: The estimation results of the symmetric and asymmetric models for Alan Greenspan's era
est table extended_2 extended_2_1_as, stat(N aic bic) star(0.1 0.05 0.01) b(%5.3f)

* --------------------------- Non-linear Taylor rule ------------------------------

* Generating squares of PCPIX and Output_gap
gen PCPI2_t1 = PCPI_t1^2
gen PCPI2_t2 = PCPI_t2^2
gen PCPIX2_t1 = PCPIX_t1^2
gen PCPIX2_t2 = PCPIX_t2^2
gen Output_gap2_t = Output_gap_t^2
gen Output_gap2_t1 = Output_gap_t1^2

* Baseline model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if $Greenspan, $vce
est store baseline
coef_ident_2
qui arch FF_A l(1/2).FF_A PCPIX_t1 PCPIX2_t1 Output_gap_t1 Output_gap2_t1 if $Greenspan, $vce
est store baseline_nl
coef_ident_2_sq

* Extended model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if $Greenspan, het(PCPIX_t1 Output_gap_t1) $vce 
est store extended
coef_ident_2
qui arch FF_A l(1/2).FF_A PCPIX_t1 PCPIX2_t1 Output_gap_t1 Output_gap2_t1 if $Greenspan, het(PCPIX_t1 Output_gap_t1) $vce 
est store extended_nl
coef_ident_2_sq

* Extended-2 model
qui qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if $Greenspan, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) $vce 
est store extended_2
coef_ident_2
qui qui arch FF_A l(1/2).FF_A PCPIX_t1 PCPIX2_t1 Output_gap_t1 Output_gap2_t1 if $Greenspan, het(PCPI_t1 PCPIX_t1 Output_gap_t1  L.VIX) $vce 
est store extended_2_nl
coef_ident_2_sq

* Table 8: The estimation results of nonlinear specifications
est table baseline baseline_nl extended extended_nl extended_2 extended_2_nl, stat(N aic bic) star(0.1 0.05 0.01) b(%5.3f)

* ---------------------------- Non-linear Phillips curve ----------------------------

arch PCPIX_t1 if $Greenspan, arch(1) garch(1)
predict Sigma2_PCPIX_t1 if $Greenspan, variance

qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if $Greenspan, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) $vce 
est store extended_2
coef_ident_2

qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 Sigma2_PCPIX_t1 if $Greenspan, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) $vce 
est store extended_2_mean
coef_ident_2_dolado

qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 Sigma2_PCPIX_t1 if $Greenspan, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX Sigma2_PCPIX_t1) $vce 
est store extended_2_mean_var
coef_ident_2_dolado

* Table 9: The estimation results of the models corresponding to linear and nonlinear versions of the Phillips curve
est table extended_2 extended_2_mean extended_2_mean_var, stat(N aic bic) star(0.1 0.05 0.01) b(%5.3f)

* ---------------------------- Additional regressors ---------------------------

* Extended-2 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) ${vce} 
est store extended_2
coef_ident_2

* Extended-3 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX L.unrate) ${vce} 
est store extended_3_1
coef_ident_2

* Extended-3 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX L.d_ln_reer) ${vce} 
est store extended_3_2
coef_ident_2

* Extended-3 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX L.GS1 L.GSslope) ${vce} 
est store extended_3_3
coef_ident_2

* Extended-3 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX L.unrate L.d_ln_reer L.GS1 L.GSslope) ${vce} 
est store extended_3
coef_ident_2

* Table 10: The estimation results of the model with additional variance regressors for Alan Greenspan's era
est table extended_2 extended_3_1 extended_3_2 extended_3_3 extended_3, stat(N aic bic) star(0.1 0.05 0.01) b(%5.3f)

* ==============================================================================

* The code below decomposes the changes in volatility into contributions of regressors

/*
gen v_PCPI_t1       = _b[HET:PCPI_t1]      *d.PCPI_t1
gen v_PCPIX_t1      = _b[HET:PCPIX_t1]     *d.PCPIX_t1
gen v_Output_gap_t1 = _b[HET:Output_gap_t1]*d.Output_gap_t1
gen v_L_VIX         = _b[HET:L.VIX]        *d.L.VIX


gen v_PCPI_t1_PCPIX_t1                     = v_PCPI_t1 + v_PCPIX_t1
gen v_PCPI_t1_PCPIX_t1_Output_gap_t1       = v_PCPI_t1 + v_PCPIX_t1 + v_Output_gap_t1
gen v_PCPI_PCPIX_Output_gap_VIX = v_PCPI_t1 + v_PCPIX_t1 + v_Output_gap_t1 + v_L_VIX

twoway (bar v_PCPI_t1_PCPIX_t1 date if ${Greenspan} & ((v_PCPI_t1 <= 0 & v_PCPIX_t1 <= 0) | (v_PCPI_t1 >= 0 & v_PCPIX_t1 >= 0)), lcolor(maroon) fcolor(maroon)) (bar v_PCPI_t1 date if ${Greenspan}, lcolor(navy) fcolor(navy)) (bar v_PCPIX_t1 date if ${Greenspan} & ((v_PCPI_t1 > 0 & v_PCPIX_t1 < 0) | (v_PCPI_t1 < 0 & v_PCPIX_t1 > 0)), lcolor(maroon) fcolor(maroon)) (line v_PCPI_t1_PCPIX_t1 date if ${Greenspan}, lcolor(black) lwidth(medthick)), ttitle("") tlabel(, format(%tqCY)) ytitle("%", orientation(horizontal)) ylabel(, angle(horizontal)) yline(0) legend(order(2 "Rule-based" 3 "Discretionary" 4 "Change of fed funds rate")) scheme(s1mono) name(g3,replace)

twoway (bar v_PCPI_t1_PCPIX_t1_Output_gap_t1 date if ${Greenspan} & (abs(v_PCPI_t1_PCPIX_t1_Output_gap_t1) >= abs(v_PCPI_t1_PCPIX_t1)), lcolor(red) fcolor(red)) ///
	(bar v_PCPI_t1_PCPIX_t1 date if ${Greenspan} & (abs(v_PCPI_t1_PCPIX_t1) >= abs(v_PCPI_t1)), lcolor(maroon) fcolor(maroon)) ///
	(bar v_PCPI_t1 date if ${Greenspan}, lcolor(navy) fcolor(navy)) ///
	(bar v_PCPIX_t1 date if ${Greenspan} & (abs(v_PCPI_t1_PCPIX_t1) < abs(v_PCPI_t1)), lcolor(maroon) fcolor(maroon)) ///
	(bar v_Output_gap_t1 date if ${Greenspan} & (abs(v_PCPI_t1_PCPIX_t1_Output_gap_t1) < abs(v_PCPI_t1_PCPIX_t1)), lcolor(red) fcolor(red)) ///
	(line v_PCPI_t1_PCPIX_t1_Output_gap_t1 date if ${Greenspan}, lcolor(black) lwidth(medthick)), ///
	ttitle("") tlabel(, format(%tqCY)) ytitle("%", orientation(horizontal)) ylabel(, angle(horizontal)) yline(0) legend(order(2 "Rule-based" 3 "Discretionary" 4 "Change of fed funds rate")) scheme(s1mono) name(g4,replace)

twoway (bar  date if ${Greenspan} & (abs(v_PCPI_t1_PCPIX_t1_Output_gap_t1) >= abs(v_PCPI_t1_PCPIX_t1)), lcolor(red) fcolor(red)) ///
	(bar  date if ${Greenspan} & (abs(v_PCPI_t1_PCPIX_t1) >= abs(v_PCPI_t1)), lcolor(maroon) fcolor(maroon)) ///
	(bar  date if ${Greenspan}, lcolor(navy) fcolor(navy)) ///
	(bar  date if ${Greenspan} & (abs(v_PCPI_t1_PCPIX_t1) < abs(v_PCPI_t1)), lcolor(maroon) fcolor(maroon)) ///
	(bar  date if ${Greenspan} & (abs(v_PCPI_t1_PCPIX_t1_Output_gap_t1) < abs(v_PCPI_t1_PCPIX_t1)), lcolor(red) fcolor(red)) ///
	(line  date if ${Greenspan}, lcolor(black) lwidth(medthick)), ///
	ttitle("") tlabel(, format(%tqCY)) ytitle("%", orientation(horizontal)) ylabel(, angle(horizontal)) yline(0) legend(order(2 "Rule-based" 3 "Discretionary" 4 "Change of fed funds rate")) scheme(s1mono) name(g4,replace)

twoway (bar v_PCPI_PCPIX_Output_gap_VIX date if ${Greenspan}) (bar v_PCPI_t1_PCPIX_t1_Output_gap_t1 date if ${Greenspan}) (bar v_PCPI_t1_PCPIX_t1 date if ${Greenspan}) (bar v_PCPI_t1 date if ${Greenspan})
*/

* ================================== Appendix ==================================

/*
* Extended-2 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX) ${vce} 
est store extended_2
coef_ident_2

* Extended-3 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 L.unrate if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX L.unrate) ${vce} 
est store extended_3_1_
coef_ident_2

* Extended-3 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 L.d_ln_reer if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX L.d_ln_reer) ${vce} 
est store extended_3_2_
coef_ident_2

* Extended-3 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 L.GS1 L.GS5 L.GS10 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX L.GS1 L.GS5 L.GS10) ${vce} 
est store extended_3_3_
coef_ident_2

* Extended-3 model
qui arch FF_A l(1/2).FF_A PCPIX_t1 Output_gap_t1 L.unrate L.d_ln_reer L.GS1 L.GS5 L.GS10 if ${Greenspan}, het(PCPI_t1 PCPIX_t1 Output_gap_t1 L.VIX L.unrate L.d_ln_reer L.GS1 L.GS5 L.GS10) ${vce} 
est store extended_3_
coef_ident_2

* Table 5: The estimation results with additional variance regressors
est table extended_2 extended_3_1_ extended_3_2_ extended_3_3_ extended_3_, stat(N ll aic bic) star(0.1 0.05 0.01) b(%5.3f)
*/

* ==============================================================================

log close
