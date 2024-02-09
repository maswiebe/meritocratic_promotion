clear
use "$data/promotion_national.dta"

*** connections

*----------------------------------------
* summary stats

lab var prov_conn_pref "Hometown (prefecture)"
lab var prov_conn_prov "Hometown (province)"
lab var prov_conn_school "School"
lab var patron_connection "Patron"
lab var avg_relgrowth "GDP growth"

* use estimation sample
reghdfe promotion2 avg_relgrowth, ab(provcode#year tenure) vce(cl prefcode)

estpost tabstat prov_conn_pref prov_conn_prov prov_conn_school patron_connection if e(sample), s(mean min max count) columns(statistics)

esttab ., cells("mean(fmt(2)) min(fmt(0)) max(fmt(0)) count(fmt(0))") nonumbers replace label
esttab . using "$tables/connection_stats.tex", cells("mean(fmt(2)) min(fmt(0)) max(fmt(0)) count(fmt(0))") nonumbers replace label


*** controlling for connections
eststo clear
qui reghdfe promotion2 avg_relgrowth age age2 sex initlpop initlgdp home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m0
estadd local fe "Yes"
estadd local cov "Yes"
qui reghdfe promotion2 avg_relgrowth prov_conn_pref age age2 sex initlpop initlgdp home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov "Yes"
qui reghdfe promotion2 avg_relgrowth prov_conn_prov age age2 sex initlpop initlgdp home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov "Yes"
qui reghdfe promotion2 avg_relgrowth prov_conn_school age age2 sex initlpop initlgdp home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov "Yes"
qui reghdfe promotion2 avg_relgrowth patron_connection age age2 sex initlpop initlgdp home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m4
estadd local fe "Yes"
estadd local cov "Yes"

esttab m* , nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) keep(avg_relgrowth prov_conn_pref prov_conn_prov prov_conn_school patron_connection) scalars("fe Province-year FE" "cov Covariates") b(%9.3f)
esttab m* using "$tables/connection_control.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) keep(avg_relgrowth prov_conn_pref prov_conn_prov prov_conn_school patron_connection) scalars("fe Province-year FE" "cov Covariates") b(%9.3f)

*** interaction: connections X growth
gen connprefXgrowth = avg_relgrowth*prov_conn_pref
gen connprovXgrowth = avg_relgrowth*prov_conn_prov
gen connschoolXgrowth = avg_relgrowth*prov_conn_school
gen connpatronXgrowth = avg_relgrowth*patron_connection

lab var connprefXgrowth "Prefecture $\times$ Growth"
lab var connprovXgrowth "Province $\times$ Growth"
lab var connschoolXgrowth "School $\times$ Growth"
lab var connpatronXgrowth "Patron $\times$ Growth"

* use `a` and `aa` to ensure same label for different connection variables
eststo clear
qui: reghdfe promotion2 avg_relgrowth age age2 sex initlpop initlgdp home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m0
estadd local fe "Yes"
estadd local cov "Yes"
rename prov_conn_pref a
rename connprefXgrowth aa
lab var a "Connection"
lab var aa "Connection $\times$ Growth"
qui: reghdfe promotion2 avg_relgrowth a aa  age age2 sex initlpop initlgdp home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
rename a prov_conn_pref
rename aa connprefXgrowth
eststo m1
estadd local fe "Yes"
estadd local cov "Yes"
rename prov_conn_prov a
rename connprovXgrowth aa
lab var a "Connection"
lab var aa "Connection $\times$ Growth"
qui: reghdfe promotion2 avg_relgrowth a aa age age2 sex initlpop initlgdp home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov "Yes"
rename a prov_conn_prov
rename aa connprovXgrowth
rename prov_conn_school a
rename connschoolXgrowth aa
lab var a "Connection"
lab var aa "Connection $\times$ Growth"
qui: reghdfe promotion2 avg_relgrowth a aa age age2 sex initlpop initlgdp home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov "Yes"
rename a prov_conn_school
rename aa connschoolXgrowth
rename patron_connection a
rename connpatronXgrowth aa
lab var a "Connection"
lab var aa "Connection $\times$ Growth"
qui: reghdfe promotion2 avg_relgrowth a aa age age2 sex initlpop initlgdp home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m4
estadd local fe "Yes"
estadd local cov "Yes"

lab var a "Connection"
lab var aa "Connection $\times$ Growth"

esttab m* , mtitles("Baseline" "Pref. hometown" "Prov. hometown" "School" "Patron") label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) keep(avg_relgrowth a aa) scalars("fe Province-year FE" "cov Covariates") b(%9.3f)
esttab m* using "$tables/connection_interaction.tex", mtitles("Baseline" "Pref. hometown" "Prov. hometown" "School" "Patron") label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) keep(avg_relgrowth a aa) scalars("fe Province-year FE" "cov Covariates") b(%9.3f)
