

cd "/Users/hendrixperalta/Downloads/NU 202304/Fall/Industrial Development/Final Industrial Development"

*insheet using "data.csv", comma clear
insheet using "sez_edu.csv", comma clear

gen sez = 0
replace sez = 1 if ent > 0

gen pop1 = pop/100000 
gen lpop = ln(pop)


xtset id year


*sez_edu =================================================================


* local variables 
gen crimepc = crime/lpop
gen c_mortality = c_death/birth
gen dropout = med_edu_dropout + bas_edu_dropout
gen lcrimepc = ln(crimepc)
gen sqdrop = sqrt(dropout)
gen sqent = sqrt(ent)
gen sqinv = sqrt(inv)
gen invpp = sqinv/ent
gen inv1 = inv/10000000
gen linv = ln(inv)
gen tec_salary1 = tec_salary/1000
*gen lc_mort = ln(c_mortality)
gen dcrimepc = crimepc - l1.crimepc
gen dinv = inv - l1.inv
gen dent = ent - l1.ent
gen ddrop = dropout - l1.dropout
gen dlpop = lpop - l1.lpop
gen dlcrimepc = lcrimepc - l1.lcrimepc
gen dtec_salary = tec_salary - l1.tec_salary


* tests 
ladder inv
ladder crimepc
ladder dropout
ladder tec_salary
ladder ent 
ladder c_mortality

corr  sez ent l_inv c_mortality tec_salary
corr  ent l_inv c_mortality tec_salary med_edu_dropout


* models with non transformed variables 
reg crimepc sez 
reg crimepc sez ent
reg crimepc ent l_inv 
reg crimepc ent l_inv c_mortality
reg crimepc ent l_inv c_mortality tec_salary 
reg crimepc ent l_inv c_mortality tec_salary dropout  
reg crimepc ent l_inv c_mortality tec_salary dropout year i.id


vif

* 
reg crimepc sez 
reg crimepc ent l_inv 
reg crimepc ent l_inv year 
reg crimepc ent l_inv year i.id

reg crimepc ent l_inv lpop 
reg crimepc ent l_inv lpop year 
reg crimepc ent l_inv lpop year i.id

reg crimepc ent l_inv lpop dropout
reg crimepc ent l_inv lpop dropout year 
xtreg crimepc ent l_inv lpop dropout year,fe
vif 

* regression with dummy sez 
reg lcrimepc sez year 
xtreg lcrimepc sez, fe
hettest
**


reg lcrimepc ent linv tec_salary year
reg lcrimepc ent linv tec_salary year 
xtreg lcrimepc ent linv  tec_salary year, fe

* 2 positive one negative 
reg lcrimepc sqent linv sqdrop
reg lcrimepc sqent linv sqdrop year 

xtset id year
xtreg lcrimepc sqent linv sqdrop, fe
* 


scatter dcrimepc dent

* significant 
reg dcrimepc sez 
reg dcrimepc dent 
reg dcrimepc dent dinv ddrop  tec_salary

xtset id year
reg dcrimepc dent dinv ddrop tec_salary year 
xtreg dcrimepc dent dinv ddrop tec_salary, fe
* heteroscedastic 

* not significant
reg dlcrimepc sez 
reg dlcrimepc dent 
reg dlcrimepc dent dinv tec_salary
reg dlcrimepc dent dinv  tec_salary year
xtreg dlcrimepc dent dinv tec_salary year, fe
hettest
* homoscedastic 

xtset id year
reg dlcrimepc dent dinv dlpop ddrop tec_salary year 
xtreg dlcrimepc dent dinv dlpop ddrop tec_salary,fe

corr  dent dinv dlpop ddrop tec_salary




* significant 
reg dcrimepc sez 
reg dcrimepc dent 
reg dcrimepc dent dinv ddrop  tec_salary


reg dlcrimepc dent dinv ddrop tec_salary 



eststo mod1: quietly reg crimepc sez 
quietly estadd local FE_province  "No", replace
quietly estadd local FE_year      "No", replace

eststo mod2: quietly reg crimepc sez year
quietly estadd local FE_province  "No", replace
quietly estadd local FE_year      "Yes", replace

eststo mod3: quietly xtreg crimepc sez  year, fe
quietly estadd local FE_province  "Yes", replace
quietly estadd local FE_year      "Yes", replace

