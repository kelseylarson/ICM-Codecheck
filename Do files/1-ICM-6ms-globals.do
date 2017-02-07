**************************************************************************************
******************************* ICM 6th month survey *********************************
**************************************************************************************

*                                    1. GLOBALS

/* 	This do file defines the globals used in the rest of the programs. 
	These are mainly used for defining paths, dates, grouping variables, etc

*/
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                    DEFINE GLOBALS
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


// PATHS

gl user = "\ifalomir" // ------------------------------- for Isabel Onate (change for sifferent users)

gl home = "C:\Users\$user\Dropbox\ICM Project Management - Internal\16. Data\6th Month Survey"
gl raw = "X:\Dropbox\ICM Project Management - Internal\16. Data\6th Month Survey\Raw"
gl data = "C:\Users\$user\Dropbox\ICM Project Management - Internal\16. Data\6th Month Survey\Data"
gl do_files = "C:\Users\$user\Dropbox\ICM Project Management - Internal\16. Data\6th Month Survey\Do files"
gl others = "C:\Users\$user\Dropbox\ICM Project Management - Internal\16. Data\6th Month Survey\Others"
gl results = "C:\Users\$user\Dropbox\ICM Project Management - Internal\16. Data\6th Month Survey\Results"
gl baseline_raw = "X:\Dropbox\ICM Project Management - Internal\16. Data\ICM Baseline\Raw"

*gl raw = "C:\Users\$user\Dropbox\ICM Project Management - Internal\16. Data\6th Month Survey\Raw" // Dropbox
*gl raw = "X:\Box.net\ICM Character Development\12_Data\5_6thMonth_Data(IO)\Stata" //



// DATE OF RAW DATA

*gl date 20160121 // First download from survey CTO - 6477 obs
*gl date 20160317 // Second download from surveyCTO - 6621 obs
*gl date 20160415 // Incluide people with same name and community
gl date 20160429 // Include duplicates



// OTHER FILES USED

gl labor_recode = "Others-activities-20160915.xlsx" // latest version of excel file with new calssigications for labor supply. Sept 15 2016





