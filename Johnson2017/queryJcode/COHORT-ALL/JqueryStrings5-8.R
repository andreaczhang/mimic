# strings 5-8

############### double check the keywords 
############### drop and create 



# -------------- 5. crystalloid-bolus
# REQUIRES MP_COHORT_1 

# CREATE TABLE 
############## mp_crystalloid_bolus_1 


q5a <- " AS
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
  
q5b <- " co
  inner join inputevents_mv mv
  on co.icustay_id = mv.icustay_id
  and mv.itemid in
  (
    -- 225943 Solution
    225158, -- NaCl 0.9%
    225828, -- LR
    225944, -- Sterile Water
    225797  -- Free Water
  )
  where mv.statusdescription != 'Rewritten'
  and
  -- in MetaVision, these ITEMIDs appear with a null rate IFF endtime=starttime + 1 minute
  -- so it is sufficient to:
  --    (1) check the rate is > 240 if it exists or
  --    (2) ensure the rate is null and amount > 240 ml
    (
      (mv.rate is not null and mv.rateuom = 'mL/hour' and mv.rate > 248)
      OR (mv.rate is not null and mv.rateuom = 'mL/min' and mv.rate > (248/60.0))
      OR (mv.rate is null and mv.amountuom = 'L' and mv.amount > 0.248)
      OR (mv.rate is null and mv.amountuom = 'ml' and mv.amount > 248)
    )
)
, t2 as
(
  select
    co.icustay_id
  , ceil(extract(EPOCH from cv.charttime-co.intime)/60.0/60.0)::smallint as hr
  -- carevue always has units in millilitres
  , round(cv.amount) as amount
  from " 
  
############# mp_cohort_1 
  
q5c <- " co
  inner join inputevents_cv cv
  on co.icustay_id = cv.icustay_id
  and cv.itemid in
  (
    30018 --	.9% Normal Saline
  , 30021 --	Lactated Ringers
  , 30058 --	Free Water Bolus
  , 40850 --	ns bolus
  , 41491 --	fluid bolus
  , 42639 --	bolus
  , 30065 --	Sterile Water
  , 42187 --	free h20
  , 43819 --	1:1 NS Repletion.
  , 30063 --	IV Piggyback
  , 41430 --	free water boluses
  , 40712 --	free H20
  , 44160 --	BOLUS
  , 42383 --	cc for cc replace
  , 30169 --	Sterile H20_GU
  , 42297 --	Fluid bolus
  , 42453 --	Fluid Bolus
  , 40872 --	free water
  , 41915 --	FREE WATER
  , 41490 --	NS bolus
  , 46501 --	H2O Bolus
  , 45045 --	WaterBolus
  , 41984 --	FREE H20
  , 41371 --	ns fluid bolus
  , 41582 --	free h20 bolus
  , 41322 --	rl bolus
  , 40778 --	Free H2O
  , 41896 --	ivf boluses
  , 41428 --	ns .9% bolus
  , 43936 --	FREE WATER BOLUSES
  , 44200 --	FLUID BOLUS
  , 41619 --	frfee water boluses
  , 40424 --	free H2O
  , 41457 --	Free H20 intake
  , 41581 --	Water bolus
  , 42844 --	NS fluid bolus
  , 42429 --	Free water
  , 41356 --	IV Bolus
  , 40532 --	FREE H2O
  , 42548 --	NS Bolus
  , 44184 --	LR Bolus
  , 44521 --	LR bolus
  , 44741 --	NS FLUID BOLUS
  , 44126 --	fl bolus
  , 44110 --	RL BOLUS
  , 44633 --	ns boluses
  , 44983 --	Bolus NS
  , 44815 --	LR BOLUS
  , 43986 --	iv bolus
  , 45079 --	500 cc ns bolus
  , 46781 --	lr bolus
  , 45155 --	ns cc/cc replacement
  , 43909 --	H20 BOlus
  , 41467 --	NS IV bolus
  , 44367 --	LR
  , 41743 --	water bolus
  , 40423 --	Bolus
  , 44263 --	fluid bolus ns
  , 42749 --	fluid bolus NS
  , 45480 --	500cc ns bolus
  , 44491 --	.9NS bolus
  , 41695 --	NS fluid boluses
  , 46169 --	free water bolus.
  , 41580 --	free h2o bolus
  , 41392 --	ns b
  , 45989 --	NS Fluid Bolus
  , 45137 --	NS cc/cc
  , 45154 --	Free H20 bolus
  , 44053 --	normal saline bolus
  , 41416 --	free h2o boluses
  , 44761 --	Free H20
  , 41237 --	ns fluid boluses
  , 44426 --	bolus ns
  , 43975 --	FREE H20 BOLUSES
  , 44894 --	N/s 500 ml bolus
  , 41380 --	nsbolus
  , 42671 --	free h2o
  )
  where cv.amount > 248
  and cv.amount < 2000
  and cv.amountuom = 'ml'
)
select
    icustay_id
  , hr
  , sum(amount) as crystalloid_bolus
