**************************************************************************************
******************************* ICM 6th month survey *********************************
**************************************************************************************

*                                4. OUTCOME VARIABLES


** Programer: Isabel Onate
** Date created: 12/23/2015
** Last modified: 
display "$S_DATE"
set more off
*version 12.1
set type double


/* 
This do file generates all the outcome variables and the indices that we will use for analysis. 
For more details on what variables we decided to use, and how they are grouped see Pre-analysis plan.

These variables will be grouped into sets of outcomes (religion, consumption, etc) using global macros. 
For this reason, this do file needs to be run anytime that these globals are used in subsequend code.

All the indices created in this do file are standardized using the control mean and sd. 
Therefore the mean of the control variable should allways be 0 and the sd 1
This means that anytime the number of observations change, the value of the indices will change as well.
For example if we decide to only run the analysis for a subset of the sample (women, catholics etc).
In these cases, this do file needs to be run again and the resulting database should be saved with a different name.

This do file can be modified to create different datasets in the following ways:
	Treatment assignment:
				Using fake treatment assignment - for running tests and making decisions included in the PAP (see notes on this) nad do file "ICM-6monthsurvey-Fake treatment"
				Using original assignment - For analysis
	Switched communities: there are 5 pairs of communities that did not follow the assignment and switched from VHL to C or from HL to V (and viceversa)
				Dropping switched communities - This is the way we decided to conduct the analysis for the paper
				Keeping original assignment not dropping switched com - Run this to compare data and results
				Changing treatment to the ones that communties actually recieved (what they switched to)
	ICM' baseline data: restricting the sample to protestants and catholics according to ICMs baseline data for HTE.
				

For analysis we have run this code in the following 3 ways:
Option 1: Fake treatment assignment - not dropping anything
Option 2: Real treatment assignment - dropping switched communities
Option 3: Real treatment assignment - not dropping switched communities (original treatment assignment)	
Option 4: Real treatment assignment - dropping switched communities	- only for catholics and protestants using ICM's baseline data.

Note: 	To change between these options modify the macros "treat", "switched" and "baseline"
		For the purpose of the paper keep these macros as treat = 1 and switched =0 and baseline = 0
				

// Notes: 	All variables starting with z_* correspond to the standardized version of the oroiginal variable
//			All variables ending with *_w correspond to winsorized versions of the original variables


*/
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                    DEFINE PATHS
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// MODEL TO RUN
loc baseline = 0 // change this local if needed - 0 for no baseline, 1 for yes ---------- CHANGE FOR USING BASELINE
gl treat = 1 // "0" for fake "1" for real ----------------------------------------------- CHANGE FOR REAL TREATMENT ASSIGNMENT
gl switched = 0 // "0" for original assignment "1" for switched communities ------------- CHANGE
loc drop = 1

// GLOBALS DO FILE
c ICM_6ms_dir
qui include "Do files\1-ICM-6ms-globals"
qui include "Do files\2-ICM-6ms-programs"

cd "$data"


// DATA TO USE				
assert !missing("`baseline'")
assert `baseline' == 1 | `baseline' == 0
if `baseline' == 0 {
	use "2-ICM-6ms-clean(ish)-$date", clear // this is the dataset WITHOUT baseline data
}
else if `baseline' == 1 {
	use "2-ICM-6ms-clean(ish)_b-$date", clear // this is the dataset WITH baseline data
	
	// We keep observations for catholic or protestant people to make this comparison - HTE
	drop if religion_b != 1 & religion_b != 2
	gen catholic = (religion_b == 1) // dummy for catholic
}
else {
	display in r "Local for baseline is not defined correctly!" // if local baseline was not propperly defined
	macro list
	stop
}



*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                 TREATMENT ASSIGNMENT
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

assert !missing("$treat")
assert $treat == 1 | $treat == 0
assert !missing("$switched")
assert $switched == 1 | $switched == 0

if $treat == 0 {
	display in r "Analysis with fake treatment assignment"
	qui {
	preserve
	include "$do_files\ICM-6monthsurvey-Fake treatment" // This do files runs a randomization on treatment assignment, different than the original one
	restore
	
	gen treatment = .
	local N=_N
	sort commid
	forvalues c=1/`C' {
		replace treatment = `t_`c'' if commid == `c_`c''
		*noi display in r "`c_`c''-`t_`c''"
	}
	}
	label var treatment "Fake Treatment group"
}



** TREATMENT

if $treat == 1 {
qui {
	gen treatment=.
	replace treatment=3 if commid==1
	replace treatment=2 if commid==2
	replace treatment=3 if commid==3
	replace treatment=2 if commid==4
	replace treatment=3 if commid==5
	replace treatment=1 if commid==6
	replace treatment=4 if commid==7
	replace treatment=1 if commid==8
	replace treatment=4 if commid==9
	replace treatment=1 if commid==10
	replace treatment=4 if commid==11
	replace treatment=4 if commid==12
	replace treatment=2 if commid==13
	replace treatment=3 if commid==14
	replace treatment=1 if commid==15
	replace treatment=4 if commid==16
	replace treatment=3 if commid==17
	replace treatment=2 if commid==18
	replace treatment=3 if commid==19
	replace treatment=2 if commid==20
	replace treatment=3 if commid==21
	replace treatment=4 if commid==22
	replace treatment=1 if commid==23
	replace treatment=4 if commid==24
	replace treatment=1 if commid==25
	replace treatment=1 if commid==26
	replace treatment=2 if commid==27
	replace treatment=3 if commid==28
	replace treatment=2 if commid==29
	replace treatment=3 if commid==30
	replace treatment=2 if commid==31
	replace treatment=3 if commid==32
	replace treatment=2 if commid==33
	replace treatment=3 if commid==34
	replace treatment=2 if commid==35
	replace treatment=4 if commid==36 // switched
	replace treatment=1 if commid==37 // switched
	replace treatment=3 if commid==38
	replace treatment=4 if commid==39
	replace treatment=1 if commid==40
	replace treatment=1 if commid==41
	replace treatment=4 if commid==42
	replace treatment=2 if commid==43
	replace treatment=3 if commid==44
	replace treatment=4 if commid==45
	replace treatment=1 if commid==46
	replace treatment=2 if commid==47
	replace treatment=3 if commid==48
	replace treatment=3 if commid==49
	replace treatment=2 if commid==50
	replace treatment=4 if commid==51
	replace treatment=1 if commid==52
	replace treatment=1 if commid==53
	replace treatment=4 if commid==54
	replace treatment=1 if commid==55
	replace treatment=4 if commid==56
	replace treatment=4 if commid==57
	replace treatment=1 if commid==58
	replace treatment=1 if commid==59
	replace treatment=4 if commid==60
	replace treatment=1 if commid==61
	replace treatment=4 if commid==62
	replace treatment=3 if commid==63
	replace treatment=2 if commid==64
	replace treatment=2 if commid==65
	replace treatment=4 if commid==66 // switched
	replace treatment=1 if commid==67 // switched
	replace treatment=1 if commid==68
	replace treatment=2 if commid==69
	replace treatment=4 if commid==70
	replace treatment=3 if commid==71
	replace treatment=2 if commid==72
	replace treatment=1 if commid==73
	replace treatment=4 if commid==74
	replace treatment=3 if commid==75
	replace treatment=2 if commid==76
	replace treatment=2 if commid==77
	replace treatment=3 if commid==78
	replace treatment=3 if commid==79
	replace treatment=2 if commid==80
	replace treatment=1 if commid==81
	replace treatment=4 if commid==82
	replace treatment=2 if commid==83
	replace treatment=3 if commid==84
	replace treatment=2 if commid==85
	replace treatment=3 if commid==86
	replace treatment=2 if commid==87
	replace treatment=3 if commid==88
	replace treatment=3 if commid==89
	replace treatment=2 if commid==90
	replace treatment=3 if commid==91 // switched
	replace treatment=2 if commid==92 // switched
	replace treatment=3 if commid==93
	replace treatment=2 if commid==94
	replace treatment=4 if commid==95
	replace treatment=1 if commid==96
	replace treatment=3 if commid==97
	replace treatment=2 if commid==98
	replace treatment=1 if commid==99
	replace treatment=4 if commid==100
	replace treatment=2 if commid==101
	replace treatment=3 if commid==102
	replace treatment=4 if commid==103
	replace treatment=1 if commid==104
	replace treatment=4 if commid==105
	replace treatment=1 if commid==106
	replace treatment=4 if commid==107
	replace treatment=1 if commid==108
	replace treatment=3 if commid==109
	replace treatment=2 if commid==110
	replace treatment=4 if commid==111
	replace treatment=1 if commid==112
	replace treatment=4 if commid==113
	replace treatment=1 if commid==114
	replace treatment=1 if commid==115
	replace treatment=4 if commid==116
	replace treatment=4 if commid==117
	replace treatment=1 if commid==118
	replace treatment=2 if commid==119
	replace treatment=3 if commid==120
	replace treatment=1 if commid==121
	replace treatment=4 if commid==122
	replace treatment=2 if commid==123
	replace treatment=3 if commid==124
	replace treatment=3 if commid==125
	replace treatment=2 if commid==126
	replace treatment=2 if commid==127
	replace treatment=3 if commid==128
	replace treatment=3 if commid==129
	replace treatment=2 if commid==130
	replace treatment=1 if commid==131
	replace treatment=4 if commid==132
	replace treatment=1 if commid==133
	replace treatment=4 if commid==134
	replace treatment=4 if commid==135
	replace treatment=1 if commid==136
	replace treatment=4 if commid==137
	replace treatment=1 if commid==138
	replace treatment=2 if commid==139
	replace treatment=3 if commid==140
	replace treatment=2 if commid==141
	replace treatment=3 if commid==142
	replace treatment=3 if commid==143
	replace treatment=2 if commid==144
	replace treatment=2 if commid==145
	replace treatment=3 if commid==146
	replace treatment=4 if commid==147
	replace treatment=1 if commid==148
	replace treatment=1 if commid==149
	replace treatment=4 if commid==150
	replace treatment=3 if commid==151
	replace treatment=2 if commid==152
	replace treatment=4 if commid==153
	replace treatment=1 if commid==154
	replace treatment=1 if commid==155
	replace treatment=4 if commid==156
	replace treatment=4 if commid==157
	replace treatment=1 if commid==158
	replace treatment=2 if commid==159
	replace treatment=3 if commid==160
	replace treatment=3 if commid==161
	replace treatment=2 if commid==162
	replace treatment=2 if commid==163
	replace treatment=3 if commid==164
	replace treatment=4 if commid==165
	replace treatment=1 if commid==166
	replace treatment=4 if commid==167
	replace treatment=1 if commid==168
	replace treatment=1 if commid==169
	replace treatment=4 if commid==170
	replace treatment=3 if commid==171
	replace treatment=2 if commid==172
	replace treatment=4 if commid==173
	replace treatment=1 if commid==174
	replace treatment=4 if commid==175
	replace treatment=1 if commid==176
	replace treatment=3 if commid==177
	replace treatment=2 if commid==178
	replace treatment=1 if commid==179
	replace treatment=4 if commid==180
	replace treatment=1 if commid==181
	replace treatment=4 if commid==182
	replace treatment=3 if commid==183
	replace treatment=2 if commid==184 
	replace treatment=3 if commid==185 // switched
	replace treatment=2 if commid==186 // switched
	replace treatment=3 if commid==187
	replace treatment=2 if commid==188
	replace treatment=3 if commid==189
	replace treatment=2 if commid==190
	replace treatment=2 if commid==191
	replace treatment=3 if commid==192
	replace treatment=4 if commid==193
	replace treatment=1 if commid==194
	replace treatment=4 if commid==195
	replace treatment=1 if commid==196
	replace treatment=3 if commid==197
	replace treatment=2 if commid==198
	replace treatment=3 if commid==199
	replace treatment=2 if commid==200
	replace treatment=1 if commid==201
	replace treatment=4 if commid==202
	replace treatment=2 if commid==203
	replace treatment=3 if commid==204
	replace treatment=1 if commid==205
	replace treatment=4 if commid==206
	replace treatment=4 if commid==207
	replace treatment=1 if commid==208
	replace treatment=2 if commid==209
	replace treatment=3 if commid==210
	replace treatment=1 if commid==211
	replace treatment=4 if commid==212
	replace treatment=3 if commid==213
	replace treatment=2 if commid==214
	replace treatment=3 if commid==215
	replace treatment=2 if commid==216
	replace treatment=4 if commid==217 // switched
	replace treatment=1 if commid==218 // switched
	replace treatment=4 if commid==219
	replace treatment=1 if commid==220
	replace treatment=4 if commid==221
	replace treatment=1 if commid==222
	replace treatment=4 if commid==223
	replace treatment=1 if commid==224
	replace treatment=2 if commid==225
	replace treatment=3 if commid==226
	replace treatment=2 if commid==227
	replace treatment=3 if commid==228
	replace treatment=2 if commid==229
	replace treatment=3 if commid==230
	replace treatment=3 if commid==231
	replace treatment=2 if commid==232
	replace treatment=4 if commid==233
	replace treatment=1 if commid==234
	replace treatment=1 if commid==235
	replace treatment=4 if commid==236
	replace treatment=4 if commid==237
	replace treatment=1 if commid==238
	replace treatment=2 if commid==239
	replace treatment=3 if commid==240
	replace treatment=1 if commid==241
	replace treatment=3 if commid==242
	replace treatment=2 if commid==243
	replace treatment=2 if commid==244
	replace treatment=3 if commid==245
	replace treatment=4 if commid==246
	replace treatment=4 if commid==247
	replace treatment=1 if commid==248
	replace treatment=4 if commid==249
	replace treatment=1 if commid==250
	replace treatment=1 if commid==251
	replace treatment=4 if commid==252
	replace treatment=4 if commid==253
	replace treatment=1 if commid==254
	replace treatment=1 if commid==255
	replace treatment=4 if commid==256
	replace treatment=1 if commid==257
	replace treatment=1 if commid==258
	replace treatment=4 if commid==259
	replace treatment=4 if commid==260
	replace treatment=1 if commid==261
	replace treatment=1 if commid==262
	replace treatment=4 if commid==263
	replace treatment=1 if commid==264
	replace treatment=4 if commid==265
	replace treatment=4 if commid==266
	replace treatment=1 if commid==267
	replace treatment=3 if commid==268
	replace treatment=2 if commid==269
	replace treatment=2 if commid==270
	replace treatment=3 if commid==271
	replace treatment=1 if commid==272
	replace treatment=4 if commid==273
	replace treatment=2 if commid==274
	replace treatment=3 if commid==275
	replace treatment=4 if commid==276
	replace treatment=1 if commid==277
	replace treatment=1 if commid==278
	replace treatment=2 if commid==279
	replace treatment=3 if commid==280
	replace treatment=4 if commid==281
	replace treatment=3 if commid==282
	replace treatment=3 if commid==283
	replace treatment=3 if commid==284
	replace treatment=2 if commid==285
	replace treatment=2 if commid==286
	replace treatment=2 if commid==287
	replace treatment=3 if commid==288
	replace treatment=4 if commid==289
	replace treatment=3 if commid==290
	replace treatment=2 if commid==291
	replace treatment=3 if commid==292
	replace treatment=2 if commid==293
	replace treatment=1 if commid==294
	replace treatment=4 if commid==295
	replace treatment=1 if commid==296
	replace treatment=4 if commid==297
	replace treatment=3 if commid==298
	replace treatment=2 if commid==299
	replace treatment=3 if commid==300
	replace treatment=2 if commid==301
	replace treatment=3 if commid==302
	replace treatment=2 if commid==303
	replace treatment=2 if commid==304
	replace treatment=3 if commid==305
	replace treatment=2 if commid==306
	replace treatment=3 if commid==307
	replace treatment=2 if commid==308
	replace treatment=2 if commid==309
	replace treatment=3 if commid==310
	replace treatment=2 if commid==311 // had to crrect treatment was incorrectly written as 4 - correct =2
	replace treatment=2 if commid==312
	replace treatment=3 if commid==313
	replace treatment=3 if commid==314
	replace treatment=4 if commid==315
	replace treatment=1 if commid==316
	replace treatment=4 if commid==317
	replace treatment=1 if commid==318
	replace treatment=4 if commid==319
	replace treatment=1 if commid==320


	if $switched == 1 {
		display in r "Analysis with switched communities"
		replace treatment=1 if commid==36 // Originally treatment=4, switched to 1
		replace treatment=4 if commid==37 // Originally treatment=1, switched to 4
		replace treatment=1 if commid==66 // Originally treatment=4, switched to 1
		replace treatment=4 if commid==67 // Originally treatment=1, switched to 4
		replace treatment=2 if commid==91 // Originally treatment=3, switched to 2
		replace treatment=3 if commid==92 // Originally treatment=2, switched to 3
		replace treatment=2 if commid==185 // Originally treatment=3, switched to 2
		replace treatment=3 if commid==186 // Originally treatment=2, switched to 3
		replace treatment=1 if commid==217 // Originally treatment=4, switched to 1
		replace treatment=4 if commid==218 // Originally treatment=1, switched to 4
	}

	label var treatment "Treatment group"
}
}

** Labels
	
label define treatment 1 "C" 2 "V" 3 "HL" 4 "VHL"
label val treatment treatment

labrec treatment (1=0) (2=1) (3=2) (4=3)
		
tab treatment, gen(treatment_)
rename treatment_1 C
rename treatment_2 V
rename treatment_3 HL
rename treatment_4 VHL


// Dummy for switched communities
gen switched = 0
replace switched = 1 if commid==185 | commid==186 | commid == 217 | commid== 218 | commid==91 | commid==92 | commid==36 | commid==37 | commid==66 | commid==67
replace switched = . if mi(commid)


if `drop' == 1 {
	drop if switched == 1 // dropping communities that switched
}

assert _N == 6276


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                 CONTROL VARIABLES
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

** Number of days since June 1 2015
gen date = mdy(6, 01, 2015)
format date %d

gen end_day = ((((end/1000)/60)/60)/24)
replace end_day=floor(end_day)
format %td end_day

gen days_june=end_day-date

** Marital status
gen marital_resp = marital_1 // Cornelius told us that the 1st member of the household ruster is allways the respondent of the survey

gen married=1 if marital_resp==1 | marital_resp==2 // 1 = "married", 2 = "married, still lives with parents"
replace married=0 if married!=1 & !missing(marital_resp)

gen divorced=1 if marital_resp == 3 // 3 = "separated/divorced"
replace divorced=0 if divorced!=1 & !missing(marital_resp)


** Education
gen educ_resp = educ_1


* Age
egen sum_age=rowtotal(age*), missing


gen adults=.
gen children=.
gen age4=. 							// we need dummys for ages 0-4 for the additional variables
local N=_N
forvalues n=1/`N' {                 // The following loop creates the dummies for 2 groups of age (0-4 and (0-16)
local count04 = 0
local count17 = 0
local count016 =0
	forvalues i=1/20 {
		if age_`i'<=4 in `n' {
			local ++count04
		}
		if age_`i'<=16 in `n' {
			local ++count016
		}	
		if age_`i'>16 & !missing(age_`i') in `n' {
			local ++count17
		}
	}
	replace adults = `count17' in `n'
	replace children = `count016' in `n'
	replace age4 = `count04' in `n'
}

