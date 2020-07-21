# strings 9-13
############### double check the keywords 
############### drop and create 




# ---------------- 9. vital
# REQUIRES MP_COHORT_1, CE_1 


# CREATE TABLE 

########### mp_vital_1 

q9a <- " as
with ce as
(
  select co.icustay_id
    , ceil(extract(EPOCH from ce.charttime-co.intime)/60.0/60.0)::smallint as hr
    , (case when itemid in (211,220045) and valuenum > 0 and valuenum < 300 then valuenum else null end) as HeartRate
    , (case when itemid in (51,442,455,6701,220179,220050) and valuenum > 0 and valuenum < 400 then valuenum else null end) as SysBP
    , (case when itemid in (8368,8440,8441,8555,220180,220051) and valuenum > 0 and valuenum < 300 then valuenum else null end) as DiasBP
    , (case when itemid in (456,52,6702,443,220052,220181,225312) and valuenum > 0 and valuenum < 300 then valuenum else null end) as MeanBP
    , (case when itemid in (615,618,220210,224690) and valuenum > 0 and valuenum < 70 then valuenum else null end) as RespRate
    , (case when itemid in (223761,678) and valuenum > 70 and valuenum < 120 then (valuenum-32)/1.8 -- converted to degC in valuenum call
               when itemid in (223762,676) and valuenum > 10 and valuenum < 50  then valuenum else null end) as TempC
    , (case when itemid in (646,220277) and valuenum > 0 and valuenum <= 100 then valuenum else null end) as SpO2
    , (case when itemid in (807,811,1529,3745,3744,225664,220621,226537) and valuenum > 0 then valuenum else null end) as Glucose
  from " 
  
############# mp_cohort_1 
  
  
q9b <- " co
  inner join " 
  
############ CE_1 
  
q9c <- " ce
    on co.icustay_id = ce.icustay_id
    and co.excluded = 0
  -- exclude rows marked as error
  where ce.error IS DISTINCT FROM 1
  and ce.itemid in
  (
  -- HEART RATE
  211, --'Heart Rate'
  220045, --'Heart Rate'

  -- Systolic/diastolic

  51, --	Arterial BP [Systolic]
  442, --	Manual BP [Systolic]
  455, --	NBP [Systolic]
  6701, --	Arterial BP #2 [Systolic]
  220179, --	Non Invasive Blood Pressure systolic
  220050, --	Arterial Blood Pressure systolic

  8368, --	Arterial BP [Diastolic]
  8440, --	Manual BP [Diastolic]
  8441, --	NBP [Diastolic]
  8555, --	Arterial BP #2 [Diastolic]
  220180, --	Non Invasive Blood Pressure diastolic
  220051, --	Arterial Blood Pressure diastolic


  -- MEAN ARTERIAL PRESSURE
  456, --'NBP Mean'
  52, --'Arterial BP Mean'
  6702, --	Arterial BP Mean #2
  443, --	Manual BP Mean(calc)
  220052, --'Arterial Blood Pressure mean'
  220181, --'Non Invasive Blood Pressure mean'
  225312, --'ART BP mean'

  -- RESPIRATORY RATE
  618,--	Respiratory Rate
  615,--	Resp Rate (Total)
  220210,--	Respiratory Rate
  224690, --	Respiratory Rate (Total)


  -- SPO2, peripheral
  646, 220277,

  -- GLUCOSE, both lab and fingerstick
  807,--	Fingerstick Glucose
  811,--	Glucose (70-105)
  1529,--	Glucose
  3745,--	BloodGlucose
  3744,--	Blood Glucose
  225664,--	Glucose finger stick
  220621,--	Glucose (serum)
  226537,--	Glucose (whole blood)

  -- TEMPERATURE
  223762, -- 'Temperature Celsius'
  676,	-- 'Temperature C'
  223761, -- 'Temperature Fahrenheit'
  678 --	'Temperature F'

  )
)
select
  ce.icustay_id, ce.hr
  , avg(HeartRate) as HeartRate
  , avg(SysBP) as SysBP
  , avg(DiasBP) as DiasBP
  , avg(MeanBP) as MeanBP
  , avg(RespRate) as RespRate
  , avg(TempC) as TempC
  , avg(SpO2) as SpO2
  , avg(Glucose) as Glucose