from t1

where amount > 248
group by t1.icustay_id, t1.hr
UNION
select
    icustay_id
  , hr
  , sum(amount) as crystalloid_bolus
from t2
group by t2.icustay_id, t2.hr
order by icustay_id, hr;
"




# -------------- 6. gcs
# REQUIRES CE_1, MP_COHORT_1

# CREATE TABLE 
############ mp_gcs_1

q6a <- " as
with base as
(
  SELECT pvt.ICUSTAY_ID
  , pvt.charttime

  -- Easier names - note we coalesced Metavision and CareVue IDs below
  , max(case when pvt.itemid = 454 then pvt.valuenum else null end) as GCSMotor
  , max(case when pvt.itemid = 723 then pvt.valuenum else null end) as GCSVerbal
  , max(case when pvt.itemid = 184 then pvt.valuenum else null end) as GCSEyes

  -- If verbal was set to 0 in the below select, then this is an intubated patient
  , case
      when max(case when pvt.itemid = 723 then pvt.valuenum else null end) = 0
    then 1
    else 0
    end as EndoTrachFlag

  , ROW_NUMBER ()
          OVER (PARTITION BY pvt.ICUSTAY_ID ORDER BY pvt.charttime ASC) as rn

  FROM  (
    select l.icustay_id, l.charttime
    -- merge the ITEMIDs so that the pivot applies to both metavision/carevue data
    , case
        when l.ITEMID in (723,223900) then 723
        when l.ITEMID in (454,223901) then 454
        when l.ITEMID in (184,220739) then 184
        else l.ITEMID end
      as ITEMID

    -- convert the data into a number, reserving a value of 0 for ET/Trach
    , case
        -- endotrach/vent is assigned a value of 0, later parsed specially
        when l.ITEMID = 723 and l.VALUE = '1.0 ET/Trach' then 0 -- carevue
        when l.ITEMID = 223900 and l.VALUE = 'No Response-ETT' then 0 -- metavision
        else VALUENUM
        end
      as VALUENUM
    from " 
    
############## CE_1 
    
q6b <- " l
    inner join "

############# mp_cohort_1 
     
q6c <- " co
      on l.icustay_id = co.icustay_id
      and co.excluded = 0
    -- Isolate the desired GCS variables
    where l.ITEMID in
    (
      -- 198 -- GCS
      -- GCS components, CareVue
      184, 454, 723
      -- GCS components, Metavision
      , 223900, 223901, 220739
    )
    -- exclude rows marked as error
    and l.error IS DISTINCT FROM 1
  ) pvt
  group by pvt.ICUSTAY_ID, pvt.charttime
)
, gcs as (
  select b.*
  , b2.GCSVerbal as GCSVerbalPrev
  , b2.GCSMotor as GCSMotorPrev
  , b2.GCSEyes as GCSEyesPrev
  -- Calculate GCS, factoring in special case when they are intubated and prev vals
  -- note that the coalesce are used to implement the following if:
  --  if current value exists, use it
  --  if previous value exists, use it
  --  otherwise, default to normal
  , case
      -- replace GCS during sedation with 15
      when b.GCSVerbal = 0
        then 15
      when b.GCSVerbal is null and b2.GCSVerbal = 0
        then 15
      -- if previously they were intub, but they aren't now, do not use previous GCS values
      when b2.GCSVerbal = 0
        then
            coalesce(b.GCSMotor,6)
          + coalesce(b.GCSVerbal,5)
          + coalesce(b.GCSEyes,4)
      -- otherwise, add up score normally, imputing previous value if none available at current time
      else
            coalesce(b.GCSMotor,coalesce(b2.GCSMotor,6))
          + coalesce(b.GCSVerbal,coalesce(b2.GCSVerbal,5))
          + coalesce(b.GCSEyes,coalesce(b2.GCSEyes,4))
      end as GCS

  from base b
  -- join to itself within 6 hours to get previous value
  left join base b2
    on b.ICUSTAY_ID = b2.ICUSTAY_ID
    and b.rn = b2.rn+1
    and b2.charttime > b.charttime - interval '6' hour
)
-- combine components with previous within 6 hours
-- filter down to cohort which is not excluded
-- truncate charttime to the hour
, gcs_stg as
(
  select gs.icustay_id
  , charttime
  , ceil(extract(EPOCH from gs.charttime-co.intime)/60.0/60.0)::smallint as hr
  , GCS
  , coalesce(GCSMotor,GCSMotorPrev) as GCSMotor
  , coalesce(GCSVerbal,GCSVerbalPrev) as GCSVerbal
  , coalesce(GCSEyes,GCSEyesPrev) as GCSEyes
  , case when coalesce(GCSMotor,GCSMotorPrev) is null then 0 else 1 end
  + case when coalesce(GCSVerbal,GCSVerbalPrev) is null then 0 else 1 end
  + case when coalesce(GCSEyes,GCSEyesPrev) is null then 0 else 1 end
    as components_measured
  , EndoTrachFlag as EndoTrachFlag
  from gcs gs
  inner join " 
  
############## mp_cohort_1 
  
q6d <- " co
    on gs.icustay_id = co.icustay_id
    and co.excluded = 0
)
-- priority is:
--  (i) complete data, (ii) non-sedated GCS, (iii) lowest GCS, (iii) charttime
, gcs_priority as
(
  select icustay_id
    , hr
    , GCS
    , GCSMotor
    , GCSVerbal
    , GCSEyes
    , EndoTrachFlag
    , ROW_NUMBER() over
      (
        PARTITION BY icustay_id, hr
        ORDER BY components_measured DESC, endotrachflag, gcs, charttime desc
      ) as rn
  from gcs_stg
)
select icustay_id
  , hr
  , GCS
  , GCSMotor
  , GCSVerbal
  , GCSEyes
  , EndoTrachFlag
