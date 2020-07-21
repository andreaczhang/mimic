# strings 1-4

############### double check the keywords 
############### drop and create 

# might drop tables altogether before making new! 
# remember to leave out the keyword space, and blank space between queries.


# ------------- 1. create table: cohort

# mp_cohort_1
# requires: ce_1



############ mp_cohort_1 


q1a <- " AS
with rawtable AS (

-- THE RAW TABLE WITH ALL RECORDS, WITH SUBSTANTIAL NULL 
with ce as
(
  select icustay_id
    , min(charttime) as intime_hr
    , max(charttime) as outtime_hr
  from " 
  
########### ce_1 
  
q1b <- " where itemid in (211,220045)   -- ###### measurement of heartrate (exclude if without)
  group by icustay_id
)
select
    ie.subject_id, ie.hadm_id, ie.icustay_id
  , ce.intime_hr as intime
  , ce.outtime_hr as outtime
  , round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) as age
  , pat.gender
  , adm.ethnicity

  -- outcomes
  , adm.HOSPITAL_EXPIRE_FLAG
  , case when pat.dod <= adm.admittime + interval '30' day then 1 else 0 end
      as THIRTYDAY_EXPIRE_FLAG
  , ie.los as icu_los
  , extract(epoch from (adm.dischtime - adm.admittime))/60.0/60.0/24.0 as hosp_los
  , ceil(extract(epoch from (adm.deathtime - ce.intime_hr))/60.0/60.0) as deathtime_hours

-- exclusions
, case when round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) <= 16 then 1 else 0 end as exclusion_adult
, case when adm.HAS_CHARTEVENTS_DATA = 0 then 1
       when ie.intime is null then 1
       when ie.outtime is null then 1
       when ce.intime_hr is null then 1
       when ce.outtime_hr is null then 1
    else 0 end as exclusion_valid_data
, case
    when (ce.outtime_hr-ce.intime_hr) <= interval '4' hour then 1
  else 0 end as exclusion_short_stay
  
-- organ donor accounts
, case when (
       (lower(diagnosis) like '%organ donor%' and deathtime is not null)
    or (lower(diagnosis) like '%donor account%' and deathtime is not null)
  ) then 1 else 0 end as exclusion_organ_donor

-- the above flags are used to summarize patients excluded
-- below flag is used to actually exclude patients in future queries
, case  when round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) <= 16 then 1
        when adm.HAS_CHARTEVENTS_DATA = 0 then 1
        when ie.intime is null then 1
        when ie.outtime is null then 1
        when ce.intime_hr is null then 1
        when ce.outtime_hr is null then 1
        when (ce.outtime_hr-ce.intime_hr) <= interval '4' hour then 1
        when ((lower(diagnosis) like '%organ donor%' and deathtime is not null)
            or (lower(diagnosis) like '%donor account%' and deathtime is not null)) then 1
      else 0 end as excluded
from icustays ie
inner join admissions adm
  on ie.hadm_id = adm.hadm_id
inner join patients pat
  on ie.subject_id = pat.subject_id
left join ce
  on ie.icustay_id = ce.icustay_id 
order by ie.icustay_id )

-- THEN SELECT FROM THE RAW TABLE WITH ONLY VALID INTIME
SELECT * FROM rawtable
WHERE intime IS NOT NULL
;

"




# ------------- 1.2 create table: hourly cohort 
# requires: mp_cohort_1

# CREATE TABLE  
############ mp_hourly_cohort_1

q1c <- " as
select
  co.subject_id, co.hadm_id, co.icustay_id
  -- create integers for each charttime in hours from admission
  -- so 0 is admission time, 1 is one hour after admission, etc, up to ICU disch
  , generate_series
  (
    -- allow up to 24 hours before ICU admission (to grab labs before admit)
    -24,
    ceil(extract(EPOCH from outtime-intime)/60.0/60.0)::INTEGER
  ) as hr
from "

############# mp_cohort_1 

q1d <- " co
where co.excluded = 0
order by co.subject_id, co.hadm_id, co.icustay_id;
"








# -------------- 2. blood gas 


# CREATE TABLE
########### mp_bg_1