replace adults=. if sum_age==.
replace children=. if sum_age==.
replace age4=. if sum_age==.


** CONTROLS
loc standard_controls			respondent_gender /// add controls
								days_june ///
								married ///
								divorced ///
								adults ///
								children ///
								educ_resp 


local standard_controls_m
foreach var of local standard_controls { // This loop generates indicators for missing values for those variables that have them
	count if missing(`var')          
	if `r(N)'>0 {
		gen `var'_m = 1 if missing(`var') 
		replace `var'_m = 0 if !missing(`var') 
		replace  `var' = 0 if missing(`var')
		note `var'_m: "Indicator for missing values in the variable `var'"
		local standard_controls_m `standard_controls_m' `var'_m
	}
}

display "`standard_controls'"
display "`standard_controls_m'"


** Labels and notes
note respondent_gender: "Gender of the respondent"
note days_june: "Number of days between June 1 2015 and interview end date"
note married: "Binary variable for respondents who are married"
note divorced: "Binary variable for respondents who are seprated or divorced"
note adults: "Number of adults in the household (older than 16)"
note children: "Number of children in the household (0 - 16)"
note educ_resp: "Number of years of education - respondent"


gl standard_controls `standard_controls' `standard_controls_m'		

display in r "$standard_controls"
foreach var of global standard_controls { // this loop take varibale notes and uses them to label each variable
	label var `var' ``var'[note1]'
}

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                 LIST RANDOMIZATION
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
** We need to create new variables using the list randomization questions in order to use them for analysis
/* Steps: 	1) stack 2 questions together
			2) create dummy variable for respondents who where not asked the sensitive question 
			
Note that when incorporating these variables in the regressions the independent variables will be: 
	a) Treatment assignment (3 dummy variables)
	b) Dummy for people who were not asked sensitive question
	c) Interaction of a & b (3 variables)
	d) all other controls as per the rest of the PAP.
			
list_rand_4_1 - I treat my water before drinking it
list_rand_4_2 - Someone in my household is experiencing physical abuse
list_rand_4_3 - I have made a personal commitment to Jesus Christ that is still important to me today
list_rand_4_4 - I wash my hands after going to the bathroom
list_rand_4_5 - I have read or listened to the Bible in the past week		
*/


local sensitive treat_water abuse comm_jc wash_hands bible
forvalues i=1/5 {
	local x : word `i' of `sensitive'
	gen lr_`x'_d=1 if !missing(list_rand_3_`i')
	replace lr_`x'_d=0 if !missing(list_rand_4_`i')
	gen lr_`x' = list_rand_3_`i' 
	replace lr_`x' = list_rand_4_`i' if !missing(list_rand_4_`i')
	qui count if !missing(list_rand_4_`i') & !missing(list_rand_3_`i') // to make sure there aro no obs with positive values for both list rand variables
	if _rc!=0 {
		display in r "error in variable `x'"
	}
}

replace lr_abuse = -lr_abuse

** Looking at the differences in means
qui {
	forvalues i=1/5  {
		local x : word `i' of `sensitive'
		forvalues n=3/4 {
			qui sum list_rand_`n'_`i'
			local mean_`n'_`i' `r(mean)'
		}
		local mean_`i' = `mean_4_`i'' - `mean_3_`i''
		noi display "`x': `mean_4_`i''-`mean_3_`i''" 
		noi display "`x': `mean_`i''" 
	}
}

** Controls for LR
gen lr_comm_jc_d_VHL = lr_comm_jc_d*VHL
gen lr_comm_jc_d_HL = lr_comm_jc_d*HL
gen lr_comm_jc_d_V = lr_comm_jc_d*V

gen lr_bible_d_VHL = lr_bible_d*VHL
gen lr_bible_d_HL = lr_bible_d*HL
gen lr_bible_d_V = lr_bible_d*V

gen lr_treat_water_d_VHL = lr_treat_water_d*VHL
gen lr_treat_water_d_HL = lr_treat_water_d*HL
gen lr_treat_water_d_V = lr_treat_water_d*V

gen lr_wash_hands_d_VHL = lr_wash_hands_d*VHL
gen lr_wash_hands_d_HL = lr_wash_hands_d*HL
gen lr_wash_hands_d_V = lr_wash_hands_d*V

gen lr_abuse_d_VHL = lr_abuse_d*VHL
gen lr_abuse_d_HL = lr_abuse_d*HL
gen lr_abuse_d_V = lr_abuse_d*V

** Labels and notes
note lr_treat_water: "I treat my water before drinking it (list randomizaton)"
note lr_treat_water_d: "Indicator for respondents who were NOT asked the sensitive question"
note lr_abuse: "Someone in my household is experiencing physical abuse (list randomizaton)"
note lr_abuse_d: "Indicator for respondents who were NOT asked the sensitive question"
note lr_comm_jc: "I have made a personal commitment to Jesus Christ that is still important to me today (list randomizaton)"
note lr_comm_jc_d: "Indicator for respondents who were NOT asked the sensitive question"
note lr_wash_hands: "I wash my hands after going to the bathroom (list randomizaton)"
note lr_wash_hands_d: "Indicator for respondents who were NOT asked the sensitive question"
note lr_bible: "I have read or listened to the Bible in the past week (list randomizaton)"
note lr_bible_d: "Indicator for respondents who were NOT asked the sensitive question"

