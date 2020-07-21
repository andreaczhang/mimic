> Use the query produced by Johnson 2017
>
> https://github.com/alistairewj/reproducibility-mimic

### Demo data: Reproduce Ripoll 2014 sepsis cohort 

https://github.com/alistairewj/reproducibility-mimic/blob/master/notebooks/reproducibility.ipynb

#### Produced tables for extraction:

`dm_cohort`: contains cohort static information and their flags of whether to include for study. Needed for cohort filtering and extraciton. Saved into **co**. 

`mp_data`: actual ts data with hourly records. saved into **df**. 

death information: queried from `dm_cohort` and admissions. saved into **df_death**.

censoring information (?)

*Save them into csv for now.* `~/Data/mimicJcode/`. 





# Instructions for code adaptation

> Note that we have NOT used static in our models.
>
> `COHORT-ALL/` is an R adaptation based on `individualQueries/`, what it does is to split the original SQL code into R chunks to be fed into loops, for easier monitoring. 

`make_all.sql` contains information for running the individual queries to produce the dataset. 



1. Height and weight first day (from mimic concept firstday, downloaded locally as `heigh-first-day.sql, weight-first-day.sql`). Needed for static_data, <span style = 'color:tomato'>Not yet </span>

2. inside mortality prediction (mp) folder:
   - `cohort.sql`, `hourly-cohort.sql`: the original ce is too big, alternative is to **do everything on the first cohort**, then merge together. `1cohort_1.sql`, result in table mp_cohort_1, mp_hourly_cohort_1. 
   - `bg.sql` blood gases and chemistry values in LABEVENTS. Creates **mp_bg**, **mp_bg_art**.
   - `colloid-bolus.sql` 
   - `crystalloid-bolus.sql` 
   - `gcs.sql`
   - `lab.sql` looks rather similar to what we already have. Yet, make again
   - `static_data.sql`  <span style = 'color:tomato'>Not yet </span>
   - `uo.sql`
   - `vital.sql`

Then finally, `data.sql` to get all the dynamic data. This produces the table **mp_data**. 

3. For the corresponding cohort information, need the other tables: (note I have changed dm into mp for readability)
   - `mp_intime_outtime`
   - `mp_service`
   - `mp_obs_count`

DO NOT NEED `dm_word_count`, `braindeath`, 

4. `final_cohort.sql`. 



NOTE: 

- the `static_data` is for constructing features for the logistic regression. We do not use it now because we don't want to add static features in our study. 

- `mp_bg_*`  are all the same, as it only queries from labevents. It does not need to be recreated all the time - but for the time being just let it be.. 

 

## Pipeline (for each of the 50 CE subgroups)

The pipeline constitutes the following elements: 

- files containing R queries in string format (`JqueryStrings1-4, 5-8, 9-13, 14.R`). These are to be fed into the functions for loops 
- Helper function `helpers-1-Rquery.R`, with the following functions
  - `createQueryJ`: create queries for preparation tables. 
  - `runQueryJ`: First drops existed tables, then runs the queries created above. 
  - `createQueryFinalCohort`: create query for the final cohort. 
  - `runQueryFinalCohort`: runs queries created for final cohort. 
  - `exportTScsv`, `exportFCcsv`: export the final csv files to specified paths.



speed: creating tables takes 2.3 min; 10 ce takes 25 min. 



### extraction after creating preparation tables: 

2 tables: 

- death information 
- time series data





## SAVED DATA

### For the whole database (all patient, not only this study)

`~/Documents/Data/MIMICJohnson/TimeSeries/TS_*.csv` files. They contain time series all 50 sub cohorts, each one has circa 1 million rows of hourly records. (1.25 G in total)

`~/Documents/Data/MIMICJohnson/FinalCohort/FC_*.csv`. They contain static information for all 50 sub cohorts. 


