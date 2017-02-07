**************************************************************************************
******************************* ICM 6th month survey *********************************
**************************************************************************************

*                                 2. PROGRAMS
The
** Programer: Isabel Onate
** Date created: 02/15/2016
** Last modified: 
display "$S_DATE"

/* 
This do file performs 2 main tasks:
	1) Installs the user writter commands required to run all the code (if they have not already been downloaded by the user). 
	2) Defines the programs that were written to perform some of repeated tasks, in an automated way. 
	A description of what each program istalled or defined here does is included below.
*/

program drop _all

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                 1) INSTALL PROGRAMS
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
labrec: 	Recodes variables keeping the labels in the order as the original variable. 
			For example if I have a variable labeled "strongly agree" with value 1 but want to recode 
			this to 5 keeping the value label as "strongly agree" instead of loosing the label 
			(what happens with "recode") and the having to define the label again.
			Note: this program has a bug.
		
outreg2: 	Exports semi formated tables. i use this to export regression results.

fstcd: 		Automates the process of changing directories within Stata. I define a permanent 
			directory which the allows me to use my globals do file and run it in the beginin 
			of any other do file
		
rmfiles: 	Removes files from a specified directory. I use this to remove text files 
			created by outreg2 when exporting results

sxpose: 	Transposes a dataset of string variables, so that observations become variables, and vice versa.

winsor:		Winzorazes variables - creating a new var (the ones stated in PAP)


 
*/

// Add user written commands that might need to be installed for the code to run 
foreach package in labrec outreg2 fastcd rmfiles sxpose winsor { 	
	cap which `package' 											// checks if the command has already been downloaded
	if _rc==111 ssc install `package' 								// if not, installs the package
}

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                 2) DEFINE PROGRAMS
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// These are programs written for this prject, to perform repetaed tasks

// "REORDER"
**  To change the order of values of a var
program define reorder 
	args x
	qui tab `x'
	local y =`r(r)'
	local z =`y'-1
	local answers
	forvalues i=0/`z' {
		local a = `y'-`i'
		local b = `i'+ 1
		local answers `answers' (`a' = `b')
	}
	labrec `x' `answers'
end

// "DUMMYS"
** This program generates dummys for categorical variables and labes the variable with the val label of each value
program define dummys // 
	args x
	tab `x', gen (`x'_)
	levelsof `x', local(levels)
	local lbl : value label `x'
	foreach l of local levels {
		local f`l' : label `lbl' `l'
		label var `x'_`l' "`f`l''"
	}
end

// "STAN"
** Standardize variables - this program uses the mean and sd of the control group to stadardize a var or an index "x".
program define stan // 
	args x
		qui sum `x' if treatment==0
		local mean `r(mean)'
		local sd `r(sd)'
		gen z_`x' = (`x' - `mean')/`sd'
		loc varlabel: variable label `x'
		la var z_`x' `"z-score: `varlabel'"' 
end


// "MISSING"
** Recode missing values to "0" and generates a new binary variable with the prefix "m_" that indicated which observations were recoded (had missing values)
program missing
	args x
	gen m_`x'=missing(`x')
	gen `x'_r = `x'
	recode `x'_r (missing=0) 
	loc varlabel: variable label `x'
	la var m_`x' `"missing: `varlabel'"'
	la var `x'_r `"missing=0: `varlabel'"'
end

/*
program missing
	args x
	gen m_`x'=missing(`x')
	recode `x' (missing=0) 
end
*/

