* ======================= identification of coefficients ======================= 

capture program drop coef_ident_1 coef_ident_1_sq
capture program drop coef_ident_2 coef_ident_2_1 coef_ident_2_2 coef_ident_2_dolado coef_ident_2_as coef_ident_2_sq

program coef_ident_1
	scalar rho = _b[L1.FF_A]+_b[L2.FF_A]
	scalar phi_pi = _b[PGDP_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_x = _b[Output_gap_dt_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	di as input "" _newline "Mean equation"
	di as text "Fed funds rate"
	di as text round(rho,0.001)
	di as text "Inflation"
	di as text round(phi_pi,0.001)
	di as text "Output gap"
	di as text round(phi_x,0.001)
end

program coef_ident_2
	scalar rho = _b[L1.FF_A]+_b[L2.FF_A]
	scalar phi_pi = _b[PCPIX_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_x = _b[Output_gap_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	di as input "" _newline "Mean equation:"
	di as text "Fed funds rate"
	di as text round(rho,0.001)
	di as text "Inflation"
	di as text round(phi_pi,0.001)
	di as text "Output gap"
	di as text round(phi_x,0.001)
end

program coef_ident_2_1
	scalar rho = _b[L1.FF_A]+_b[L2.FF_A]
	scalar phi_pi = _b[PCPI_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_x = _b[Output_gap_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	di as input "" _newline "Mean equation:"
	di as text "Fed funds rate"
	di as text round(rho,0.001)
	di as text "Inflation"
	di as text round(phi_pi,0.001)
	di as text "Output gap"
	di as text round(phi_x,0.001)
end

program coef_ident_2_2
	scalar rho = _b[L1.FF_A]+_b[L2.FF_A]
	scalar phi_pi = _b[PCPI_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_pix = _b[PCPIX_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_x = _b[Output_gap_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	di as input "" _newline "Mean equation:"
	di as text "Fed funds rate"
	di as text round(rho,0.001)
	di as text "Headline Inflation"
	di as text round(phi_pi,0.001)
	di as text "Core Inflation"
	di as text round(phi_pix,0.001)
	di as text "Output gap"
	di as text round(phi_x,0.001)
end

program coef_ident_2_as
	scalar rho = _b[L1.FF_A]+_b[L2.FF_A]
	scalar phi_pi_p = _b[PCPIX_t1_p]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_pi_n = _b[PCPIX_t1_n]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_x_p = _b[Output_gap_t1_p]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_x_n = _b[Output_gap_t1_n]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	di as input "" _newline "Mean equation:"
	di as text "Fed funds rate"
	di as text round(rho,0.001)
	di as text "Inflation >2%"
	di as text round(phi_pi_p,0.001)
	di as text "Inflation <2%"
	di as text round(phi_pi_n,0.001)
	di as text "Output gap +"
	di as text round(phi_x_p,0.001)
	di as text "Output gap -"
	di as text round(phi_x_n,0.001)
end

program coef_ident_2_dolado
	scalar rho = _b[L1.FF_A]+_b[L2.FF_A]
	scalar phi_pi = _b[PCPIX_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_x = _b[Output_gap_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_s2 = _b[Sigma2_PCPIX_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	di as input "" _newline "Mean equation:"
	di as text "Fed funds rate"
	di as text round(rho,0.001)
	di as text "Inflation"
	di as text round(phi_pi,0.001)
	di as text "Output gap"
	di as text round(phi_x,0.001)
	di as text "Variance of inflation"
	di as text round(phi_s2,0.001)
end

program coef_ident_1_sq
	scalar rho = _b[L1.FF_A]+_b[L2.FF_A]
	scalar phi_pi = _b[PGDP_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_pi2 = _b[PGDP2_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_x = _b[Output_gap_dt_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_x2 = _b[Output_gap_dt2_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	di as input "" _newline "Mean equation:"
	di as text "Fed funds rate"
	di as text round(rho,0.001)
	di as text "Inflation"
	di as text round(phi_pi,0.001)
	di as text "Inflation sq"
	di as text round(phi_pi2,0.001)
	di as text "Output gap"
	di as text round(phi_x,0.001)
	di as text "Output gap sq"
	di as text round(phi_x2,0.001)
end

program coef_ident_2_sq
	scalar rho = _b[L1.FF_A]+_b[L2.FF_A]
	scalar phi_pi = _b[PCPIX_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_pi2 = _b[PCPIX2_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_x = _b[Output_gap_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	scalar phi_x2 = _b[Output_gap2_t1]/(1-_b[L1.FF_A]-_b[L2.FF_A])
	di as input "" _newline "Mean equation:"
	di as text "Fed funds rate"
	di as text round(rho,0.001)
	di as text "Inflation"
	di as text round(phi_pi,0.001)
	di as text "Inflation sq"
	di as text round(phi_pi2,0.001)
	di as text "Output gap"
	di as text round(phi_x,0.001)
	di as text "Output gap sq"
	di as text round(phi_x2,0.001)
end