gl lr 		lr_treat_water ///
			lr_abuse ///
			lr_comm_jc ///
			lr_wash_hands ///
			lr_bible 
			
foreach var of global lr { // this loop take varibale notes and uses them to label each variable
	label var `var' ``var'[note1]'
}

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                       RELIGION 
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// NEW VARIABLES

gen religious_service_num = religious_service
recode religious_service_num (1=0) (2=1.5) (3=9) (4=18) (5=52) (6=104) (7=365) // we transform categories to number of days in a year

egen icm_religion = rowtotal(icm_bible_accurate icm_bible_authority icm_christiangod_tru), missing
*icm_satan_exists

gen icm_accept_jc = 1 if icm_afterdeath == 4
replace icm_accept_jc = 0 if icm_afterdeath != 4 & !missing(icm_afterdeath)

gen rotr_goodness_r = rotr_goodness // variables that will be reordered
gen rotr_daily_life_r = rotr_daily_life
gen rotr_other_things_r = rotr_other_things


// LABELS
note religious_service_num: "How often do you go to religious service? (number of days in a year)"
note icm_religion: "Sum of the variables: icm_bible_accurate icm_bible_authority icm_christiangod_tru"
note icm_accept_jc: "Binary indicator: I will go to heaven because I have accepted Jesus Christ as my personal savior"


// DEFINING COMPONENTS

gl religion_intr_i			rotr_thinking_religion ///
							rotr_goodness ///
							rotr_private_thoughts ///
							rotr_god_presence ///
							rotr_life_beliefs ///
							rotr_daily_life ///
							rotr_life_religion ///
							rotr_other_things
							
gl religion_intr_r_i		rotr_thinking_religion ///
							rotr_goodness_r /// reversed order
							rotr_private_thoughts ///
							rotr_god_presence ///
							rotr_life_beliefs ///
							rotr_daily_life_r /// reversed order
							rotr_life_religion ///
							rotr_other_things_r // reversed order
							
gl religion_intr_a_i		rotr_thinking_religion ///
							rotr_private_thoughts ///
							rotr_god_presence ///
							rotr_life_beliefs ///
							rotr_life_religion 

gl religion_intr_b_i		rotr_goodness_r ///
							rotr_daily_life_r ///
							rotr_other_things_r

gl religion_extr_i			rotr_service_make_frien ///
							rotr_pray_relief ///
							rotr_religion_comfort ///
							rotr_pray_peace ///
							rotr_service_time_frien ///
							rotr_service_see_people

gl general_religion_i		religious_person ///
							icm_convince_others ///
							icm_convince_others_fre /// 
							private_prayer ///
							satisfaction_splife ///
							religious_service_num ///
							icm_religion // This var has to be weighted 3 times when constructing the index
										
gl religion_listr_i			lr_comm_jc /// list_rand_3_3
							lr_bible // list_rand_3_5

								
gl religion_know_i			icm_good_sinless ///
							icm_laws_heaven ///
							icm_accept_jc // dummy
							

tab icm_good_sinless
tab icm_good_sinless, nolab
tab icm_laws_heaven
tab icm_laws_heaven, nolab
tab icm_accept_jc
tab icm_accept_jc, nolab


// INDEX

** Step 0: reordering
					
** Varibales that need reordering according to previous lit - we use recode and label define instad of the program designed to reorder, beacuse this variable does not have labels.
label define agree_r 1 "Strongly agree" 2 "Slightly agree" 3 "Neither agree nor disagree" 4 "Slightly disagree" 5 "Strongly disagree"
foreach var of varlist rotr_goodness_r rotr_daily_life_r rotr_other_things_r { 
	recode `var' (1=5) (2=4) (4=2) (5=1)
	label val `var' agree_r
}

** Reorder
foreach var of varlist icm_good_sinless icm_laws_heaven { 
	reorder `var'
}

** Step 1: Standardizing components: only for general religion and religion knowledge
foreach var of varlist $general_religion_i $religion_know_i {
	stan `var'	// program defined before that standandized variables
}

** Step 2: Agregating components 

// intrisic and extrinsic - these indices are agrregated differentely since they come from previous lit
egen religion_intr_i = rowtotal($religion_intr_i), m
egen religion_intr_r_i = rowtotal($religion_intr_r_i), m
egen religion_intr_a_i = rowtotal($religion_intr_a_i), m
egen religion_intr_b_i = rowtotal($religion_intr_b_i), m
egen religion_extr_i = rowtotal($religion_extr_i), m

egen religion_listr_i = rowmean($religion_listr_i)
assert lr_comm_jc_d == lr_bible_d
gen religion_listr_i_d = lr_comm_jc_d // or = to lr_bible_d. this is the dummy for whether they were asked sensitive quetsion

// general and religion knowledge
replace icm_religion = 3*icm_religion // we do this to weight by 3 as stated by the PAP

foreach x of newlist general_religion_i religion_know_i {	
	local `x' $`x'
	local z_`x' 
	foreach var of local `x' {
		local z_`x' `z_`x'' z_`var'
	}
	egen `x' = rowmean(`z_`x'')	
}

replace icm_religion = icm_religion/3 // to come back to the original var


** Step 3: Standardizing index
foreach i of varlist religion_intr_i religion_intr_r_i religion_intr_a_i religion_intr_b_i religion_extr_i general_religion_i religion_know_i {
 	stan `i' 
}


/*
** Step 1: Standardizing components 
foreach var of varlist $religion_intr_i $religion_extr_i $general_religion_i $religion_listr_i $religion_know_i {
	stan `var'	// program defined before that standandized variables
}

** Step 2: Agregating components 

replace icm_religion = 3*icm_religion // we do this to weight by 3 as stated by the PAP

foreach x of newlist religion_intr_i religion_extr_i general_religion_i religion_listr_i religion_know_i {	
	local `x' $`x'
	local z_`x' 
	foreach var of local `x' {
		local z_`x' `z_`x'' z_`var'
	}
	egen `x' = rowmean(`z_`x'')	
}

replace icm_religion = icm_religion/3 // to come back to the original var

** Step 3: Standardizing index
foreach i of varlist religion_intr_i religion_extr_i general_religion_i religion_listr_i religion_know_i {
 	stan `i' 
}
*/

note z_religion_intr_i: "Religion Intrinsic Index"
note z_religion_intr_i: "Standardized - calculated without reversing order"
note z_religion_intr_r_i: "Religion Intrinsic Index"
note z_religion_intr_r_i: "Standardized - calculated as in lit (reversing order of 3 questions)"
note z_religion_intr_a_i: "Religion Intrinsic Index"
note z_religion_intr_a_i: "Standardized - only 5 questions that dont neet to be reversed"
note z_religion_intr_b_i: "Religion Intrinsic Index"
note z_religion_intr_b_i: "Standardized - only 3 questions that neet to be reversed"

note z_religion_extr_i: "Religion Extrinsic Index"
note z_religion_extr_i: "Standardized - calculated as in literature"

note z_general_religion_i: "General Religion Index"
note z_general_religion_i: "Standardized"
note religion_listr_i: "Religion List Randomization Index"
note religion_listr_i: "Not Standardized"
note z_religion_know_i: "Religion Knowledge Index"
note z_religion_know_i: "Standardized"

**************************************************************************************
************************************* CONSUMPTION ************************************
**************************************************************************************
						
loc food_consumption 		w11 /// Viand
							w12 /// Rice/corn/beans/etc
							w13 /// Bananas/cassava/potatoes/yams/starches/etc.
							w14 /// Fruits/Vegetables
							w15 /// Milk/eggs
							w16 // Non-alcoholic beverages
						
loc nonfood_consumption 	w17 /// Alcoholic beverages
							w18 /// Cigarettes
							w19 /// Phone credit
							w110 /// Transportation
							w111 /// Clothing/shoes
							w112 /// Soaps/cosmetics
							w113 // Gifts	
							
loc celebration_spending 	w21 /// Weddings
							w22 /// Funerals
							w23 // Festivals, aniversaries, birthdays

// NEW VARIABLES

egen food_consumption = rowtotal(`food_consumption')
replace food_consumption = food_consumption*(30/7) // we make consumption a monthly meassuremnt to make in comparable with income

egen nonfood_consumption = rowtotal(`nonfood_consumption')
replace nonfood_consumption = nonfood_consumption*(30/7) // we make consumption a monthly meassuremnt to make in comparable with income

egen celebration_spending = rowtotal(`celebration_spending')
replace celebration_spending = celebration_spending/6

*egen tot_consumption = rowtotal(`food_consumption' `nonfood_consumption' `celebration_spending')
egen tot_consumption = rowtotal(food_consumption nonfood_consumption celebration_spending)

// LABELS AND NOTES
note tot_consumption: "Total consumption in the household (last 30 days)"
note tot_consumption: "Includes food consumption, non food consumption and celebration spending"
note food_consumption: "Food consumption in the household (last 30 days)"
note food_consumption: "Includes: Viand, Rice/corn/beans/etc, Bananas/cassava/potatoes/yams/starches/etc, Fruits/Vegetables, Milk/Eggs, Non-alcoholic beverages"
note nonfood_consumption: "Non food consumption in the household (last 30 days)"
note nonfood_consumption: "Includes: Alcoholic beverages, Cigarettes, Phone credit, Transportation, Clothing/shoes, Soaps/cosmetics, Gifts"
note celebration_spending: "Celebration spending in the household (last 30 days)"
note celebration_spending: "Includes: Weddings, Funerals, Festivals, Aniversaries, Birthdays"

label var tot_consumption "Total consumption in the household (last 30 days)"
label var food_consumption "Food consumption in the household (last 30 days)"
label var nonfood_consumption "Non food consumption in the household (last 30 days)"
label var celebration_spending "Celebration spending in the household (last 30 days)"


gl tot_consumption  food_consumption nonfood_consumption celebration_spending


**************************************************************************************
********************************** FOOD SECURITY *************************************
**************************************************************************************

// NEW VARIABLES

** No members of the household went to bed hungry (last 6 months)
gen hungry_d=1 if hs6==3
replace hungry_d=0 if hs6==1 | hs6==2 
*label define hungry_d 1 "No" 0 "Yes"
*label val hungry_d hungry_d

** No members of the household went to bed hungry outside of lean season (last 6 months)
gen hungry_lean_d=1 if hs6==2 | hs6==3
replace hungry_lean_d=0 if hs6==1 
*label define hungry_lean_d 1 "No" 0 "Yes"
*label val hungry_lean_d hungry_lean_d 

** Number of days someone went to bed hungry (last 7 days): reorder!!! -----------------------------CHECK!!
gen hs7_neg = -hs7
gen hs7_inv = 7-hs7

// LABELS AND NOTES

note hungry_d: "Binary indicator: No members of the household went to bed hungry (last 6 months)"
note hungry_lean_d: "Binary indicator: No members of the household went to bed hungry outside of lean season (last 6 months)"
note hs7_inv: "Number of days no member of the household went to bed hungry (last 7 days)"


gl food_security_i 		hungry_d /// no one gone to bed hungry - past 6 months
						hungry_lean_d /// no one gone to bead hungry lean season - past 6 months
						hs7_inv // how many days? Last 7 days
					

					
// INDEX
					
** Step 1: Standardizing components 
foreach var of varlist $food_security_i {
	stan `var'
}

** Step 2: Agregating components 
local food_security_i $food_security_i	
local z_food_security_i 
foreach var of local food_security_i {
		local z_food_security_i `z_food_security_i' z_`var'
}
egen food_security_i = rowmean(`z_food_security_i')	

** Step 3: Standardizing index
stan food_security_i


note z_food_security_i: "Food security index"
note z_food_security_i: "Standardized"

**************************************************************************************
*********************************** HOUSEHOLD INCOME *********************************
**************************************************************************************

// NEW VARIABLES

** NEW CATEGORIES FOR LABOR SUPPLY AND PAY

forvalues i=1/20 {
	cap confirm var pay_1_`i'
	if _rc==0 {
		// hours
		gen hrs_agr_labor_`i' = activities_hours_1_`i'
		gen hrs_livestock_`i' = activities_hours_4_`i'
		egen hrs_formal_employ_`i' = rowtotal(activities_hours_2_`i' activities_hours_5_`i'), missing
		gen hrs_self_employ_`i' = activities_hours_7_`i' if activities_other_types_`i'==0
		replace hrs_self_employ_`i' = 0 if hrs_self_employ_`i'==. & work_outside!=""
		egen hrs_daily_labor_`i' = rowtotal(activities_hours_6_`i' activities_hours_3_`i'), missing
		gen hrs_uncl_employ_`i' = activities_hours_7_`i' if activities_other_types_`i'==1 | activities_other_types_`i'==2
		replace hrs_uncl_employ_`i' = 0 if hrs_uncl_employ_`i'==. & work_outside!=""
		//pay
		gen pay_agr_labor_`i' = pay_1_`i'
		gen pay_livestock_`i' = pay_4_`i'
		egen pay_formal_employ_`i' = rowtotal(pay_2_`i' pay_5_`i'), missing
		gen pay_self_employ_`i' = pay_7_`i' if activities_other_types_`i'==0
		replace pay_self_employ_`i' = 0 if pay_self_employ_`i' ==. & work_outside!=""
		egen pay_daily_labor_`i' = rowtotal(pay_6_`i' pay_3_`i'), missing
		gen pay_uncl_employ_`i' = pay_7_`i' if activities_other_types_`i'==1 | activities_other_types_`i'==2
		replace pay_uncl_employ_`i' = 0 if pay_uncl_employ_`i' ==. & work_outside!=""
	}
}

