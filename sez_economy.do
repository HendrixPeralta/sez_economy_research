*cd "/Users/hendrixperalta/Documents"

*insheet using "data.csv", comma clear
*insheet using "long_df.csv", comma clear
import delimited "https://raw.githubusercontent.com/HendrixPeralta/research_data/main/aggregated%20_data/municipalities/long_df.csv", clear


drop if year == 2000

xtset id year

gen sez = 0
replace sez = 1 if ent > 0

destring pop, replace
gen pop1 = pop/100000 
gen lpop = ln(pop1)
gen emp = ob_f_ + tec_f_ + adm_f_ + ob_m_ + tec_m_ + adm_m_
gen prep3 = prep^3
gen sal_tec2 = sqrt(sal_tec)
rename ntl egdp

replace emp = cond(missing(emp), cond(missing(l1.emp), 0, l1.emp), emp)
replace sal_tec2 = 0 if missing(sal_tec2)

misstable summarize

* TESTS

* tests 
ladder ntl_
ladder urb_
ladder temp
ladder prep
ladder pop1
ladder sal_tec
ladder sal_op
ladder ocu
ladder tss
ladder wat
ladder inf
ladder com
ladder ele
ladder ent
ladder emp

* local variables 
/*
	gen crimepc = crime/lpop
	gen lcrimepc = ln(crimepc)
	
	gen sqent = sqrt(ent)
	gen sqinv = sqrt(inv)
	gen inv1 = inv/10000000
	gen tec_salary1 = tec_salary/1000

*/

* lagged variables
/*
	gen dcrimepc = crimepc - l1.crimepc
	gen dinv = inv - l1.inv
	gen dent = ent - l1.ent
	gen dlcrimepc = lcrimepc - l1.lcrimepc
	gen dtec_salary = tec_salary - l1.tec_salary
*/

* eq1 ===================================================
eststo mod1: quietly reg egdp sez 
quietly estadd local FE_province  "No", replace
quietly estadd local FE_year      "No", replace

eststo mod2: quietly reg egdp sez i.year 
quietly estadd local FE_province  "No", replace
quietly estadd local FE_year      "Yes", replace

eststo mod3: quietly xtreg egdp sez  i.year, fe vce(robust)
quietly estadd local FE_province  "Yes", replace
quietly estadd local FE_year      "Yes", replace

esttab mod1 mod2 mod3, keep(sez) b(3) se(3) star(* 0.05 ** 0.01 *** 0.001) label ///
varlabels(sez "SEZ")

*vce(robust)


eststo mod4: quietly xtreg egdp sez lpop i.year, fe vce(robust)
quietly estadd local FE_province  "Yes", replace
quietly estadd local FE_year      "Yes", replace

eststo mod5: quietly xtreg egdp sez lpop urb_ i.year, fe vce(robust)
quietly estadd local FE_province  "Yes", replace
quietly estadd local FE_year      "Yes", replace

eststo mod6: quietly xtreg egdp sez lpop urb_ prep i.year, fe vce(robust)
quietly estadd local FE_province  "Yes", replace
quietly estadd local FE_year      "Yes", replace

eststo mod7: quietly xtreg egdp sez lpop urb_ prep temp i.year, fe vce(robust)
quietly estadd local FE_province  "Yes", replace
quietly estadd local FE_year      "Yes", replace

esttab mod4 mod5 mod6 mod7, keep(sez lpop urb_ prep temp) b(3) se(3) star(* 0.05 ** 0.01 *** 0.001) label ///
varlabels(sez "SEZ" lpop "Log Population" urb_ "Urban Land Cover" prep "Prepcipitation" temp "Temperature")

esttab mod4 mod5 mod6 mod7 using "egdp-sez.tex", replace ///
    keep(sez lpop urb_ prep temp) ///
    se label stats(N N_g r2 FE_province FE_year, fmt(0 0 2) label("Observations" "N Provinces" "R-squared" "Province FE" "Year FE")) ///
    mtitles("EGDP" "EGDP" "EGDP" "EGDP") nonotes ///
    addnote("Notes: The dependent variable is the homicides per capita." ///
            "All models include a constant" ///
            "$* p<0.10, ** p<0.05, *** p<0.01") star(* 0.10 ** 0.05 *** 0.01) b(%7.3f) ///
	varlabels(sez "SEZ" lpop "Log Population" urb_ "Urban Land Cover" prep "Prepcipitation" temp "Temperature")

*ent emp tss sal_tec inf ocu ele 
* eq2 ==========================================================
eststo mod8: quietly xtreg egdp sez ent lpop i.year, fe vce(robust)
quietly estadd local FE_province  "Yes", replace
quietly estadd local FE_year      "Yes", replace


eststo mod9: quietly xtreg egdp sez ent emp lpop urb_ i.year, fe vce(robust)
quietly estadd local FE_province  "Yes", replace
quietly estadd local FE_year      "Yes", replace

eststo mod10: quietly xtreg egdp sez ent emp tss lpop urb_ prep i.year, fe vce(robust)
quietly estadd local FE_province  "Yes", replace
quietly estadd local FE_year      "Yes", replace

eststo mod11: quietly xtreg egdp sez ent emp tss sal_tec inf ocu ele  lpop urb_ prep temp i.year, fe vce(robust)
quietly estadd local FE_province  "Yes", replace
quietly estadd local FE_year      "Yes", replace

esttab mod8 mod9 mod10 mod11, keep(ent emp tss sal_tec inf ocu ele  lpop urb_ prep temp) b(3) se(3) star(* 0.05 ** 0.01 *** 0.001) 
*label ///
*varlabels(sez "SEZ" lpop "Log Population" urb_ "Urban Land Cover" prep "Prepcipitation" temp "Temperature")


xtreg egdp sez lpop urb_ prep temp i.year, fe vce(robust)
hettest
