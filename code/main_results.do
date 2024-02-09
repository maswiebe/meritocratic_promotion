clear
use "$data/promotion_national.dta"

lab var age "Age"
lab var age2 "Age squared"
lab var tenure "Tenure"
lab var educ "Education"
lab var sex "Sex"
lab var avg_relgrowth "GDP growth"
lab var avg_relgrowth_ceic "GDP growth"
lab var initlgdp "Initial GDP"
lab var initlpop "Initial Population"
lab var home_pref "Home prefecture"
lab var patron_connection "Connection"

*-------------------------------------------------------------------------------
*** lpm

eststo clear
qui reghdfe promotion2 avg_relgrowth, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 avg_relgrowth age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 avg_relgrowth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

*** logit
qui clogit promotion2 avg_relgrowth , group(fe_provyear) vce(cl fe_provyear)
eststo m4
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui clogit promotion2 avg_relgrowth age age2 sex i.edu_code i.tenure home_pref patron_connection, group(fe_provyear) vce(cl fe_provyear)
eststo m5
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui clogit promotion2 avg_relgrowth initlgdp initlpop age age2 sex i.edu_code i.tenure i.preftype home_pref patron_connection, group(fe_provyear) vce(cl fe_provyear)
* edu_code, tenure: show FE categories, or keep as continuous
eststo m6
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

*** ordered logit
qui ologit opromotion avg_relgrowth i.fe_provyear, vce(cl fe_provyear)
eststo m7
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui ologit opromotion avg_relgrowth  age age2 sex i.edu_code i.tenure home_pref i.fe_provyear patron_connection, vce(cl fe_provyear)
eststo m8
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui ologit opromotion avg_relgrowth initlgdp initlpop age age2 sex i.edu_code i.tenure i.preftype home_pref i.fe_provyear patron_connection, vce(cl fe_provyear)
eststo m9
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

* giant table
esttab m*, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") keep(avg_relgrowth initlgdp initlpop age age2 sex home_pref patron_connection) eqlabels(none) b(%9.3f)
esttab m* using "$tables/main_bigtable.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") keep(avg_relgrowth initlgdp initlpop age age2 sex home_pref patron_connection) eqlabels(none) b(%9.3f) mgroups("LPM" "Logit" "Ordered logit", pattern(1 0 0 1 0 0 1 0 0))

*-------------------------------------------------------------------------------
*** alternate clustering

* lpm, cluster at provcode
eststo clear
qui reghdfe promotion2 avg_relgrowth, ab(provcode#year) vce(cl provcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 avg_relgrowth age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl provcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 avg_relgrowth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl provcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
esttab m1 m2 m3 using "$tables/lpm_cl_prov.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)

* lpm, cluster at provcode#year
eststo clear
qui reghdfe promotion2 avg_relgrowth, ab(provcode#year) vce(cl provcode#year) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 avg_relgrowth age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl provcode#year) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 avg_relgrowth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl provcode#year) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
esttab m1 m2 m3 using "$tables/lpm_cl_provyear.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)

*-------------------------------------------------------------------------------
*** lpm results for tenure, education
label define edu_lab 1 "High school" 2 "College" 3 "Master's" 4 "Ph.D."
label values edu_code edu_lab

eststo clear
qui reghdfe promotion2 avg_relgrowth, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 avg_relgrowth tenure i.edu_code age age2 sex home_pref patron_connection, ab(provcode#year) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 avg_relgrowth tenure i.edu_code initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f) noomitted
esttab m1 m2 m3 using "$tables/main_lpm_tenure_edu.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f) noomitted