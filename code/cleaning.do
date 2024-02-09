*** prefecture-level data on gdp, politicians

* politician data
clear
import excel "$raw_data/city_full_v14.xlsx", sheet("Sheet1") firstrow

drop A
drop if missing(year)
drop if missing(name)
gen prefid = prefcode
replace prefcode = prefcode/100

* old codes
replace prefcode=2327 if prefcode==2317
replace prefcode=5206 if prefcode==5222
replace prefcode=5205 if prefcode==5224
replace prefcode=5402 if prefcode==5423
replace prefcode=5404 if prefcode==5426
replace prefcode=6302 if prefcode==6321

gen arrest_date = date(arrestDate,"YM")
format arrest_date %td
drop arrestDate

replace birth = "1963-06" if birth == "2963-06"
gen birth2 = date(birth,"YM")
format birth2 %td
drop birth
rename birth2 birth

gen join2 = date(join_ccp,"YMD")
gen join3 = date(join_ccp,"YM")
gen join4 = join2 if missing(join2)==0
replace join4 = join3 if missing(join3)==0
format join4 %td
drop join_ccp join2 join3
rename join4 join_ccp

gen start2 = date(start, "YM")
format start2 %td
gen start_month2 = month(start2)
* four errors in start variable
replace start_month2 = 0 if start_month==0 & missing(start_month2)
drop start_month
rename start_month2 start_month

gen start_year2 = year(start2)
replace start_year2 = start_year if missing(start_year2)
* two errors
drop start_year
rename start_year2 start_year

drop start
rename start2 start

keep if inrange(year,1998, 2017)

* drop directly-controlled cities: beijing, chongqing, shanghai, tianjin
drop if prefcode==1100 | prefcode==1101 | prefcode==1200 | prefcode==1201 | prefcode==3100 | prefcode==5000

* add in missing data
append using "$raw_data/mayor_missing.dta"
duplicates t prefcode year, gen(tag)
drop if tag==1 & missing(educ)
duplicates drop prefcode year, force
drop tag

append using "$raw_data/mayor_missing2.dta"
duplicates t prefcode year, gen(tag)
drop if tag==1 & missing(educ)
duplicates drop prefcode year, force
drop tag

gen arrest_year = year(arrest_date)
format arrest_date %td
gen birthyear = year(birth)

* need to use birth to distinguish mayors with the same name
egen name_birth = concat(name birth)
egen id = group(name_birth)
egen idpref = group(prefcode name_birth)

rename promoCode promoted
rename prov provname
rename provpy provname_py

replace native_pref_code = native_pref_code/100 if native_pref_code>9999

drop if missing(idpref)
egen minyear = min(year), by(idpref)
tostring minyear, gen(stringyear)
tostring idpref, gen(string_idpref)
gen ordered_id = stringyear + string_idpref
egen idpref2 = group(prefcode ordered_id) if missing(idpref)==0

tsset idpref year
tsspell idpref
* careful: if missing educ or birth, those observations get lumped together when calculating avg_gdp


* generate tenure variable
gen startyear_temp = year if _seq==1
egen startyear_temper = max(startyear_temp), by(idpref)
replace start_year = startyear_temper if start_year==0 | missing(start_year)==1

gen firstyear_temp = start_year if start_year==year & start_month<7
replace firstyear_temp = start_year+1 if start_year == year-1 & start_month>=7 & missing(firstyear_temp) & _seq==1
* note: this doesn't work if missing observations; eg, 6543, starts in 2003, but only have data (so far) from 2004-2014.
replace firstyear_temp = start_year if start_year == year-1 & start_month<7 & missing(firstyear_temp) & _seq==1
* people who start before 1998
replace firstyear_temp = start_year if start_year<1998 & start_month<7 & missing(firstyear_temp) & _seq==1
replace firstyear_temp = start_year+1 if start_year<1998 & start_month>=7 & missing(firstyear_temp) & _seq==1