esttab mod1 mod2 mod3 using "crime_sez.tex", replace ///
    keep(sez) ///
    se label stats(N N_g r2 FE_province FE_year, fmt(0 0 2) label("Observations" "N Provinces" "R-squared" "Province FE" "Year FE")) ///
    mtitles("OLS" "1-FE" "2-FE") nonotes ///
    addnote("Notes: The dependent variable is the homicides per capita." ///
            "All models include a constant" ///
            "$* p<0.10, ** p<0.05, *** p<0.01") star(* 0.10 ** 0.05 *** 0.01) b(%7.3f) compress



*estimates store model2

*estimates store model3

*esttab model1 model2 model3, title(Crime - SEZ)


eststo mod4: quietly reg crimepc ent inv1 tec_salary1
quietly estadd local FE_province  "No", replace
quietly estadd local FE_year      "No", replace

eststo mod5: quietly reg crimepc ent inv1 tec_salary1 year 
quietly estadd local FE_province  "No", replace
quietly estadd local FE_year      "Yes", replace

eststo mod6: quietly xtreg crimepc ent inv1 tec_salary1 year, fe
quietly estadd local FE_province  "Yes", replace
quietly estadd local FE_year      "Yes", replace

esttab mod4 mod5 mod6, title(Crime - ent)	

esttab mod4 mod5 mod6 using "crime_ent.tex", replace ///
    keep(ent inv1 tec_salary1) ///
    se label stats(N N_g r2 FE_province FE_year, fmt(0 0 2) label("Observations" "N Provinces" "R-squared" "Province FE" "Year FE")) ///
    mtitles("OLS" "1-FE" "2-FE") nonotes ///
    addnote("Notes: The dependent variable is the homicides per capita." ///
            "All models include a constant" ///
            "$* p<0.10, ** p<0.05, *** p<0.01") star(* 0.10 ** 0.05 *** 0.01) b(%7.3f) compress


reg dcrimepc sez
estimates store model4
hettest
reg dcrimepc sez year 
estimates store model5
xtreg dcrimepc sez year, fe
estimates store model6

esttab model4 model5 model6, title(Crime - ent)			
			
			
reg dcrimepc ent inv tec_salary
estimates store model4
hettest
reg dcrimepc dent dinv dtec_salary year 
estimates store model5
xtreg dcrimepc dent dinv dtec_salary year, fe
estimates store model6

esttab model4 model5 model6, title(Crime - ent)

reg crimepc ent inv tec_salary 



** test dropout 
reg sqdrop sez 
reg sqdrop sez year
xtreg sqdrop sez year, fe


reg  sqdrop  ent 
reg  sqdrop  ent  year
xtreg sqdrop ent year, fe

reg sqdrop  ent inv  tec_salary lcrimepc
reg dropout  ent inv tec_salary lcrimepc  year 
xtreg dropout  ent inv  tec_salary lcrimepc year, fe

reg ddrop dlcrimepc dent dinv dlpop  tec_salary 
graph box sqdrop, over(sez)
graph twoway (lfit sqdrop ent) (scatter sqdrop ent)
*sez_edu =================================================================



reg dlcrimepc tec_salary
hettest

graph box crimepc, over(sez) 

graph twoway (lfit crimepc ent) (scatter crimepc ent)
graph twoway (lfit lcrimepc tec_salary) (scatter lcrimepc tec_salary)
graph twoway (lfit dlcrimepc dent) (scatter dlcrimepc dent)


***** final graphs 

graph box lcrimepc, over(sez) label 
    legend(off) 
    title("Box Plot of Crimepc by Sez") 
    ytitle("Crimepc") 
    xlabel(0 "Sez = 0" 1 "NO = 1") 
    note("Sez = 1 indicates sez") 
    noteangle(0)
	
	
	


*Data =================================================================
ladder pop
ladder inv
ladder op
ladder ent


drop if sez == 0 

reg ntl sez 
reg ntl sez pop
reg ntl sez pop sqinv 
reg ntl sez pop sqinv ent  
reg ntl sez pop sqinv ent  op 
reg ntl sez pop sqinv ent  op tc


reg ntl sez year 
reg ntl sez pop year
reg ntl sez pop sqinv year 
reg ntl sez pop sqinv ent year  
reg ntl sez pop sqinv ent  op year
reg ntl sez pop sqinv ent  op tc year