** EARNINGS FROM WORKING OUTSIDE THE HOUSEHOLD - all members of the household

local act agr_labor livestock formal_employ self_employ daily_labor uncl_employ

forvalues i=1/6 {                                   // 6 new classifications following the fiel team recomendations 
	local x : word `i' of `act'
	loc pay_`x'
	forvalues n=1/20 {
		cap confirm var pay_`x'_`n'
		if _rc==0 {
			loc pay_`x' `pay_`x'' pay_`x'_`n'
		}
	}
	*display in r "`pay_`x''"
	egen pay_`x' = rowtotal(`pay_`x''), missing
	local pay_all `pay_all' pay_`x'
}
*display in r "`pay_all'"

egen tot_pay = rowtotal(`pay_all'), missing

** MICROENTERPRISE SALES, PROFITS AND SPENDING
/*
egen sales=rowmean(z8_1 z8_2 z8_3) // if there is more that one month with normal sales, take the mean of the 2
egen profit=rowmean(z9_1 z9_2 z9_3)
egen z10=rowmean(z10_1 z10_2 z10_3)
egen z11=rowmean(z11_1 z11_2 z11_3)
egen z12=rowmean(z12_1 z12_2 z12_3)
egen z13=rowmean(z13_1 z13_2 z13_3)
egen spending=rowtotal(z10 z11 z12 z13), missing
*/
egen profit=rowtotal(z9_1 z9_2 z9_3)
egen sales=rowtotal(z8_1 z8_2 z8_3) // take the sum of the 3 businesses
egen z10=rowtotal(z10_1 z10_2 z10_3)
egen z11=rowtotal(z11_1 z11_2 z11_3)
egen z12=rowtotal(z12_1 z12_2 z12_3)
egen z13=rowtotal(z13_1 z13_2 z13_3)
egen spending=rowtotal(z10 z11 z12 z13), missing // CHECK this line

replace sales = 0 if z1 == 0
replace profit = 0 if z1 ==0
replace spending = 0 if z1 ==0

// LABELS AND NOTES


/*
note pay_agr_labor: "Total paymemts for agricultural - all members of the household (last 30 days)"
note pay_formal_employ: "Total paymemts for formal employment - all members of the household (last 30 days)"
note pay_housework: "Total paymemts for housework - all members of the household (last 30 days)"
note pay_livestock: "Total paymemts for livestock - all members of the household (last 30 days)"
note pay_business: "Total paymemts for business - all members of the household (last 30 days)"
note pay_daily_labor: "Total paymemts for daily labor - all members of the household (last 30 days)"
note pay_other: "Total paymemts for other activities - all members of the household (last 30 days)"
note sales: "Business total sales (most recent month with normal sales)"
note profit: "Business total profit (most recent month with normal sales)"
note spending: "Bussines total spending (most recent month with normal sales)"
note tot_pay: "Total paymemts for all activities - all members of the household (last 30 days)"


label var pay_agr_labor "Total paymemts for agricultural labor - all members of the household (last 30 days)"
label var pay_formal_employ "Total paymemts for formal employment - all members of the household (last 30 days)"
label var pay_housework "Total paymemts for housework - all members of the household (last 30 days)"
label var pay_livestock "Total paymemts for livestock - all members of the household (last 30 days)"
label var pay_business "Total paymemts for business - all members of the household (last 30 days)"
label var pay_daily_labor "Total paymemts for daily labor - all members of the household (last 30 days)"
label var pay_other "Total paymemts for other activities - all members of the household (last 30 days)"
label var sales "Business total sales (most recent month with normal sales)"
label var profit "Business total profit (most recent month with normal sales)"
label var spending "Bussines total spending (most recent month with normal sales)"
label var tot_pay "Total paymemts for all activities - all members of the household (last 30 days)"
*/

gl household_income 	pay_agr_labor ///
						pay_livestock ///
						pay_formal_employ ///
						pay_self_employ ///
						pay_daily_labor ///
						pay_uncl_employ ///
						profit 
						
egen household_income = rowtotal($household_income), m
replace household_income = . if tot_pay==. // we want to replace with . for those obs for which we have no info on income generating activities other than profits

assert tot_pay <= household_income

note household_income: "Total paymemts for all activities - all members of the household (last 30 days)"

**************************************************************************************
************************************ LABOR SUPPLY ************************************ ////// CHECK- DROP VARS THAT WE DONT USE
**************************************************************************************					
** TIME SPENT WORING OUTSIDE THE HOUSEHOLD (HOURS)

** Agragate the following variables for all members of the household and different economic activities: 

local N =_N
local act agr_labor livestock formal_employ self_employ daily_labor uncl_employ 
local hours_ad
local hours_ch
forvalues j=1/6 {
	local x : word `j' of `act' 
	forvalues i = 1/20 {
		cap confirm var hrs_`x'_`i'
		if _rc == 0 {
			// number of hours per day multiplied by 7
			gen tothrs_ad_`x'_`i'= hrs_`x'_`i'*7 if age_`i'>16 & !mi(age_`i') // numer of hours per day multiplied by 7
			replace tothrs_ad_`x'_`i' = 0 if !mi(hrs_`x'_`i') & age_`i'<=16 & !mi(age_`i')
			assert tothrs_ad_`x'_`i' == . if hrs_`x'_`i' == .
			assert  hrs_`x'_`i'==. if (tothrs_ad_`x'_`i' == . & age_`i'!=.)
			
			gen tothrs_ch_`x'_`i'= hrs_`x'_`i'*7 if age_`i'<=16
			replace tothrs_ch_`x'_`i' = 0 if !mi(hrs_`x'_`i') & age_`i'>16 & !mi(age_`i')
			assert tothrs_ch_`x'_`i' == . if hrs_`x'_`i' == .
			assert hrs_`x'_`i'==. if (tothrs_ch_`x'_`i' == . & age_`i'!=.)
		}
	}
	egen tothrs_`x'_ad= rowtotal(tothrs_ad_`x'_*), missing
	egen tothrs_`x'_ch= rowtotal(tothrs_ch_`x'_*), missing
	loc tothrs_ad `tothrs_ad' tothrs_`x'_ad
	loc tothrs_ch `tothrs_ch' tothrs_`x'_ch
}


egen tothrs_ad = rowtotal(`tothrs_ad'), missing
egen tothrs_ch = rowtotal(`tothrs_ch'), missing

egen ages = concat(age_*), punct(" ")
replace ages = subinstr(ages, ".", "", .)
replace ages = trim(itrim(ages))


// LABELS AND NOTES
/*
note tothrs_ad: "Labor supply in all activities - total adult hours in the household (last 7 days)"
note tothrs_agr_labor_ad: "Labor supply agricultural labor - total adult hours in the household (last 7 days)"
note tothrs_formal_employ_ad: "Labor supply formal employment - total adult hours in the household (last 7 days)"
note tothrs_housework_ad: "Labor supply housework-adult hours - total adult hours in the household (last 7 days)"
note tothrs_livestock_ad: "Labor supply livestock-adult hours - total adult hours in the household (last 7 days)"
note tothrs_business_ad: "Labor supply business-adults hours - total adult hours in the household (last 7 days)"
note tothrs_daily_labor_ad: "Labor supply daily labor-adults - total adult hours in the household (last 7 days)"
note tothrs_other_ad: "Labor supply other activities-adults - total adult hours in the household (last 7 days)"

note tothrs_ch: "Labor supply in all activities - total children hours in the household (last 7 days)"
note tothrs_agr_labor_ch: "Labor supply agricultural labor - total children hours in the household (last 7 days)"
note tothrs_formal_employ_ch: "Labor supply formal employment - total children hours in the household (last 7 days)"
note tothrs_housework_ch: "Labor supply housework - total children hours in the household (last 7 days)"
note tothrs_livestock_ch: "Labor supply livestock - total children hours in the household (last 7 days)"
note tothrs_business_ch: "Labor supply business - total children hours in the household (last 7 days)"
note tothrs_daily_labor_ch: "Labor supply daily labor - total children hours in the household (last 7 days)"
note tothrs_other_ch: "Labor supply other activities - total children hours in the household (last 7 days)"

label var tothrs_ad "Labor supply in all activities - total adult hours in the household (last 7 days)"
label var tothrs_ch "Labor supply in all activities-children hours in the last 7 days"
label var tothrs_agr_labor_ad "Labor supply agricultural labor-adult hours in the last 7 days"
label var tothrs_agr_labor_ch "Labor supply agricultural labor-children hours in the last 7 days"
label var tothrs_formal_employ_ad "Labor supply formal employment-adult hours in the last 7 days"
label var tothrs_formal_employ_ch "Labor supply formal employment-children hours in the last 7 days"
label var tothrs_housework_ad "Labor supply housework-adult hours in the last 7 days"
label var tothrs_housework_ch "Labor supply housework-children hours in the last 7 days"
label var tothrs_livestock_ad "Labor supply livestock-adult hours in the last 7 days"
label var tothrs_livestock_ch "Labor supply livestock-children hours in the last 7 days"
label var tothrs_business_ad "Labor supply business-adults hours in the last 7 days"
label var tothrs_business_ch "Labor supply business-children hours in the last 7 days"
label var tothrs_daily_labor_ad "Labor supply daily labor-adults hours in the last 7 days"
label var tothrs_daily_labor_ch "Labor supply daily labor-children hours in the last 7 days"
label var tothrs_other_ad "Labor supply other activities-adults hours in the last 7 days"
label var tothrs_other_ch "Labor supply other activities-children hours in the last 7 days"
*/			

gl labor_supply_ad			tothrs_agr_labor_ad /// 
							tothrs_livestock_ad /// 
							tothrs_formal_employ_ad ///
							tothrs_self_employ_ad ///
							tothrs_daily_labor_ad ///
							tothrs_uncl_employ_ad 

**************************************************************************************
**************************** LIFE SATISFACTION/MENTAL HEALTH *************************
**************************************************************************************
// NEW VARIABLES

gen feeling_worry_neg = - feeling_worry
gen feeling_sad_neg = - feeling_sad
egen sum_wvs = rowtotal(feeling_enjoy feeling_happy feeling_worry_neg feeling_sad_neg), missing

// LABELS AND NOTES

note replace life_sat in 1: "How would describe your satisfaction with life? 1-10 (higher = more satisfied)"
note life_sat: "Ladder: (1) represents very dissatisfied and the top of the ladder (10) represents very satisfied"
note replace happy in 1: "Taking all things together, would you say you are happy?"
note sum_wvs: "Did you experience the following feelings during a lot of the day yesterday? Enjoyment, happiness, worry, sadness"
note sum_wvs: "World values survey questions: feeling_enjoy + feeling_happy - feeling_worry_neg - feeling_sad_neg"

gl kessler_i 			feel_nervous /// check order
						feel_hopeless ///
						feel_restless ///
						feel_depressed ///
						feel_effort ///
						feel_worthless

gl life_satisfacton_i	kessler_i ///
						life_sat ///
						happy ///
						smile ///
						sum_wvs
						
	
// INDEX

** Step 1: Standardizing componets - Kessler index 
foreach var of varlist $kessler_i {
	stan `var'
}

** Step 2: Agregating - Kessler index 
local kessler_i $kessler_i
local z_kessler_i 
foreach var of local kessler_i {
	local z_kessler_i `z_kessler_i' z_`var'
}
egen kessler_i = rowmean(`z_kessler_i')	

** Step 1: standardizing components - Life satisfaction index
foreach var of varlist $life_satisfacton_i {
	stan `var'
}


** Step 2: Agregating - Life satisfaction index
local life_satisfacton_i $life_satisfacton_i
local z_life_satisfacton_i 
foreach var of local life_satisfacton_i {
	local z_life_satisfacton_i `z_life_satisfacton_i' z_`var'
}
egen life_satisfacton_i = rowmean(`z_life_satisfacton_i')	


** Step 3: Standardizing the index
stan life_satisfacton_i

note kessler_i: "Kessler psycological scale"
note z_life_satisfacton_i: "Life satisfaction index"
note z_life_satisfacton_i: "Standardized"

**************************************************************************************
********************************* ECONOMIC WELLBEING *********************************
**************************************************************************************

gl econ_well_i 		relative_ses // Ladder: place your household in terms of economic status. 1-poorest, 10-best off members of community

note replace relative_ses in 1: "Where would you place your household on the ladder in terms of economic status? (higher = more economic status)"

// This variable is not standardized!
**************************************************************************************
*********************************** SOCIAL CAPITAL ***********************************
**************************************************************************************

// NEW VARIABLES
gen discuss_freq_num = discuss_freq
recode discuss_freq_num (2=6) (3=12) (4=24) (5=52) (6=104) (7=365)

gen comm_act_freq_num = comm_act_freq
recode comm_act_freq_num (2=6) (3=12) (4=24) (5=52) (6=104) (7=365)

// WINSORIZING
gen w31_w = w31
gen w33_w = w33

foreach var of varlist w31 w33 {																				
	sum `var', detail
	local 99_perc `r(p99)'
	replace `var'_w= `99_perc' if `var'>`99_perc' & !mi(`var')
}