egen firstyear = max(firstyear_temp), by(idpref)
gen tenure = year - firstyear + 1
replace tenure = _seq if missing(tenure)==1 & missing(_seq)==0
replace tenure = _seq if tenure<=0

xtset prefcode year

gen arrested_inoffice = (inrange(arrested,1,1) & _end==1)
egen everarrested_inoffice = max(arrested_inoffice), by(idpref)
gen arrested_dummy = (inrange(arrested,1,2))
replace arrested_dummy=. if missing(arrested)==1
egen everarrested = max(arrested_dummy), by(idpref)
gen arrested_outofoffice = (inrange(arrested,2,2))
egen everarrested_outofoffice = max(arrested_dummy), by(idpref)

*---------------------------------------------------------------------------------
*** promotion definitions

gen promotion1 = (inrange(promoted,500,500) & _end==1) if missing(promoted)==0
gen promotion2 = (inrange(promoted,500,504) & _end==1) if missing(promoted)==0
* exclude LPC/CPPCC positions
gen promotion3 = ((inrange(promoted,500,504)|inrange(promoted,411,412)) & _end==1) if missing(promoted)==0
* include LPC/CPPCC positions: provincial vice-chairman, chairman
gen promotion4 = ((inrange(promoted,500,504)|inrange(promoted,411,412)|inrange(promoted,304,304)) & _end==1) if missing(promoted)==0
* include provincial positions, which may have higher de facto rank
gen promotion5 = (inrange(promoted,501,504) & _end==1) if missing(promoted)==0
* don't count secretary as promotion, only provincial positions
gen promotion6 = ((inrange(promoted,501,504)|inrange(promoted,411,412)) & _end==1) if missing(promoted)==0

egen everpromoted1 = max(promotion1), by(idpref)
egen everpromoted2 = max(promotion2), by(idpref)
egen everpromoted3 = max(promotion3), by(idpref)
egen everpromoted4 = max(promotion4), by(idpref)

* ordered promotion variable
gen opromotion=2 if missing(promoted)==0
* default is stay in office
replace opromotion = 0 if (inrange(promoted,100,103) & _end==1)
* death, termination, retirement
replace opromotion = 1 if (inrange(promoted,200,209) & _end==1)
* demotion
replace opromotion = 2 if ((inrange(promoted,300,422)|promoted==600) & _end==1)
* transfer
replace opromotion = 3 if (inrange(promoted,500,504) & _end==1)

gen opromotion1=2 if missing(promoted)==0
replace opromotion1 = 0 if (inrange(promoted,100,103) & _end==1)
replace opromotion1 = 1 if (inrange(promoted,200,209) & _end==1)
replace opromotion1 = 2 if ((inrange(promoted,300,422)|promoted==600|inrange(promoted,501,504)) & _end==1)
replace opromotion1 = 3 if (inrange(promoted,500,500) & _end==1)

gen opromotion3=2 if missing(promoted)==0
replace opromotion3 = 0 if (inrange(promoted,100,103) & _end==1)
replace opromotion3 = 1 if (inrange(promoted,200,209) & _end==1)
replace opromotion3 = 2 if ((inrange(promoted,300,410)|promoted==600|promoted==422) & _end==1)
replace opromotion3 = 3 if ((inrange(promoted,500,504)|inrange(promoted,411,412)) & _end==1)

gen opromotion4=2 if missing(promoted)==0
replace opromotion4 = 0 if (inrange(promoted,100,103) & _end==1)
replace opromotion4 = 1 if (inrange(promoted,200,209) & _end==1)
replace opromotion4 = 2 if ((inrange(promoted,300,303)|inrange(promoted,305,410)|promoted==600|promoted==422) & _end==1)
replace opromotion4 = 3 if ((inrange(promoted,500,504)|inrange(promoted,411,412)|inrange(promoted,304,304)) & _end==1)

