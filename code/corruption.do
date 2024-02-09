*** Corruption crackdown

clear
use "$data/promotion_national.dta"

tab arrested_in
* 36 actual arrests
lab var avg_relgrowth "Growth rate"
lab var avg_relgrowth_ceic "Growth rate"
lab var arrested_inoffice "Arrest"
lab var avgXpost "Growth $\times$ Post"

eststo clear
qui reghdfe promotion2 avg_relgrowth initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local cov "Yes"
eststo m1
qui reghdfe promotion2 avg_relgrowth arrested_inoffice initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local cov "Yes"
eststo m2

* interact with post
qui reghdfe promotion2 avg_relgrowth avgXpost initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local cov "Yes"
eststo m3
qui reghdfe promotion2 avg_relgrowth avgXpost arrested_inoffice initlgdp initlpop age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local cov "Yes"
eststo m4

esttab m*, nomtitle label replace se star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov Covariates") ar2 order(avg_relgrowth arrested_inoffice avgXpost) keep(avg_relgrowth arrested_inoffice avgXpost) b(%9.3f)
esttab m* using "$tables/corruption_small.tex", nomtitle label replace se star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov Covariates") ar2 order(avg_relgrowth arrested_inoffice avgXpost) keep(avg_relgrowth arrested_inoffice avgXpost) b(%9.3f)