from gcs_priority gs
where rn = 1
ORDER BY icustay_id, hr;
"







# ---------------- 7. lab
# REQUIRES MP_COHORT_1


# CREATE TABLE 

############ mp_lab_1 

q7a <- " AS
SELECT
    pvt.hadm_id, pvt.hr
  , avg(CASE WHEN label = 'ANION GAP' THEN valuenum ELSE null END) as ANIONGAP
  , avg(CASE WHEN label = 'ALBUMIN' THEN valuenum ELSE null END) as ALBUMIN
  , avg(CASE WHEN label = 'BANDS' THEN valuenum ELSE null END) as BANDS
  , avg(CASE WHEN label = 'BICARBONATE' THEN valuenum ELSE null END) as BICARBONATE
  , avg(CASE WHEN label = 'BILIRUBIN' THEN valuenum ELSE null END) as BILIRUBIN
  , avg(CASE WHEN label = 'CREATININE' THEN valuenum ELSE null END) as CREATININE
  , avg(CASE WHEN label = 'CHLORIDE' THEN valuenum ELSE null END) as CHLORIDE
  , avg(CASE WHEN label = 'GLUCOSE' THEN valuenum ELSE null END) as GLUCOSE
  , avg(CASE WHEN label = 'HEMATOCRIT' THEN valuenum ELSE null END) as HEMATOCRIT
  , avg(CASE WHEN label = 'HEMOGLOBIN' THEN valuenum ELSE null END) as HEMOGLOBIN
  , avg(CASE WHEN label = 'LACTATE' THEN valuenum ELSE null END) as LACTATE
  , avg(CASE WHEN label = 'PLATELET' THEN valuenum ELSE null END) as PLATELET
  , avg(CASE WHEN label = 'POTASSIUM' THEN valuenum ELSE null END) as POTASSIUM
  , avg(CASE WHEN label = 'PTT' THEN valuenum ELSE null END) as PTT
  , avg(CASE WHEN label = 'INR' THEN valuenum ELSE null END) as INR
  , avg(CASE WHEN label = 'PT' THEN valuenum ELSE null END) as PT
  , avg(CASE WHEN label = 'SODIUM' THEN valuenum ELSE null end) as SODIUM
  , avg(CASE WHEN label = 'BUN' THEN valuenum ELSE null end) as BUN
  , avg(CASE WHEN label = 'WBC' THEN valuenum ELSE null end) as WBC
