clear
use "$data/promotion_national.dta"

* categories
  * average: cumulative average of relative real gdp growth
  * annual: annual growth
  * covars: covariates
  * defn: definition
  * fe: pref FE
  * pc: gdppc

cd "$tables"
* speccurve saves 'estimates.dta' to the current directory

* main spec: defn2, covars, average
reghdfe promotion2 avg_relgrowth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode)
specchart avg_relgrowth,spec(main defn2 covars average) replace

* loop over promotion definition
forval i=1(1)4 {
  * no covars, average
  qui reghdfe promotion`i' avg_relgrowth, ab(provcode#year) vce(cl prefcode)
  specchart avg_relgrowth,spec(defn`i' average)
  qui reghdfe promotion`i' avg_relgrowth_pc, ab(provcode#year) vce(cl prefcode)
  specchart avg_relgrowth_pc,spec(defn`i' average pc)

  * no covars, average, pref
  qui reghdfe promotion`i' avg_relgrowth, ab(provcode#year prefcode) vce(cl prefcode)
  specchart avg_relgrowth,spec(defn`i' average pref)
  qui reghdfe promotion`i' avg_relgrowth_pc, ab(provcode#year prefcode) vce(cl prefcode)
  specchart avg_relgrowth_pc,spec(defn`i' average pc pref)

  * no covars, average, prov
  qui reghdfe promotion`i' avg_relgrowth, ab(provcode year) vce(cl prefcode)
  specchart avg_relgrowth,spec(defn`i' average prov)
  qui reghdfe promotion`i' avg_relgrowth_pc, ab(provcode year) vce(cl prefcode)
  specchart avg_relgrowth_pc,spec(defn`i' average pc prov)

  * no covars, annual
  qui reghdfe promotion`i' rel_growth, ab(provcode#year) vce(cl prefcode)
  specchart rel_growth,spec(defn`i' annual)
  qui reghdfe promotion`i' rel_growth_pc, ab(provcode#year) vce(cl prefcode)
  specchart rel_growth_pc,spec(defn`i' annual pc)

  * no covars, annual, pref
  qui reghdfe promotion`i' rel_growth, ab(provcode#year prefcode) vce(cl prefcode)
  specchart rel_growth,spec(defn`i' annual pref)
  qui reghdfe promotion`i' rel_growth_pc, ab(provcode#year prefcode) vce(cl prefcode)
  specchart rel_growth_pc,spec(defn`i' annual pref pc)

  * no covars, annual, prov
  qui reghdfe promotion`i' rel_growth, ab(provcode year) vce(cl prefcode)
  specchart rel_growth,spec(defn`i' annual prov)
  qui reghdfe promotion`i' rel_growth_pc, ab(provcode year) vce(cl prefcode)
  specchart rel_growth_pc,spec(defn`i' annual prov pc)

  * covars, average
  qui reghdfe promotion`i' avg_relgrowth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode)
  specchart avg_relgrowth,spec(defn`i' covars average)
  qui reghdfe promotion`i' avg_relgrowth_pc initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode)
  specchart avg_relgrowth_pc,spec(defn`i' covars average pc)

  * covars, average, pref
  qui reghdfe promotion`i' avg_relgrowth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year prefcode tenure edu_code preftype) vce(cl prefcode)
  specchart avg_relgrowth,spec(defn`i' covars average pref)
  qui reghdfe promotion`i' avg_relgrowth_pc initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year prefcode tenure edu_code preftype) vce(cl prefcode)
  specchart avg_relgrowth_pc,spec(defn`i' covars average pref pc)

  * covars, average, prov
  qui reghdfe promotion`i' avg_relgrowth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode year tenure edu_code preftype) vce(cl prefcode)
  specchart avg_relgrowth,spec(defn`i' covars average prov)
  qui reghdfe promotion`i' avg_relgrowth_pc initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode year tenure edu_code preftype) vce(cl prefcode)
  specchart avg_relgrowth_pc,spec(defn`i' covars average prov pc)

  * covars, annual
  qui reghdfe promotion`i' rel_growth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode)
  specchart rel_growth,spec(defn`i' covars annual)
  qui reghdfe promotion`i' rel_growth_pc initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode)
  specchart rel_growth_pc,spec(defn`i' covars annual pc)

  * covars, annual, pref
  qui reghdfe promotion`i' rel_growth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year prefcode tenure edu_code preftype) vce(cl prefcode)
  specchart rel_growth,spec(defn`i' covars annual pref)
  qui reghdfe promotion`i' rel_growth_pc initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year prefcode tenure edu_code preftype) vce(cl prefcode)
  specchart rel_growth_pc,spec(defn`i' covars annual pref pc)

  * covars, annual, prov
  qui reghdfe promotion`i' rel_growth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode year tenure edu_code preftype) vce(cl prefcode)
  specchart rel_growth,spec(defn`i' covars annual prov)
  qui reghdfe promotion`i' rel_growth_pc initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode year tenure edu_code preftype) vce(cl prefcode)
  specchart rel_growth_pc,spec(defn`i' covars annual prov pc)

}