from ce
group by ce.icustay_id, ce.hr
order by ce.icustay_id, ce.hr;
"





# ---------------- 10. data
# REQUIRES: MP_HOURLY_COHORT_1, MP_VITAL_1, MP_GCS_1, MP_UO_1, MP_BG_ART_1, MP_LAB_1.


# CREATE TABLE 

############ mp_data_1 


q10a <- " as
select
  mp.subject_id, mp.hadm_id, mp.icustay_id
  , mp.hr
  -- vitals
  , vi.HeartRate
  , vi.SysBP
  , vi.DiasBP
  , vi.MeanBP
  , vi.RespRate
  , vi.TempC
  , vi.SpO2
  , vi.Glucose as glucose_chart
  -- gcs
  , gcs.GCS
  , gcs.GCSMotor
  , gcs.GCSVerbal
  , gcs.GCSEyes
  , gcs.EndoTrachFlag
  -- blood gases
  -- oxygen related parameters
  , bg.SO2 as bg_SO2
  , bg.PO2 as bg_PO2
  , bg.PCO2 as bg_PCO2
  -- also calculate AADO2
  -- , bg.AADO2 as bg_AADO2
  --, AADO2_calc
  , bg.PaO2FiO2Ratio as bg_PaO2FiO2Ratio
  -- acid-base parameters
  , bg.PH as bg_PH
  , bg.BASEEXCESS as bg_BASEEXCESS
  , bg.BICARBONATE as bg_BICARBONATE
  , bg.TOTALCO2 as bg_TOTALCO2

  -- blood count parameters
  , bg.HEMATOCRIT as bg_HEMATOCRIT
  , bg.HEMOGLOBIN as bg_HEMOGLOBIN
  , bg.CARBOXYHEMOGLOBIN as bg_CARBOXYHEMOGLOBIN
  , bg.METHEMOGLOBIN as bg_METHEMOGLOBIN

  -- chemistry
  , bg.CHLORIDE as bg_CHLORIDE
  , bg.CALCIUM as bg_CALCIUM
  , bg.TEMPERATURE as bg_TEMPERATURE
  , bg.POTASSIUM as bg_POTASSIUM
  , bg.SODIUM as bg_SODIUM
  , bg.LACTATE as bg_LACTATE
  , bg.GLUCOSE as bg_GLUCOSE

  -- ventilation stuff that's sometimes input
  -- , INTUBATED, TIDALVOLUME, VENTILATIONRATE, VENTILATOR
  -- , bg.PEEP as bg_PEEP
  -- , O2Flow
  -- , REQUIREDO2

  -- labs
  , lab.ANIONGAP as ANIONGAP
  , lab.ALBUMIN as ALBUMIN
  , lab.BANDS as BANDS
  , lab.BICARBONATE as BICARBONATE
  , lab.BILIRUBIN as BILIRUBIN
  , lab.CREATININE as CREATININE
  , lab.CHLORIDE as CHLORIDE
  , lab.GLUCOSE as GLUCOSE
  , lab.HEMATOCRIT as HEMATOCRIT
  , lab.HEMOGLOBIN as HEMOGLOBIN
  , lab.LACTATE as LACTATE
  , lab.PLATELET as PLATELET
  , lab.POTASSIUM as POTASSIUM
  , lab.PTT as PTT
  , lab.INR as INR
  , lab.PT as PT
  , lab.SODIUM as SODIUM
  , lab.BUN as BUN
  , lab.WBC as WBC

  , uo.UrineOutput
from "

############## mp_hourly_cohort_1

q10b <- " mp
left join " 

############## mp_vital_1 

q10c <- " vi
  on  mp.icustay_id = vi.icustay_id
  and mp.hr = vi.hr
left join " 

############## mp_gcs_1 

q10d <- " gcs
  on  mp.icustay_id = gcs.icustay_id
  and mp.hr = gcs.hr
left join " 

############## mp_uo_1 

