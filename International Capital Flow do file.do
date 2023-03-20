
************************************************************************************
*************************** Re-do the Feldstein-Horioka paper **********************
******************** Quantitative Global Economics Class (Spring 2022) *************
*************************************  Feb 2023  ***********************************
************************** Single author: Xiaoqiao Shen ****************************

****** Purpose and methodologies: 
******(1)look at the relationship between investment and savings across countries using country fixed effect to examine the international capital flow. 
******(2)conduct subsample analysis by dividng the periods periods and sample countries into 3 periods and 3 groups. 
******(3)conduct heterogeneity analysis between English speaking countries and non-English speaking countries. 


*****
clear
cd "/Users/annashen/Desktop/Stata Practice/FH re-run"

******** clean the WEO dataset, reshape to long data*********
import delimited "WEOOct2022all.csv"

keep iso country subjectdescriptor v*
rename v* yr(####), renumber(1980)
rename subjectdescriptor item
keep if item == "Total investment" | item == "Gross national savings"

foreach v of varlist yr*{
	replace `v' = "" if `v'== "n/a"
}

reshape long yr, i(country item) j(year)
rename yr value
destring value, replace

gen subject = 1 if item == "Total investment"
replace subject = 0 if item == "Gross national savings"
label define subject 0 "savings" 1 "investment"
label value subject subject 
drop item
move subject year

reshape wide value, i(country year) j(subject)

rename value0 savings
rename value1 investment

save "allcountrymaster.dta", replace

******** creat language dataset *******
clear
use allcountrymaster.dta
keep if year==1980
drop year iso savings investment
gen language = 0 
replace language = 1 if inlist(country, "Barbados", "Belize", "Belgium", "Botswana")
replace language = 1 if inlist(country, "Cameroon", "Canada", "Dominica", "Fiji", "Gambia", "Ghana")
replace language = 1 if inlist(country, "Hong Kong", "India", "Ireland", "Jersey", "Kenya", "Liberia", "Malawi")
replace language = 1 if inlist(country, "Malta", "Marshall Islands", "Micronesia", "Namibia", "New Zealand")
replace language = 1 if inlist(country, "Nigeria", "Pakistan", "Palau", "Papua New Guinea", "Philippines", "Rwanda")
replace language = 1 if inlist(country, "Somoa", "Seychelles", "Sierra Leone", "Singapore", "Solomon Island", "Somalia")
replace language = 1 if inlist(country, "Sount Africa", "South Sudan", "Sudan", "Tonga", "Trinidad and Tobago")
replace language = 1 if inlist(country, "Uganda", "Zambia", "Zimbabwe")
save "language.dta", replace

******** merge language and WEO **********
clear
use allcountrymaster.dta
merge m:1 country using language.dta
keep if _merge == 3
drop _merge
save allcountries.dta, replace

****** sub sample analysis ***********
**FH origin countries: 
clear
use allcountries.dta

keep if inlist(country, "Australia", "Austria", "Belgium", "Canada") | inlist(country, "Denmark", "Finland", "France", "Germany") |inlist(country, "Greece", "Ireland", "Italy", "Japan", "Luxembourg") | inlist(country, "Netherlands", "New Zealand", "Norway", "Spain") | inlist(country, "Sweden", "Switzerland", "United Kingdom", "United States")

eststo clear

preserve
	keep if year>=1980 & year<=1989
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings i.year, fe
	eststo FH1980
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef2-coef12
	drop country year savings investment iso language countrycode _est_FH1980
	keep if _n==1
	save coefFH1.dta, replace
restore

preserve
	keep if year>=1990 & year<=1999
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings i.year, fe
	eststo FH1990	
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef2-coef12
	drop country year savings investment iso language countrycode _est_FH1990
	keep if _n==1
	save coefFH2.dta, replace
restore

preserve
	keep if year>=2000 & year<=2020
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings i.year, fe
	eststo FH2000
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef2-coef23
	drop country year savings investment iso language countrycode _est_FH2000
	keep if _n==1
	save coefFH3.dta, replace
restore

esttab FH1980 FH1990 FH2000 using "coef table.rtf", replace drop(*.year _cons) noobs mtitle(1980s 1990s 2000s) varlabels(savings FH)
esttab FH1980 FH1990 FH2000 using "coef table.xls", replace drop(*.year _cons) noobs mtitle(1980s 1990s 2000s) varlabels(savings FH) 

use coefFH1.dta, clear
append using coefFH2.dta coefFH3.dta
rename coef1 FH
gen year="1980s"
replace year="1990s" if _n==2
replace year="2000s" if _n==3
move year FH
save FHcoef.dta, replace


**OECD origin countries: 

clear
use allcountries.dta

keep if inlist(country, "Australia", "Austria", "Belgium", "Canada") | inlist(country, "Denmark", "Finland", "France", "Germany") | inlist(country, "Greece", "Ireland", "Italy", "Japan", "Luxembourg") | inlist(country, "Netherlands", "New Zealand", "Norway", "Portugal", "Spain") | inlist(country, "Sweden", "Switzerland", "United Kingdom", "United States")

preserve
	keep if year>=1980 & year<=1989
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings i.year, fe
	eststo OECD1980
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef2-coef12
	drop country year savings investment iso language countrycode _est_OECD1980
	keep if _n==1
	save coefOECD1.dta, replace
restore

preserve
	keep if year>=1990 & year<=1999
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings i.year, fe
	eststo OECD1990
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef2-coef12
	drop country year savings investment iso language countrycode _est_OECD1990
	keep if _n==1
	save coefOECD2.dta, replace
restore

preserve
	keep if year>=2000 & year<=2020
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings i.year, fe
	eststo OECD2000
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef2-coef23
	drop country year savings investment iso language countrycode _est_OECD2000
	keep if _n==1
	save coefOECD3.dta, replace
restore

esttab OECD1980 OECD1990 OECD2000 using "coef table.rtf", append drop(*.year _cons) noobs mtitle(1980s 1990s 2000s) varlabels(savings OECD)
esttab OECD1980 OECD1990 OECD2000 using "coef table.xls", append drop(*.year _cons) noobs mtitle(1980s 1990s 2000s) varlabels(savings OECD)

use coefOECD1.dta, clear
append using coefOECD2.dta coefOECD3.dta
rename coef1 OECD
save OECDcoef.dta, replace

use OECDcoef.dta, clear
gen year="1980s"
replace year="1990s" if _n==2
replace year="2000s" if _n==3
move year OECD
save OECDcoef.dta, replace


**all countries: 
clear
use allcountries.dta

preserve
	keep if year>=1980 & year<=1989
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings i.year, fe
	eststo all1980
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef2-coef12
	drop country year savings investment iso language countrycode _est_all1980
	keep if _n==1
	save coefall1.dta, replace
restore

preserve
	keep if year>=1990 & year<=1999
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings i.year, fe
	eststo all1990
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef2-coef12
	drop country year savings investment iso language countrycode _est_all1990
	keep if _n==1
	save coefall2.dta, replace
restore

preserve
	keep if year>=2000 & year<=2020
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings i.year, fe
	eststo all2000
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef2-coef23
	drop country year savings investment iso language countrycode _est_all2000
	keep if _n==1
	save coefall3.dta, replace
restore

esttab all1980 all1990 all2000 using "coef table.rtf", append drop(*.year _cons) noobs mtitle(1980s 1990s 2000s) varlabels(savings all)
esttab all1980 all1990 all2000 using "coef table.xls", append drop(*.year _cons) noobs mtitle(1980s 1990s 2000s) varlabels(savings all)


use coefall1.dta, clear
append using coefall2.dta coefall3.dta
rename coef1 allcountries
gen year="1980s"
replace year="1990s" if _n==2
replace year="2000s" if _n==3
move year allcountries
save Allcoef.dta, replace

***************** Get the coef into one dataset and make graph***********
use FHcoef.dta, clear
merge 1:1 year using OECDcoef.dta
drop _merge
merge 1:1 year using ALLcoef.dta
drop _merge
save coef.dta, replace

destring year, replace
gen year1=substr(year, 1,4)
drop year
rename year1 year
destring year, replace
move year FH

twoway line FH OECD allcountries year, sort xlabel(1980 "1980s" 1990 "1990s" 2000 "2000s", grid) ylabel(0(0.1)0.6) ytitle("Fixed Effecit Coef") xtitle("Time") title("Change of FH coefficients overtime across subsamples", size(s) margin(b+2.5)) legend(cols(3) order(1 "FH origin" 2 "FH+newOECD" 3 "All Countries")) graphregion(c(white) m(l+5 b+5 r+8 t+5)) lcolor(cranberry ebblue black)

graph save "Graph 1.gph", replace

*******  Heterogeneity on English-speaking and Non-speaking countries ******
**FH origin countries: 
clear
use allcountries.dta

keep if inlist(country, "Australia", "Austria", "Belgium", "Canada") | inlist(country, "Denmark", "Finland", "France", "Germany") |inlist(country, "Greece", "Ireland", "Italy", "Japan", "Luxembourg") | inlist(country, "Netherlands", "New Zealand", "Norway", "Spain") | inlist(country, "Sweden", "Switzerland", "United Kingdom", "United States")

gen interaction=savings*language

eststo clear

preserve
	keep if year>=1980 & year<=1989
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings interaction i.year, fe
	eststo FH1980english
	ereturn list
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef3-coef13
	drop country year savings investment iso language interaction countrycode _est_FH1980
	keep if _n==1
	save coefFH1english.dta, replace
restore

preserve
	keep if year>=1990 & year<=1999
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings interaction i.year, fe
	eststo FH1990english	
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef3-coef13
	drop country year savings investment iso interaction language countrycode _est_FH1990
	keep if _n==1
	save coefFH2english.dta, replace
restore

preserve
	keep if year>=2000 & year<=2020
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings interaction i.year, fe
	eststo FH2000english
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef3-coef24
	drop country year savings investment interaction iso language countrycode _est_FH2000
	keep if _n==1
	save coefFH3english.dta, replace
restore

esttab FH1980english FH1990english FH2000english using "coef table 2.rtf", replace drop(*.year _cons) noobs mtitle(1980s 1990s 2000s) varlabels(savings FHnonEnglish) 

use coefFH1english.dta, clear
append using coefFH2english.dta coefFH3english.dta
rename coef1 FHnonEnglish
rename coef2 interaction
gen FHEnglish=FHnonEnglish+interaction
drop interaction
gen year="1980s"
replace year="1990s" if _n==2
replace year="2000s" if _n==3
move year FHnonEnglish 
save FHcoefenglish.dta, replace 

**OECD countries: 
clear
use allcountries.dta

keep if inlist(country, "Australia", "Austria", "Belgium", "Canada") | inlist(country, "Denmark", "Finland", "France", "Germany") | inlist(country, "Greece", "Ireland", "Italy", "Japan", "Luxembourg") | inlist(country, "Netherlands", "New Zealand", "Norway", "Portugal", "Spain") | inlist(country, "Sweden", "Switzerland", "United Kingdom", "United States")

gen interaction=savings*language

eststo clear

preserve
	keep if year>=1980 & year<=1989
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings interaction i.year, fe
	eststo OECD1980english
	ereturn list
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef3-coef13
	drop country year savings investment iso language interaction countrycode _est_OECD1980
	keep if _n==1
	save coefOECD1english.dta, replace
restore

preserve
	keep if year>=1990 & year<=1999
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings interaction i.year, fe
	eststo OECD1990english	
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef3-coef13
	drop country year savings investment iso interaction language countrycode _est_OECD1990
	keep if _n==1
	save coefOECD2english.dta, replace
restore

preserve
	keep if year>=2000 & year<=2020
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings interaction i.year, fe
	eststo OECD2000english
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef3-coef24
	drop country year savings investment interaction iso language countrycode _est_OECD2000
	keep if _n==1
	save coefOECD3english.dta, replace
restore

esttab OECD1980english OECD1990english OECD2000english using "coef table 2.rtf", append drop(*.year _cons) noobs mtitle(1980s 1990s 2000s) varlabels(savings OECDnonEnglish) 

use coefOECD1english.dta, clear
append using coefOECD2english.dta coefOECD3english.dta
rename coef1 OECDnonEnglish
rename coef2 interaction
gen OECDEnglish=OECDnonEnglish+interaction
drop interaction
gen year="1980s"
replace year="1990s" if _n==2
replace year="2000s" if _n==3
move year OECDnonEnglish 
save OECDcoefenglish.dta, replace 

**all countries: 
clear
use allcountries.dta
gen interaction=savings*language

eststo clear

preserve
	keep if year>=1980 & year<=1989
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings interaction i.year, fe
	eststo all1980english
	ereturn list
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef3-coef13
	drop country year savings investment iso language interaction countrycode _est_all1980
	keep if _n==1
	save coefall1english.dta, replace
restore

preserve
	keep if year>=1990 & year<=1999
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings interaction i.year, fe
	eststo all1990english	
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef3-coef13
	drop country year savings investment iso interaction language countrycode _est_all1990
	keep if _n==1
	save coefall2english.dta, replace
restore

preserve
	keep if year>=2000 & year<=2020
	encode country, gen(countrycode)
	xtset countrycode year
	xtreg investment savings interaction i.year, fe
	eststo all2000english
	mat coef=get(_b)
	mat list coef
	svmat coef
	drop coef3-coef24
	drop country year savings investment interaction iso language countrycode _est_all2000
	keep if _n==1
	save coefall3english.dta, replace
restore

esttab all1980english all1990english all2000english using "coef table 2.rtf", append drop(*.year _cons) noobs mtitle(1980s 1990s 2000s) varlabels(savings ALLnonEnglish) 

use coefall1english.dta, clear
append using coefall2english.dta coefall3english.dta
rename coef1 ALLnonEnglish
rename coef2 interaction
gen ALLEnglish=ALLnonEnglish+interaction
drop interaction
gen year="1980s"
replace year="1990s" if _n==2
replace year="2000s" if _n==3
move year ALLnonEnglish 
save ALLcoefenglish.dta, replace 

***************** Get the coef into one dataset ***********
use FHcoefenglish.dta, clear
merge 1:1 year using OECDcoefenglish.dta
drop _merge
merge 1:1 year using ALLcoefenglish.dta
drop _merge
save coefenglish.dta, replace

gen year1=substr(year, 1,4)
drop year
rename year1 year
destring year, replace
move year FHnonEnglish
save coefenglish.dta, replace

twoway line FHnonEnglish FHEnglish OECDnonEnglish OECDEnglish ALLnonEnglish ALLEnglish year, sort ///
xlabel(1980 "1980s" 1990 "1990s" 2000 "2000s", grid) ylabel(0(0.2)1) ytitle("Fixed Effecit Coef") ///
xtitle("Time") title("Change of FH coefficients overtime across subsamples", size(s) margin(b+2.5)) ///
graphregion(c(white) m(l+5 b+5 r+8 t+5)) ///
lpattern(solid dash solid dash solid dash) ///
lcolor(cranberry cranberry ebblue ebblue black black)

graph save "Graph 2.gph", replace