*** create graph
use "$tables/estimates.dta",clear
* drop duplicates
duplicates drop covars average annual prov pref pc defn*, force
* sort specification by category
gsort -average -annual -prov -pref -pc -covars -defn1 -defn2 -defn3 -defn4, mfirst

* sort estimates by coefficient size, uncomment to activate sort by category */
* sort beta
  * uncomment to sort by coefficient size
* rank
gen rank=_n
* gen indicators and scatters
	local scoff=" "
	local scon=" "
	local ind=-.6
  * edit this for positioning
	foreach var in covars average annual prov pref pc  {
	   cap gen i_`var'=`ind'
	   local ind=`ind'-0.1
	   local scoff="`scoff' (scatter i_`var' rank,msize(vsmall) mcolor(gs10))"
	   local scon="`scon' (scatter i_`var' rank if `var'==1,msize(vsmall) mcolor(black))"
	}
	* definitions
	local ind=`ind'-0.1
	forval i=1(1)4{
		cap gen i_defn`i'=`ind'
		local ind=`ind'-0.1
	   local scoff="`scoff' (scatter i_defn`i' rank,msize(vsmall) mcolor(gs10))"
	   local scon="`scon' (scatter i_defn`i' rank if defn`i'==1,msize(vsmall) mcolor(black))"
	}


* plot
tw  (scatter beta rank if main==1, mcolor(blue) msymbol(D)  msize(small)) ///  main spec
   (rbar u95 l95 rank, fcolor(gs12) lcolor(gs12) lwidth(none)) /// 95% CI
   (scatter beta rank, mcolor(black) msymbol(D) msize(small)) ///  point estimates
   `scoff' `scon' /// indicators for spec
  (scatter beta rank if main==1, mcolor(blue) msymbol(D)  msize(small)) ///  main spec
  (scatter i_defn2 rank if main==1,msize(vsmall) mcolor(blue))  ///
  (scatter i_average rank if main==1,msize(vsmall) mcolor(blue))  ///
  (scatter i_covars rank if main==1,msize(vsmall) mcolor(blue))  ///
   ,legend (order(1 "Main spec." 4 "Point estimate" 2 "95% CI") region(lcolor(white)) ///
	pos(12) ring(1) rows(1) size(vsmall) symysize(small) symxsize(small)) ///
   xtitle(" ") ytitle(" ") ///
   yscale(noline) xscale(noline) ylab(-.3(.15).3,noticks nogrid angle(horizontal)) xlab("", noticks)  ///
   graphregion (fcolor(white) lcolor(white)) plotregion(fcolor(white) lcolor(white)) yline(0, lcolor(black))

* now add stuff to the y axis
gr_edit .yaxis1.add_ticks -.5 `"Specification             "', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -.6 `"Covariates"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -.7 `"Average"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -.8 `"Annual"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -.9 `"Prov + Year FE"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -1 `"Pref FE"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -1.1 `"Per capita"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )

gr_edit .yaxis1.add_ticks -1.25 `"Definition               "', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -1.3 `"1"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -1.4 `"2"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -1.5 `"3"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -1.6 `"4"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )

gr_edit .yaxis1.add_ticks .4 `"Coefficient"', custom tickset(major) editstyle(tickstyle(textstyle(size(small))) )

graph export "$figures/robustness_big.png",replace

*------------------------------------------------------------------------------------
*** add covariates one at a time
clear
use "$data/promotion_national.dta"

lab var age "Age"
lab var age2 "Age squared"
lab var tenure "Tenure"
lab var educ "Education"
lab var sex "Sex"
lab var avg_relgrowth "Growth"
lab var initlgdp "Initial GDP"
lab var initlpop "Initial Population"
lab var patron_connection "Connections"
lab var home_pref "Home prefecture"


* table
eststo clear
qui reghdfe promotion2 avg_relgrowth, ab(provcode#year) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local ten "No"
estadd local edu "No"
estadd local pref "No"
eststo m1
qui reghdfe promotion2 avg_relgrowth age age2, ab(provcode#year) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local ten "No"
estadd local edu "No"
estadd local pref "No"
eststo m2
qui reghdfe promotion2 avg_relgrowth age age2 sex, ab(provcode#year) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local ten "No"
estadd local edu "No"
estadd local pref "No"
eststo m3
qui reghdfe promotion2 avg_relgrowth age age2 sex, ab(provcode#year tenure) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local ten "Yes"
estadd local edu "No"
estadd local pref "No"
eststo m4
qui reghdfe promotion2 avg_relgrowth age age2 sex, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local ten "Yes"
estadd local edu "Yes"
estadd local pref "No"
eststo m5
qui reghdfe promotion2 avg_relgrowth age age2 sex home_pref, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local ten "Yes"
estadd local edu "Yes"
estadd local pref "No"
eststo m6
qui reghdfe promotion2 avg_relgrowth age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local ten "Yes"
estadd local edu "Yes"
estadd local pref "No"
eststo m7
qui reghdfe promotion2 avg_relgrowth age age2 sex home_pref patron_connection initlgdp, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local ten "Yes"
estadd local edu "Yes"
estadd local pref "No"
eststo m8
qui reghdfe promotion2 avg_relgrowth age age2 sex home_pref patron_connection initlgdp initlpop, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local ten "Yes"
estadd local edu "Yes"
estadd local pref "No"
eststo m9
qui reghdfe promotion2 avg_relgrowth age age2 sex home_pref patron_connection initlgdp initlpop, ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
estadd local fe "Yes"
estadd local ten "Yes"
estadd local edu "Yes"
estadd local pref "Yes"
eststo m10

esttab m*, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) b(%9.3f) scalars("fe Province-year FE" "ten Tenure" "edu Education" "pref Prefecture type")
esttab m* using "$tables/covars1by1.tex", nomtitle label replace se star(* 0.1 ** 0.05 *** 0.01) b(%9.3f) scalars("fe Province-year FE" "ten Tenure" "edu Education" "pref Prefecture type")

*** drop mayors who are promoted in first year
gen promtenure_temp = tenure if promotion2==1
egen promtenure = max(promtenure_temp), by(idpref)

preserve
drop if promtenure<2

eststo clear
qui reghdfe promotion2 avg_relgrowth, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 avg_relgrowth age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov2 "Yes"
estadd local cov1 "No"
qui reghdfe promotion2 avg_relgrowth initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
esttab m1 m2 m3 using "$tables/lpm_no_y1prom.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)

restore

*--------------------------------------
*** growth relative to predecessor

lab var avg_relgrowth_relpred "GDP growth"
lab var avg_growth_relpred "GDP growth"

* relative to predecessor only
eststo clear
qui reghdfe promotion2 avg_growth_relpred, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 avg_growth_relpred age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 avg_growth_relpred initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
esttab m1 m2 m3 using "$tables/rel_pred.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)


* relative to provincial average and predecessor
eststo clear
qui reghdfe promotion2 avg_relgrowth_relpred, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 avg_relgrowth_relpred age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 avg_relgrowth_relpred initlgdp initlpop age age2 sex home_pref  patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
esttab m1 m2 m3 using "$tables/relprov_pred.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)


*---------------------------------------------
* maximum growth in province-year tournament
lab var maxgrowth "Maximum growth"
eststo clear
qui reghdfe promotion2 maxgrowth, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 maxgrowth age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 maxgrowth initlgdp initlpop age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
esttab m1 m2 m3 using "$tables/lpm_maxgrowth.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)

* above median growth
lab var abovemedian_growth "Growth $>$ median"
eststo clear
qui reghdfe promotion2 abovemedian_growth, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 abovemedian_growth age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 abovemedian_growth initlgdp initlpop age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
esttab m1 m2 m3 using "$tables/lpm_medgrowth.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)

* quartiles of growth
gen growth_q1 = (quartile_growth==1) if missing(quartile_growth)==0
gen growth_q2 = (quartile_growth==2) if missing(quartile_growth)==0
gen growth_q3 = (quartile_growth==3) if missing(quartile_growth)==0
gen growth_q4 = (quartile_growth==4) if missing(quartile_growth)==0
lab var growth_q2 "Growth: 2nd quartile"
lab var growth_q3 "Growth: 3rd quartile"
lab var growth_q4 "Growth: 4th quartile"

eststo clear
qui reghdfe promotion2 growth_q2 growth_q3 growth_q4 , ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 growth_q2 growth_q3 growth_q4 age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 growth_q2 growth_q3 growth_q4 initlgdp initlpop age age2 sex home_pref patron_connection , ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
esttab m1 m2 m3 using "$tables/lpm_quartiles.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)

*-------------------------------
* exclude i when calculating provincial average growth rate, which is used for calculating relative growth
lab var avg_relgrowth_mi "GDP growth"
eststo clear
qui reghdfe promotion2 avg_relgrowth_mi, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "No"
qui reghdfe promotion2 avg_relgrowth_mi  age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code) vce(cl prefcode) nocons
eststo m2
estadd local fe "Yes"
estadd local cov1 "No"
estadd local cov2 "Yes"
qui reghdfe promotion2 avg_relgrowth_mi initlgdp initlpop age age2 sex home_pref patron_connection, ab(provcode#year tenure edu_code preftype) vce(cl prefcode) nocons
eststo m3
estadd local fe "Yes"
estadd local cov1 "Yes"
estadd local cov2 "Yes"

esttab m1 m2 m3, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)
esttab m1 m2 m3 using "$tables/lpm_minus_i.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) scalars("fe Province-year FE" "cov2 Mayor covariates" "cov1 Prefecture covariates") b(%9.3f)