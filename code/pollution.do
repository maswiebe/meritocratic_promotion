clear
use "$data/promotion_national.dta"

*** pollution results

merge 1:1 prefcode year using "$data/pm25.dta"
drop if _merge==2
drop _merge

merge 1:1 prefcode year using "$data/so2_ceic.dta"
drop if _merge==2
drop _merge

* war on pollution 2014
gen post14 = (year>2013)
gen pm25Xpost14 = pm25_growth*post14

* big outliers
winsor2 so2_growth, cuts(1,99) replace

gen so2Xpost14 = so2_growth*post14

egen med_so2growth = median(so2_growth),by(provcode year)
egen med_pm25growth = median(pm25_growth),by(provcode year)
egen med_lso2 = median(lso2),by(provcode year)
egen med_lpm25 = median(lpm25),by(provcode year)
gen abovemed_so2growth = (so2_growth>med_so2growth) if missing(so2_growth)==0
gen abovemed_pm25growth = (pm25_growth>med_pm25growth) if missing(pm25_growth)==0
gen abovemed_lso2 = (lso2>med_lso2) if missing(lso2)==0
gen abovemed_lpm25 = (lpm25>med_lpm25) if missing(lpm25)==0

lab var pm25_growth "PM2.5 growth rate"
lab var pm25Xpost14 "PM2.5 growth $\times$ Post"
lab var so2_growth "SO2 growth rate"
lab var so2Xpost14 "SO2 growth $\times$ Post"
lab var avg_relgrowth "Growth rate"
lab var age "Age"
lab var age2 "Age squared"
lab var lgdp "Log GDP"
lab var lpop "Log population"
lab var sex "Gender"
lab var arrested_inoffice "Arrested"
lab var home_pref "Home prefecture"

lab var abovemed_so2growth "SO2 growth $>$ median"
lab var abovemed_pm25growth "PM2.5 growth $>$ median"
lab var abovemed_lso2 "Log SO2 $>$ median"
lab var abovemed_lpm25 "Log PM2.5 $>$ median"

gen growthXabovemed_so2growth = avg_relgrowth*abovemed_so2growth
gen growthXabovemed_pm25growth = avg_relgrowth*abovemed_pm25growth
gen growthXabovemed_lso2 = avg_relgrowth*abovemed_lso2
gen growthXabovemed_lpm25 = avg_relgrowth*abovemed_lpm25
lab var growthXabovemed_so2growth "Growth $\times$ SO2 growth $>$ median"
lab var growthXabovemed_pm25growth "Growth $\times$ PM2.5 growth $>$ median"
lab var growthXabovemed_lso2 "Growth $\times$ Log SO2 $>$ median"
lab var growthXabovemed_lpm25 "Growth $\times$ Log PM2.5 $>$ median"


* so2
eststo clear
qui reghdfe promotion2 avg_relgrowth abovemed_so2growth initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
eststo m1
qui reghdfe promotion2 avg_relgrowth abovemed_so2growth growthXabovemed_so2growth initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
eststo m2
qui reghdfe promotion2 avg_relgrowth abovemed_lso2 initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
eststo m3
qui reghdfe promotion2 avg_relgrowth abovemed_lso2 growthXabovemed_lso2 initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
eststo m4
esttab m*, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE") order(avg_relgrowth abovemed_so2growth growthXabovemed_so2growth abovemed_lso2 growthXabovemed_lso2) keep(avg_relgrowth abovemed_so2growth growthXabovemed_so2growth abovemed_lso2 growthXabovemed_lso2)
esttab m* using "$tables/so2_interaction.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE") order(avg_relgrowth abovemed_so2growth growthXabovemed_so2growth abovemed_lso2 growthXabovemed_lso2) keep(avg_relgrowth abovemed_so2growth growthXabovemed_so2growth abovemed_lso2 growthXabovemed_lso2) b(%9.3f)

* pm25
eststo clear
qui reghdfe promotion2 avg_relgrowth abovemed_pm25growth initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
eststo m1
qui reghdfe promotion2 avg_relgrowth abovemed_pm25growth growthXabovemed_pm25growth initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
eststo m2
qui reghdfe promotion2 avg_relgrowth abovemed_lpm25 initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
eststo m3
qui reghdfe promotion2 avg_relgrowth abovemed_lpm25 growthXabovemed_lpm25 initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
eststo m4
esttab m*, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE") order(avg_relgrowth abovemed_pm25growth growthXabovemed_pm25growth abovemed_lpm25 growthXabovemed_lpm25) keep(avg_relgrowth abovemed_pm25growth growthXabovemed_pm25growth abovemed_lpm25 growthXabovemed_lpm25) b(%9.3f)
esttab m* using "$tables/pm25_interaction.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE") order(avg_relgrowth abovemed_pm25growth growthXabovemed_pm25growth abovemed_lpm25 growthXabovemed_lpm25) keep(avg_relgrowth abovemed_pm25growth growthXabovemed_pm25growth abovemed_lpm25 growthXabovemed_lpm25) b(%9.3f)
