clear
use "$data/promotion_national.dta"

lab var rgdpgrowth "Annual GDP growth"
lab var rel_growth "Average relative growth"
lab var lgdp "Log GDP"
lab var lpop "Log population"
lab var promotion2 "Promotion"
lab var age "Age"
lab var sex "Sex"
lab var edu_code "Education"
lab var tenure "Tenure"
lab var arrested_dummy "Arrested"
lab var home_pref "Home prefecture"
lab var patron_connection "Political connection"

* use estimation sample
reghdfe promotion2 avg_relgrowth, ab(provcode#year) vce(cl prefcode)

estpost tabstat rgdpgrowth rel_growth lgdp lpop promotion2 age sex edu_code tenure arrested_dummy home_pref patron_connection  if e(sample)==1, s(mean p50 min max count) columns(statistics)
esttab ., cells("mean(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2)) count(fmt(0))") nonumbers replace label
esttab . using "$tables/summary_stats.tex", cells("mean(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2)) count(fmt(0))") nonumbers replace label