// LABELS AND NOTES
note w31_w: `w31[note1]'
note w31_w: "Winzorized"
note w33_w: `w33[note1]'
note w33_w: "Winzorized"
note discuss_freq_num: "How often do you usually speak to this person? - Number of days in a year"
note comm_act_freq_num: "How frequently did you participate in community activities? - Number of days in a year"
note people_trust: "higher = trusted"
note people_fair: "higher = fair"
note people_helpful: "higher = helpful"

gl trust_i					people_trust ///
							people_fair ///
							people_helpful

gl safety_net_i				small_financial_borrow ///
							large_financial_borrow ///
							discuss_person ///
							discuss_freq_num ///
							w3 ///
							w31_w ///
							w32 ///
							w33_w
												
gl community_act_i 			vill_meet /// 
							comm_act ///
							comm_act_freq_num 

							
							
							
// INDEX

** Step 1: Standardizing components 
foreach var of varlist $trust_i $safety_net_i $community_act_i {
	stan `var'	// program defined before that standandized variables
}

** Step 2: Agregating components 
foreach x of newlist trust_i safety_net_i community_act_i {	
	local `x' $`x'
	local z_`x' 
	foreach var of local `x' {
		local z_`x' `z_`x'' z_`var'
	}
	egen `x' = rowmean(`z_`x'')	
}

** Step 3: Standardizing index
foreach i of varlist trust_i safety_net_i community_act_i {
 	stan `i' 
}
	

note z_trust_i: "Trust Index"
note z_trust_i: "Standardized"	
note z_safety_net_i: "Social Safety net Index"
note z_safety_net_i: "Standardized"	
note z_community_act_i: "Community activities Index"
note z_community_act_i: "Standardized"						
							
							
**************************************************************************************
********************************* LOCUS OF CONTROL ***********************************
**************************************************************************************

gl 	stress_i				s1 ///
							s2 ///
							s3 ///
							s4

gl 	others_i				loc_events_god /// CHECK ORDER
							loc_success_god ///
							loc_life_god ///
							loc_wants_god ///
							loc_accident_god ///
							loc_plans_god
				
gl internal_i				loc_success_self ///
							loc_accident_self ///
							loc_plans_self ///
							loc_friends_self /// 
							loc_events_self ///
							loc_interests_self ///
							loc_wants_self ///
							loc_life_self

				
gl chance_i					loc_life_chance ///
							loc_interests_chance ///
							loc_wants_chance ///
							loc_events_chance ///
							loc_accident_chance ///
							loc_plan_chance ///
							loc_success_chance ///
							loc_friends_chance
							
gl locus_control_i 			internal_i ///
							chance_i ///
							wvs_loc // Please tell me which comes closest to your view on a scale on which (1) means everything in life is determined by fate and (10) means people shape their fate themselves


// INDEX

** Step 0: reordering						
foreach var of varlist s1 s4 {
	labrec `var' (1=5) (2=4) (4=2) (5=1)
}

foreach var of varlist $chance_i {
	reorder `var' 
}

** Step 1: Standardizing componets - subindices 
foreach var of varlist $internal_i $chance_i {
	stan `var'
}

** Step 2: Agregating - subindices
foreach x of newlist internal_i chance_i {	
	local `x' $`x'
	local z_`x' 
	foreach var of local `x' {
		local z_`x' `z_`x'' z_`var'
	}
	egen `x' = rowmean(`z_`x'')	
}

** Step 1: Standardizing components - main indices
foreach var of varlist $stress_i $others_i $locus_control_i {
	stan `var'
}

** Step 2: Agregating components - main indices
foreach x of newlist stress_i others_i locus_control_i {	
	local `x' $`x'
	local z_`x' 
	foreach var of local `x' {
		local z_`x' `z_`x'' z_`var'
	}
	egen `x' = rowmean(`z_`x'')	
}

** Step 3: Standardizing index
foreach i of varlist stress_i others_i locus_control_i {
 	stan `i' 
}

note z_stress_i: "Percieved Stress Scale Index"
note z_stress_i: "Standardized"	
note z_others_i: "Powerful Others Subscale"
note z_others_i: "Standardized"	
note z_locus_control_i: "Locus of control Index"
note z_locus_control_i: "Standardized"		
note z_internal_i: "Internality Subscale"
note z_internal_i: "Standardized"
note z_chance_i: "Chance Index"
note z_chance_i: "Standardized"

**************************************************************************************
************************************* OPTIMISM ***************************************
**************************************************************************************
// NEW VARIBALES

** to check for consistency in optimism/pesimism vars
gen opt_pes = r1 + r2
tab opt_pes

gen r2_inv = 8-r2

// LABELS AND NOTES
note replace r1 in 1: "How optimistic are you in general, on a scale of 1 to 7? (higher = more optimistic)"
note r2_inv: "How pessimistic are you in general, on a scale of 1 to 7? (higher = less pessimistic)"
note replace future_life_sat in 1: "Where do you believe you will be in 5 years - in terms of life satisfaction? 1-10 (higher = more satisfied)"
note future_life_sat: "Ladder: (1) represents very dissatisfied and the top of the ladder (10) represents very satisfied"
note future_life_sat: "Where do you think you will be 5 years from now - in terms of your economic status? 1-10 (higher = more economic status)"


gl life_orientation_i			q1 /// higher-positive
								q3 /// higher-negative ----> reorder
								q4 /// higher-positive
								q7 /// higher-negative ----> reorder
								q9 /// higher-negative ----> reorder
								q10 // higher-positive

gl expectations_i 		future_life_sat ///
						future_relative_ses /// 

gl optimism_i 			r1 ///
						r2_inv
						
// INDEX

** Step 0: reordering					
** Optimism: higher outcomes more optimism
foreach var of varlist q3 q7 q9 { 
	labrec `var' (1=5) (2=4) (4=2) (5=1)
}

** Step 1: Standardizing components 
foreach var of varlist $life_orientation_i $expectations_i $optimism_i {
	stan `var'	
}

** Step 2: Agregating components 
foreach x of newlist life_orientation_i expectations_i optimism_i {	
	local `x' $`x'
	local z_`x' 
	foreach var of local `x' {
		local z_`x' `z_`x'' z_`var'
	}
	egen `x' = rowmean(`z_`x'')	
}

** Step 3: Standardizing index
foreach i of varlist life_orientation_i expectations_i optimism_i {
 	stan `i' 
}


note z_life_orientation_i: "Life Orientation Index"
note z_life_orientation_i: "Standardized"	
note z_expectations_i: "Expectations Index"
note z_expectations_i: "Standardized"	
note z_optimism_i: "Optimism Index"
note z_optimism_i: "Standardized"		


**************************************************************************************
****************************** GRIT AND SELF-CONTROL *********************************
**************************************************************************************					

gl grit_i				grit_distract /// higher-negative ----> reorder
						grit_setbacks /// higher-positive
						grit_short_obsession /// higher-negative ----> reorder
						grit_hard_worker /// higher-positive
						grit_goals /// higher-negative ----> reorder
						grit_extended_focus /// higher-negative ----> reorder
						grit_finish /// higher-positive
						grit_diligent // higher-positive
						

gl self_control_i		m1 /// higher-negative ----> reorder
						m2 /// higher-negative ----> reorder
						m3 /// higher-negative ----> reorder
						m4 /// higher-positive
						m5 /// higher-positive
						m6 /// higher-positive
						m7 /// higher-negative ----> reorder
						m8 /// higher-negative ----> reorder
						m9 /// higher-negative ----> reorder
						m10 // higher-negative ----> reorder

						
// INDEX

** Step 0: reordering	
** Grit: higher outcomes more disciplined
foreach var of varlist grit_distract grit_short_obsession grit_goals grit_extended_focus {
	labrec `var' (1=5) (2=4) (4=2) (5=1)
}

** Self control: higher outcomes more self control
foreach var of varlist m1 m2 m3 m7 m8 m9 m10 {
	labrec `var' (1=5) (2=4) (4=2) (5=1)
}

** Step 1: Standardizing components 
foreach var of varlist $grit_i $self_control_i  {
	stan `var'	
}

** Step 2: Agregating components 
foreach x of newlist grit_i self_control_i {	
	local `x' $`x'
	local z_`x' 
	foreach var of local `x' {
		local z_`x' `z_`x'' z_`var'
	}
	egen `x' = rowmean(`z_`x'')	
}

** Step 3: Standardizing index
foreach i of varlist grit_i self_control_i {
 	stan `i' 
}

note z_grit_i: "Grit Index"
note z_grit_i: "Standardized"	
note z_self_control_i: "Self Control Index"
note z_self_control_i: "Standardized"	

**************************************************************************************
************************************** ASSETS ****************************************
**************************************************************************************

// NEW VARIABLES

** Productive assets
local prod_assets 	11 /// Tractor
					12 /// Sewing Machine
					20 // Farm tools


** Household assets
local house_assets 	1 /// TV
					2 /// VTR/VHS/VCD/DVD player
					3 /// Radio / Transistor / Stereo
					4 /// Electric Fan
					5 /// Refrigerator/Freezer
					6 /// Telephone / Mobile Phone
					7 /// Sala set
					8 /// Bicycle or Pedicab
					9 /// Motorcab or Motorcycle
					10 /// Boat
					13 /// Washing machine
					14 /// Chair / Stool
					15 /// Bed or Cot
					16 /// Table
					17 /// watch or Clock
					18 /// Jewelry
					19 // Gas stove

local prod_assets_unit 
local house_assets_unit
local prod_assets_val 
local house_assets_val
local prod_assets_unit_6m
local house_assets_unit_6m
local prod_assets_val_6m
local house_assets_val_6m

