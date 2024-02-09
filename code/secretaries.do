*** prefecture secretaries

*---------------------------------------------------
* Chen and Kung (2019) prefecture secretary data
* prefecture_panel.dta is from Chen and Kung (2019)
* prefecture_leaders.dta is from James Kung
* prefecture.dta is prefecture characteristics for 1991-2019
    * [formerly: prefecture_helena]

clear
use "$data/prefecture_panel.dta", clear

merge 1:1 prefid year ps using "$data/prefecture_leaders.dta"
drop if _m==2
drop _m

keep if ps==1
drop ps

merge 1:1 prefid year using "$data/prefecture.dta"
drop if _m==2
drop _m

egen leader = group(name birthy)
drop if missing(leader)
egen leaderpref = group(leader prefid)

tsset leaderpref year
tsspell leaderpref

table year, c(count promote1)
* missing data for 2014

sort leaderpref year
bys leaderpref: gen runsum_rgdp = sum(rgdpgrowth) if missing(rgdpgrowth)==0
gen avg_rgdp = runsum_rgdp/_seq
replace avg_rgdp=. if missing(rgdpgrowth)

gen lgdp = log(gdp)
gen initlgdpper = lgdp if _seq==1
egen initlgdp = max(initlgdpper), by(leaderpref)

* don't have true start year, so can't control for tenure properly
  * _seq is "first year in office observed in the data", which could be their nth actual year
  * can't do anything about this without having "start year" variable

lab var rgdpgrowth "Annual growth"
lab var avg_rgdp "Cumulative average growth"
lab var age "Age"
lab var age2 "Age squared"
lab var sex "Sex"
lab var eduyear "Education"
lab var ties "Connections"
lab var initlgdp "Initial GDP"
lab var _seq "Tenure"

egen fe_provyear = group(provcode year)