q2a <- " as
select le.hadm_id, le.charttime
, max(case when itemid = 50800 then value else null end) as SPECIMEN
, avg(case when itemid = 50801 and valuenum > 0 then valuenum else null end) as AADO2
, avg(case when itemid = 50802 and valuenum > 0 then valuenum else null end) as BASEEXCESS
, avg(case when itemid = 50803 and valuenum > 0 then valuenum else null end) as BICARBONATE
, avg(case when itemid = 50804 and valuenum > 0 then valuenum else null end) as TOTALCO2
, avg(case when itemid = 50805 and valuenum > 0 then valuenum else null end) as CARBOXYHEMOGLOBIN
, avg(case when itemid = 50806 and valuenum > 0 then valuenum else null end) as CHLORIDE
, avg(case when itemid = 50808 and valuenum > 0 then valuenum else null end) as CALCIUM
, avg(case when itemid = 50809 and valuenum > 0 then valuenum else null end) as GLUCOSE
, avg(case when itemid = 50810 and valuenum <= 100 then valuenum else null end) as HEMATOCRIT
, avg(case when itemid = 50811 and valuenum > 0 then valuenum else null end) as HEMOGLOBIN
, max(case when itemid = 50812 then value else null end) as INTUBATED
, avg(case when itemid = 50813 and valuenum > 0 then valuenum else null end) as LACTATE
, avg(case when itemid = 50814 and valuenum > 0 then valuenum else null end) as METHEMOGLOBIN
, avg(case when itemid = 50815 and valuenum > 0 and valuenum <=  70 then valuenum else null end) as O2FLOW
, avg(case when itemid = 50816 and valuenum > 0 and valuenum <= 100 then valuenum else null end) as FIO2
, avg(case when itemid = 50817 and valuenum > 0 and valuenum <= 100 then valuenum else null end) as SO2 -- OXYGENSATURATION
, avg(case when itemid = 50818 and valuenum > 0 then valuenum else null end) as PCO2
, avg(case when itemid = 50819 and valuenum > 0 then valuenum else null end) as PEEP
, avg(case when itemid = 50820 and valuenum > 0 then valuenum else null end) as PH
, avg(case when itemid = 50821 and valuenum <= 800 then valuenum else null end) as PO2
, avg(case when itemid = 50822 and valuenum > 0 then valuenum else null end) as POTASSIUM
, avg(case when itemid = 50823 and valuenum > 0 then valuenum else null end) as REQUIREDO2
, avg(case when itemid = 50824 and valuenum > 0 then valuenum else null end) as SODIUM
, avg(case when itemid = 50825 and valuenum > 0 then valuenum else null end) as TEMPERATURE
, avg(case when itemid = 50826 and valuenum > 0 then valuenum else null end) as TIDALVOLUME
, avg(case when itemid = 50827 and valuenum > 0 then valuenum else null end) as VENTILATIONRATE
, avg(case when itemid = 50828 and valuenum > 0 then valuenum else null end) as VENTILATOR
from labevents le
where le.ITEMID in
-- blood gases
(
    50800, 50801, 50802, 50803, 50804, 50805, 50806, 50807, 50808, 50809
  , 50810, 50811, 50812, 50813, 50814, 50815, 50816, 50817, 50818, 50819
  , 50820, 50821, 50822, 50823, 50824, 50825, 50826, 50827, 50828
  , 51545
)
group by le.hadm_id, le.charttime
-- remove observations if there is more than one specimen listed
-- we do not know whether these are arterial or mixed venous, etc...
having count(case when itemid = 50800 then value else null end)<2;
"







# -------------- 2.2 blood gas art
# REQUIRES CE_1, MP_COHORT_1, MP_BG_1


# CREATE TABLE 
############# mp_bg_art_1 


