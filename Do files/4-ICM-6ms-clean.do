**************************************************************************************
******************************* ICM 6th month survey *********************************
**************************************************************************************

*                                     4. CLEAN

** Programer: Isabel Onate
** Date created: 12/23/2015
** Last modified: 01/18/2015
display "$S_DATE"


/*
This do file cleans the variables that we will use for analysis and saves a semi clean dataset. 
Eventually we should clean all the data contained in this file
The main taks completed in this do file are the following:

	Remove observations for which consent was not given
	Check for complete interviews - format date variables
	Ecode variables that have "other" as possible responses
	Recode missing values - extended missing values
	Recode binary variables 
	Reorder answers in some variables
	Other recodes
	Fix and add labels
	Logic checks
	Fixing errors in variables
	Add variable for pastor
	Merge baseline data form ICM (fox exploratory analysis - HTE) - when this is done a seperate datset is saved with the sufix "_b"
	
	
Note: 	Some of the tasks descried before are done because of the way the CTO instrument was programed. 
		(for example order in repsonses was weird, binary variables were coded inconsistetly etc.)
		Some oter tasks coulnt be done perfectly because of the same reason. 
		Extended missing values could not be coded because the survey had weird answers and values were not consistent across quetsions.
		
*/ 

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                    DEFINE PATHS
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local baseline = 0 // "0" for data without baseline "1" for data with ------------------ MODIFY


// GLOBALS DO FILE
c ICM_6ms_dir
qui include "Do files\1-ICM-6ms-globals"
qui include "Do files\2-ICM-6ms-programs"


cd "$data"
if `baseline' == 1 {
	use "1-ICM-6ms-noPII_b-$date", clear
}
else if `baseline' == 0 {
	use "1-ICM-6ms-noPII-$date", clear
}
else {
	display in r "Local for baseline is not defined!"
	stop
}


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                           CONSENT AND COMPLETE INTERVIEWS
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// CONSENT

*tab treatment if consent==2 	// check for balance - commented out because tretament variable is not yet defined
tab consent_given, m
assert !mi(consent_given)		// all observations should have consent as yes or no (no missing values)
count if consent_given == 2
assert `r(N)' == 60 			// if error check why number of obs has changed

drop if consent_given==2 		// if consent was not given, dorp observations
assert _N == 6507				// if error check why number of obs has changed



// CHECK FOR COMPLETE INTERVIEWS

local dates submissiondate start end datetime_begin 	// variables that correspond to dates
assert !mi(submissiondate)								// chec that all surveys have a submission date

generate incomplete = missing(submissiondate)			// incomplete submissions - we should have none
assert incomplete == 0

*sort key datetime_begin								// Next 2 lines are only relevant if complete = 1
*list key datetime_begin fieldofficer if incomplete == 1

local N=_N
forvalues i = 1/`N' {
	if incomplete == 1 in `i'{
		display "`=id[`i']' `=dup[`i']'"
	}
	if end < start in `i' {
		display "`=id[`i']' `=dup[`i']'"
	}
}


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                     DESTRING
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Some variable have been exported into stata as strings when they should be numerical.
// This section converts them into numerical and labels them

** HH
destring haspartner hasmalepartner hasson30 hasdaughter30, replace
destring nummembers, replace // number of household members

** MOBILE MONEY
split mm4, gen(mm4_)
destring mm4_1, replace
destring mm4_2, replace

label define mm4 1 "Yes - Banko" 2 "Yes - Gcash" 3 "Yes - Smart Money" 4 "Yes - Other" 5 "No"
label val mm4_1 mm4
label val mm4_2 mm4

replace mm4_2=. if mm4_2==5 // we cant have someone a bank account and no bank account as a second option


**KESSLER - Dummies
local feel 	feel_nervous_cal ///
			feel_hopeless_ca ///
			feel_restless_ca ///
			feel_depressed_c ///
			feel_effort_calc ///
			feel_worthless_c //
			
label define feel 0 "No" 1 "Yes"
foreach var of local feel {
	destring `var', replace
	label val `var' feel
}

** INCOME GENERATING ACTIVITIES
destring outside_repeats, replace // number of members of the household working outside

** GENDER
destring respondent_gender, replace
recode respondent_gender (2=0)
label define gender 1 "Male" 0 "Female"
label val respondent_gender gender

** MIGRATION
forvalues i=1/20 {
	cap confirm var loc_work_time_`i'
	if _rc==0 {
		destring loc_work_time_`i', replace
		*recode loc_work_time_`i' (.98 = -98) // CHECK!!!!
	}
}

** EDUCATION
forvalues i=1/20 {
	cap confirm var educ_`i'
	if _rc==0 {
		destring educ_`i', replace
	}
}


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                  RECODE "OTHER" RESPONSES								------ This section is not complete!!!
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* 
This section checks for resposnses categorized as "other" - only for variables used for analysis.
I created an excel file in the do file "list_others" where I identify variables that have such 
responses and export a list of observations into an excel file called "Others".
In this file I looked for obs that need to be recoded. If there are too many we could use a 
read replace file. In the case of the variables of interest I was able to make the changes with the next code.

Variables: 	v18 - 	look for electricity in file "Others-readreplace". 
					I found a few cases of responses "No electricity" that need to be replaces as "0"
			v3 - 	look for concrete in file "Others-readreplace". I found no changes
			

NOTE: for the march 2016 analysis not all the variables with "other" responses were checked and recoded!!!!!
*/


// RELIGION
label define religion 0 "Agnostic or atheist" 1 "Catholic" 2 "Muslim" 3 "Iglesia Filipina Independiente" 4 "Iglesia Ni Cristo" 5 "Jehovah's Witness" 6 "Protestant (Evangelical, Baptist, etc.)" 7 "Mormon" 8 "Buddhist" .o "Don't know"

forvalues i=1/20 {
	replace religion_`i'=".o" if religion_`i'=="other"
	destring religion_`i', replace
	label val religion_`i' religion
}


// ENERGY - v18
split v18, gen(v18_)

replace v18_other = lower(v18_other)
*replace v18_1 = "3" if strmatch( v18_other , "*solar*") & v18_2==""
*replace v18_2 = "3" if strmatch( v18_other , "*solar*") & v18_2!=""
replace v18_1 = "0" if strmatch( v18_other , "*no electricity*") & v18_2==""
replace v18_2 = "0" if strmatch( v18_other , "*no electricity*") & v18_2!=""

replace v18_1=".o" if v18_1=="other" // I create another category for other=3 in order to destring the variable and label
replace v18_2=".o" if v18_2=="other"

destring v18_1, replace
destring v18_2, replace

label define v18 0 "No lighting arrangment" 1 "Kerosene" 2 "Electricity" .o "Other"
label val v18_1 v18
label val v18_2 v18

// FLOORS - v3
label define v3 1 "Concrete" 2 "Metal" 3 "Straw/thatch/sod" 4 "Tile/asbestos" 5 "Tarpaulin/plastic" .o "Other"
split v3, gen(v3_)
foreach var of varlist `r(varlist)' {
	replace `var'=".o" if `var'=="other"
	destring `var', replace
	label val `var' v3
}