foreach n of local prod_assets {
	replace y2_`n'=0 if y1_`n' == 0
	replace y4_`n'=0 if y1_`n' == 0
	
	gen y1_`n'_6m = y1_`n' // generating vars for assets aquired in the last 6 months
	replace y1_`n'_6m = 0 if y3_`n' == 0
	gen y2_`n'_6m = y2_`n'
	replace y2_`n'_6m = 0 if y3_`n' == 0
	label val y2_`n'_6m y1_20
	gen y4_`n'_6m = y4_`n'
	replace y4_`n'_6m = 0 if y3_`n' == 0
	
	local prod_assets_unit `prod_assets_unit' y2_`n'
	local prod_assets_val `prod_assets_val' y4_`n'
	local prod_assets_unit_6m `prod_assets_unit_6m' y2_`n'_6m
	local prod_assets_val_6m `prod_assets_val_6m' y4_`n'_6m
	
	
}

foreach n of local house_assets {
	replace y2_`n'=0 if y1_`n' == 0
	replace y4_`n'=0 if y1_`n' == 0
	
	gen y1_`n'_6m = y1_`n' // generating vars for assets aquired in the last 6 months
	replace y1_`n'_6m = 0 if y3_`n' == 0
	gen y2_`n'_6m = y2_`n'
	replace y2_`n'_6m = 0 if y3_`n' == 0
	label val y2_`n'_6m y1_20
	gen y4_`n'_6m = y4_`n'
	replace y4_`n'_6m = 0 if y3_`n' == 0
	
	local house_assets_unit `house_assets_unit' y2_`n'
	local house_assets_val `house_assets_val' y4_`n'
	local house_assets_unit_6m `house_assets_unit_6m' y2_`n'_6m
	local house_assets_val_6m `house_assets_val_6m' y4_`n'_6m
}

** Levels
egen prod_assets_unit = rowtotal(`prod_assets_unit'), missing // count of productive assets
egen prod_assets_val = rowtotal(`prod_assets_val'), missing // value of productive assets	
egen house_assets_unit = rowtotal(`house_assets_unit'), missing // count of household assets				
egen house_assets_val = rowtotal(`house_assets_val'), missing // count of household assets			

** Aquired in the last 6 months
egen prod_assets_unit_6m = rowtotal(`prod_assets_unit_6m'), missing // count of productive assets
egen prod_assets_val_6m = rowtotal(`prod_assets_val_6m'), missing // value of productive assets	
egen house_assets_unit_6m = rowtotal(`house_assets_unit_6m'), missing // count of household assets				
egen house_assets_val_6m = rowtotal(`house_assets_val_6m'), missing // count of household assets	


// LABELS AND NOTES
 
note prod_assets_unit: "Number of productive assets in the household"
note prod_assets_unit: "Includes: Tractors, Sewing machines, Farm tools"
note prod_assets_val: "Value of the productive assets in the household"
note prod_assets_val: "Includes: Tractors, Sewing machines, Farm tools"
note house_assets_unit: "Number of house assets in the household"
note house_assets_unit: "Includes: TV, VTR/VHS/VCD/DVD player, Radio/Transistor/Stereo, Electric Fan, Refrigerator/Freezer, Telephone/Mobile Phone, Sala set, Bicycle or Pedicab, Motorcab or MotorcycleBoat, Washing machine, Chair/Stool, Bed or Cot, Table, Watch or Clock, Jewelry, Gas stove"
note house_assets_val: "Value of the house assets in the household"
note house_assets_val: "Includes: TV, VTR/VHS/VCD/DVD player, Radio/Transistor/Stereo, Electric Fan, Refrigerator/Freezer, Telephone/Mobile Phone, Sala set, Bicycle or Pedicab, Motorcab or MotorcycleBoat, Washing machine, Chair/Stool, Bed or Cot, Table, Watch or Clock, Jewelry, Gas stove"
note prod_assets_unit_6m: "Number of productive assets in the household (aquired in last 6 months)"
note prod_assets_unit_6m: "Includes: Tractors, Sewing machines, Farm tools"
note prod_assets_val_6m: "Value of the productive assets in the household (aquired in last 6 months)"
note prod_assets_unit_6m: "Includes: Tractors, Sewing machines, Farm tools"
note house_assets_unit_6m: "Number of house assets in the household (aquired in last 6 months)"
note house_assets_unit_6m: "Includes: TV, VTR/VHS/VCD/DVD player, Radio/Transistor/Stereo, Electric Fan, Refrigerator/Freezer, Telephone/Mobile Phone, Sala set, Bicycle or Pedicab, Motorcab or MotorcycleBoat, Washing machine, Chair/Stool, Bed or Cot, Table, Watch or Clock, Jewelry, Gas stove"
note house_assets_val_6m: "Value of the house assets in the household (aquired in last 6 months)"
note house_assets_val_6m: "Includes: TV, VTR/VHS/VCD/DVD player, Radio/Transistor/Stereo, Electric Fan, Refrigerator/Freezer, Telephone/Mobile Phone, Sala set, Bicycle or Pedicab, Motorcab or MotorcycleBoat, Washing machine, Chair/Stool, Bed or Cot, Table, Watch or Clock, Jewelry, Gas stove"

note replace small_financial_reserve in 1: "In the case of urgent need, what is the chance that you, or someone in your household, would have 40Php available for your use?"
note replace large_financial_reserve in 1: "In the case of urgent need, what is the chance that you, or someone in your household, would have 1000Php available for your use?"


// WINSORIZING
foreach var of varlist prod_assets_unit prod_assets_val house_assets_unit house_assets_val prod_assets_unit_6m prod_assets_val_6m house_assets_unit_6m house_assets_val_6m {	// -----------check			
	clonevar `var'_w = `var'
	qui sum `var'_w, detail
	local 99_perc `r(p99)'
	replace `var'_w= `99_perc' if `var'>`99_perc' & !mi(`var')
	note `var'_w: "Winsorized"
}


gl assets_i 		prod_assets_unit_w ///
					prod_assets_val_w ///
					house_assets_unit_w ///
					house_assets_val_w ///
					prod_assets_unit_6m_w ///
					prod_assets_val_6m_w ///
					house_assets_unit_6m_w ///
					house_assets_val_6m_w ///
					fs7 ///
					small_financial_reserve ///
					large_financial_reserve
				

// INDEX

** Step 1: Standardizing components 
foreach var of varlist $assets_i  {
	stan `var'	
}

** Step 2: Agregating components 
local assets_i $assets_i
local z_assets_i 
foreach var of local assets_i {
	local z_assets_i `z_assets_i' z_`var'
}
egen assets_i = rowmean(`z_assets_i')	

** Step 3: Standardizing index
stan assets_i 


note z_assets_i: "Assets Index"
note z_assets_i: "Standardized"	


		
**************************************************************************************
********************************* FINANCIAL INCLUSION ********************************
**************************************************************************************	

gl financial_incl_i 	fs1 ///
						fs2 ///
						fs5 //

						
// INDEX

** Step 1: Standardizing components 
foreach var of varlist $financial_incl_i  {
	stan `var'	
}

** Step 2: Agregating components 
local financial_incl_i $financial_incl_i
local z_financial_incl_i
foreach var of local financial_incl_i {
	local z_financial_incl_i `z_financial_incl_i' z_`var'
}
egen financial_incl_i = rowmean(`z_financial_incl_i')	

** Step 3: Standardizing index
stan financial_incl_i 

note z_financial_incl_i: "Financial Inclusion Index"
note z_financial_incl_i: "Standardized"		
		
**************************************************************************************
***************************************** HEALTH *************************************
**************************************************************************************
// NEW VARIABLES

** Serious health events in the household - this var should be winsorized according to PAP
gen hs1_w = hs1

*winsor2 hs1, cuts(0 99)	
qui sum hs1, detail         
local 99_perc `r(p99)'
replace hs1_w= `99_perc' if hs1>`99_perc' & !mi(hs1) 


** Number of illnesses in household
gen number_illness = .
gen number_accidents = .
local N=_N
forvalues n=1/`N' {        // this loop counts the number of "illness" or "accident + illness" for all mebers of the household                 
	local count = 0
	local count_a = 0
	forvalues i=1/15 {
		if (hs4_`i'==1 | hs4_`i'==3) in `n' { 		// illness or both
			local ++count
		}
		if (hs4_`i'==2 | hs4_`i'==3) in `n' { 		// accident or both
			local ++count_a
		}
	}
	replace number_illness=`count' in `n'
	replace number_accidents=`count_a' in `n'
}

replace number_illness = . if missing(hs3)
replace number_accidents = . if missing(hs3)
gen illness_d = hs3
replace illness_d = 0 if number_illness == 0 // This variable only includes illnesses (not accidents)


** Number of days someone was incapacitated
forvalues i=1/15 {
	gen hs5_days_`i' = hs5_`i' if hs5_unit_`i' == 1
	replace hs5_days_`i' = hs5_`i'*7 if hs5_unit_`i' == 2
	replace hs5_days_`i' = hs5_`i'*30 if hs5_unit_`i' == 3
}

gen days_incap = .
gen days_incap_a = .
local N=_N
forvalues n=1/`N' {        // this loop counts the number of "illness" or "accident + illness" for all mebers of the household                 
	local count = 0
	local count_a = 0
	forvalues i=1/15 {
		if (hs4_`i'==1 | hs4_`i'==3) in `n' {
			local days = hs5_days_`i' in `n'
			local count = `count' + `days'
		}
		
		if (hs4_`i'==2 | hs4_`i'==3) in `n' {
			local days_a = hs5_days_`i' in `n'
			local count_a = `count_a' + `days'
		}
		
	}
	replace days_incap=`count' in `n'
	replace days_incap_a=`count_a' in `n'
}

replace days_incap = . if missing(hs3)
replace days_incap_a = . if missing(hs3)
replace days_incap = 30 if days_incap>30 & !missing(days_incap)
replace days_incap_a = 30 if days_incap_a>30 & !missing(days_incap_a)

// Change to negative values - this is done so that higher numbers correcpond to better outcomes
gen hs1_w_neg = -hs1_w
gen number_illness_neg = -number_illness
gen days_incap_neg = -days_incap

// LABELS AND NOTES

*note hs1_w: `hs1[note1]'
*note replace hs1 in 1: "Number of serious health events in the household (last 6 months)"
note hs1_w: "Number of serious health events in the household - winsorized (last 6 months)"
note hs1_w: "(that required hospital or health center admission, or resulted in loss of workdays)"
note hs1_w: "Winsorized"
note hs1_w_neg: "Number of serious health events in the household - negative and winsorized (last 6 months)"
note hs1_w_neg: "(that required hospital or health center admission, or resulted in loss of workdays)"
note hs1_w_neg: "Negative"
note hs1_w_neg: "Winsorized"
note number_illness: "Number of household memebers that have suffered an illness that has kept them from working (last 30 days)"
note number_illness_neg: "Number of household memebers that have suffered an illness that has kept them from working - negative (last 30 days)"
note number_accidents: "Number of household memebers that have suffered an accident that has kept them from working (last 30 days)"
note illness_d: "Binary indicator - households with at least one member that has suffered an illness that has kep them fom working (last 30 days)"
note: days_incap: "Total number of workdays missed due to illness (last 30 days)"
note: days_incap_neg: "Total number of workdays missed due to illness - negative (last 30 days)"


gl health_i		hs1_w_neg ///
				number_illness_neg ///
				days_incap_neg // check if include this variable 
					


// INDEX

** Step 1: Standardizing components 
foreach var of varlist $health_i  {
	stan `var'	
}

** Step 2: Agregating components 
local health_i $health_i
local z_health_i
foreach var of local health_i {
	local z_health_i `z_health_i' z_`var'
}
egen health_i = rowmean(`z_health_i')	

** Step 3: Standardizing index
stan health_i 
		
note z_health_i: "Health Index"
note z_health_i: "Standardized"		
				
**************************************************************************************
************************************** HYGENE ****************************************
**************************************************************************************

// NEW VARIABLES

** Open defecation (primary latrine)
gen lt4_open_def_d = .
replace lt4_open_def_d = 1 if lt4 == 1 | lt4 == 2 | lt4 == 3 // Ask about inluiding 3....
replace lt4_open_def_d = 0 if lt4 == 4 | lt4 == 5 

gen lt4_no_open_def_d = lt4_open_def_d
recode lt4_no_open_def_d (1=0) (0=1)


forvalues i=1/3 {  // this loop generated dummies for men (1) women (2) and children (3) that use this latrine as primary
	gen lt5_`i' = regexm(lt5, "`i'")
	replace lt5_`i' = . if lt5 == ""
	gen lt4_open_def_d_`i' = lt5_`i' * lt4_open_def_d
}