eststo clear
qui reghdfe promote1 rgdpgrowth age age2 sex eduyear ties initlgdp _seq, ab(provcode#year) vce(cl prefcode)
eststo m2
estadd local cov1 "Yes"
qui reghdfe promote1 avg_rgdp age age2 sex eduyear ties initlgdp _seq, ab(provcode#year) vce(cl prefcode)
eststo m4
estadd local cov1 "Yes"
qui clogit promote1 rgdpgrowth age age2 sex eduyear ties initlgdp _seq, group(fe_provyear) vce(cl fe_provyear)
eststo m5
qui clogit promote1 avg_rgdp age age2 sex eduyear ties initlgdp _seq, group(fe_provyear) vce(cl fe_provyear)
eststo m6
qui ologit promote rgdpgrowth age age2 sex eduyear ties initlgdp _seq i.fe_provyear, vce(cl prefcode)
eststo m7
qui ologit promote avg_rgdp age age2 sex eduyear ties initlgdp _seq i.fe_provyear, vce(cl prefcode)
eststo m8
esttab m*, nomtitle label replace se star(* 0.1 ** 0.05 *** 0.01) eqlabels(none) b(%9.3f) order(rgdpgrowth avg_rgdp) keep(rgdpgrowth avg_rgdp age age2 sex eduyear ties initlgdp _seq) nocons mgroups("LPM" "Logit" "Ordered logit", pattern(1 0 1 0 1 0))
esttab m* using "$tables/ck_secretary.tex", nomtitle label replace se star(* 0.1 ** 0.05 *** 0.01) eqlabels(none) b(%9.3f) keep(rgdpgrowth avg_rgdp age age2 sex eduyear ties initlgdp _seq) order(rgdpgrowth avg_rgdp) nocons mgroups("LPM" "Logit" "Ordered logit", pattern(1 0 1 0 1 0))

*------------------------------------------------------------------------------
*** Yao and Zhang (2015)
* Leader_Long.dta is from Yao and Zhang (2015)

use "$data/Leader_Long.dta", clear

keep if secretary==1
drop cname
rename region pref
format pref %10s
rename code06 prefcode
rename leader name
rename yob birthyear
format prepos %20s
format postpos %20s
rename firstyear startyear
rename lastyear endyear
rename ctenure tenure
rename rgdppcr1 rgdpgrowth
rename pid provcode
drop if year<1998
sort prefcode year
gen lingdp = log(inigdppc)

egen fe_provyear = group(provcode year)

* outliers
replace rgdpgrowth=. if inrange(rgdpgrowth,2,10)

* cumulative average growth
drop if missing(lid)
egen leaderpref = group(lid prefcode)
tsset leaderpref year
tsspell leaderpref

sort leaderpref year
bys leaderpref: gen runsum_rgdp = sum(rgdpgrowth) if missing(rgdpgrowth)==0
gen avg_rgdp = runsum_rgdp/_seq
replace avg_rgdp=. if missing(rgdpgrowth)

lab var rgdpgrowth "Annual growth"
lab var avg_rgdp "Cumulative average growth"
lab var age "Age"
lab var agesq "Age squared"
lab var tenure "Tenure"
lab var preprov "Provincial experience"
lab var lingdp "Initial GDP"


eststo clear
qui:reghdfe prom_y rgdpgrowth age agesq tenure preprov lingdp, ab(provcode#year) vce(cl prefcode) nocons
eststo m1
qui:reghdfe prom_y avg_rgdp age agesq tenure preprov lingdp, ab(provcode#year) vce(cl prefcode) nocons
eststo m2
qui:clogit prom_y rgdpgrowth age agesq tenure preprov lingdp, group(fe_provyear) vce(cl fe_provyear)
eststo m3
qui:clogit prom_y avg_rgdp age agesq tenure preprov lingdp, group(fe_provyear) vce(cl fe_provyear)
eststo m4
esttab m*, nomtitle label replace se star(* 0.1 ** 0.05 *** 0.01) eqlabels(none) b(%9.3f) order(rgdpgrowth avg_rgdp) keep(rgdpgrowth avg_rgdp age agesq tenure preprov lingdp) nocons mgroups("LPM" "Logit", pattern(1 0 1 0))
esttab m* using "$tables/yz_secretary.tex", nomtitle label replace se star(* 0.1 ** 0.05 *** 0.01) eqlabels(none) b(%9.3f) keep(rgdpgrowth avg_rgdp age agesq tenure preprov lingdp) order(rgdpgrowth avg_rgdp) nocons mgroups("LPM" "Logit", pattern(1 0 1 0))

*-------------------------------------------------------------------------------
*** Li et al. (2019)
* promotion.csv is from Li et al. (2019)

clear
import delimited "$data/promotion.csv"
* note: cityprom.csv has columns messed up

* can't identify leaders, or spells
  * don't have names
tostring city, gen(prefcode)
replace prefcode = substr(prefcode,1,4)
destring prefcode, replace

rename real gdpgrowth
rename cumreal avggdp
  * seems to be calculated correctly
  * but I can't check without a spell variable
rename on_seat_yr tenure

gen age2 = age*age

replace gdpgrowth = gdpgrowth/100
replace avggdp = avggdp/100
keep if pos==1

egen fe_provyear = group(province year)

lab var gdpgrowth "Annual growth"
lab var avggdp "Cumulative average growth"
lab var age "Age"
lab var age2 "Age squared"
lab var tenure "Tenure"
lab var edu "Education"

eststo clear
qui reghdfe promotion gdpgrowth age age2 tenure edu, ab(province#year) vce(cl prefcode) nocons
estadd local fe "Yes"
eststo m1
qui reghdfe promotion avggdp age age2 tenure edu, ab(province#year) vce(cl prefcode) nocons
estadd local fe "Yes"
eststo m3
qui clogit promotion gdpgrowth age age2 tenure edu, group(fe_provyear) vce(cl fe_provyear)
eststo m4
qui clogit promotion avggdp age age2 tenure edu, group(fe_provyear) vce(cl fe_provyear)
eststo m5

esttab m*, nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) order(gdpgrowth avggdp) nocons mgroups("LPM" "Logit", pattern(1 0 1 0))  eqlabels(none) b(%9.3f)
esttab m* using "$tables/li_etal_secretary.tex", nomtitle label replace se ar2 star(* 0.1 ** 0.05 *** 0.01) order(gdpgrowth avggdp) nocons mgroups("LPM" "Logit", pattern(1 0 1 0)) eqlabels(none) b(%9.3f)

*-------------------------------------------------------------------------------
*** Landry et al. (2019)
* CHN_Fiscal_Promtn_Data_Pref.dta is from Landry et al. (2019)

use "$data/CHN_Fiscal_Promtn_Data_Pref.dta",clear
drop if all_tax_gdp>=100
drop if sec_position_next_year==0 & year==2007

gen sec_age2=sec_age^2
egen id = group(ccp_sec)
egen idpref = group(id pref_id)
drop if missing(idpref)
tsset idpref year
tsspell idpref
sort idpref year
bys idpref: gen runsum_gdp = sum(rel_gdp_gr) if missing(rel_gdp_gr)==0
gen avg_gdp = runsum_gdp/_seq
lab var avg_gdp "GDP growth"
lab var pref_sec_pw_prov "Connection"
rename pref_sec_pw_prov conn
rename rel_gdp_gr gdpgrowth

egen fe_provyear = group(prov_id year)

* tenure is total, not annual
  * connection is annual
egen tmax = max(_seq), by(idpref)
gen tdiff = sec_tty - tmax
gen tenure = _seq + tdiff
drop if year<1999

* annual promotion variable
gen promotion = sec_promotion if _end==1
replace promotion = 0 if missing(promotion) & missing(sec_promotion)==0

lab var gdpgrowth "Annual growth"
lab var avg_gdp "Cumulative average growth"
lab var tenure "Tenure"
lab var sec_age "Age"
lab var sec_age2 "Age squared"
lab var conn "Connections"

eststo clear
qui:reghdfe promotion gdpgrowth sec_age sec_age2 tenure conn  ,  vce(cl pref_id) absorb(prov_id year pref_type_id)
eststo m1
qui:reghdfe promotion avg_gdp sec_age sec_age2 tenure conn ,  vce(cl pref_id) absorb(prov_id year pref_type_id)
eststo m2
qui:clogit promotion gdpgrowth sec_age sec_age2 tenure conn ,  group(fe_provyear) vce(cl fe_provyear)
eststo m3
qui:clogit promotion avg_gdp sec_age sec_age2 tenure conn ,  group(fe_provyear) vce(cl fe_provyear)
eststo m4

esttab m*, nomtitle label replace se star(* 0.1 ** 0.05 *** 0.01) order(gdpgrowth avg_gdp) mgroups("LPM" "Logit", pattern(1 0 1 0))  eqlabels(none) b(%9.3f) nocons
esttab m* using "$tables/landry_secretary.tex", nomtitle label replace se star(* 0.1 ** 0.05 *** 0.01) order(gdpgrowth avg_gdp)  mgroups("LPM" "Logit", pattern(1 0 1 0))  eqlabels(none) b(%9.3f) nocons
