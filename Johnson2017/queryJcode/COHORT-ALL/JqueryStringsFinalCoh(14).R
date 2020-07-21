# strings 14-16
# these are slightly different: final filtering and extraction 



# ---------------- 14. final_cohort
############ final_cohort_1

q14a <- " AS
WITH FINAL_COHORT_TOTAL AS (
with tr as
(
select hadm_id, icustay_id, intime, outtime, curr_careunit
, ROW_NUMBER() over (partition by hadm_id order by intime desc) as rn
from transfers
where outtime is not null
)
, ds as
(
  select distinct hadm_id
  from noteevents
  where category = 'Discharge summary'
)
, fullcode as
(

  select
      icustay_id
    , max(FullCode) as fullcode
    , max(case when CMO=1 then 1 else 0 end) as cmo 
    , max(DNR) as dnr
    , max(DNI) as dni
    , max(DNCPR) as dncpr
  from "
  
############ mp_code_status_1
  
q14b <-  " group by icustay_id
)
, bg4days as
(
  select ce.icustay_id
    , min(PaO2FiO2Ratio) as pao2fio2ratio_min
  from "
  
  ############ MP_INTIME_OUTTIME_1
  
q14c <- " ce  
  inner join icustays ie
    on ce.icustay_id = ie.icustay_id
  left join "
  
############ mp_bg_art_1
q14d <- " on ie.hadm_id = "

############ mp_bg_art_1
q14e <- ".hadm_id
    and ce.intime_hr <= "

############ mp_bg_art_1
q14f <- ".charttime
    and ce.outtime_hr >= "
    
############ mp_bg_art_1
q14g <- ".charttime
  group by ce.icustay_id
)

, icd_alc as
(
  select distinct hadm_id
  from diagnoses_icd
  where
     icd9_code like '291%'
  or (icd9_code like '303%' and length(icd9_code)=5)
  or icd9_code like '3050%'
  or icd9_code = '3575'
  or icd9_code = '4255'
  or icd9_code like '5353%'
  or icd9_code = '5712'
  or icd9_code = '5713'
)
, icd_aki as
(
  select distinct hadm_id
  from diagnoses_icd
  where icd9_code = '5849'
)
, icd_sah as
(
  select distinct hadm_id
  from diagnoses_icd
  where icd9_code = '430'
    or icd9_code like '852%'
)
, icd_crf as
(
  select distinct hadm_id
  from diagnoses_icd
  where icd9_code like '585%'
)
, icd_sepsis as
(
  select distinct hadm_id
  from diagnoses_icd
  where icd9_code in ('99592','78552')
)
, cs as
(
    select ce.icustay_id, min(cs.charttime) as censortime
    , ceil(extract(epoch from min(cs.charttime-ce.intime_hr) )/60.0/60.0) as censortime_hours
    from "
    
  ############ mp_intime_outtime_1
    
q14h <- " ce
    inner join "
    
############ mp_code_status_1
    
q14i <-    " cs   
    on ce.icustay_id = cs.icustay_id
    where (cmo+dnr+dni+dncpr)>0
    group by ce.icustay_id
)
select
    ie.subject_id, ie.hadm_id, ie.icustay_id
  , ce.intime_hr as intime
  , ce.outtime_hr as outtime
  , round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) as age
  , pat.gender
  , adm.ethnicity

  , ceil(extract(epoch from (ce.outtime_hr- ce.intime_hr))/60.0/60.0) as dischtime_hours
  , ceil(extract(epoch from (adm.deathtime - ce.intime_hr))/60.0/60.0) as deathtime_hours
  , cs.censortime_hours


  , ie.los as icu_los
  , extract(epoch from (adm.dischtime - adm.admittime))/60.0/60.0/24.0 as hosp_los

  , case
      when adm.deathtime is not null and adm.deathtime <= ce.intime_hr + interval '48' hour
        then 1
      else 0
    end as death_48hr_post_icu_admit
	, case
      when adm.hospital_expire_flag = 1 and tr.outtime is not null
        then 1
      else 0
    end as death_icu
  , adm.HOSPITAL_EXPIRE_FLAG -- keeping this temporarily before refactor
  , adm.HOSPITAL_EXPIRE_FLAG as death_in_hospital
  , case
      when adm.deathtime is not null and adm.deathtime <= ce.intime_hr + interval '30' day
        then 1
      when pat.dod is not null and pat.dod <= ce.intime_hr + interval '30' day
        then 1
      else 0
    end as death_30dy_post_icu_admit
  , case
      when adm.deathtime is not null and adm.deathtime <= ce.outtime_hr + interval '30' day
        then 1
      when pat.dod is not null and pat.dod <= ce.outtime_hr + interval '30' day
        then 1
      else 0
    end as death_30dy_post_icu_disch
  , case
      when adm.deathtime is not null and adm.deathtime <= adm.dischtime + interval '30' day
        then 1
      -- died outside of hospital or during a later readmission to hospital
      when pat.dod is not null and pat.dod <= adm.dischtime + interval '30' day
        then 1
      else 0
    end as death_30dy_post_hos_disch
  -- 6-month post hospital discharge
  , case
      -- died in hospital
      when adm.deathtime is not null and adm.deathtime <= adm.dischtime + interval '6' month
        then 1
      -- died outside of hospital or during a later readmission to hospital
      when pat.dod is not null and pat.dod <= adm.dischtime + interval '6' month
        then 1
      else 0
    end as death_6mo_post_hos_disch
  -- 1-year post hospital discharge
  , case
      -- died in hospital
      when adm.deathtime is not null and adm.deathtime <= adm.dischtime + interval '1' year
        then 1
      -- died outside of hospital or during a later readmission to hospital
      when pat.dod is not null and pat.dod <= adm.dischtime + interval '1' year
        then 1
      else 0
    end as death_1yr_post_hos_disch
  -- 2-year post hospital discharge
  , case
      -- died in hospital
      when adm.deathtime is not null and adm.deathtime <= adm.dischtime + interval '2' year
        then 1
      -- died outside of hospital or during a later readmission to hospital
      when pat.dod is not null and pat.dod <= adm.dischtime + interval '2' year
        then 1
      else 0
    end as death_2yr_post_hos_disch

  , case when pat.dod <= adm.admittime + interval '30' day then 1 else 0 end
      as death_30dy_post_hos_admit

  , case when round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) <= 15
      then 1
    else 0 end as exclusion_over_15
  , case when adm.HAS_CHARTEVENTS_DATA = 0 then 1
         when ie.intime is null then 1
         when ie.outtime is null then 1
         when ce.intime_hr is null then 1
         when ce.outtime_hr is null then 1
      else 0 end as exclusion_valid_data

  , case
      when (ce.outtime_hr-ce.intime_hr) < interval '4' hour then 1
    else 0 end as exclusion_stay_lt_4hr

  -- organ donor accounts
  , case when (
         (lower(diagnosis) like '%organ donor%' and deathtime is not null)
      or (lower(diagnosis) like '%donor account%' and deathtime is not null)
    ) then 1 else 0 end as exclusion_organ_donor

  , case when round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) <= 15 then 1
         when adm.HAS_CHARTEVENTS_DATA = 0 then 1
         when ie.intime is null then 1
         when ie.outtime is null then 1
         when ce.intime_hr is null then 1
         when ce.outtime_hr is null then 1
         when (ce.outtime_hr-ce.intime_hr) <= interval '4' hour then 1
         when lower(diagnosis) like '%organ donor%' and deathtime is not null then 1
         when lower(diagnosis) like '%donor account%' and deathtime is not null then 1
      else 0 end
    as excluded


  , case when round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) > 16
      then 1
    else 0 end as inclusion_over_16
  , case when round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) > 18
      then 1
    else 0 end as inclusion_over_18

  , case
      when (ce.outtime_hr-ce.intime_hr) >= interval '12' hour then 1
    else 0 end as inclusion_stay_ge_12hr
  , case
      when (ce.outtime_hr-ce.intime_hr) >= interval '17' hour then 1
    else 0 end as inclusion_stay_ge_17hr
  , case
      when (ce.outtime_hr-ce.intime_hr) >= interval '24' hour then 1
    else 0 end as inclusion_stay_ge_24hr
  , case
      when (ce.outtime_hr-ce.intime_hr) >= interval '48' hour then 1
    else 0 end as inclusion_stay_ge_48hr
  , case
      when (ce.outtime_hr-ce.intime_hr) < interval '500' hour then 1
    else 0 end as inclusion_stay_le_500hr

  , case when ROW_NUMBER() OVER (partition by ie.hadm_id order by ie.intime) = 1 then 1 else 0 end as inclusion_first_admission

  , case when ie.dbsource = 'carevue' then 1 else 0 end as inclusion_only_mimicii

  , case when ie.first_careunit = 'MICU' then 1 else 0 end as inclusion_only_micu
  , case when icd_alc.hadm_id is not null then 1 else 0 end as inclusion_non_alc_icd9

  , case when icd_aki.hadm_id is not null then 1 else 0 end as inclusion_aki_icd9
  , case when icd_sah.hadm_id is not null then 1 else 0 end as inclusion_sah_icd9

  , case when count(ie.hadm_id) OVER (partition by ie.subject_id) = 1 then 1 else 0 end as inclusion_multiple_hadm

   , case when count(ie.icustay_id) OVER (partition by ie.hadm_id) = 1 then 1 else 0 end as inclusion_multiple_icustay

  , case when serv.service_NMED=1 or serv.service_NSURG=1 or serv.service_TSURG=1 then 0 else 1 end as inclusion_hug2009_proposed_service
   , case when serv.nsicu_chart=1 or serv.csicu_chart=1 then 0 else 1 end as inclusion_hug2009_not_nsicu_csicu
  , case when cmo=1 or dnr=1 or dni=1 or dncpr=1 then 0 else 1 end as inclusion_full_code
  , case when icd_crf.hadm_id is not null then 0 else 1 end as inclusion_not_crf

  , case when ie.dbsource != 'metavision'
          and (serv.medicine_chart=1 or serv.ccu_chart=1 or serv.surg_chart=1 or
               serv.msicu_chart=1 or serv.csru_chart=1)
              then 1
        when ie.dbsource != 'metavision' then 0
        when (serv.service_MED=1 or serv.service_PSURG=1 or serv.service_SURG=1 or
              serv.service_CSURG=1 or serv.service_VSURG=1)
            then 1
        else 0 end
      as inclusion_lee2015_service

   , case when obs.saps_vars > 0 then 1 else 0 end as inclusion_has_saps

   , case when ds.hadm_id is not null then 1 else 0 end as inclusion_no_disch_summary
   , case when icd_sepsis.hadm_id is not null then 1 else 0 end as inclusion_not_explicit_sepsis

  , case when adm.hospital_expire_flag = 0 then 1 else 0 end as inclusion_alive_hos_disch
  , case when round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) > 65
      then 1
    else 0 end as inclusion_over_65

