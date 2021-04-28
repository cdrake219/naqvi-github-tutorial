/// SETUP ///

* Start

clear *
cap cd "C:\Users\Coleman\OneDrive - University of Pittsburgh\Documents\GitHub\naqvi-github-tutorial"

* Install Packages

*net d tsg_schemes, from("https://raw.githubusercontent.com/asjadnaqvi/Stata-schemes/main/schemes/")
*net install tsg_schemes, from("https://raw.githubusercontent.com/asjadnaqvi/Stata-schemes/main/schemes/") replace

* Settings

set scheme black_w3d
graph set window fontface "Arial Narrow"

/// PULL DATA ///

* COVID Data

insheet using "https://covid.ourworldindata.org/data/owid-covid-data.csv", clear
gen date2 = date(date, "YMD")
format date2 %tdDD-Mon-yy
drop date
ren date2 date
ren location country
replace country = "Slovak Republic" if country == "Slovakia"
replace country = "Czech Republic"  if country == "Czechia"
replace country = "Kyrgyz Republic" if country == "Kyrgyzstan"
replace country = "Macedonia"   if country == "North Macedonia"
drop if date < 21915
save "./data/OWID_data.dta", replace

* Country Classifications
  
copy "https://github.com/asjadnaqvi/COVID19-Stata-Tutorials/blob/master/master/country_codes.dta?raw=true" "./data/country_codes.dta", replace

/// CLEANING ///

use "./data/OWID_data.dta", clear
merge m:1 country using "./data/country_codes.dta"
drop if _m!=3
keep country date new_cases new_deaths group*
summ date
drop if date>=r(max) - 2
gen region = .
replace region = 1 if group29==1 & country=="United States" // North America
replace region = 2 if group29==1 & country!="United States" // North America
replace region = 3 if group20==1 & country=="Brazil" // Latin America and Carribean
replace region = 4 if group20==1 & country!="Brazil" // Latin America and Carribean
replace region = 5 if group10==1 & country=="Germany" // Germany
replace region = 6 if group10==1 & country!="Germany" // Rest of EU
replace region = 7 if  group8==1 & group10!=1 & country=="United Kingdom" // Rest of Europe and Central Asia
replace region = 8 if  group8==1 & group10!=1 & country!="United Kingdom" // Rest of Europe and Central Asia
replace region = 9 if group26==1 // MENA
replace region = 10 if group37==1 // Sub-saharan Africa
replace region = 11 if group35==1 & country=="India" // South Asia
replace region = 12 if group35==1 & country!="India" // South Asia
replace region = 13 if  group6==1 // East Asia and Pacific
lab de region  1 "United States" 2 "Rest of North America" 3 "Brazil" 4 "Rest of Latin America" 5 "Germany" 6 "Rest of European Union" 7 "United Kingdom" 8 "Rest of Europe" 9 "MENA" 10 "Sub-Saharan Africa" 11 "India" 12 "Rest of South Asia" 13 "East Asia and Pacific"
lab val region region

collapse (sum) new_cases new_deaths, by(date region)

xtset region date
tssmooth ma new_cases_ma7  = new_cases , w(6 1 0) 
tssmooth ma new_deaths_ma7  = new_deaths , w(6 1 0) 
 
format date %tdDD-Mon-YY
format new_cases %9.0fc

/// GRAPHS ///

set scheme black_w3d
graph set window fontface "Arial Narrow"

xtline new_deaths_ma7, overlay xtitle("") ytitle("New deaths (7 day M-A)") 
graph export "./figures/region_deaths.png", replace wid(1000)

xtline new_cases_ma7, overlay xtitle("") ytitle("New cases (7 day M-A)") 
graph export "./figures/region_cases.png", replace wid(1000)

twoway (scatter new_deaths_ma7 new_cases_ma7, mc(%10) ms(vsmall)), xtitle("New deaths (7 day M-A)") ytitle("New cases (7 day M-A)") 
graph export "./figures/scatter_cases_deaths.png", replace wid(1000)

twoway (scatter new_cases_ma7 new_deaths_ma7, mc(red%10) ms(vsmall)), xtitle("New cases (7 day M-A)") ytitle("New deaths (7 day M-A)") 
graph export "./figures/scatter_deaths_cases.png", replace wid(1000)

/// GITHUB SYNC ///

* Initialize

! echo # naqvi-github-tutorial  >> README.md // create read.md
! git init // intialize Git code (create hidden .git directory)

* Commmit

! git add README.md
! git commit -m 'my first upload'
! git remote add origin https://github.com/cdrake219/naqvi-github-tutorial.git
! git push -u origin main