q2b <- " AS
with stg_spo2 as
(
  select HADM_ID, CHARTTIME
    -- max here is just used to group SpO2 by charttime
    , avg(valuenum) as SpO2
  from "
  
############ ce_1

q2c <- " where ITEMID in
  (
    646 -- SpO2
  , 220277 -- O2 saturation pulseoxymetry
  )
  and valuenum > 0 and valuenum <= 100
  group by HADM_ID, CHARTTIME
)
, stg_fio2 as
(
  select HADM_ID, CHARTTIME
    -- pre-process the FiO2s to ensure they are between 21-100%
    , max(
        case
          when itemid = 223835
            then case
              when valuenum > 0 and valuenum <= 1
                then valuenum * 100
              -- improperly input data - looks like O2 flow in litres
              when valuenum > 1 and valuenum < 21
                then null
              when valuenum >= 21 and valuenum <= 100
                then valuenum
              else null end -- unphysiological
        when itemid in (3420, 3422)
        -- all these values are well formatted
            then valuenum
        when itemid = 190 and valuenum > 0.20 and valuenum < 1
        -- well formatted but not in %
            then valuenum * 100
      else null end
    ) as fio2_chartevents
  from "
  
############ ce_1
  
q2d <- " where ITEMID in
  (
    3420 -- FiO2
  , 190 -- FiO2 set
  , 223835 -- Inspired O2 Fraction (FiO2)
  , 3422 -- FiO2 [measured]
  )
  and valuenum > 0 and valuenum < 100
  -- exclude rows marked as error
  and error IS DISTINCT FROM 1
  group by HADM_ID, CHARTTIME
)
, stg2 as
(
select bg.*
  , ceil(extract(EPOCH from bg.charttime-co.intime)/60.0/60.0)::smallint as hr
  , ROW_NUMBER() OVER (partition by bg.hadm_id, bg.charttime order by s1.charttime DESC) as lastRowSpO2
  , s1.spo2
from " 

############## mp_bg_1


q2e <- " bg
inner join "

############### mp_cohort_1 


q2f <- " co
  on bg.hadm_id = co.hadm_id
  and co.excluded = 0
left join stg_spo2 s1
  -- same hospitalization
  on  bg.hadm_id = s1.hadm_id
  -- spo2 occurred at most 2 hours before this blood gas
  and s1.charttime between bg.charttime - interval '2' hour and bg.charttime
where bg.po2 is not null
)
, stg3 as
(
select bg.*
  , ROW_NUMBER() OVER (partition by bg.hadm_id, bg.charttime order by s2.charttime DESC) as lastRowFiO2
  , ROW_NUMBER() over (partition by bg.hadm_id, bg.hr order by bg.charttime DESC) as lastRowInHour
  , s2.fio2_chartevents

  -- create our specimen prediction
  ,  1/(1+exp(-(-0.02544
  +    0.04598 * po2
  + coalesce(-0.15356 * spo2             , -0.15356 *   97.49420 +    0.13429)
  + coalesce( 0.00621 * fio2_chartevents ,  0.00621 *   51.49550 +   -0.24958)
  + coalesce( 0.10559 * hemoglobin       ,  0.10559 *   10.32307 +    0.05954)
  + coalesce( 0.13251 * so2              ,  0.13251 *   93.66539 +   -0.23172)
  + coalesce(-0.01511 * pco2             , -0.01511 *   42.08866 +   -0.01630)
  + coalesce( 0.01480 * fio2             ,  0.01480 *   63.97836 +   -0.31142)
  + coalesce(-0.00200 * aado2            , -0.00200 *  442.21186 +   -0.01328)
  + coalesce(-0.03220 * bicarbonate      , -0.03220 *   22.96894 +   -0.06535)
  + coalesce( 0.05384 * totalco2         ,  0.05384 *   24.72632 +   -0.01405)
  + coalesce( 0.08202 * lactate          ,  0.08202 *    3.06436 +    0.06038)
  + coalesce( 0.10956 * ph               ,  0.10956 *    7.36233 +   -0.00617)
  + coalesce( 0.00848 * o2flow           ,  0.00848 *    7.59362 +   -0.35803)
  ))) as SPECIMEN_PROB
from stg2 bg
left join stg_fio2 s2
  -- same patient
  on  bg.hadm_id = s2.hadm_id
  -- fio2 occurred at most 4 hours before this blood gas
  and s2.charttime between bg.charttime - interval '4' hour and bg.charttime
  and s2.fio2_chartevents > 0
where bg.lastRowSpO2 = 1 -- only the row with the most recent SpO2 (if no SpO2 found lastRowSpO2 = 1)
)