** keep animals in sanitary way: if dont have animals or animals have stable
gen animals_sanitary = 1 if v6 == 0
replace animals_sanitary = 1 if v6 == 1 & v7 == 1 
replace animals_sanitary = 0 if v6 == 1 & v7 == 0

// LABELS AND NOTES

label val lt4_open_def_d dummy
label val lt4_open_def_d_1 dummy
label val lt4_open_def_d_2 dummy
label val lt4_open_def_d_3 dummy

note animals_sanitary: "Binary indicator: Households that keep animals in a sanitary way"
note lt4_open_def_d: "Binary indicator: Households with members that practice open defecation" 
note lt4_open_def_d_1: "Binary indicator: Households with men that practice open defecation"
note lt4_open_def_d_2: "Binary indicator: Households with women that practice open defecation"
note lt4_open_def_d_3: "Binary indicator: Households with children that practice open defecation"
note lt4_no_open_def_d: "Binary indicator: Households with no members that practice open defecation" 


gl hygiene_listr_i 	lr_wash_hands ///
					lr_treat_water //

gl hygiene_i 		animals_sanitary /// Dummy for households with separate stables for aniimals
					lt4_no_open_def_d // Dummy for households with at least one member that practices open defecation
					
				
// INDEX

** Step 1: Standardizing components - only for hygiene index (not lr)
foreach var of varlist $hygiene_i {
	stan `var'	
}

** Step 2: Agregating components 

egen hygiene_listr_i = rowmean($hygiene_listr_i)
assert lr_treat_water_d == lr_wash_hands_d
gen hygiene_listr_i_d = lr_treat_water_d

foreach x of newlist hygiene_i {	
	local `x' $`x'
	local z_`x' 
	foreach var of local `x' {
		local z_`x' `z_`x'' z_`var'
	}
	egen `x' = rowmean(`z_`x'')	
}

** Step 3: Standardizing index - only for hygiene index (not lr)
foreach i of varlist hygiene_i  {
 	stan `i' 
}


/*
** Step 1: Standardizing components 
foreach var of varlist $hygiene_listr_i $hygiene_i {
	stan `var'	
}

** Step 2: Agregating components 
foreach x of newlist hygiene_listr_i hygiene_i {	
	local `x' $`x'
	local z_`x' 
	foreach var of local `x' {
		local z_`x' `z_`x'' z_`var'
	}
	egen `x' = rowmean(`z_`x'')	
}

** Step 3: Standardizing index
foreach i of varlist hygiene_listr_i hygiene_i  {
 	stan `i' 
}
*/

	
note hygiene_listr_i: "Hygiene List Randomization Index"
note hygiene_listr_i: "Standardized - not standardized"	
note z_hygiene_i: "Hygiene Index"
note z_hygiene_i: "Standardized"	

**************************************************************************************
*************************************** HOME *****************************************
**************************************************************************************
//NEW VARIABLES

** Leak
gen leakfree_all_d = 1 if v4 == 3
replace leakfree_all_d = 0 if v4 == 1 | v4 == 2

gen leakfree_some_d = 1 if v4 == 3 | v4 == 2
replace leakfree_some_d = 0 if v4 == 1 


** Lock
gen lock_all_d = 1 if v5 == 1
replace lock_all_d = 0 if v4 == 2 | v4 == 3

gen lock_some_d = 1 if v4 == 1 | v4 == 2
replace lock_some_d = 0 if v4 == 3


** Electricity
gen electricity_d = 0
replace electricity_d = 1 if v18_1 == 2 | v18_2 == 2
replace electricity_d =. if v18_1 == . & v18_2 == .
// should we have a var that is electricity, others, no lighting arrangement?

** Latrine in house - note: values were inverted in claning do file so they dont correspond to survey sheet
gen lt_house_d = .
replace lt_house_d = 1 if lt3 == 4 
replace lt_house_d = 0 if lt3 == 1 | lt3 == 2 | lt3 == 3


// NOTES AND LABELS

label val electricity_d dummy
label val lt_house_d dummy

note leakfree_all_d: "Are all rooms leak-free? (binary)"
note leakfree_all_d: "Households with no rooms that leak during rains (binary)"
note leakfree_some_d: "Are at least some rooms leak-free? (binary)"
note leakfree_some_d: "Households with at least some rooms that dont leak during rains (binary)"
note lock_all_d: "Are all rooms safely locked? (binary)"
note lock_some_d: "Are at least some rooms safely locked? (binary)"
note electricity_d: "Households with electricity for lighting (binary)"
note lt_house_d: "Households with primary latrine inside the house (binary)"
		

gl house_i 			leakfree_all_d /// Leak - all rooms
					leakfree_some_d /// Leak - some rooms
					lock_all_d /// Lock - all rooms
					lock_some_d /// Lock - some rooms
					electricity_d /// Source of energy for lighting
					lt_house_d // Primary latrine inside the house
			

			
// INDEX

** Step 1: Standardizing components 
foreach var of varlist $house_i  {
	stan `var'	
}

** Step 2: Agregating components 
local house_i $house_i
local z_house_i
foreach var of local house_i {
	local z_house_i `z_house_i' z_`var'
}
egen house_i = rowmean(`z_house_i')	

** Step 3: Standardizing index
stan house_i 

note z_house_i: "House Index"
note z_house_i: "Standardized"	
		

**************************************************************************************
************************************ MIGRATION *************************************** CHECK
**************************************************************************************

// NEW VARIABLES

destring migrator_count, replace

** Time away from household, dummy for remitances and bring cash
local trip_length_days
local away_long_days
local loc_work_time
local remit_cash

forvalues i=1/20 { // watch out for number of migrators!!
	cap confirm var away_long_`i'
	if _rc==0 {
		gen away_long_days_`i' = away_long_`i' if away_long_unit_`i'==1
		replace away_long_days_`i' = away_long_`i'*7 if away_long_unit_`i'==2
		replace away_long_days_`i' = away_long_`i'*30 if away_long_unit_`i'==3
		local away_long_days `away_long_days' away_long_days_`i'
	}
	if _rc!=0 {
		display in r "away_long_`i'"
	}

	cap confirm var trip_length_`i'
	if _rc==0 {
		gen trip_length_days_`i' = trip_length_`i' if trip_length_unit_`i'==1
		replace trip_length_days_`i' = trip_length_`i'*7 if trip_length_unit_`i'==2
		replace trip_length_days_`i' = trip_length_`i'*30 if trip_length_unit_`i'==3
		local trip_length_days `trip_length_days' trip_length_days_`i'
	}
	if _rc!=0 {
		display in r "trip_length_`i'"
	}
	
	cap confirm var loc_work_time_`i'
	if _rc==0 {
		gen loc_work_days_`i' = loc_work_time_`i' if loc_work_time_unit_`i'==1
		replace loc_work_days_`i' = loc_work_time_`i'*7 if loc_work_time_unit_`i'==2
		replace loc_work_days_`i' = loc_work_time_`i'*30 if loc_work_time_unit_`i'==3
		local loc_work_days `loc_work_days' loc_work_days_`i'
	}
	if _rc!=0 {
		display in r "loc_work_time_`i'"
	}
	
	cap confirm var remit_`i'
	if _rc==0 {
		gen remit_cash_`i' = 1 if remit_`i'==1 | bring_cash_`i'==1
		replace remit_cash_`i' =0 if remit_`i' == 0 & bring_cash_`i' == 0
		replace remit_cash_`i' =0 if remit_`i' == 0 & missing(bring_cash_`i') 
		replace remit_cash_`i' =0 if missing(remit_`i') & bring_cash_`i'==0
		replace remit_cash_`i' =.d if remit_`i'==.d & bring_cash_`i'==.d
		local remit_cash `remit_cash' remit_cash_`i'
	
	}
	
}


egen trip_length_days = rowtotal(`trip_length_days'), missing // for all members of the houehold
replace trip_length_days = 0 if migrator_count == 0 // this var only includes past trips, not current ones
egen away_long_days = rowtotal(`away_long_days'), missing 
replace away_long_days = 0 if migrator_count == 0 

egen days_away = rowtotal(trip_length_days away_long_days), missing
assert days_away==. if slept_out==.

egen loc_work_days = rowtotal(`loc_work_days'), missing
replace loc_work_days = 0 if migrator_count == 0 

egen migrators_remit_cash = rowtotal(`remit_cash'), missing // dont knows are treated as 0 when aggregating members of the household
replace migrators_remit_cash = 0 if migrator_count == 0 


local remit_d
local remit_amount
local bring_cash_d
local bring_cash_amount

forvalues i=1/20 { // watch out for number of migrators!!
	cap confirm var remit_`i'
	if _rc==0 {
		local remit_d `remit_d' remit_`i'
	}
	cap confirm var remit_amount_`i'
	if _rc==0 {
		local remit_amount `remit_amount' remit_amount_`i'
	}
	cap confirm var bring_cash_`i'
	if _rc==0 {
		local bring_cash_d `bring_cash_d' bring_cash_`i'
	}
	cap confirm var bring_cash_amount_`i'
	if _rc==0 {
		local bring_cash_amount `bring_cash_amount' bring_cash_amount_`i'
	}
}


