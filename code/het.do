clear
use "$data/promotion_national.dta"

*** heterogeneous effects

*-------------------------------------------------------------------------------
*** region
gen ne_growth = northeast*avg_relgrowth
gen nc_growth = northcentral*avg_relgrowth
gen nw_growth = northwest*avg_relgrowth
gen sw_growth = southwest*avg_relgrowth
gen sc_growth = southcentral*avg_relgrowth
gen se_growth = southeast*avg_relgrowth

lab var ne_growth "Growth $\times$ Northeast"
lab var nc_growth "Growth $\times$ Northcentral"
lab var nw_growth "Growth $\times$ Northwest"
lab var sw_growth "Growth $\times$ Southwest"
lab var sc_growth "Growth $\times$ Southcentral"

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

eststo clear
qui reghdfe promotion2 avg_relgrowth ne_growth nc_growth nw_growth sw_growth sc_growth, ab(provcode#year) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
eststo m1
qui reghdfe promotion2 avg_relgrowth ne_growth nc_growth nw_growth sw_growth sc_growth age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "No"
eststo m2
qui reghdfe promotion2 avg_relgrowth ne_growth nc_growth nw_growth sw_growth sc_growth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"
eststo m3

esttab m*, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Prefecture characteristics" "cov1 Mayor characteristics") b(%9.3f)
esttab m* using "$tables/heterogeneity_region_small.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov1 Mayor characteristics" "cov2 Prefecture characteristics") keep(avg_relgrowth ne_growth nc_growth nw_growth sw_growth sc_growth) b(%9.3f)

*** era
gen t1_growth = time_jiang2*avg_relgrowth
gen t2_growth = time_hu1*avg_relgrowth
gen t3_growth = time_hu2*avg_relgrowth
gen t4_growth = time_xi*avg_relgrowth

lab var t2_growth "Growth $\times$ Hu I era"
lab var t3_growth "Growth $\times$ Hu II era"
lab var t4_growth "Growth $\times$ Xi era"

eststo clear
qui reghdfe promotion2 avg_relgrowth t2_growth t3_growth t4_growth, ab(provcode#year) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
eststo m1
qui reghdfe promotion2 avg_relgrowth t2_growth t3_growth t4_growth age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
eststo m2
qui reghdfe promotion2 avg_relgrowth t2_growth t3_growth t4_growth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"
eststo m3
esttab m*, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE") b(%9.3f)
esttab m* using "$tables/heterogeneity_era_small.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov1 Mayor characteristics" "cov2 Prefecture characteristics") keep(avg_relgrowth t2_growth t3_growth t4_growth) b(%9.3f)

*----------------------------------
* coefficient for each year
  * interact growth X year

reghdfe promotion2 c.avg_relgrowth##i.year initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
*di e(indepvars)
* note: need to remove 'bn'
local coef 1999.year#c.avg_relgrowth 2000.year#c.avg_relgrowth 2001.year#c.avg_relgrowth 2002.year#c.avg_relgrowth 2003.year#c.avg_relgrowth 2004.year#c.avg_relgrowth 2005.year#c.avg_relgrowth 2006.year#c.avg_relgrowth 2007.year#c.avg_relgrowth 2008.year#c.avg_relgrowth 2009.year#c.avg_relgrowth 2010.year#c.avg_relgrowth 2011.year#c.avg_relgrowth 2012.year#c.avg_relgrowth 2013.year#c.avg_relgrowth 2014.year#c.avg_relgrowth 2015.year#c.avg_relgrowth 2016.year#c.avg_relgrowth 2017.year#c.avg_relgrowth

set scheme s1mono