reg ntl sez year 
reg ntl sez sqinv year 
reg ntl sez sqinv tc  year 



corr ntl sez sqinv tc op pop

corr ntl sez sqinv tc op lpop ent 


reg ntl sqinv tc ent
vif 

corr ntl inv tc ent

*Data =================================================================




















******* GUIDE **********************************************************************

*****Constructing "Management Practice" variables
*====Cleaning data
*What Best Describes What Happened When Problem In The Production Process Arose?
tab r1  
tab r1  , nolab
recode r1 (-9 -7=.)
*How Many Production Performance Indicators Were Monitored At This Establishment?
tab r3 
tab r3  , nolab
recode r3 (-9=.)
*How Easy To Achieve Its Production Targets?
tab r6
tab r6, nolab
*recode r6 (-9=.)

*Who Was Aware Of The Production Targets At This Establishment?
tab r7
tab r7, nolab
*recode r7 (-9=.)

*Does this establishment offer performance bonus to managers
*tab ASCr111
tab r8


*What Were Managers' Performance Bonuses Usually Based On?
tab r9
tab r9, nolab
recode r9 (-9=.)
 


*====Variable construction
*monitoring
gen moquan=r3
recode moquan (4=0)
sum moquan
replace moquan=(0-moquan)/(0-3)


gen moqual=r1
recode moqual (4=0)
sum moqual
replace moqual=(0-moqual)/(0-3)

gen monitor=(0.5*moquan)+(0.5*moqual)


*target setting
gen taquan=r7
sum taquan
replace taquan=(1-taquan)/(1-4)

gen taqual=r6
sum taqual
replace taqual=(6-taqual)/(6-1)
gen target=(0.5*taquan)+(0.5*taqual)

*people management
gen pmquan=r8
sum pmquan
replace pmquan=(2-pmquan)/(2-1)

gen pmqual=r9
sum pmqual
replace pmqual=(1-pmqual)/(1-4)
gen pmanage=(0.5*pmquan)+(0.5*pmqual)

*Management practice
gen manage=(monitor+ target+ pmanage)/3

*****Constructing "Sales" variables

*annual sales
tab d2, nolabel
recode d2 (-9 =.)

gen lsales=ln(d2)

*tw (scatter lsales manage )


*annual sales three years ago
tab n3
tab n3, nolabel
recode n3 (-9 -7=.)

*sales growth (three years)
gen sg=((d2-n3)/n3)
replace sg=. if sg==149
tab sg
*tw (scatter sg manage )



*****Constructing "Other" variables
*sector
clonevar sector=a4a
*Firm age
ta b5
recode b5 (-9=.) 
gen fage=2017-b5
gen lfage=ln(fage)

*firm fize
ta  l1
recode l1 (-9=.) 
gen fsize=l1
gen lfsize=ln(fsize)




*******************************************************************************************************************************************************

*******************************************************************************************************************************************************




* k6 k8 k7 k3bc k3e k5bc1 k5e1
*define firms with checking or saving accounts
recode k6 (-9=.) (2=0), gen (bankacc)
label var bankacc "does firm have bank account?"
label define bankacc 1 "Yes" 0 "No"
label values bankacc bankacc

*k8  - does not have invalid values 
*define firms with line of credit/loan from financial institution
recode k8 (-9=.) (2=0), gen (linecred)
label var linecred "does firm currently have a line of credit or loan from a financial institution?"
label define line_cred 1 "Yes" 0 "No"
label values linecred line_cred

*k7
*define firms with overdraft  
recode k7 (-9=.) (2=0), gen (overdraft)
label var overdraft "Does firm currently have overdraft?"
label define overdraft 1 "Yes" 0 "No"
label values overdraft overdraft

*k3bc
*working capital that was finance by bank loan
recode k3bc (-9=.) , gen (wcapb)
label var wcapb "Working capital finance by bank loan?"

*k3e
*working capital that was finance by microfinance
recode k3e (-9=.) , gen (wcapm)
label var wcapm "Working capital by microfinance?"

*k5bc1 - does not have invalid values 
*Fixed asset (Investment) that was financed by bank loan
recode k5bc (-9=.) , gen (invb)
label var inv "Is investment finance by bank loan?"
 
*k5e1 - does not have invalid values 
*Fixed asset (Investment) that was financed by microfinance
recode k5e (-9=.)  , gen (invm)
label var invm "Investment finance by microfinance?"



