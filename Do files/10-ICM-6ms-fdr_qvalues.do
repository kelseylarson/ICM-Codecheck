**************************************************************************************
******************************* ICM 6th month survey *********************************
**************************************************************************************

*                     10. Q VALUE ADJUSTMENTS - FALSE DISCOVERY RATE


** Programer: Isabel Onate
** Date created: 09/16/2016
** Last modified: 11/07/2016
display "$S_DATE"

macro drop _all
clear all
set more off
set type double

/* 
This do file calculates the false discovery rate and outputs the adjusted q values 
(analog of the p value = adjusted p value) that result from multiple hypothesis 
correction. (Hocheberger adjustemnt)

We use the regular adjustement (as opposed to the sharpened procedure).

This do file is a modification of Michael Andersen code, which can be found here: 
https://are.berkeley.edu/~mlanderson/ARE_Website/Research.html

A notable feature of this test is that it tells you whether or not each p-value can be 
rejected at every a given significance level, but doesn't automatically give the q-value. 
What Andersen's code (and thi do file) does is first test at .999 significance level, 
then .998, then so on until .001, and saves the q-value as the smallest value at which 
the null can be rejected.

Tests: According to the PAP we will split outcomes into religious outcomes (1st stage) 
and non religious outcomes (downstream effects). We will make the adjustments for the 
following groups of p values and run the adjustment for each group separately: 

	- Group 1: 	Religious outcomes - VHL vs HL and V vs C (8 pvalues)
	- Group 2: 	Non religious primary outcomes - V vs C (6 pvalues). 
				We dont include VHL vs HL here because this group doesnt show any 
				significant q values for 1st stahe = religion
	- Group 3: Religious outcomes - Any V vs C (4 pvalues)
	- Group 4: Non religious primary outcomes - Any V vs C (6 pvalues)
 

INPUT: data file with outcome variable names, and p values for the 2 different tests
OUTPUT: Excel file with the q values 
*/

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                    DEFINE PATHS
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// GLOBALS DO FILE
c ICM_6ms_dir
*cd "C:\Users\ifalomir\Dropbox\ICM Project Management - Internal\16. Data\6th Month Survey\Do files"
qui include "Do files\1-ICM-6monthsurvey-globals"

cd "$data\Results matrices"
use "ICM-6monthsurvey-pvalues_adj", clear // use the dataset containg p values for the 2 tests we are interested in

tempfile q_1 // VHL vs HL and V vs C:  group 1 of outcomes - religious vars (first stage)
tempfile q_2 // V vs C: group 2 of outcomes - non religious vars, economic vars
tempfile q_3 // Any V vs C: group 1 of outcomes - religious vars (first stage)
tempfile q_4 // Any V vs C: group 2 of outcomes - non religious vars, economic vars

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                    OUTCOMES
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// Rename p values
rename VHL_HL p1 
rename V_C p2
rename anyV_C p3


// Groups of variables: religous and non religious
			
local vars_religion		z_religion_intr_a_i ///
						z_religion_extr_i ///
						z_general_religion_i ///
						religion_listr_i 
			
local vars_economic		tot_consumption ///
						z_food_security_i ///
						household_income ///
						tothrs_ad ///
						z_life_satisfacton_i ///
						relative_ses 


// Main indices in primary outcomes
*  We are only interested in making the adjustment for the main indices within primary outcomes.
*  Therefore we only keep observations for them and drop all others(incluiding components)

gen main = .
foreach var in `vars_religion' `vars_economic' {
	replace main = 1 if outcome == "`var'"
}

keep if main == 1 // We only do the adjustmenrt for main outcomes of interest
sort sort
gen order = _n
drop main
drop sort

// Tag religious variables
gen group = .
gen religion = 0
foreach var of local vars_religion {
	replace religion = 1 if outcome == "`var'"
	replace group = 1 if outcome == "`var'"
}

foreach var of local vars_economic {
	replace group = 2 if outcome == "`var'"
}

// Variable for q values
gen q = . // empty var to fill with q values


// Some checks
assert 			`: word count `vars_religion'' == 4 		// make sure we have 4 religious vars
assert 			`: word count `vars_economic'' == 6 		// make sure we have 4 religious vars
assert _N == 	`: word count `vars_religion'' + ///
				`: word count `vars_economic'' 				// make sure we have 10 observations
isid outcome 												// make sure all outcomes are unique (no duplicates)

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                    DATA BY GROUPS
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// GROUP 1
preserve
	keep outcome p1 p2 order religion q
	keep if religion == 1 									// Religious variables
	reshape long p, i(outcome) j(test)						// Reshape becaus we have p values here, those for VHL_HL and those for V_C. To make the adjustment for all at the same time we need to have them in the same column
	sort order test
	drop order
	gen initial_order = _n if !mi(p)
	gen group = 1
	order outcome test p q religion initial_order group
	save `q_1', replace
restore

// GROUP 2
preserve
	keep outcome p2 order religion q
	keep if religion == 0
	rename p2 p
	sort order
	gen initial_order = _n
	drop order
	gen test = 2
	gen group = 2
	order outcome test p q religion initial_order group
	save `q_2', replace
restore

// GROUP 3
preserve
	keep outcome p3 order religion q
	keep if religion == 1
	rename p3 p
	sort order
	gen initial_order = _n
	drop order
	gen test = 3
	gen group = 3
	order outcome test p q religion initial_order group
	save `q_3', replace
restore

// GROUP 4
preserve
	keep outcome p3 order religion q
	keep if religion == 0
	rename p3 p
	sort order
	gen initial_order = _n
	drop order
	gen test = 3
	gen group = 4
	order outcome test p q religion initial_order group
	save `q_4', replace
restore


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                ADJUSTMENT BY GROUP
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

forvalues i = 1/4 {
	di in r "Group `i'"
	
	use `q_`i'', clear
	
	tostring initial_order, gen(varname)
	replace varname = "var" + varname
	replace q = 1 if !mi(p)
	sort p
	qui sum p
	drop if mi(p)
	qui sum p
	loc count = `r(N)'
	gen order = _n if !mi(p)

	forvalues qval = .999(-.001).000 {
			* Generate value q'*r/M
				gen fdr_temp = `qval'*order/`count'
				* Generate binary variable checking condition p(r) <= q'*r/M
				gen reject_temp = (fdr_temp>=p) if !mi(fdr_temp)
				* Generate variable containing p-value ranks for all p-values that meet above condition
				gen reject_rank = reject_temp*order
				* Record the rank of the largest p-value that meets above condition
				egen total_rejected = max(reject_rank)
				* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
				replace q = `qval' if order <= total_rejected & !mi(order)
				drop fdr_temp* reject_temp* reject_rank* total_rejected*
				sort initial_order
	}

	assert q > p if !mi(p) // make sure that q values are allways larger than p values
	save `q_`i'', replace
}


// Append data from all 4 groups
use `q_1', clear
append using `q_2'
append using `q_3'
append using `q_4'

label define test 1 "VHL_HL" 2 "V_C" 3 "AnyV_C"
label val test test


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                      EXPORT
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//FORMAT DATA FOR EXPORTIMG
gsort -test -religion initial_order
keep outcome test p q religion group
replace q = 0.999 if q == 1
 
gen q_string = q
tostring q_string, replace force
replace q_string = "[0" + q_string +"]"

cd "$results\Tables\Adjustments"
export excel using "ICM-fdr_qvalues", firstrow(var) sheet(raw) sheetreplace