q10e <- " uo
  on  mp.icustay_id = uo.icustay_id
  and mp.hr = uo.hr
left join "

############ mp_bg_art_1 

q10f <- " bg
  on  mp.hadm_id = bg.hadm_id
  and mp.hr = bg.hr
left join "

########## mp_lab_1 

q10g <- " lab
  on  mp.hadm_id = lab.hadm_id
  and mp.hr = lab.hr
order by mp.subject_id, mp.hadm_id, mp.icustay_id, mp.hr;
"






# ---------------- 11. mp_intime_outtime
# REQUIRES CE_1

# create table 

############ mp_intime_outtime_1

q11a <- " as
select icustay_id
  , min(charttime) as intime_hr
  , max(charttime) as outtime_hr
from " 

############ ce_1 

q11b <- " ce
-- very loose join to admissions to ensure charttime is near patient admission
inner join admissions adm
  on ce.hadm_id = adm.hadm_id
  and ce.charttime between adm.admittime - interval '1' day and adm.dischtime + interval '1' day
where itemid in (211,220045)
group by icustay_id
order by icustay_id;

"




# ---------------- 12. mp_service

# REQUIRES CE_1
# NOTE: NEED INTERMEDIATE SUBQUERY


# create table 

############# mp_service_1


q12a <- " as