FROM
( -- begin query that extracts the data
  SELECT le.hadm_id
  , ceil(extract(EPOCH from le.charttime-co.intime)/60.0/60.0)::smallint as hr
  -- here we assign labels to ITEMIDs
  -- this also fuses together multiple ITEMIDs containing the same data
  , CASE
        WHEN itemid = 50868 THEN 'ANION GAP'
        WHEN itemid = 50862 THEN 'ALBUMIN'
        WHEN itemid = 51144 THEN 'BANDS'
        WHEN itemid = 50882 THEN 'BICARBONATE'
        WHEN itemid = 50885 THEN 'BILIRUBIN'
        WHEN itemid = 50912 THEN 'CREATININE'
        -- exclude blood gas
        -- WHEN itemid = 50806 THEN 'CHLORIDE'
        WHEN itemid = 50902 THEN 'CHLORIDE'
        -- exclude blood gas
        -- WHEN itemid = 50809 THEN 'GLUCOSE'
        WHEN itemid = 50931 THEN 'GLUCOSE'
        -- exclude blood gas
        --WHEN itemid = 50810 THEN 'HEMATOCRIT'
        WHEN itemid = 51221 THEN 'HEMATOCRIT'
        -- exclude blood gas
        --WHEN itemid = 50811 THEN 'HEMOGLOBIN'
        WHEN itemid = 51222 THEN 'HEMOGLOBIN'
        WHEN itemid = 50813 THEN 'LACTATE'
        WHEN itemid = 51265 THEN 'PLATELET'
        -- exclude blood gas
        -- WHEN itemid = 50822 THEN 'POTASSIUM'
        WHEN itemid = 50971 THEN 'POTASSIUM'
        WHEN itemid = 51275 THEN 'PTT'
        WHEN itemid = 51237 THEN 'INR'
        WHEN itemid = 51274 THEN 'PT'
        -- exclude blood gas
        -- WHEN itemid = 50824 THEN 'SODIUM'
        WHEN itemid = 50983 THEN 'SODIUM'
        WHEN itemid = 51006 THEN 'BUN'
        WHEN itemid = 51300 THEN 'WBC'
        WHEN itemid = 51301 THEN 'WBC'
      ELSE null
    END AS label
  , -- add in some sanity checks on the values
  -- the where clause below requires all valuenum to be > 0, so these are only upper limit checks
    CASE
      WHEN itemid = 50862 and valuenum >    10 THEN null -- g/dL 'ALBUMIN'
      WHEN itemid = 50868 and valuenum > 10000 THEN null -- mEq/L 'ANION GAP'
      WHEN itemid = 51144 and valuenum <     0 THEN null -- immature band forms, %
      WHEN itemid = 51144 and valuenum >   100 THEN null -- immature band forms, %
      WHEN itemid = 50882 and valuenum > 10000 THEN null -- mEq/L 'BICARBONATE'
      WHEN itemid = 50885 and valuenum >   150 THEN null -- mg/dL 'BILIRUBIN'
      WHEN itemid = 50806 and valuenum > 10000 THEN null -- mEq/L 'CHLORIDE'
      WHEN itemid = 50902 and valuenum > 10000 THEN null -- mEq/L 'CHLORIDE'
      WHEN itemid = 50912 and valuenum >   150 THEN null -- mg/dL 'CREATININE'
      WHEN itemid = 50809 and valuenum > 10000 THEN null -- mg/dL 'GLUCOSE'
      WHEN itemid = 50931 and valuenum > 10000 THEN null -- mg/dL 'GLUCOSE'
      WHEN itemid = 50810 and valuenum >   100 THEN null -- % 'HEMATOCRIT'
      WHEN itemid = 51221 and valuenum >   100 THEN null -- % 'HEMATOCRIT'
      WHEN itemid = 50811 and valuenum >    50 THEN null -- g/dL 'HEMOGLOBIN'
      WHEN itemid = 51222 and valuenum >    50 THEN null -- g/dL 'HEMOGLOBIN'
      WHEN itemid = 50813 and valuenum >    50 THEN null -- mmol/L 'LACTATE'
      WHEN itemid = 51265 and valuenum > 10000 THEN null -- K/uL 'PLATELET'
      WHEN itemid = 50822 and valuenum >    30 THEN null -- mEq/L 'POTASSIUM'
      WHEN itemid = 50971 and valuenum >    30 THEN null -- mEq/L 'POTASSIUM'
      WHEN itemid = 51275 and valuenum >   150 THEN null -- sec 'PTT'
      WHEN itemid = 51237 and valuenum >    50 THEN null -- 'INR'
      WHEN itemid = 51274 and valuenum >   150 THEN null -- sec 'PT'
      WHEN itemid = 50824 and valuenum >   200 THEN null -- mEq/L == mmol/L 'SODIUM'
      WHEN itemid = 50983 and valuenum >   200 THEN null -- mEq/L == mmol/L 'SODIUM'
      WHEN itemid = 51006 and valuenum >   300 THEN null -- 'BUN'
      WHEN itemid = 51300 and valuenum >  1000 THEN null -- 'WBC'
      WHEN itemid = 51301 and valuenum >  1000 THEN null -- 'WBC'
    ELSE le.valuenum
    END AS valuenum

  FROM labevents le
  inner join " 
  
################ mp_cohort_1 
  
q7b <- " co
    on le.hadm_id = co.hadm_id
    and co.excluded = 0
  WHERE le.ITEMID in
  (
    -- comment is: LABEL | CATEGORY | FLUID | NUMBER OF ROWS IN LABEVENTS
    50868, -- ANION GAP | CHEMISTRY | BLOOD | 769895
    50862, -- ALBUMIN | CHEMISTRY | BLOOD | 146697
    51144, -- BANDS - hematology
    50882, -- BICARBONATE | CHEMISTRY | BLOOD | 780733
    50885, -- BILIRUBIN, TOTAL | CHEMISTRY | BLOOD | 238277
    50912, -- CREATININE | CHEMISTRY | BLOOD | 797476
    50902, -- CHLORIDE | CHEMISTRY | BLOOD | 795568
    -- 50806, -- CHLORIDE, WHOLE BLOOD | BLOOD GAS | BLOOD | 48187
    50931, -- GLUCOSE | CHEMISTRY | BLOOD | 748981
    -- 50809, -- GLUCOSE | BLOOD GAS | BLOOD | 196734
    51221, -- HEMATOCRIT | HEMATOLOGY | BLOOD | 881846
    -- 50810, -- HEMATOCRIT, CALCULATED | BLOOD GAS | BLOOD | 89715
    51222, -- HEMOGLOBIN | HEMATOLOGY | BLOOD | 752523
    -- 50811, -- HEMOGLOBIN | BLOOD GAS | BLOOD | 89712
    50813, -- LACTATE | BLOOD GAS | BLOOD | 187124
    51265, -- PLATELET COUNT | HEMATOLOGY | BLOOD | 778444
    50971, -- POTASSIUM | CHEMISTRY | BLOOD | 845825
    -- 50822, -- POTASSIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 192946
    51275, -- PTT | HEMATOLOGY | BLOOD | 474937
    51237, -- INR(PT) | HEMATOLOGY | BLOOD | 471183
    51274, -- PT | HEMATOLOGY | BLOOD | 469090
    50983, -- SODIUM | CHEMISTRY | BLOOD | 808489
    -- 50824, -- SODIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 71503
    51006, -- UREA NITROGEN | CHEMISTRY | BLOOD | 791925
    51301, -- WHITE BLOOD CELLS | HEMATOLOGY | BLOOD | 753301
    51300  -- WBC COUNT | HEMATOLOGY | BLOOD | 2371
  )
  AND valuenum IS NOT null AND valuenum > 0 -- lab values cannot be 0 and cannot be negative
) pvt
GROUP BY pvt.hadm_id, pvt.hr
ORDER BY pvt.hadm_id, pvt.hr;
"