select
  stg3.hadm_id
  , stg3.charttime
  , stg3.hr
  , SPECIMEN -- raw data indicating sample type, only present 80% of the time
  -- prediction of specimen for missing data
  , case
        when SPECIMEN is not null then SPECIMEN
        when SPECIMEN_PROB > 0.75 then 'ART'
      else null end as SPECIMEN_PRED
  , SPECIMEN_PROB

  -- oxygen related parameters
  , SO2, spo2 -- note spo2 is from chartevents
  , PO2, PCO2
  , fio2_chartevents, FIO2
  , AADO2
  -- also calculate AADO2
  , case
      when  PO2 is not null
        and pco2 is not null
        and coalesce(FIO2, fio2_chartevents) is not null
       -- multiple by 100 because FiO2 is in a % but should be a fraction
        then (coalesce(FIO2, fio2_chartevents)/100) * (760 - 47) - (pco2/0.8) - po2
      else null
    end as AADO2_calc
  , case
      when PO2 is not null and coalesce(FIO2, fio2_chartevents) is not null
       -- multiply by 100 because FiO2 is in a % but should be a fraction
        then 100*PO2/(coalesce(FIO2, fio2_chartevents))
      else null
    end as PaO2FiO2Ratio
  -- acid-base parameters
  , PH, BASEEXCESS
  , BICARBONATE, TOTALCO2

  -- blood count parameters
  , HEMATOCRIT
  , HEMOGLOBIN
  , CARBOXYHEMOGLOBIN
  , METHEMOGLOBIN

  -- chemistry
  , CHLORIDE, CALCIUM
  , TEMPERATURE
  , POTASSIUM, SODIUM
  , LACTATE
  , GLUCOSE

  -- ventilation stuff that's sometimes input
  , INTUBATED, TIDALVOLUME, VENTILATIONRATE, VENTILATOR
  , PEEP, O2Flow
  , REQUIREDO2
from stg3
where lastRowFiO2 = 1 -- only the most recent FiO2
and lastRowInHour = 1 -- only the most recent row for the hour
-- restrict it to *only* arterial samples
and (SPECIMEN = 'ART' or SPECIMEN_PROB > 0.75)
order by hadm_id, hr;
"






# -------------- 3. code_status
# REQUIRES mp_cohort_1, ce_1


# CREATE TABLE 
############# mp_code_status_1 

q3a <- " AS
WITH code_status_all AS (

with t1 as
(
  select icustay_id, charttime
  -- coalesce the values
  , max(case
      when value in ('Full Code','Full code') then 1
    else 0 end) as FullCode
  , max(case
      when value in ('Comfort Measures','Comfort measures only') then 1
    else 0 end) as CMO
  , max(case
      when value = 'CPR Not Indicate' then 1
    else 0 end) as DNCPR -- only in CareVue, i.e. only possible for ~60-70% of patients
  , max(case
      when value in ('Do Not Intubate','DNI (do not intubate)','DNR / DNI') then 1
    else 0 end) as DNI
  , max(case
      when value in ('Do Not Resuscita','DNR (do not resuscitate)','DNR / DNI') then 1
    else 0 end) as DNR
  from "
  
############ CE_1
  
  
q3b <- " where itemid in (128, 223758)
  and value is not null
  and value != 'Other/Remarks'
  -- exclude rows marked as error
  AND error IS DISTINCT FROM 1
  group by icustay_id, charttime
)
-- examine the notes to determine if they were ever made cmo


, nnote as
(
  select
    hadm_id, charttime
    , max(case
        when substring(text from 'made CMO') != '' then 1
        when substring(lower(text) from 'cmo ordered') != '' then 1
        when substring(lower(text) from 'pt. is cmo') != '' then 1
        when substring(text from 'Code status:([ \r\n]+)Comfort measures only') != '' then 1
        --when substring(text from 'made CMO') != '' then 1
        --when substring(substring(text from '[^E]CMO') from 2 for 3) = 'CMO'
        --  then 1
        else 0
      end) as CMO
  from noteevents ne
  where category in ('Nursing/other','Nursing','Physician')
  and lower(text) like '%cmo%'
  group by hadm_id, charttime
)



select ie.subject_id
  , ie.hadm_id
  , ie.icustay_id

  , t1.charttime

  , t1.FullCode
  , t1.CMO
  , t1.DNR
  , t1.DNI
  , t1.DNCPR

  , 0 as CMO_notes
from icustays ie
left join t1
  on ie.icustay_id = t1.icustay_id


UNION
select ie.subject_id
  , ie.hadm_id
  , ie.icustay_id

  , nn.charttime

  , 0 as FullCode
  , 0 as CMO
  , 0 as DNR
  , 0 as DNI
  , 0 as DNCPR

  , nn.CMO as CMO_notes
from icustays ie
inner join nnote nn
  on ie.hadm_id = nn.hadm_id
  and nn.charttime between ie.intime and ie.outtime 
ORDER BY icustay_id, charttime)


SELECT * FROM code_status_all
WHERE subject_id IN (
  SELECT subject_id FROM " 

############# mp_cohort_1
 
q3c <-  "
)
;
"




