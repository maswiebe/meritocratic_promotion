* https://github.com/hhsievertsen/speccurve/blob/master/spec_curve_demo.do

*** program
clear
cap program drop specchart
program specchart
syntax varlist, [replace] spec(string)
	* save current data
	tempfile temp
	save "`temp'",replace
	*dataset to store estimates
	if "`replace'"!=""{
			clear
			gen beta=.
			gen se=.
			gen spec_id=.
			gen u95=.
			gen u90=.
			gen l95=.
			gen l90=.
			save "estimates.dta",replace
	}
	else{
		* load dataset
		use "estimates.dta",clear
	}
	* add observation
	local obs=_N+1
	set obs `obs'
	replace spec_id=`obs' if _n==`obs'
	* store estimates
	replace beta =_b[`varlist'] if  spec_id==`obs'
	replace se=_se[`varlist']   if  spec_id==`obs'
	replace u95=beta+invt(e(df_r),0.975)*se if  spec_id==`obs'
	replace u90=beta+invt(e(df_r),0.95)*se if  spec_id==`obs'
	replace l95=beta-invt(e(df_r),0.975)*se  if  spec_id==`obs'
	replace l90=beta-invt(e(df_r),0.95)*se  if  spec_id==`obs'
	* store specification
	foreach s in `spec'{
		cap gen `s'=1 			if  spec_id==`obs'
		cap replace `s'=1 		 if  spec_id==`obs'
	}
		save "estimates.dta",replace
	* restore dataset
	use `temp',clear
end