*define firms that have credits. credits: combine line of credit, overdraft, working cap finance by bank loan, and investment finance by bank loan.  

recode wcapb invb (0=0) (.=.) (else=1),gen(wcap inv)


*(will leave missing variable as missing)
egen credit= rowmax (linecred overdraft wcap inv)
label var credit "Does firm have credit?"
label define credit 1 "Yes" 0 "No"
label values credit credit 

*alternative method
*gen credit=.
*replace credit=1 if linecred==1
*replace credit=1 if overdraft==1
*replace credit=1 if wcap==1
*replace credit=1 if inv==1
*replace credit=0 if credit==.
*label var credit "Does firm have credit?"
*label define credit 1 "Yes" 0 "No"
*label values credit credit 


*depth A categorical variable that contains a count of how many credit products a firm reports. One point is added for each of the following: 
*overdraft, loan or line of credit, bank financing for working capital, and bank financing for investment
egen depth= rowtotal (overdraft linecred wcap inv), missing



*gen capital
*capital is proxied by the amount of money spent on the purchase of machinery and land/building in last FY
recode n5a (-9=.), gen(machine)
recode n5b (-9=.), gen(land)
gen cap = (machine + land)
gen lncap = ln(cap)
label var lncap "log of capital"

 
*gen input, proxied by Total annual cost of raw materials and intermediate goods used in production
recode n2e (-9=.), gen(input)
gen lninput = ln(input)
label var lninput "log of intermediate input"




*******************************************************************************************************************************************************

*******************************************************************************************************************************************************


*define credit constraint firm*
*firm are considered credit constrain when:
*1. applied for credit but was denied ---------- k20a1

	
recode k20a1 (-9 -6=.) (2=1) (3 4=0), gen (nocred)
label var nocred "Applied for credit but was denied"
label define nocred 1 "Approved" 0 "Denied"
label values nocred nocred


*2. did not apply due to: application procedure were complex, interest rates were not favorable,
	*collateral requirements were too high, size of loan and maturity wer insufficient
	*and did not think it would be approve ----------------k17
	
recode k17 (2/7=0), gen (complex)
label var complex "Was the application procedure complex"
label define complex 0 "Yes" 1 "No"
label values complex complex

egen kcons = rowmax (nocred complex)
label var kcons "Is the firm capital constrained?"
label define kcons 1 "Non Capital Constrained" 0 "Capital constrained"
label values kcons kcons 	 

* 2) Implications:

* 1. (Verified in class using the command "binscatter" )

*2. Capital constraints impact firm size universally: Capital constraints affect the size of firms across the board, regardless of their management ability.

*reg lfsize manage lfage kcons  i.sector if lfsize<5,  vce(cluster id)
reg lfsize manage lfage kcons sg i.sector,  vce(cluster id)
outreg2  using result01.xls, ctitle("") label bdec(3) se  excel nocons append

* 3. High-ability entrepreneurs face significant challenges: While capital constraints affect all firms, they pose particularly significant challenges to high-ability entrepreneurs. These individuals, with the potential for substantial growth, may find their ambitions curtailed by limited access to capital.
graph box manage, over(kcons)

* 4. Inefficient allocation of resources: Capital constraints can lead to an inefficient allocation of resources. Firms with high management ability and innovative ideas may be unable to access the capital needed for expansion, while less capable firms may have excess capital relative to their potential.

twoway (scatter lfsize manage) (lfit lfsize manage), by(kcons)	
reg 
* 5. Stifled economic growth: When high-ability entrepreneurs face barriers to expanding their businesses, it can result in a slower pace of economic development and reduced innovation. 

*To submit your completed assignment, please upload it to TATC under the "Lecture 6_Firm_Capital" category. Your submission should consist of a .pdf document that includes all relevant Stata output and a .do file containing all the commands.


reg lsales manage lfage lfsize i.sector,  vce(cluster id)
outreg2  using result01.xls, ctitle("") label bdec(3) se  excel nocons replace  

reg sg manage lfage lfsize i.sector,  vce(cluster id)
outreg2  using result01.xls, ctitle("") label bdec(3) se  excel nocons append

reg lfsize manage lfage  i.sector,  vce(cluster id)
outreg2  using result01.xls, ctitle("") label bdec(3) se  excel nocons append