from icustays ie
inner join admissions adm
  on ie.hadm_id = adm.hadm_id
inner join patients pat
  on ie.subject_id = pat.subject_id
left join "

############ mp_intime_outtime_1

q14j <- " ce   
  on ie.icustay_id = ce.icustay_id
left join tr
	on ie.icustay_id = tr.icustay_id
	and tr.rn = 1
left join icd_alc
  on ie.hadm_id = icd_alc.hadm_id
left join icd_aki
  on ie.hadm_id = icd_aki.hadm_id
left join icd_sah
  on ie.hadm_id = icd_sah.hadm_id
left join icd_crf
  on ie.hadm_id = icd_crf.hadm_id
left join icd_sepsis
  on ie.hadm_id = icd_sepsis.hadm_id
--left join dm_word_count wc
  --on ie.hadm_id = wc.hadm_id
--left join dm_number_of_notes dm_nn
  --on ie.hadm_id = dm_nn.hadm_id
left join ds
  on ie.hadm_id = ds.hadm_id
left join "

############ mp_obs_count_1

q14k <- " obs
  on ie.icustay_id = obs.icustay_id
left join fullcode
  on ie.icustay_id = fullcode.icustay_id
-- left join dm_braindeath
  -- on ie.hadm_id = dm_braindeath.hadm_id
left join "
############ MP_SERVICE_1

q14l <- " serv  
  on ie.icustay_id = serv.icustay_id
-- left join dm_dialysis_start dial
  -- on ie.icustay_id = dial.icustay_id
left join (select icustay_id, min(starttime) as starttime from ventdurations vd group by icustay_id) vdstart
  on ie.icustay_id = vdstart.icustay_id
left join cs
  on ie.icustay_id = cs.icustay_id
order by ie.icustay_id)


SELECT * FROM FINAL_COHORT_TOTAL
WHERE subject_id IN (SELECT subject_id FROM "

############ MP_COHORT_1

q14m <- ")
;

"






