> The subcohort extraction is based on the cohorts created by Johnson reproducible study.

# General guidelines

For each cohort's inclusion criteria, refer to https://github.com/alistairewj/reproducibility-mimic/blob/master/notebooks/reproducibility.ipynb

It is necessary to create cohort-specific inclusion strings, for example, sepsis cohort and AKI cohort needs their own inclusion criteria. 









### Ripoll 2014 sepsis cohort

After the above steps, we get 2 very important tables: `mp_data` and `mp_cohort`. (In the prototype all tables end with `_1`. )

The time series table `mp_data` still has large amount of missing in the less measured features. Now use the idea of Ripoll 2014, produce one condensed table that is less missing.  



Inclusion_only_mimicii

inclusion_has_saps

inclusion_not_explicit_sepsis

inclusion_over_18



2250 patients. 

`~/Documents/Data/Project2/Ripoll2014/cohortTSAll.csv` contains all the time series data

`~/Documents/Data/Project2/Ripoll2014/cohortInfoAll.csv` contains the death information associated. 





