This repository contains data and Stata .do files for my [paper](https://michaelwiebe.com/assets/ch1.pdf) "Does meritocratic promotion explain China’s growth?", which was Chapter 1 of my [dissertation](https://open.library.ubc.ca/soa/cIRcle/collections/ubctheses/24/items/1.0395341).

To rerun the analyses, run the file `run.do` using Stata (version 16).
Note that you need to set the path in `run.do` on line 2, to define the location of the folder that contains this README.
Required Stata packages are included in 'code/libraries/stata/', so that the user does not have to download anything and the replication can be run offline.
The file `code/_config.do` tells Stata to load packages from this location.

Figures and tables are saved in 'output/'; that directory is created by `code/_config.do`.

List of data files:
- promotion_national.dta is the main dataset on prefecture mayors
- prefecture.dta is prefecture characteristics for 1991-2019

The raw data is included in 'data/raw_data/'.
The data dictionary for the promotion data (city_full_v14.xlsx) is data/raw_data/dictionary.docx.

I include data on prefecture secretaries from other papers:
- prefecture_panel.dta is from Chen and Kung (2019)
- prefecture_leaders.dta is from James Kung
- Leader_Long.dta is from Yao and Zhang (2015)
- promotion.csv is from Li et al. (2019)
- CHN_Fiscal_Promtn_Data_Pref.dta is from Landry et al. (2019)