gen opromotion5=2 if missing(promoted)==0
replace opromotion5 = 0 if (inrange(promoted,100,103) & _end==1)
replace opromotion5 = 1 if (inrange(promoted,200,209) & _end==1)
replace opromotion5 = 2 if ((inrange(promoted,300,422)|promoted==600|promoted==500) & _end==1)
replace opromotion5 = 3 if (inrange(promoted,501,504) & _end==1)


gen age = year - birthyear
gen age2 = age*age

gen ccp_year = year(join_ccp)
gen ccp_time = year - ccp_year

gen retirement = (age>55)

gen home_prov = (native_prov_code == provcode) if missing(native_prov_code)==0
gen home_pref = (native_pref_code == prefcode) if missing(native_pref_code)==0

egen school_id = group(school) if missing(school)==0

* regions
gen region = 1 if (provname_py == "Jiangsu" | provname_py == "Zhejiang" | provname_py == "Fujian" | provname_py == "Guangdong" | provname_py == "Hainan")
replace region = 2 if (provname_py == "Henan" | provname_py == "Hubei" | provname_py == "Hunan" | provname_py == "Anhui" | provname_py == "Jiangxi")
replace region = 3 if (provname_py == "Shandong" | provname_py == "Hebei" | provname_py == "Liaoning" | provname_py == "Jilin" | provname_py == "Heilongjiang")
replace region = 4 if (provname_py == "Shanxi" | provname_py == "Inner Mongolia")
replace region = 5 if (provname_py == "Shaanxi" | provname_py == "Ningxia" | provname_py == "Gansu" | provname_py == "Qinghai" | provname_py == "Xinjiang")
replace region = 6 if (provname_py == "Guangxi" | provname_py == "Guizhou" | provname_py == "Yunnan" | provname_py == "Sichuan" | provname_py == "Tibet")
label define region_label 1 "Southeast" 2 "Southcentral" 3 "Northeast" 4 "Northcentral" 5 "Northwest" 6 "Southwest"
label values region region_label

gen northeast = (region==3)
gen northcentral = (region==4)
gen northwest = (region==5)
gen southwest = (region==6)
gen southcentral = (region==2)
gen southeast = (region==1)

gen central = (region==4|region==2)
gen east = (region==3|region==1)
gen west = (region==5|region==6)

*** eras
gen time_jiang2 = inrange(year,1998,2002)
gen time_hu1 = inrange(year,2003,2007)
gen time_hu2 = inrange(year,2008,2012)
gen time_xi = inrange(year,2013,2017)
gen era =1 if time_jiang2==1
replace era =2 if time_hu1==1
replace era =3 if time_hu2==1
replace era =4 if time_xi==1
label define era_label 1 "Jiang: II" 2 "Hu: I" 3 "Hu: 2" 4 "Xi"
label values era era_label

*** provincial leader data
merge m:1 provcode year using "$raw_data/provleader.dta"
drop if _merge==2
drop _merge

replace provleader_native_pref1 = provleader_native_pref1/100
replace provleader_native_pref2 = provleader_native_pref2/100

gen provsec_conn_school = (school==provleader_uni1) if missing(school)==0
gen provgov_conn_school = (school==provleader_uni2) if missing(school)==0
gen prov_conn_school = (provsec_conn_school==1 | provgov_conn_school==1) if missing(provsec_conn_school)==0|missing(provgov_conn_school)==0

gen provsec_conn_prov = (native_prov_code==provleader_native_prov1) if missing(native_prov_code)==0
gen provgov_conn_prov = (native_prov_code==provleader_native_prov2) if missing(native_prov_code)==0
gen prov_conn_prov = (provsec_conn_prov==1 | provgov_conn_prov==1) if missing(provsec_conn_prov)==0|missing(provgov_conn_prov)==0

gen provsec_conn_pref = (native_pref_code==provleader_native_pref1) if missing(native_pref_code)==0
gen provgov_conn_pref = (native_pref_code==provleader_native_pref2) if missing(native_pref_code)==0
gen prov_conn_pref = (provsec_conn_pref==1 | provgov_conn_pref==1) if missing(provsec_conn_pref)==0|missing(provgov_conn_pref)==0