** Remittances
egen remit_count = rowtotal(`remit_d'), missing
egen remit_amount = rowtotal(`remit_amount'), missing
gen remit_d = 1 if remit_count>=1 & remit_count!=. // to creat a dummy for whether at least 1 member of household sent remittances

replace remit_count = 0 if migrator_count == 0
replace remit_amount = 0 if migrator_count == 0
replace remit_d = 0 if remit_count == 0 

** Bring cash
egen bring_cash_count = rowtotal(`bring_cash_d'), missing
egen bring_cash_amount = rowtotal(`bring_cash_amount'), missing
gen bring_cash_d = 1 if bring_cash_count>=1 & bring_cash_count!=.

replace bring_cash_count = 0 if migrator_count == 0
replace bring_cash_amount =0 if migrator_count == 0
replace bring_cash_d = 0 if bring_cash_count == 0

** Remittances + cash
gen remit_cash_d = 1 if bring_cash_d == 1 | remit_d == 1
replace remit_cash_d = 0 if bring_cash_d == 0 & bring_cash_d == 0
egen remit_cash_amount = rowtotal (bring_cash_amount remit_amount), missing
assert missing(remit_cash_d) if missing(migrator_count)

// LABELS AND NOTES

label val remit_d dummy
label val bring_cash_d dummy
label val remit_cash_d dummy

note migrator_count: "Number of migrators in the household"
note migrator_count: "(slept outside for more than 2 nights for work)"
note loc_work_days: "Number of days someone was away from the household (last 6 months)"
note migrators_remit_cash: "Number of migrators that sent remitances or brought cash home (last 6 months)"
note remit_cash_d: "Households that recieved remittances or had someone bring cash home (binary - last 6 months)"
note remit_cash_amount: "Ammount recieved in remittances or cash brought home (last 6 months)"


gl migration_i  	migrator_count ///
					loc_work_days ///
					migrators_remit_cash ///
					remit_cash_d ///
					remit_cash_amount 
											
	
	
// INDEX

** Step 1: Standardizing components 
foreach var of varlist $migration_i  {
	stan `var'	
}

** Step 2: Agregating components 
local migration_i $migration_i
local z_migration_i
foreach var of local migration_i {
	local z_migration_i `z_migration_i' z_`var'
}
egen migration_i = rowmean(`z_migration_i')	

** Step 3: Standardizing index
stan migration_i 

note z_migration_i: "Migration and Remittance Activity Index"
note z_migration_i: "Standardized"

**************************************************************************************
*********************** DISCORD ABUSE AND DOMESTIC VIOLENCE **************************
**************************************************************************************
gl discord_i 				t1 ///
							t2 ///
							t3 ///
							t4 ///
							t5 ///
							t6


							
									
gl domestic_violence 		lr_abuse

// INDEX

** Step 0: reordering	
** Discord: higher outcomes more disciplined
foreach var of varlist t1 t2 t3 t4 t5 t6 {
	labrec `var' (1=0) (0=1)
}

** Step 1: Standardizing components 
foreach var of varlist $discord_i  {
	stan `var'	
}

** Step 2: Agregating components 
local discord_i $discord_i
local z_discord_i
foreach var of local discord_i {
	local z_discord_i `z_discord_i' z_`var'
}
egen discord_i = rowmean(`z_discord_i')	

** Step 3: Standardizing index
stan discord_i 

note z_discord_i: "Discord Index"
note z_discord_i: "Standardized"


**************************************************************************************
************************************** CHILDREN **************************************
**************************************************************************************

// NEW VARIABLES

local school
forvalues i=1/20 {
	local school `school' school_`i'
}

egen children_school = rowtotal(`school'), missing
egen num_children = rownonmiss (`school')
gen prop_school=children_school/num_children

notes children_school: "Number of children enrolled in school"

gl labor_supply_children	tothrs_agr_labor_ch /// 
							tothrs_livestock_ch /// 
							tothrs_formal_employ_ch ///
							tothrs_self_employ_ch ///
							tothrs_daily_labor_ch ///
							tothrs_uncl_employ_ch 

gl child_labor $labor_supply_children children_school // check if this var is balanced

stop
**************************************************************************************
***************************************** SAVING *************************************
**************************************************************************************
display "$treat"			

if $treat == 0 {
	save "ICM-6monthsurvey-outcomes(FT)-$date", replace
}

else if $treat == 1  {
	if $switched== 0 { // real treatment and dropping communities that switched. See beginning of do file
		if `baseline' == 0 {
			save "3-ICM-6monthsurvey-outcomes-$date", replace
		}
		else if `baseline' == 1 {
			save "3-ICM-6monthsurvey-outcomes_b-$date", replace
		}
		
	}
	else if $switched== 1 {
		save "3-ICM-6monthsurvey-outcomes(switched)-$date", replace
	}
}


stop
**************************************************************************************
*********************************** ADDITIONAL VARS **********************************
**************************************************************************************

** Support
dummys w4 // ---------------------------------- check labels!!!!!!
rename w4_1 w4_yes
rename w4_2 w4_applied
rename w4_3 w4_no

** Migration
local migrate_hadto
forvalues i=1/19 {
	gen migrate_reason_`i'_d=1 if migrate_reason_`i'==1
	local migrate_hadto `migrate_hadto' migrate_reason_`i'_d
}

egen migrate_hadto = rowtotal (`migrate_hadto') // we dont add ",missing" since we want empty spaces to be accounted as ceros
label var migrate_hadto "Number of members of the household that migrated for economic necessity"

** Checkups and vaccines
local checkup 
local vacc
forvalues i=1/20 {
	local checkup `checkup' checkup_`i'
	local vacc `vacc' vacc_`i'
}

egen checkup_tot = rowtotal(`checkup') // Total number of checkups for children in the household (4 and under)
replace checkup_tot=. if age4==0
*gen checkup_prop = checkup_tot/age4_d // Average number of check-ups in past six months for children in household of ages 4 and under 
*egen checkup_mem = rownonmiss(`checkup')
egen checkup_av = rowmean (`checkup') // ?????????????????????

egen vacc_tot = rowtotal(`vacc'), missing  // Number of children in household with up-to-date vaccinations (16 and under)
*gen vacc_prop = vacc_tot/age16_d // Proportion of children in household with up-to-date vaccinations (16 and under)
*egen vacc_mem = rownonmiss(`vacc')
egen vacc_prop = rowmean (`vacc')

label var checkup_tot "Total number of checkups for children in the household (4 and under)"
label var checkup_av "Average number of check-ups in past six months for children in household of ages 4 and under"
label var vacc_tot "Number of children in household with up-to-date vaccinations (16 and under)"
label var vacc_prop "Proportion of children in household with up-to-date vaccinations (16 and under)"


** Dummy washes hands
dummys v14
rename v14_1 v14_never
rename v14_2 v14_sometimes
rename v14_3 v14_allways

dummys v15
rename v15_1 v15_never
rename v15_2 v15_sometimes
rename v15_3 v15_allways
/*
gen v14_washes_d = .
replace v14_washes_d = 1 if v14 == 3
replace v14_washes_d = 0 if v14 == 2 | v14 == 1

gen v15_washes_d = .
replace v15_washes_d = 1 if v14 == 3
replace v15_washes_d = 0 if v14 == 2 | v14 == 1
*/

** Latrine owner
dummys lt6
rename lt6_1 lt6_public
rename lt6_2 lt6_neighbor
rename lt6_3 lt6_household_joint
rename lt6_4 lt6_household

/*
gen lt6_owner_d = .
replace lt6_owner_d = 1 if lt6 == 4 // only for households that are the only owner of the latrine
replace lt6_owner_d = 0 if lt6 == 1 | lt6 == 2 | lt6 == 3 
*/

** Animals sharing water source
replace v9=0 if v8!="5" & v8!="other"


** Religion
dummys k12

** Mobile money
gen mobile_money_d = 1 if (mm4_1!=5 & mm4_1!=.) | (mm4_2!=5 & mm4_2!=.)
replace mobile_money_d=0 if mm4_1==5
replace mobile_money_d=0 if mm1==0 // only respondents that were "aware" of mm were asked these quetsions
label define dummy 1 "Yes" 0 "No" 
label val mobile_money_d dummy
label var mobile_money_d "Households with mobile money"

** Dummy concrete
egen v3_sum=rowtotal(v3_1 v3_2 v3_3), missing
gen v3_concrete_d = .
replace v3_concrete_d=1 if v3_1==1 | v3_2==1  | v3_3==1
replace v3_concrete_d=0 if (v3_1!=1 & v3_1!=.) | (v3_2!=1 & v3_2!=.) | (v3_3!=1 & v3_3!=.)

label var v3_concrete_d "Households with concrete roofs"
label val v3_concrete_d dummy

** Dummy concrete/metal
gen v3_conc_metal_d = .
replace v3_conc_metal_d=1 if v3_1==1 | v3_2==1  | v3_3==1
replace v3_conc_metal_d=1 if v3_1==2 | v3_2==2  | v3_3==2
replace v3_conc_metal_d=0 if (v3_1!=1 & v3_1!=2 & v3_1!=.) | (v3_2!=1 & v3_2!=2 & v3_2!=.) | (v3_3!=1 & v3_3!=2 & v3_3!=.) // excludes metal + others

** Electricity 
encode v18, gen(v18_all)
label drop v18_all
label define light 1 "None" 2 "Kerosene" 3 "Kerosene & Electricity" 4 "Kerosene & Other" 5 "Electricity" 6 "Electricity & Other" 7 "Other"
label val v18_all light

dummys v18_all
rename v18_all_1 v18_d_none
rename v18_all_2 v18_d_kerosene
rename v18_all_3 v18_d_kerosene_electricity
rename v18_all_4 v18_d_kerosene_other
rename v18_all_5 v18_d_electricity
rename v18_all_6 v18_d_electricity_other
rename v18_all_7 v18_d_other


**
rename other_religion_activiti other_religion_act


local dropped 	religious_lit ///
				icm_jesus_christ ///
				other_religion_act ///
				k12_1 ///
				k12_2 ///
				k12_3 ///
				k12_4 ///
				k12_5 ///
				k12_6 ///
				k12_7 ///
				outside_repeats /// number of members in the household that worked outside in the last 7 days
				z1 /// dummy for households with income gen activity, apart from work
				sales /// generated in the income section
				spending /// generated in the income section
				migrate_hadto /// ( from "migrate_reason_*")
				w4_yes /// dummys from w4
				w4_applied ///
				w4_no ///
				control_ses ///
				future_plan ///
				vacc_tot /// cretaed from vacc_* num vs prop (checup_av)
				checkup_tot /// created checkup_num vs prop (vacc_prop)
				hs2 /// medical assistance
				number_accidents /// only accidents 
				days_incap_a /// only accidents
				v13 /// soap
				v14_allways ///
				v14_sometimes ///
				v14_never ///
				v15_allways ///
				v15_sometimes ///
				v15_never ///
				v161 ///
				lt6_public ///
				lt6_neighbor ///
				lt6_household_joint ///
				lt6_household ///
				lt4_open_def_d_1 /// Men
				lt4_open_def_d_2 /// Woman
				lt4_open_def_d_3 /// Children
				mobile_money_d /// from mm4
				v3_concrete_d /// from v3
				u1 /// ----------------------------- CHECK IF GENDER APPLIES
				u2 ///
				u3 ///
				u4 ///
				u5 ///
				u6 

				*v18

** Other vars

split v17
replace v171=".o" if v171=="other"
replace v172=".o" if v172=="other"
replace v173=".o" if v173=="other"
destring v171 v172 v173, replace

gen v17_no = 0
gen v17_coal = 0
gen v17_firewood = 0
gen v17_LPG = 0
gen v17_gobar = 0
gen v17_dung = 0
gen v17_charcoal = 0
gen v17_kerosene = 0
gen v17_electricity = 0
gen v17_cake = 0
gen v17_NTFP = 0

replace v17_no = 1 if v171==0 | v172==0 | v173==0
replace v17_coal = 1 if v171==1 | v172==1 | v173==1
replace v17_firewood = 1 if v171==2 | v172==2 | v173==2
replace v17_LPG = 1 if v171==3 | v172==3 | v173==3
replace v17_gobar = 1 if v171==4 | v172==4 | v173==4
replace v17_dung = 1 if v171==5 | v172==5 | v173==5
replace v17_charcoal = 1 if v171==6 | v172==6 | v173==6
replace v17_kerosene = 1 if v171==7 | v172==7 | v173==7
replace v17_electricity = 1 if v171==8 | v172==8 | v173==8
replace v17_cake = 1 if v171==9 | v172==9 | v173==9
replace v17_NTFP = 1 if v171==10 | v172==10 | v173==10

label var v17_no "Cooking arrangement - No cooking arrangement"
label var v17_coal "Cooking arrangement - Coke, coal"
label var v17_LPG "Cooking arrangement - LPG"
label var v17_gobar "Cooking arrangement - Gobar gas"
label var v17_dung "Cooking arrangement - Dung cake"
label var v17_charcoal "Cooking arrangement - Charcoal"
label var v17_kerosene "Cooking arrangement - Kerosene"
label var v17_electricity "Cooking arrangement - Electricity"
label var v17_cake "Cooking arrangement - Cake made of coal dust"
label var v17_NTFP "Cooking arrangement - NTFP"

replace v22 = 0 if v19 == 0


local others 	v17_no  /// from v17
				v17_coal ///
				v17_firewood ///
				v17_LPG ///
				v17_gobar ///
				v17_dung ///
				v17_charcoal ///
				v17_kerosene ///
				v17_electricity ///
				v17_cake ///
				v17_NTFP ///
				v19 /// v20-type of repair
				v21 /// money spent in repair
				v22 ///
				k131 ///
				k132 ///
				k141 ///
				k142 ///
				k143 ///
				k144 ///
				k145 ///
				k146 ///
				k147 ///
				k148 ///
				k149 ///
				k151 ///
				k152 ///
				k153 ///
				k161 ///
				k162 ///
				k163 ///
				k164 ///
				k165 ///
				k166 ///
				k167 ///
				k168 ///
				k169 ///
				feel_unable_day ///
				feel_partial_day ///
				feel_doc_day ///
				source_worry ///
				s1 ///
				s2 ///
				s3 ///
				s4 

gl more `dropped' `others' 




**************************************************************************************
*********************************** LABELS AND NOTES *********************************
**************************************************************************************


*****
**work*







	
/*
New room
New roofing
Painting
Latrine
Plumbing
Repair of damage to existing structure
Wiring
Flooring
Wall improvement
Repairing of animal shed
Building new shed for animals
*/

				
*****************
/*
** Rooms
gen adult_equivalent = .
forvalues n=1/`N' {                      // The following loop the number of adults equvalent ( 1 for people 14 and older and 0.5 for younger)
	local adult_eq = 0
	forvalues i=1/20 {
		if (age_`i'>=14 & age_`i'!=.) in `n' {
			local ++adult_eq
		}	
		if (age_`i'<14 & age_`i'!=.) in `n' {
			local adult_eq = `adult_eq' + .5
		}	
	}
	replace adult_equivalent=`adult_eq' in `n'
}


gen v1_prop = v1/nummembers
gen v1_prop_adeq = v1/adult_equivalent
*/