coefplot, vertical recast(scatter) ytitle("Coefficient") label xtitle("") xlabel(1 "1999" 5 "2003" 9 "2007" 13 "2011" 17 "2015") ci(95) keep(`coef') yline(0,lcolor(black%30))
graph export "$figures/promotiongrowth_allyears.png", replace

*-----------------------------------------------------------------------------
* provincial growth targets
lab var age "Age"
lab var age2 "Age squared"
lab var tenure "Tenure"
lab var educ "Education"
lab var sex "Gender"
lab var initlgdp "Initial GDP"
lab var initlpop "Initial Population"
lab var abovetarget "Above target"
lab var above2x "Above twice"
lab var above3x "Above thrice"
lab var below2x "Below twice"
lab var below3x "Below thrice"
lab var abovetarget2 "Above by 2pp"
lab var abovetarget3 "Above by 3pp"
lab var abovetarget5 "Above by 5pp"
lab var home_pref "Home prefecture"
lab var dist_target "Distance to target"

* dummy: 1{above target}
eststo clear
qui reghdfe promotion2 abovetarget, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 abovetarget age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 abovetarget initlgdp initlpop age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

* dummy: above target by 3pp
	* corresponds to p75 of distance to target
qui reghdfe promotion2 abovetarget3, ab(provcode#year) vce(cl prefcode) nocons
eststo m4
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 abovetarget3 age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m5
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 abovetarget3 initlgdp initlpop age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m6
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

* continuous: distance to target
qui reghdfe promotion2 dist_target, ab(provcode#year) vce(cl prefcode) nocons
eststo m7
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 dist_target age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m8
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 dist_target initlgdp initlpop age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m9
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m*, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates") order(abovetarget abovetarget3 dist_target) b(%9.3f)
esttab m* using "$tables/abovetarget.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") order(abovetarget abovetarget3 dist_target) b(%9.3f)


*** above target for two consecutive years
eststo clear
qui reghdfe promotion2 above2x, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 above2x age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 above2x initlgdp initlpop age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

*** above target for three consecutive years
qui reghdfe promotion2 above3x, ab(provcode#year) vce(cl prefcode) nocons
eststo m4
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 above3x age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m5
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 above3x initlgdp initlpop age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m6
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m*, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") order(above2x above3x) b(%9.3f)
esttab m* using "$tables/abovetarget_consecutive.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") order(above2x above3x) b(%9.3f)


* below target for two consecutive years
eststo clear
qui reghdfe promotion2 below2x, ab(provcode#year) vce(cl prefcode) nocons
eststo m7
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 below2x age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m8
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 below2x initlgdp initlpop age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m9
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

*** below target for three consecutive years
qui reghdfe promotion2 below3x, ab(provcode#year) vce(cl prefcode) nocons
eststo m10
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 below3x age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m11
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 below3x initlgdp initlpop age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m12
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m*, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") order(below2x below3x) b(%9.3f)
esttab m* using "$tables/belowtarget_consecutive.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") order(below2x below3x) b(%9.3f)


*-------------------------------------------------------------------------------
*** meritocracy differs by prefecture type?
	* use within prefecture variation: compare prefecture before and after status change

* https://en.wikipedia.org/wiki/Administrative_divisions_of_China#Prefecture_level
	* 293 PLC
	* 7 prefectures
	* 30 autonomous
	* 3 leagues

gen type_pref = (preftype==2)
gen type_auton = (preftype==3)
gen growthXpref = avg_relgrowth*type_pref
gen growthXauton = avg_relgrowth*type_auton

lab var type_pref "Type: prefecture"
lab var type_auton "Type: Autonomous prefecture"
lab var growthXpref "Growth $\times$ prefecture"
lab var growthXauton "Growth $\times$ autonomous"
lab var home_pref "Home prefecture"
lab var patron_connection "Connection"

eststo clear
qui reghdfe promotion2 avg_relgrowth type_pref type_auton growthXpref growthXauton, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 avg_relgrowth type_pref type_auton growthXpref growthXauton age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 avg_relgrowth type_pref type_auton growthXpref growthXauton initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
esttab m1 m2 m3 using "$tables/preftype_interaction.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)

*------------------------
*** heterogeneity by autonomous regions

* autonomous regions
* https://en.wikipedia.org/wiki/Autonomous_regions_of_China
* tibet, xinjiang, inner mongolia, ningxia, guangxi

gen autonomous = (provcode==54 | provcode == 65| provcode == 15| provcode == 64| provcode == 45)

*** interact growth X autonomous
gen growthXautonomous = avg_relgrowth*autonomous
lab var growthXautonomous "Growth $\times$ Autonomous"
eststo clear
qui: reghdfe promotion2 avg_relgrowth growthXautonomous, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui: reghdfe promotion2 avg_relgrowth growthXautonomous age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui: reghdfe promotion2 avg_relgrowth growthXautonomous initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"
esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
esttab m1 m2 m3 using "$tables/growthXautonomous.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