gen any_connection = (prov_conn_prov==1|prov_conn_school==1)
* pref=1 implies prov=1
replace any_connection =. if missing(prov_conn_prov)==1 & missing(prov_conn_school)==1

* jiang patron connection: patron = provsec who appointed you
  * left-censoring is an issue; need to observe their first year in office
egen provsec_id = group(provleader_name1)
gen patron_temp = provsec_id if _seq==1
egen patron = max(patron_temp), by(idpref)
gen patron_connection = (patron==provsec_id) if missing(patron)==0
replace patron_connection=. if missing(provsec_id)

gen subprovincial = inlist(prefcode,2201,5101,2102,4401,3301,2301,3701,3201,3302,3702,2101,4403,4201,6101,3502)

*------------------------------------------------------------------------
*** merge with gdp data
merge 1:1 prefcode year using "$data/prefecture.dta"
*drop if _m==2
rename _m merge_helena

merge 1:1 prefcode year using "$raw_data/ceic.dta"
*drop if _m==2
rename _m merge_ceic

tostring prefcode, gen( prefstring )
gen pcode = substr(prefstring,1,2)
destring pcode, replace
drop provcode
rename pcode provcode
drop prefstring

sort prefcode year
bysort prefcode (pref) : replace pref = pref[_N] if missing(pref)
sort prefcode year
bysort prefcode (prefecture) : replace prefecture = prefecture[_N] if missing(prefecture)
replace prefecture = pref if missing(prefecture)
sort prefcode year

* population variable problems
replace rgdppcgrowth = . if prefcode==4409 & year==2001
replace rgdppcgrowth = . if prefcode==4228 & year==2001
replace rgdppcgrowth = . if prefcode==5118 & year==2000
replace rgdppcgrowth = . if prefcode==5306 & year==1999
replace rgdppcgrowth = . if prefcode==5308 & year==1999
replace rgdppcgrowth = . if prefcode==5323 & year==2003
replace rgdppcgrowth = . if prefcode==5328 & year==2004
replace rgdppcgrowth = . if prefcode==5329 & year==2003
replace rgdppcgrowth = . if prefcode==5331 & year==2004

* manually calculate relative real gdp growth
egen prov_growth = mean(rgdpgrowth), by(provcode year)
egen prov_growth_ceic = mean(rgdpgrowth_ceic), by(provcode year)
egen prov_growth_gold = mean(rgoldgrowth), by(provcode year)
egen prov_growth_pc = mean(rgdppcgrowth), by(provcode year)
egen prov_growth_pc_ceic = mean(rgdppcgrowth_ceic), by(provcode year)
gen rel_growth = rgdpgrowth - prov_growth
gen rel_growth_ceic = rgdpgrowth_ceic - prov_growth_ceic
gen rel_growth_gold = rgoldgrowth - prov_growth_gold
gen rel_growth_pc = rgdppcgrowth - prov_growth_pc
gen rel_growth_pc_ceic = rgdppcgrowth_ceic - prov_growth_pc_ceic

* growth relative to provincial average, where average is calculated excluding observation i
rangestat provgrowth_mi=rgdpgrowth, interval(year 0 9999) excludeself by(provcode year)
gen rel_growth_mi = rgdpgrowth - provgrowth_mi