# ------------------ 4. colloid-bolus
# REQUIRES MP_COHORT_1, CE_1

# CREATE TABLE 
########### mp_colloid_bolus_1 

q4a <- " AS
with t1 as
(
  select
    co.icustay_id
  , ceil(extract(EPOCH from mv.starttime-co.intime)/60.0/60.0)::smallint as hr
  -- standardize the units to millilitres
  -- also metavision has floating point precision.. but we only care down to the mL
  , round(case
      when mv.amountuom = 'L'
        then mv.amount * 1000.0
      when mv.amountuom = 'ml'
        then mv.amount
    else null end) as amount
  from "
############# mp_cohort_1 
  
  
q4b <- " co
  inner join inputevents_mv mv
  on co.icustay_id = mv.icustay_id
  and mv.itemid in
  (
    220864, --	Albumin 5%	7466 132 7466
    220862, --	Albumin 25%	9851 174 9851
    225174, --	Hetastarch (Hespan) 6%	82 1 82
    225795,  --	Dextran 40	38 3 38
    225796 --  Dextran 70
    -- below ITEMIDs not in use
   -- 220861 | Albumin (Human) 20%
   -- 220863 | Albumin (Human) 4%
  )
  where mv.statusdescription != 'Rewritten'
  and
  -- in MetaVision, these ITEMIDs never appear with a null rate
  -- so it is sufficient to check the rate is > 100
    (
      (mv.rateuom = 'mL/hour' and mv.rate > 99)
      OR (mv.rateuom = 'mL/min' and mv.rate > (99/60.0))
      OR (mv.rateuom = 'mL/kg/hour' and (mv.rate*mv.patientweight) > 99)
    )
)
, t2 as
(
  select
    co.icustay_id
  , ceil(extract(EPOCH from cv.charttime-co.intime)/60.0/60.0)::smallint as hr
  -- carevue always has units in millilitres (or null)
  , round(cv.amount) as amount
  from "
  
############ mp_cohort_1 
  
q4c <- " co
  inner join inputevents_cv cv
  on co.icustay_id = cv.icustay_id
  and cv.itemid in
  (
   30008 --	Albumin 5%
  ,30181 -- Serum Albumin 5%
  ,40548 --	ALBUMIN
  ,45403 --	albumin
  ,46564 -- Albumin
  ,44203 --	Albumin 12.5%
  ,42832 --	albumin 12.5%
  ,43237 -- 25% Albumin
  ,43353 -- Albumin (human) 25%
  ,30009 --	Albumin 25%

  ,30012 --	Hespan
  ,46313 --	6% Hespan

  ,30011 -- Dextran 40
  ,40033 --	DEXTRAN
  ,42731 -- Dextran40 10%
  ,42975 --	DEXTRAN DRIP
  ,42944 --	dextran
  ,46336 --	10% Dextran 40/D5W
  ,46729 --	Dextran
  ,45410 --	10% Dextran 40
  )
  where cv.amount > 99
  and cv.amount < 2000
)
-- some colloids are charted in chartevents
, t3 as
(
  select
    co.icustay_id
  , ceil(extract(EPOCH from ce.charttime-co.intime)/60.0/60.0)::smallint as hr
  -- carevue always has units in millilitres (or null)
  , round(ce.valuenum) as amount
  from "
  

############# mp_cohort_1 
  
  
q4d <- " co
  inner join "

############3 CE_1 
  
q4e <- " ce
  on co.icustay_id = ce.icustay_id
  and ce.itemid in
  (
      2510 --	DEXTRAN LML 10%
    , 3087 --	DEXTRAN 40  10%
    , 6937 --	Dextran
    , 3087 -- | DEXTRAN 40  10%
    , 3088 --	DEXTRAN 40%
  )
  where ce.valuenum is not null
  and ce.valuenum > 99
  and ce.valuenum < 2000
)
select
    icustay_id
  , hr
  , sum(amount) as colloid_bolus
from t1
-- just because the rate was high enough, does *not* mean the final amount was
where amount > 99
group by t1.icustay_id, t1.hr
UNION
select
    icustay_id
  , hr
  , sum(amount) as colloid_bolus
from t2
group by t2.icustay_id, t2.hr
UNION
select
    icustay_id
  , hr
  , sum(amount) as colloid_bolus
from t3
group by t3.icustay_id, t3.hr
order by icustay_id, hr;
"




