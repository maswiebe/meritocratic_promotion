* set path: uncomment the following line and set the filepath for the folder containing this run.do file
*global root "[location of replication archive]"
global raw_data "$root/data/raw_data"
global data "$root/data"
global code "$root/code"
global tables "$root/output/tables"
global figures "$root/output/figures"

* Stata version control
version 16

* configure library environment
do "$code/_config.do"

*** clean the raw data
do "$code/cleaning.do"

*** results
* summary statistics
do "$code/summary.do"

* main regressions
do "$code/main_results.do"

* robustness checks
    * specification curve, adding covariates, first-year mayors, measures of growth
do "$code/robust.do"

* heterogeneity
    * region, era, year, growth target, prefecture type, autonomous regions
do "$code/het.do"

* political connections
do "$code/connections.do"

* SO2 and PM2.5
do "$code/pollution.do"

* corruption
do "$code/corruption.do"

* prefecture secretaries
do "$code/secretaries.do"