* average growth from t0 to year T
sort idpref year
bys idpref: gen runsum_gdp = sum(gdpgrowth) if missing(gdpgrowth)==0
bys idpref: gen runsum_rgdp = sum(rgdpgrowth) if missing(rgdpgrowth)==0
bys idpref: gen runsum_rgdppc = sum(rgdppcgrowth) if missing(rgdppcgrowth)==0
bys idpref: gen runsum_gdp_ceic = sum(gdpgrowth_ceic) if missing(gdpgrowth_ceic)==0
bys idpref: gen runsum_rgdp_ceic = sum(rgdpgrowth_ceic) if missing(rgdpgrowth_ceic)==0
bys idpref: gen runsum_rgdppc_ceic = sum(rgdppcgrowth_ceic) if missing(rgdppcgrowth_ceic)==0
bys idpref: gen runsum_relgrowth = sum(rel_growth) if missing(rel_growth)==0
bys idpref: gen runsum_relgrowth_mi = sum(rel_growth_mi) if missing(rel_growth_mi)==0
bys idpref: gen runsum_relgrowth_ceic = sum(rel_growth_ceic) if missing(rel_growth_ceic)==0
bys idpref: gen runsum_relgrowth_pc = sum(rel_growth_pc) if missing(rel_growth_pc)==0
bys idpref: gen runsum_relgrowth_pc_ceic = sum(rel_growth_pc_ceic) if missing(rel_growth_pc_ceic)==0
bys idpref: gen runsum_relgrowth_gold = sum(rel_growth_gold) if missing(rel_growth_gold)==0
gen avg_gdp = runsum_gdp/_seq
gen avg_rgdp = runsum_rgdp/_seq
gen avg_rgdppc = runsum_rgdppc/_seq
gen avg_gdp_ceic = runsum_gdp_ceic/_seq
gen avg_rgdp_ceic = runsum_rgdp_ceic/_seq
gen avg_rgdppc_ceic = runsum_rgdppc_ceic/_seq
gen avg_relgrowth = runsum_relgrowth/_seq
gen avg_relgrowth_mi = runsum_relgrowth_mi/_seq
gen avg_relgrowth_ceic = runsum_relgrowth_ceic/_seq
gen avg_relgrowth_pc = runsum_relgrowth_pc/_seq
gen avg_relgrowth_pc_ceic = runsum_relgrowth_pc_ceic/_seq
gen avg_relgrowth_gold = runsum_relgrowth_gold/_seq
* have to use _seq, not _seqtrue
replace avg_gdp=. if missing(gdpgrowth)
replace avg_rgdp=. if missing(rgdpgrowth)
replace avg_rgdppc=. if missing(rgdppcgrowth)
replace avg_gdp_ceic=. if missing(gdpgrowth_ceic)
replace avg_rgdp_ceic=. if missing(rgdpgrowth_ceic)
replace avg_rgdppc_ceic=. if missing(rgdppcgrowth_ceic)
replace avg_relgrowth=. if missing(rel_growth)
replace avg_relgrowth_mi=. if missing(rel_growth_mi)
replace avg_relgrowth_ceic=. if missing(rel_growth_ceic)
replace avg_relgrowth_pc=. if missing(rel_growth_pc)
replace avg_relgrowth_pc_ceic=. if missing(rel_growth_pc_ceic)
replace avg_relgrowth_gold=. if missing(rel_growth_gold)

* growth relative to predecessor
merge m:1 prefcode idpref2 using "$raw_data/predgrowth.dta"
drop _m
gen avg_relgrowth_relpred = avg_relgrowth - predgrowth
* relative to provincial average and predecessor average
gen avg_growth_relpred = avg_rgdp - predgrowth
* relative to predecessor only

* highest growth in tournament
egen maxgrowther = max(rgdpgrowth), by(provcode year)
gen maxgrowth = (rgdpgrowth == maxgrowther) if missing(rgdpgrowth)==0
* above median growth
egen median_growth = median(rgdpgrowth), by(provcode year)
gen abovemedian_growth = (rgdpgrowth > median_growth) if missing(rgdpgrowth)==0
* quartiles
egen quartile_growth = xtile(rgdpgrowth), n(4) by(provcode year)

