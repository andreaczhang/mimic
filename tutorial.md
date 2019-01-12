# MIMIC tutorial

## SQL for this dataset 

https://github.com/MIT-LCP/mimic-code/blob/master/tutorials/sql-intro.md

This should help me getting started, at least more tuned for this specific dataset. https://mimic.physionet.org/mimictables/admissions/ for the description of each table



### 1. admissions 

`hadm_id` is the unique admission, corresponding to a patient using `subject_id`. Possible to have multiple `subject_id` with different `hadm_id` for several visits. 

links to <u>patients</u> table. 



### 2. chartevents

`value` is a string, and `valuenum` is a numeric. When querying aggregated value must use `MAX(valuenum)`, for example. 



it is important to notice that there can be multiple ICU stays: we need to decide which one we want to keep. 





It is possible to cerate materialised view of the output. 





## Arterial line study

https://github.com/MIT-LCP/mimic-code/blob/master/notebooks/aline/aline.ipynb

One step closer to really getting the data ready 