# ---------------- 8. uo
# REQUIRES MP_COHORT_1


# CREATE TABLE 

############# mp_uo_1 


q8a <- " AS
select
  icustay_id
  , hr
  , sum(UrineOutput) as UrineOutput
from
(
  select
  -- patient identifiers
    co.icustay_id
  , ceil(extract(EPOCH from oe.charttime-co.intime)/60.0/60.0)::smallint as hr
  -- volumes associated with urine output ITEMIDs
  -- note we consider input of GU irrigant as a negative volume
  , case when oe.itemid = 227489 then -1*oe.value
      else oe.value end as UrineOutput
  from " 
  
############### mp_cohort_1 
  
q8b <- " co
  -- Join to the outputevents table to get urine output
  inner join outputevents oe
    on co.icustay_id = oe.icustay_id
  -- exclude rows marked as error
  where oe.iserror IS DISTINCT FROM 1
  and co.excluded = 0
  and itemid in
  (
  -- these are the most frequently occurring urine output observations in CareVue
  40055, -- 'Urine Out Foley'
  43175, -- 'Urine .'
  40069, -- 'Urine Out Void'
  40094, -- 'Urine Out Condom Cath'
  40715, -- 'Urine Out Suprapubic'
  40473, -- 'Urine Out IleoConduit'
  40085, -- 'Urine Out Incontinent'
  40057, -- 'Urine Out Rt Nephrostomy'
  40056, -- 'Urine Out Lt Nephrostomy'
  40405, -- 'Urine Out Other'
  40428, -- 'Urine Out Straight Cath'
  40086,--	Urine Out Incontinent
  40096, -- 'Urine Out Ureteral Stent #1'
  40651, -- 'Urine Out Ureteral Stent #2'
  
  -- these are the most frequently occurring urine output observations in CareVue
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
  )
) t1
group by t1.icustay_id, t1.hr
order by t1.icustay_id, t1.hr;
"