sort idpref year
bys idpref: gen runsum_tax = sum(taxgrowth) if missing(taxgrowth)==0
gen avg_tax = runsum_tax/_seq
replace avg_tax=. if missing(taxgrowth)
bys idpref: gen runsum_rev_ceic = sum(revgrowth_ceic) if missing(revgrowth_ceic)==0
gen avg_rev_ceic = runsum_rev_ceic/_seq
replace avg_rev_ceic=. if missing(revgrowth_ceic)

gen post = (year>2012)
gen growthXpost = rgdpgrowth*post
gen avgXpost = avg_rgdp*post

gen lpop = log(pop)
gen lgdp = log(gdp)
gen lrev = log(revenue)
gen lpop_ceic = log(pop_ceic)
gen lgdp_ceic = log(gdp_ceic)
gen lrev_ceic = log(rev_ceic)

gen initlpopper = lpop if _seq==1
egen initlpop = max(initlpopper), by(idpref)
gen initlgdpper = lgdp if _seq==1
egen initlgdp = max(initlgdpper), by(idpref)

replace sex=. if sex==0

keep if inrange(year,1998,2017)
xtset prefcode year

drop if prefcode==1100 | prefcode==1101 | prefcode==1200 | prefcode==1201 | prefcode==3100 | prefcode==5000

replace sex=0 if sex==1
replace sex=1 if sex==2

egen fe_provyear = group(provcode year)

gen edu_code = 1 if educ<=1
replace edu_code = 2 if inrange(educ,2,3)
replace edu_code = 3 if inrange(educ,4,5)
replace edu_code = 4 if educ==6
label define edu_lab 1 "High school" 2 "College" 3 "Master's" 4 "Ph.D."
label values edu_code edu_lab

*** prefecture type
merge 1:1 prefcode year using  "$raw_data/prefecture_type.dta"
drop if _merge==2
drop _merge
* prefecture changes
drop if prefcode==3414 & inrange(year,2012,2017)
  * Chaohu split in Aug, 2011; demoted from PLC
drop if prefcode==6405 & inrange(year,1997,2002)
  * Zhongwei upgraded from CLC in 2003
drop if prefcode==4604 & inrange(year,1998,2014)
  * Danzhou upgraded from CLC in 2015
    * shouldn't be in the data until 2015
drop if prefcode==4213 & inrange(year,1998,1999)
  * Suizhou upgraded from CLC in 2000
drop if prefcode==3416 & inrange(year,1998,1999)
  * Bozhou upgraded from CLC in 2000
drop if prefcode==4603
  * small Hainan island with ~zero population

gen preftype = 1 if pref_type_code==3
replace preftype=1 if pref_type_code==6
replace preftype=1 if pref_type_code==5
replace preftype=2 if pref_type_code==4
replace preftype=3 if pref_type_code==1|pref_type_code==2

*** provincial growth targets
merge m:1 provcode year using "$raw_data/prov_target.dta"
drop _merge
gen abovetarget = (avg_rgdp>target/100) if missing(rgdpgrowth)==0
* targets are set using real GDP

gen dist_target = avg_rgdp - target/100 if missing(rgdpgrowth)==0
gen abovetarget5 = (dist_target>=0.05) if missing(dist_target)==0
gen abovetarget3 = (dist_target>=0.03) if missing(dist_target)==0
gen abovetarget2 = (dist_target>=0.02) if missing(dist_target)==0

drop if missing(idpref)
xtset idpref year
gen above2x = (abovetarget==1 & L.abovetarget==1) if missing(rgdpgrowth)==0
gen above3x = (abovetarget==1 & L.abovetarget==1 & L2.abovetarget==1) if missing(rgdpgrowth)==0
gen below2x = (abovetarget==0 & L.abovetarget==0) if missing(rgdpgrowth)==0
gen below3x = (abovetarget==0 & L.abovetarget==0 & L2.abovetarget==0) if missing(rgdpgrowth)==0

replace prefid = prefcode*100

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
lab var prov_conn_pref "Hometown (prefecture)"
lab var prov_conn_prov "Hometown (province)"
lab var prov_conn_school "School"

save "$data/promotion_national.dta", replace