// DISCUSS ISSUES - discuss_freq
label define discuss_freq 7 "Daily" 6 "A few times a week" 5 "Weekly" 4 "A few times a month" 3 "Monthly" 2 "A few times a year" 1 "Yearly" .d "Dont know" .o "Other"
replace discuss_freq = "2" if discuss_freq_other == "Three times a week" // (id 253011)
replace discuss_freq = "3" if discuss_freq_other == "weekly" // (id 41025)
replace discuss_freq = "6" if discuss_freq_other == "5 times a year" // (id 212002)
replace discuss_freq = ".o" if discuss_freq == "other" // (id 212002)

destring discuss_freq, replace
label val discuss_freq discuss_freq


// PAY variables

/* For this variables first we will generate an additional one that contains the info for the payments that were not in philiphino pesos PHP.
This was we can begin analysis and summary stats only for those payments in PHP
Later when we correct for the other units we can add this information to the pay variable
*/

label define pay_unit 1 "PHP" 2 "KG" 3 "L" 4 "other"
foreach var of varlist pay_unit_* {
	replace `var'="4" if `var'=="other"
	destring `var', replace
	label val `var' pay_unit
}

forvalues i=1/7 {            // 7 economic activities
	forvalues n=1/20 {        // max 18 members of the household. 20 just in case. Check why some members not there 
			cap confirm var pay_`i'_`n'
			if _rc == 0 {
				gen pay_noPHP_`i'_`n' = pay_`i'_`n' if pay_unit_`i'_`n' == 2 | pay_unit_`i'_`n' == 3 | pay_unit_`i'_`n' == 4
				replace pay_`i'_`n' = . if pay_unit_`i'_`n' == 2 | pay_unit_`i'_`n' == 3 | pay_unit_`i'_`n' == 4
				move pay_noPHP_`i'_`n' pay_unit_`i'_`n'
			}
	}
}


// REASONS FOR MIGRATING
label define migrate 1 "Had to (economic necessity)" 2 "Wanted to" 
forvalues i=1/20 {
	replace migrate_reason_`i' = lower(migrate_reason_`i')
	replace migrate_reason_`i'=".o" if migrate_reason_`i'=="other"
	destring migrate_reason_`i', replace
	label val migrate_reason_`i' migrate
}

// SORCES OF TENSION 
replace source_worry=".o" if source_worry=="other"
destring source_worry, replace


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                  RECODE MISSING VALUES									KELSEY: could you check if what I did in this section makes sense to you?
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
This section is complicated. The CTO instrument has no consistency of codes for extended 
missing values in different quetsions.
For example some quetsions "Dont know" was coded and -98, while in others it was -99 (see instrument)
I tried to make all the questions have consistent values, but for some this was not possible. 
In these cases I recoded all negative values as "."
This is far form ideal but it wa sthe best alternative to clean the data and avoid mistakes.

We want to make sure that for every variable the values are coded in the following way:
	Dont know = -98
	Refusal = -99
	Dont understand = -97
	No spouse/partner = -96
*/

// RECODE VALUES  ----------------------- KELSEY, COULD YOU CHECK THIS WITH THE CTO SPREADSHEET?
labrec resp_available (-66=-99) (-98=5) // I recoded response "No-Other" to 5 instead of -98.
labrec hs2 hs3 (-99=-98) // This command recodes the variable while keeping th evalue label.
labrec w3 w32 (-99=-98)
labrec v9 v10 v13 v19 v22 (-99=-98)
labrec vill_meet (-99=-98)
labrec comm_act (-99=-98)
labrec fs1 fs2 fs5 (-99=-98)
labrec mm1 mm8 (-99=-98)
labrec bring_cash_1-bring_cash_12 (-99=-98)
labrec remit_1-remit_12 (-99=-98)
labrec y3_1-y3_20(-99=-98)

// CORRECT ERRORS
recode religious_lit (99=-99) // There is one obervation with the value 99 - I decided this would be treated as an error and that the person actually intended to respond -99 (refusal)
recode feel_unable_day (98=-98) // I decided that observations with values 98 would be recoded to -98. The max of this variable should be 30.
recode feel_partial_day (98=-98)
recode feel_doc_day (98=-98)


// CLASSIFY VARIBALES
qui ds, has(type numeric) 								// Numeric variables
local numeric `r(varlist)' 
qui ds, has(vallabel) 									// Variables with value labels (categorical)
local labels `r(varlist)'
local num_lab : list numeric & labels 					// Numeric variables with value labels - KELSEY: do you see any reason why this group should be different to the one saved as "`labels'"?
local num_nolab : list numeric - labels 				// numeric variables without value labels

assert `: word count `labels'' == `: word count `num_lab''



// RECODE NUMERIC VARIABLES 
// I recoded all these variables to "." if they have negative values. It was impossible to figure out what values represented "other" as opposed to "refusals" etc.
foreach var of local num_nolab {
	qui replace `var'=. if `var'<0
}

// RECODE CATEGORICAL VARIABLES
foreach var of local num_lab { 								// this could also use the local "labels"
	if (!missing(`"`: value label `var''"')) {
		qui labrec `var' (-98=.d) (-99=.r) (-97=.u) (-96=.s)
	}
}


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                  RECODE BINARY VARIABLES
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// In the CTO instrument binnary variables had different values. 


preserve
include "$do_files\CTO_binary_recode" // this do file saves locals with the list of variables that have the previous lables and need to be recoded
restore

local errors
local ambiguous

foreach x of local labels {
	foreach var of local `x' {
		cap confirm var `var'
		if _rc==0 {
			cap labrec `var' (2=0)
		}
		if _rc==111 {
			local ambiguous `ambiguous' `var'
		}
		if _rc!=0 & _rc!=111 {
			local errors `errors' `var'
		}
	}
}
display "`errors'"

display "`ambiguous'"                             // variables of the form: var_i
*alive away_now curr_home lt1 perm_home school vacc y1 z4 bring_cash remit y3 gender migrate_reason

foreach var of local ambiguous {                  // we need to make sure all the varibales have the same label. Otherwise the labrec command wont work
	cap confirm var `var'_1 
	if _rc==0 {
		local lbe : value label `var'_1
		forvalues i=1/20 {
			cap label val `var'_`i' `lbe'
		}
	}
}