WITH SERVICE_TOTAL AS (
with serv as
(
  select hadm_id, curr_service
    , ROW_NUMBER() over (PARTITION BY hadm_id ORDER BY transfertime) as rn
  from services
)
, chart_serv as
(
  select ce.icustay_id
  , max(case when ce.value in ('medicine','Med','med','MEDICINE','M','MICU','MED','MED            8') then 1 else 0 end) as medicine_chart
  -- ccu
  , max(case when ce.value in ('CCU','ccu','CCU/EP') then 1 else 0 end) as ccu_chart
  -- neuro (combined surgical or medical)
  , max(case when ce.value in ('NSICU','NSU','nsu','NEUROSURGURY','NSURG','neuro/sicu','N/SURG','NMED','NME','NEUROSURG') then 1 else 0 end) as neuro_chart


  -- csurg
  , max(case when ce.value in ('MICU/SICU','MSICU') then 1 else 0 end) as msicu_chart

  , max(case when ce.value in ('ORT','ORTHO') then 1 else 0 end) as ortho_chart
  , max(case when ce.value in ('GU') then 1 else 0 end) as gu_chart
  , max(case when ce.value in ('GYN') then 1 else 0 end) as gyn_chart
  , max(case when ce.value in ('PSU') then 1 else 0 end) as psu_chart
  , max(case when ce.value in ('ENT') then 1 else 0 end) as ent_chart
  , max(case when ce.value in ('OBS') then 1 else 0 end) as obs_chart
  , max(case when ce.value in ('CMED','cmed','CME','c-med','cardiology') then 1 else 0 end) as cmed_chart
  , max(case when ce.value in ('CSRU','CSURG','CRSU','CSU','csru','csurg','CSICU','csu','SCRU','CVI/CSRU','VASCULAR','VSURG','V SURG','VSU') then 1 else 0 end) as csru_chart
  , max(case when ce.value in ('SICU','SURG','SUR','surg','Surgery') then 1 else 0 end) as surg_chart
  , max(case when ce.value in ('DEN') then 1 else 0 end) as den_chart
  , max(case when ce.value in ('TRAUMA','trauma','Trauma','TSURG','TSU','T-SICU','TRA') then 1 else 0 end) as trauma_chart
  , max(case when ce.value in ('TRANSPLANT','Transplant') then 1 else 0 end) as transplant_chart
  , max(case when ce.value in ('OME') then 1 else 0 end) as omed_chart

  -- unable to guess, also only contains a handful of pts (<5 each)
  -- '',,
  -- 'TA','CFIRM','PCP',
  -- 'CE','MD','ICU','VU',

  -- redundant services for a study's exclusion criteria
  , max(case when ce.value = 'NSICU' then 1 else 0 end) as nsicu_chart
  , max(case when ce.value = 'CSICU' then 1 else 0 end) as csicu_chart

  from " 
  
############# ce_1 
  
q12b <- " ce  
  where itemid in (1125,919,224640)
  group by ce.icustay_id
)
SELECT
  ie.icustay_id

  -- charted services
  , cs.medicine_chart
  , cs.ccu_chart
  , cs.neuro_chart
  , cs.msicu_chart
  , cs.ortho_chart
  , cs.gu_chart
  , cs.gyn_chart
  , cs.psu_chart
  , cs.ent_chart
  , cs.obs_chart
  , cs.cmed_chart
  , cs.csru_chart
  , cs.surg_chart
  , cs.den_chart
  , cs.trauma_chart
  , cs.transplant_chart

  -- redundant to above (supersetted by above)
  -- used for some exclusions to precisely reproduce their criteria
  , cs.nsicu_chart
  , cs.csicu_chart
  
  , serv.curr_service
  -- reference is MED
  -- excluding (due to low sample size): DENT, PSYCH, OBS
  -- excluding newborns NB and NBB
  , case when serv.curr_service = 'MED'  then 1 else 0 end as service_MED
  , case when serv.curr_service = 'CMED'  then 1 else 0 end as service_CMED
  , case when serv.curr_service = 'OMED'  then 1 else 0 end as service_OMED
  , case when serv.curr_service = 'NMED'  then 1 else 0 end as service_NMED
  , case when serv.curr_service = 'NSURG' then 1 else 0 end as service_NSURG
  , case when serv.curr_service = 'TSURG' then 1 else 0 end as service_TSURG
  , case when serv.curr_service = 'CSURG' then 1 else 0 end as service_CSURG
  , case when serv.curr_service = 'VSURG' then 1 else 0 end as service_VSURG
  , case when serv.curr_service = 'ORTHO' then 1 else 0 end as service_ORTHO
  , case when serv.curr_service = 'PSURG' then 1 else 0 end as service_PSURG
  , case when serv.curr_service = 'SURG'  then 1 else 0 end as service_SURG

  , case when serv.curr_service = 'GU'    then 1 else 0 end as service_GU
  , case when serv.curr_service = 'GYN'   then 1 else 0 end as service_GYN
  , case when serv.curr_service = 'TRAUM' then 1 else 0 end as service_TRAUM
  , case when serv.curr_service = 'ENT'   then 1 else 0 end as service_ENT

  -- we aggregate some of these together due to low sample size
  , case when serv.curr_service in
      (
        'NSURG', 'TSURG', 'PSURG', 'SURG', 'ORTHO'
      ) then 1 else 0 end as service_ANY_NONCARD_SURG
  , case when serv.curr_service in
      (
        'CSURG', 'VSURG'
      ) then 1 else 0 end as service_ANY_CARD_SURG
from icustays ie
left join serv
  on ie.hadm_id = serv.hadm_id
  and serv.rn = 1
left join chart_serv cs
  on ie.icustay_id = cs.icustay_id
order by ie.icustay_id)


