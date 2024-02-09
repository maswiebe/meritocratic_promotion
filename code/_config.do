* Ensure Stata uses only local libraries and programs
tokenize `"$S_ADO"', parse(";")
while `"`1'"' != "" {
  if `"`1'"'!="BASE" cap adopath - `"`1'"'
  macro shift
}
adopath ++ "$root/code/libraries/stata"

* load packages
include "$root/code/libraries/stata/s/speccurve.do"

* create directories
cap mkdir "$root/output"
cap mkdir "$root/output/figures"
cap mkdir "$root/output/tables"