foreach var of local ambiguous {                  // now we recode
	cap confirm var `var'_1
	if _rc==0 {
		labrec `var'_1 (2=0)
	}
	if _rc==111 {
		local ambiguous2 `ambiguous2' `var'
	}
}

display "`ambiguous2'"                             // variables of the form: var_i_j

foreach var of local ambiguous2 {
	cap confirm var `var'_1_1
	if _rc==0 {
		local lbe : value label `var'_1_1
		forvalues i=1/5 {
			forvalues j=1/3 {
				cap label val `var'_`i'_`j' `lbe'
			}
		}
	}
}

foreach var of local ambiguous {
	cap confirm var `var'_1_1
	if _rc==0 {
		labrec `var'_1_1 (2=0)
	}
}


macro drop labels errors ambiguous ambiguous2

**********************************************************************************************
*********************************** CHANGE ORDER OF RESPONSES ********************************
**********************************************************************************************

preserve
include "$do_files\CTO_reorder_recode" // this do file saves locals with the list of variables that have to be reordered
restore

local errors
local ambiguous
foreach x of local labels {
	foreach var of local `x' {
		cap confirm var `var'
		if _rc==111 {
			local ambiguous `ambiguous' `var'
		}
		if _rc==0 {
			reorder `var'
		}
		if _rc!=0 & _rc!=111 {
				local errors `errors' `var'
		}
		
	}
}
macro drop labels
display "`errors'"
display "`ambiguous'"

** variables in the ambiguous category 
foreach var of local ambiguous {                  // we need to make sure all the varibales have the same label. Otherwise the labrec command wont work
	cap confirm var `var'_1 
	if _rc==0 {
		local lbe : value label `var'_1
		forvalues i=1/20 {
			cap label val `var'_`i' `lbe'
		}
	}
	if _rc!=0 {
		cap confirm var `var'_1_1
		if _rc==0 {
			local lbe : value label `var'_1_1
			forvalues i=1/20 {
				forvalues i=1/20 {
					cap label val `var'_`i'_`j' `lbe'
				}
			}
		}
	}
}


reorder z2_1 // for some reason this command takes care of all the variables when just specifying one number at the end
reorder lit_1
reorder lt2_1_1


** Variables with "ladder as a possible answer need to be recoded, while changing the labels as well. This is why I use recode instead of labrec for these
local recode 	life_sat ///
				future_life_sat ///
				relative_ses ///
				future_relative_ses //

foreach var of local recode {
	recode `var' (1=10) (2=9) (3=8) (4=7) (5=6) (6=5) (7=4) (8=3) (9=2) (10=1)
}			


** some variables with weird order
labrec v4 (2=3) (3=2)
labrec v5 (2=3) (3=2)				
labrec hs6 (2=3) (3=2)

** variables with the label or "other" --------------------- Check: try to incluide in the prvious loop......
reorder discuss_freq

reorder u6 // check if this should be made in other do file


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                  RECODE OTHER VARIABLES
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

replace female_spouse_head = "No female spouse/partner" if female_spouse_head == "96"



*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                          LABELS
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

** LADDER
label var life_sat "How would describe your satisfaction with life? (1 Very dissatisfied - 10 Very satisfied)"
label var future_life_sat "On the same ladder, which step do you believe you will be on in 5 years?"
label var relative_ses "Where would you place your household on the ladder in terms of economic status? (1 Poorest individuals - 10 Best-off members)"
label var future_relative_ses "Where do you think you will be on this ladder 5 years from now – in terms of your economic status?"


label var r1 "How optimistic are you in general (1-7, “not at all optimistic”-“very optimistic”)?"
label var r2 "How pessimistic are you in general (1-7, “not at all pessimistic”-“very pessimistic”)?"

** LOCUS OF CONTROL
label define wvs_loc 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10"
label val wvs_loc wvs_loc


** VIOLENCE
foreach var of varlist u1 u2 u3 u4 u5 {
	label define `var' -96 "No spouse/Partner", modify
}

** OPTIMISM
label define r 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 
label val r1 r
label val r2 r


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                     LOGIC CHECKS
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

** RELIGION VARIABLES
assert missing(icm_convince_others_fre) if icm_convince_others==0
replace icm_convince_others_fre=0 if icm_convince_others==0 // do this because of skip pattern of the question
assert missing(icm_convince_others_fre) if missing(icm_convince_others)
replace icm_convince_others=0 if icm_convince_others_fre==0 // line added after assertion - frequency is more accurate.
assert icm_convince_others_fre>0 if icm_convince_others ==1 // assertion is false. Some obs said yes to first question and then replied 0 to the second. 
assert icm_convince_others==0 if icm_convince_others_fre==0 // assertion is false


** FOOD SECURITY
** Note that first question is for last 6 months and seccond only for last 7 days. Take this in consideration for the logic checks. In this case fist question can be "yes" but seccond "0"
assert missing(hs7) if hs6==3 // assertion is true
replace hs7=0 if hs6==3 
assert hs7==0 if hs6==3 // assertion is false because of skip pattern


** SOCIAL CAPITAL
** community activities
assert missing(comm_act_freq) if comm_act ==0
assert comm_act_freq > 0 if comm_act == 1
assert missing(comm_act_freq) if missing(comm_act)
replace comm_act_freq = 0 if comm_act == 0
assert comm_act_freq==0 if comm_act ==0 // assertion is false before the replace

label define comm_act_freq 0 "Didn't participate", add

** discuss personal problems
assert missing(discuss_freq) if discuss_person == 0 // beacuse of skip pattern
assert discuss_freq > 0 if discuss_person == 1
assert missing(discuss_freq) if missing(discuss_person)
replace discuss_freq = 0 if discuss_person == 0
assert discuss_freq==0 if discuss_person ==0 // assertion is false before the replace

label define discuss_freq 0 "Didn't discuss", add

** recieve and give meals
assert missing(w31) if w3== 0 // beacuse of skip pattern
assert missing(w31) if missing(w3)
replace w3 = 0 if w31 == 0 // ---------------------- Contradiction - frequency more accurate
assert w31 > 0 if w3 == 1
replace w31 = 0 if w3 == 0
assert w31==0 if w3 ==0

assert missing(w33) if w32== 0 // beacuse of skip pattern
assert missing(w33) if missing(w32)
replace w32 = 0 if w33 == 0 // ---------------------- Contradiction - frequency more accurate
assert w33 > 0 if w32 == 1
replace w33 = 0 if w32 == 0
assert w33==0 if w32 ==0


** ASSETS
** savings-------------------------------------------NO SKIP PATTERN !!!!!
replace fs1 = 0 if fs7 == 0 // we do this changes after looking at the following assertion
assert fs7 > 0 if fs1 == 1 // this one was false in so we added the previous lines of code to recode these observations
replace fs1 = 1 if fs7 >0 & !missing(fs7)

count if fs1==1 & fs7==0 // people than answered "yes" and 0
count if missing(fs1) & fs7==0 // people that answered "dont know" and 0
count if fs1!=0 & fs7==0 // sum of the previous 2

count if fs1==0 & fs7>0 & !missing(fs7) // people than answered "No" and >0
count if missing(fs1) & fs7>0 & !missing(fs7) // people than answered "yes" and 0
count if fs1!=1 & fs7>0 & !missing(fs7)


** HEALTH
** accident or illnes
gen hs31_count=wordcount(hs31)
replace hs31_count=. if missing(hs3)
assert missing(hs31) if hs3 == 0
assert hs31_count==0 if hs3 == 0
assert hs31_count > 0 if hs3 == 1 
assert missing(hs31) if missing(hs3)

** MIGRATION
forvalues i=1/20 {
	assert remit_amount_`i'>0 if remit_`i'==1
	assert missing(remit_amount_`i') if remit_`i'==0
}

** LABOR SUPPLY AND INCOME GENERATING ACTIVITIES
forvalues j=1/7 {
	forvalues i = 1/20 {
		cap confirm var activities_hours_`j'_`i'
		if _rc == 0 {
				assert pay_`j'_`i' ==. if work_outside == "" // this should be true because of the skip patterns of the survey
				replace activities_day_`j'_`i' = 0 if work_outside !="" & activities_day_`j'_`i'==. // CHECK THIS!  not sure if the "" in the var "work_outside" are . or 0. I think "" are beacuse people skipped this section of the survey
				replace activities_hours_`j'_`i' = 0 if work_outside !="" & activities_hours_`j'_`i'==.
				replace pay_`j'_`i' = 0 if work_outside !="" & pay_`j'_`i'==.
		}
	}
}

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                              LABOR SUPPLY CORRECTIONS
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

** Recoding to fit existing categories
preserve
import excel 	"$others\Labor supply\Translations and recodes\\$labor_recode", ///
				sheet("Sheet1") firstrow allstr clear


keep id individual age Activity Recode Recode_2
keep if Recode!="0"
loc tot = _N

forvalues i=1/`tot' {
	local id_`i' = id in `i'
	local ind_`i' = individual in `i'
	local rec_`i' = Recode in `i'
}
restore


forvalues i=1/`tot' {
	replace activities_day_`rec_`i''_`ind_`i'' = activities_day_`rec_`i''_`ind_`i'' + activities_day_7_`ind_`i'' if id=="`id_`i''"
	replace activities_day_7_`ind_`i'' = 0 if id=="`id_`i''"
	
	replace activities_hours_`rec_`i''_`ind_`i'' = activities_hours_`rec_`i''_`ind_`i'' + activities_hours_7_`ind_`i'' if id=="`id_`i''"
	replace activities_hours_7_`ind_`i'' = 0 if id=="`id_`i''"
	
	replace pay_`rec_`i''_`ind_`i'' = pay_`rec_`i''_`ind_`i'' + pay_7_`ind_`i'' if id=="`id_`i''"
	replace pay_7_`ind_`i'' = 0 if id=="`id_`i''"
	
	macro drop id_`i' 
	macro drop ind_`i'
	macro drop rec_`i'
}

// create new vars for classifying employment types for "others"
forvalues i = 1/20 {
	cap confirm var outside_activities_other_`i'
	if _rc == 0 {
			gen activities_other_types_`i' = .
	}
}

preserve
import excel 	"$others\Labor supply\Translations and recodes\\$labor_recode", ///
				sheet("Sheet1") firstrow allstr clear


keep id individual age Activity Recode Recode_2
keep if Recode=="0" & Recode_2!=""
loc tot = _N


forvalues j=1/`tot' {
	local id_`j' = id in `j'
	local ind_`j' = individual in `j'
	loc rec2_`j' = Recode_2 in `j'
}
restore

forvalues j=1/`tot' {
	replace activities_other_types_`ind_`j'' = `rec2_`j'' if id=="`id_`j''"
	
	macro drop id_`j' 
	macro drop ind_`j'
	macro drop rec2_`j'
}

forvalues i = 1/20 {
	cap confirm var outside_activities_other_`i'
	if _rc == 0 {
			assert outside_activities_other_`i'!="" if activities_other_types_`i' !=. 
	}
}

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                   CORRECT ERRORS
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* This section of the do file was added after reviewing the summary stats and finding mistakes in the data. 
The following corrections were decided together with the field team and the PI's.
*/

** wvs_loc: Please tell me which comes closest to your view on a scale on which (1) means everything in life is determined by fate and (10) means people shape their fate themselves
replace wvs_loc = 1 if wvs == 0 // possible answers for this questions were integers. The question could not be skipped. I decided to replace "0" with "1" since it was probably a mistake in interpreting the possible answers.

** Rooms
*replace v1=1 if v1==. // for missing values we assume there is only one room in the household. Field team told us this was the case for most households.
*replace v1=1 if v1==0


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                    NEW VARIABLES
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* I moved this to the PII do file in order to do the merge
** Base and community ID

split householdid, p("-") gen(commid)
drop commid2
rename commid1 commid
gen commid_str = commid
destring commid, replace
move commid householdid

gen base_str = base
replace base = "1" if base_str == "Koronadal"
replace base = "2" if base_str == "General Santos"
replace base = "3" if base_str == "Bacolod"
replace base = "4" if base_str == "Dumaguete"
replace base_str = base

destring base, replace
label define base 1 "Koronoadal" 2 "General Santos" 3 "Bacolod" 4 "Dumaguete"
label val base base
/*
gen commid_str = commid
tostring commid_str, replace
replace commid_str = commid_str if commid>99
replace commid_str = "0" + commid_str if commid>9 & commid<=99
replace commid_str = "00" + commid_str if commid>0 & commid<=9
*/
*/

gen basecomm = base_str + commid_str

** Pastor
qui {
	gen pastor = ""
	replace pastor = "George Gines" if commid == 1
	replace pastor = "German Ligero" if commid == 2
	replace pastor = "German Ligero" if commid == 3
	replace pastor = "Eliezer Sorongon" if commid == 4
	replace pastor = "Eliezer Sorongon" if commid == 5
	replace pastor = "Allan Mendoza" if commid == 6
	replace pastor = "Allan Mendoza" if commid == 7
	replace pastor = "Gilbert Saraosos" if commid == 8
	replace pastor = "Gilbert Saraosos" if commid == 9
	replace pastor = "Joemar Misajon" if commid == 10
	replace pastor = "Joemar Misajon" if commid == 11
	replace pastor = "Kuya Tuan" if commid == 12
	replace pastor = "Luis Tagal" if commid == 13
	replace pastor = "Luis Tagal" if commid == 14
	replace pastor = "Richard Palencia" if commid == 15
	replace pastor = "Richard Palencia" if commid == 16
	replace pastor = "Rodrigo Sabal" if commid == 17
	replace pastor = "Rodrigo Sabal" if commid == 18
	replace pastor = "Rolando Dacumos" if commid == 19
	replace pastor = "Rolando Dacumos" if commid == 20
	replace pastor = "Ronnie Gaspar" if commid == 21
	replace pastor = "Samson Abayon" if commid == 22
	replace pastor = "Samson Abayon" if commid == 23
	replace pastor = "Soloman" if commid == 24
	replace pastor = "Soloman" if commid == 25
	replace pastor = "Wilfredo Dingcong" if commid == 26
	replace pastor = "Wilson Binola" if commid == 27
	replace pastor = "Alma Octaviano" if commid == 28
	replace pastor = "Alma Octaviano" if commid == 29
	replace pastor = "Donnabelle Fabro" if commid == 30
	replace pastor = "Donnabelle Fabro" if commid == 31
	replace pastor = "Elena Aguirre" if commid == 32
	replace pastor = "Elena Aguirre" if commid == 33
	replace pastor = "Ma. Fe Aguilar" if commid == 34
	replace pastor = "Ma. Fe Aguilar" if commid == 35
	replace pastor = "Marla Bantilan" if commid == 36
	replace pastor = "Marla Bantilan" if commid == 37
	replace pastor = "Mona Fulgencio " if commid == 38
	replace pastor = "Rolly Paran" if commid == 39
	replace pastor = "Rolly Paran" if commid == 40
	replace pastor = "Danny Calanza" if commid == 41
	replace pastor = "Danny Calanza" if commid == 42
	replace pastor = "Albert Perez" if commid == 43
	replace pastor = "Albert Perez" if commid == 44
	replace pastor = "Renato Faderogao" if commid == 45
	replace pastor = "Renato Faderogao" if commid == 46
	replace pastor = "Joery Aman" if commid == 47
	replace pastor = "Joery Aman" if commid == 48
	replace pastor = "Mario Sabal" if commid == 49
	replace pastor = "Mario Sabal" if commid == 50
	replace pastor = "Ricky Langguyan" if commid == 51
	replace pastor = "Ricky Langguyan" if commid == 52
	replace pastor = "Neri Burao" if commid == 53
	replace pastor = "Neri Burao" if commid == 54
	replace pastor = "Jovenil Banggay" if commid == 55
	replace pastor = "Jovenil Banggay" if commid == 56
	replace pastor = "Glenn Sagun" if commid == 57
	replace pastor = "Glenn Sagun" if commid == 58
	replace pastor = "Alex Bantolinao" if commid == 59
	replace pastor = "Alex Bantolinao" if commid == 60
	replace pastor = "Edmedio Asayas" if commid == 61
	replace pastor = "Edmedio Asayas" if commid == 62
	replace pastor = "Antonio Asayas" if commid == 63
	replace pastor = "Antonio Asayas" if commid == 64
	replace pastor = "George Gines" if commid == 65
	replace pastor = "Blahiro Goy" if commid == 66
	replace pastor = "Blahiro Goy" if commid == 67
	replace pastor = "Kuya Tuan" if commid == 68
	replace pastor = "Ronnie Gaspar" if commid == 69
	replace pastor = "Wilfredo Dingcong" if commid == 70
	replace pastor = "Wilson Binola" if commid == 71
	replace pastor = "Mona Fulgencio " if commid == 72
	replace pastor = "Wenifredo Derilon" if commid == 73
	replace pastor = "Wenifredo Derilon" if commid == 74
	replace pastor = "Bartolome Dumasis" if commid == 75
	replace pastor = "Bartolome Dumasis" if commid == 76
	replace pastor = "Antonio Flores" if commid == 77
	replace pastor = "Antonio Flores" if commid == 78
	replace pastor = "Greg Domingo" if commid == 79
	replace pastor = "Greg Domingo" if commid == 80
	replace pastor = "Ben Tetisora" if commid == 81
	replace pastor = "Ben Tetisora" if commid == 82
	replace pastor = "Algir Curaraton" if commid == 83
	replace pastor = "Algir Curaraton" if commid == 84
	replace pastor = "Redentor Del Mundo" if commid == 85
	replace pastor = "Redentor Del Mundo" if commid == 86
	replace pastor = "Dario Bohol" if commid == 87
	replace pastor = "Dario Bohol" if commid == 88
	replace pastor = "Mark Mamuad" if commid == 89
	replace pastor = "Mark Mamuad" if commid == 90
	replace pastor = "Romeo Ubas" if commid == 91
	replace pastor = "Romeo Ubas" if commid == 92
	replace pastor = "Lodiver Marcelo" if commid == 93
	replace pastor = "Lodiver Marcelo" if commid == 94
	replace pastor = "Jerry Labos" if commid == 95
	replace pastor = "Jerry Labos" if commid == 96
	replace pastor = "Elpilda Tincayao" if commid == 97
	replace pastor = "Elpilda Tincayao" if commid == 98
	replace pastor = "Orlando Sandingay" if commid == 99
	replace pastor = "Orlando Sandingay" if commid == 100
	replace pastor = "Samuel Dinapo" if commid == 101
	replace pastor = "Samuel Dinapo" if commid == 102
	replace pastor = "Argie Lumongdang" if commid == 103
	replace pastor = "Argie Lumongdang" if commid == 104
	replace pastor = "Rudevico Montero" if commid == 105
	replace pastor = "Rudevico Montero" if commid == 106
	replace pastor = "Ike Limburan" if commid == 107
	replace pastor = "Ike Limburan" if commid == 108
	replace pastor = "Philip Villareal" if commid == 109
	replace pastor = "Philip Villareal" if commid == 110
	replace pastor = "Francisco Minsera" if commid == 111
	replace pastor = "Francisco Minsera" if commid == 112
	replace pastor = "Renan Josol" if commid == 113
	replace pastor = "Renan Josol" if commid == 114
	replace pastor = "Dario Magulinay" if commid == 115
	replace pastor = "Dario Magulinay" if commid == 116
	replace pastor = "Oliver Celin" if commid == 117
	replace pastor = "Oliver Celin" if commid == 118
	replace pastor = "Jojit Villacura" if commid == 119
	replace pastor = "Jojit Villacura" if commid == 120
	replace pastor = "Sanny Ariza" if commid == 121
	replace pastor = "Sanny Ariza" if commid == 122
	replace pastor = "Ricardo Deluao" if commid == 123
	replace pastor = "Ricardo Deluao" if commid == 124
	replace pastor = "Marjo Punes" if commid == 125
	replace pastor = "Marjo Punes" if commid == 126
	replace pastor = "Eric Arzaga" if commid == 127
	replace pastor = "Eric Arzaga" if commid == 128
	replace pastor = "Perla Griffin" if commid == 129 // used to be "Perla Mae Griffin"
	replace pastor = "Perla Griffin" if commid == 130
	replace pastor = "Reynaldo Dasal" if commid == 131
	replace pastor = "Reynaldo Dasal" if commid == 132
	replace pastor = "Susan De Guzman" if commid == 133
	replace pastor = "Susan De Guzman" if commid == 134
	replace pastor = "Roger Umbod" if commid == 135
	replace pastor = "Roger Umbod" if commid == 136
	replace pastor = "Rosalie Alarcon" if commid == 137
	replace pastor = "Rosalie Alarcon" if commid == 138
	replace pastor = "Cely Tawas" if commid == 139
	replace pastor = "Cely Tawas" if commid == 140
	replace pastor = "Federico Abellana" if commid == 141
	replace pastor = "Federico Abellana" if commid == 142
	replace pastor = "Cesar Soriano" if commid == 143
	replace pastor = "Cesar Soriano" if commid == 144
	replace pastor = "Polly Galaura" if commid == 145
	replace pastor = "Polly Galaura" if commid == 146
	replace pastor = "Leonardo Miguel" if commid == 147
	replace pastor = "Leonardo Miguel" if commid == 148
	replace pastor = "Jimmy Layo" if commid == 149
	replace pastor = "Jimmy Layo" if commid == 150
	replace pastor = "Rudolfo Cadayona" if commid == 151
	replace pastor = "Rudolfo Cadayona" if commid == 152
	replace pastor = "Felipe Laspeno" if commid == 153
	replace pastor = "Felipe Laspeno" if commid == 154
	replace pastor = "Ruel Ruelan" if commid == 155
	replace pastor = "Ruel Ruelan" if commid == 156
	replace pastor = "Estrellita Abellana" if commid == 157
	replace pastor = "Estrellita Abellana" if commid == 158
	replace pastor = "Danilo Santos" if commid == 159
	replace pastor = "Danilo Santos" if commid == 160
	replace pastor = "Cosio Bernard" if commid == 161
	replace pastor = "Cosio Bernard" if commid == 162
	replace pastor = "Remeleo Vigno" if commid == 163
	replace pastor = "Remeleo Vigno" if commid == 164
	replace pastor = "Merlinda Belangel" if commid == 165
	replace pastor = "Merlinda Belangel" if commid == 166
	replace pastor = "Joshua Nervez" if commid == 167
	replace pastor = "Joshua Nervez" if commid == 168
	replace pastor = "Jose Gabo" if commid == 169
	replace pastor = "Jose Gabo" if commid == 170
	replace pastor = "Greg Aurillo" if commid == 171
	replace pastor = "Greg Aurillo" if commid == 172
	replace pastor = "Glenn Buenviaje" if commid == 173
	replace pastor = "Glenn Buenviaje" if commid == 174
	replace pastor = "Joesal Macapagal" if commid == 175
	replace pastor = "Joesal Macapagal" if commid == 176
	replace pastor = "Rey Sungco" if commid == 177
	replace pastor = "Rey Sungco" if commid == 178
	replace pastor = "Teofilo Mahilum" if commid == 179
	replace pastor = "Teofilo Mahilum" if commid == 180
	replace pastor = "Julian Mahilum" if commid == 181
	replace pastor = "Julian Mahilum" if commid == 182
	replace pastor = "Benjie Ebcas" if commid == 183
	replace pastor = "Benjie Ebcas" if commid == 184
	replace pastor = "Joebert Recabo" if commid == 185
	replace pastor = "Joebert Recabo" if commid == 186
	replace pastor = "Javie Gepulani" if commid == 187
	replace pastor = "Javie Gepulani" if commid == 188
	replace pastor = "Eddie Yu" if commid == 189
	replace pastor = "Eddie Yu" if commid == 190
	replace pastor = "Jenny Espinosa" if commid == 191
	replace pastor = "Jenny Espinosa" if commid == 192
	replace pastor = "Arturo Legaspina" if commid == 193
	replace pastor = "Arturo Legaspina" if commid == 194
	replace pastor = "Melvin Balsomo" if commid == 195
	replace pastor = "Melvin Balsomo" if commid == 196
	replace pastor = "Louie Oliverio" if commid == 197
	replace pastor = "Louie Oliverio" if commid == 198
	replace pastor = "Albito Almer" if commid == 199
	replace pastor = "Albito Almer" if commid == 200
	replace pastor = "Iredonia Thatcher" if commid == 201
	replace pastor = "Iredonia Thatcher" if commid == 202
	replace pastor = "George Cadelina" if commid == 203
	replace pastor = "George Cadelina" if commid == 204
	replace pastor = "Joel Magbanua" if commid == 205
	replace pastor = "Joel Magbanua" if commid == 206
	replace pastor = "Romel Siray" if commid == 207
	replace pastor = "Romel Siray" if commid == 208
	replace pastor = "Ronnie Fegar" if commid == 209
	replace pastor = "Ronnie Fegar" if commid == 210
	replace pastor = "Jerry Dionson" if commid == 211
	replace pastor = "Jerry Dionson" if commid == 212
	replace pastor = "Joenel Capatar" if commid == 213
	replace pastor = "Joenel Capatar" if commid == 214
	replace pastor = "Rex Duhina" if commid == 215
	replace pastor = "Rex Duhina" if commid == 216
	replace pastor = "Joe Pirolino" if commid == 217
	replace pastor = "Joe Pirolino" if commid == 218
	replace pastor = "Rey Lanayon" if commid == 219
	replace pastor = "Rey Lanayon" if commid == 220
	replace pastor = "Ifor Alvior" if commid == 221
	replace pastor = "Ifor Alvior" if commid == 222
	replace pastor = "Winston Villaneuva" if commid == 223
	replace pastor = "Winston Villaneuva" if commid == 224
	replace pastor = "Nepthalie Malaga" if commid == 225
	replace pastor = "Nepthalie Malaga" if commid == 226
	replace pastor = "Tito Arroz" if commid == 227
	replace pastor = "Tito Arroz" if commid == 228
	replace pastor = "Leonardo Moreno" if commid == 229
	replace pastor = "Leonardo Moreno" if commid == 230
	replace pastor = "Isoto Felix" if commid == 231
	replace pastor = "Isoto Felix" if commid == 232
	replace pastor = "Melagros Opelario" if commid == 233
	replace pastor = "Melagros Opelario" if commid == 234
	replace pastor = "M Mirasol" if commid == 235
	replace pastor = "M Mirasol" if commid == 236
	replace pastor = "Jesus Echarri" if commid == 237
	replace pastor = "Jesus Echarri" if commid == 238
	replace pastor = "Annie Melligen" if commid == 239
	replace pastor = "Annie Melligen" if commid == 240
	replace pastor = "Jun Sebial" if commid == 241
	replace pastor = "Dennis Ocay" if commid == 242
	replace pastor = "Dennis Ocay" if commid == 243
	replace pastor = "Elmer Llanos" if commid == 244
	replace pastor = "Elmer Llanos" if commid == 245
	replace pastor = "Jun Sebial" if commid == 246
	replace pastor = "Mario Anhao" if commid == 247
	replace pastor = "Mario Anhao" if commid == 248
	replace pastor = "Rosalie Sebial" if commid == 249
	replace pastor = "Rosalie Sebial" if commid == 250
	replace pastor = "Wilter Castillon" if commid == 251
	replace pastor = "Wilter Castillon" if commid == 252
	replace pastor = "Aji Campos" if commid == 253
	replace pastor = "Aji Campos" if commid == 254
	replace pastor = "Cornelia Jaugan" if commid == 255
	replace pastor = "Cornelia Jaugan" if commid == 256
	replace pastor = "Nezel Lim" if commid == 257
	replace pastor = "Wenmar Sarupa" if commid == 258
	replace pastor = "Wenmar Sarupa" if commid == 259
	replace pastor = "Braule Duhaylungsod" if commid == 260
	replace pastor = "Braule Duhaylungsod" if commid == 261
	replace pastor = "Robert Buquiran" if commid == 262
	replace pastor = "Robert Buquiran" if commid == 263
	replace pastor = "Charles Harvey Lim" if commid == 264
	replace pastor = "Charles Harvey Lim" if commid == 265
	replace pastor = "Edwin Casido" if commid == 266
	replace pastor = "Edwin Casido" if commid == 267
	replace pastor = "Roland Cabanlit" if commid == 268
	replace pastor = "Roland Cabanlit" if commid == 269
	replace pastor = "Patrocenio Vios" if commid == 270
	replace pastor = "Patrocenio Vios" if commid == 271
	replace pastor = "Emer Pacunla" if commid == 272
	replace pastor = "Emer Pacunla" if commid == 273
	replace pastor = "Venancio Torebio" if commid == 274
	replace pastor = "Venancio Torebio" if commid == 275
	replace pastor = "Samuel Aglosolos" if commid == 276
	replace pastor = "Samuel Aglosolos" if commid == 277
	replace pastor = "Eduardo Cagampang" if commid == 278
	replace pastor = "Marites Gerago" if commid == 279
	replace pastor = "Marites Gerago" if commid == 280
	replace pastor = "Eduardo Cagampang" if commid == 281
	replace pastor = "Rufino Maylan" if commid == 282
	replace pastor = "Ariston" if commid == 283
	replace pastor = "Anthony Caldera" if commid == 284
	replace pastor = "Anthony Caldera" if commid == 285
	replace pastor = "Francisco Tenchavez" if commid == 286
	replace pastor = "Vincent Suarez" if commid == 287
	replace pastor = "Vincent Suarez" if commid == 288
	replace pastor = "Nezel Lim" if commid == 289
	replace pastor = "Antonieta Etang" if commid == 290
	replace pastor = "Antonieta Etang" if commid == 291
	replace pastor = "Emmanuelito Lajot" if commid == 292
	replace pastor = "Emmanuelito Lajot" if commid == 293
	replace pastor = "Edwin Beligolo" if commid == 294
	replace pastor = "Edwin Beligolo" if commid == 295
	replace pastor = "Nico Folio" if commid == 296
	replace pastor = "Nico Folio" if commid == 297
	replace pastor = "Diosdado Dandoy" if commid == 298
	replace pastor = "Diosdado Dandoy" if commid == 299
	replace pastor = "Abel Villacampo" if commid == 300
	replace pastor = "Abel Villacampo" if commid == 301
	replace pastor = "Elmer Tag" if commid == 302
	replace pastor = "Elmer Tag" if commid == 303
	replace pastor = "Nenito Torres" if commid == 304
	replace pastor = "Nenito Torres" if commid == 305
	replace pastor = "Rufino Maylan" if commid == 306
	replace pastor = "Jerome Cabugnason" if commid == 307
	replace pastor = "Jerome Cabugnason" if commid == 308
	replace pastor = "Aguanta" if commid == 309
	replace pastor = "Aguanta" if commid == 310
	replace pastor = "Ariston" if commid == 311
	replace pastor = "Emmanuel Torreda" if commid == 312
	replace pastor = "Emmanuel Torreda" if commid == 313
	replace pastor = "Francisco Tenchavez" if commid == 314
	replace pastor = "Mardwin Raagas" if commid == 315
	replace pastor = "Mardwin Raagas" if commid == 316
	replace pastor = "Buenaventura Orot" if commid == 317
	replace pastor = "Buenaventura Orot" if commid == 318
	replace pastor = "Jofran Constancio" if commid == 319
	replace pastor = "Jofran Constancio" if commid == 320

}

encode pastor, gen(pastor_id)
rename pastor pastor_str
rename pastor_id pastor



*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                        SAVE
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

assert !missing(`baseline') // make sure the local is not empty

if `baseline' == 0 {
	save "2-ICM-6monthsurvey-clean(ish)-$date", replace
}
else if `baseline' == 1 {
	save "2-ICM-6monthsurvey-clean(ish)_b-$date", replace
}