SELECT * FROM SERVICE_TOTAL 
WHERE icustay_id IN (SELECT icustay_id FROM " 

############## CE_1

q12c <- ")
;
"




# ---------------- 13. mp_obs_count
# REQUIRES CE_1 
# remove SOFA
# REQUIRES INTERMEDIATE SUBQUERY




# drop table if exists dm_obs_count cascade;
# create table 

########## mp_obs_count_1


q13a <- " as

WITH OBS_COUNT_TOTAL AS (

with ie_cv as
(
  select icustay_id, count(*) as iv
  -- only 'MedEvents' (As was done in Hug 2009)
  , count(rate) as iv_rate
  -- saps-I var  (urine output)
  , SUM (CASE WHEN ITEMID IN
      (
        651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96,
        288, 405, 428, 473,
        2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859,
        3053, 3462, 3519, 3175, 2366, 2463, 2507, 2510,
        2592, 2676, 3966, 3987, 4132, 4253, 5927
      ) THEN 1 ELSE 0 END) AS urineoutput

  from inputevents_cv
  group by icustay_id
)
, ie_mv as
(
  select icustay_id, count(*) as iv
  , count(rate) as iv_rate
  -- my replication of SAPS-I var in metavision (urine output)
  , SUM(CASE WHEN ITEMID IN
      (
      226559, -- 'Foley'
      226560, -- 'Void'
      226561, -- 'Condom Cath'
      226584, -- 'Ileoconduit'
      226563, -- 'Suprapubic'
      226564, -- 'R Nephrostomy'
      226565, -- 'L Nephrostomy'
      226567, --	Straight Cath
      226557, -- R Ureteral Stent
      226558, -- L Ureteral Stent
      227488, -- GU Irrigant Volume In
      227489  -- GU Irrigant/Urine Volume Out
      ) THEN 1 ELSE 0 END) AS urineoutput
  from inputevents_mv
  group by icustay_id
)
, labs as
(
  select ie.icustay_id
    , SUM(CASE WHEN itemid = 50868 THEN 1 ELSE 0 END) as ANIONGAP
    , SUM(CASE WHEN itemid = 50862 THEN 1 ELSE 0 END) as ALBUMIN
    , SUM(CASE WHEN itemid = 51144 THEN 1 ELSE 0 END) as BANDS
    , SUM(CASE WHEN itemid = 50882 THEN 1 ELSE 0 END) as BICARBONATE
    , SUM(CASE WHEN itemid = 50885 THEN 1 ELSE 0 END) as BILIRUBIN
    , SUM(CASE WHEN itemid = 50912 THEN 1 ELSE 0 END) as CREATININE
    , SUM(CASE WHEN itemid in (50806,50902) THEN 1 ELSE 0 END) as CHLORIDE
    , SUM(CASE WHEN itemid in (50809,50931) THEN 1 ELSE 0 END) as GLUCOSE
    , SUM(CASE WHEN itemid in (50810,51221) THEN 1 ELSE 0 END) as HEMATOCRIT
    , SUM(CASE WHEN itemid in (50811,51222) THEN 1 ELSE 0 END) as HEMOGLOBIN
    , SUM(CASE WHEN itemid = 50813 THEN 1 ELSE 0 END) as LACTATE
    , SUM(CASE WHEN itemid = 51265 THEN 1 ELSE 0 END) as PLATELET
    , SUM(CASE WHEN itemid in (50822,50971) THEN 1 ELSE 0 END) as POTASSIUM
    , SUM(CASE WHEN itemid = 51275 THEN 1 ELSE 0 END) as PTT
    , SUM(CASE WHEN itemid = 51237 THEN 1 ELSE 0 END) as INR
    , SUM(CASE WHEN itemid = 51274 THEN 1 ELSE 0 END) as PT
    , SUM(CASE WHEN itemid in (50824,50983) THEN 1 ELSE 0 END) as SODIUM
    , SUM(CASE WHEN itemid = 51006 THEN 1 ELSE 0 END) as BUN
    , SUM(CASE WHEN itemid in (51300,51301) THEN 1 ELSE 0 END) as WBC

    -- blood gases
    , SUM(case when itemid = 50821 then 1 else 0 end) as PO2
    , SUM(case when itemid = 50820 then 1 else 0 end) as PH

    --  SAPS-I labs !
    , SUM(CASE WHEN itemid in (
        50810, 51221,        -- HCT
        51300, 51301, -- WBC
        50809, 50931, -- Glucose
        50882, -- HCO3
        50822, 50971, -- Potassium
        50824, 50983,  -- Sodium
        51006         -- BUN
      ) THEN 1 ELSE 0 END) as saps_labs
    -- SOFA labs
    , SUM(CASE WHEN itemid in (
        50885, -- bilirubin
        51265, -- platelets
        50912  -- creatinine
      ) THEN 1 ELSE 0 END) as sofa_labs

  from icustays ie
  left join labevents le
    on ie.hadm_id = le.hadm_id
    and le.charttime between ie.intime and ie.outtime
  group by ie.icustay_id
)
-- charted data
, chart as
(

  select ce.icustay_id
  , SUM(case when itemid in (211,220045) then 1 else 0 end) as HeartRate
  , SUM(case when itemid in (51,442,455,6701,220179,220050) then 1 else 0 end) as SysBP
  , SUM(case when itemid in (8368,8440,8441,8555,220180,220051) then 1 else 0 end) as DiasBP
  , SUM(case when itemid in (456,52,6702,443,220052,220181,225312) then 1 else 0 end) as MeanBP
  , SUM(case when itemid in (615,618,220210,224690) then 1 else 0 end) as RespRate
  , SUM(case when itemid in (223761,678,223762,676) then 1 else 0 end) as Temp
  , SUM(case when itemid in (646,220277) then 1 else 0 end) as SpO2
  , SUM(case when itemid in (807,811,1529,3745,3744,225664,220621,226537) then 1 else 0 end) as Glucose
  , SUM(case when itemid in (184, 454, 723, 223900, 223901, 220739) then 1 else 0 end) as GCS
  -- missing SAPS-I
  , SUM(CASE WHEN itemid IN
    (
      -- vitals/gcs etc
      211,220045,
      676, 677, 678, 679,223761,223762,
      51,455,220179,220050,
      781,225624, -- BUN
      184, 454, 723, 223900, 223901, 220739,
      -- breathing params
      615,618,220210,224690
    ) then 1 else 0 end) as saps_chart

  -- missing SOFA
  , SUM(CASE WHEN itemid IN
    (
      189, 190, 2981, 7570, 3420, 3422, 223835,-- fio2
      490, 779, 220224,-- pao2
      52,456,220052,220181,225312, -- mbp
      184, 454, 723, 223900, 223901, 220739 -- gcs
    ) then 1 else 0 end) as sofa_chart
  from " 
  
########### CE_1 
  
q13b <- " ce 
  group by ce.icustay_id
)
select
  ie.icustay_id
  -- vitals
  , chart.heartrate
  , chart.sysbp
  , chart.diasbp
  , chart.meanbp
  , chart.resprate
  , chart.temp
  , chart.spo2
  , chart.gcs

  -- labs
  , labs.ANIONGAP
  , labs.ALBUMIN
  , labs.BANDS
  , labs.BICARBONATE
  , labs.BILIRUBIN
  , labs.CREATININE
  , labs.CHLORIDE
  , labs.HEMATOCRIT
  , labs.HEMOGLOBIN
  , labs.LACTATE
  , labs.PLATELET
  , labs.POTASSIUM
  , labs.PTT
  , labs.INR
  , labs.PT
  , labs.SODIUM
  , labs.BUN
  , labs.WBC

  -- bgs
  , labs.po2
  , labs.ph

  -- both (may double count some observations)
  , chart.glucose + labs.GLUCOSE as glucose

  -- 'any IV recording'
  , coalesce(ie_cv.iv,0) + coalesce(ie_mv.iv,0) as iv
  , coalesce(ie_cv.iv_rate,0) + coalesce(ie_mv.iv_rate,0) as iv_rate

  -- saps
  ,  coalesce(labs.saps_labs,0)
    + coalesce(chart.saps_chart,0)
    + coalesce(ie_cv.urineoutput,0)
    + coalesce(ie_mv.urineoutput,0)
    as saps_vars

  -- sofa
 /* ,  coalesce(labs.sofa_labs,0)
    + coalesce(chart.sofa_chart,0)
    + coalesce(ie_cv.urineoutput,0)
    + coalesce(ie_mv.urineoutput,0)
    + case when vaso.icustay_id is not null then 1 else 0 end
    as sofa_vars*/
from icustays ie
left join labs
  on ie.icustay_id = labs.icustay_id
left join ie_cv
on ie.icustay_id = ie_cv.icustay_id
left join ie_mv
  on ie.icustay_id = ie_mv.icustay_id
left join chart
  on ie.icustay_id = chart.icustay_id
-- below used for sofa
--left join (select distinct icustay_id from vasopressordurations) vaso
  --on ie.icustay_id = vaso.icustay_id
order by ie.icustay_id)


SELECT * FROM OBS_COUNT_TOTAL 
WHERE icustay_id IN (SELECT icustay_id FROM " 

########## CE_1

q13c <- ")
;
"




