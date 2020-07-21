-- ############ FOR CE_1 ############## 



-- The aim of this query is to pivot entries related to blood gases and
-- chemistry values which were found in LABEVENTS

DROP TABLE IF EXISTS mp_bg_1 CASCADE;
CREATE TABLE mp_bg_1 as
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






-- ############ FOR CE_1 ############## 
-- REQUIRES CE_1, MP_COHORT_1, MP_BG_1





DROP TABLE IF EXISTS mp_bg_art CASCADE;
CREATE TABLE mp_bg_art_1 AS
with stg_spo2 as
(
  select HADM_ID, CHARTTIME
    -- max here is just used to group SpO2 by charttime
    , avg(valuenum) as SpO2
  from ce_1 
  -- o2 sat
  where ITEMID in
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
  from ce_1
  where ITEMID in
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
from mp_bg_1 bg
inner join mp_cohort_1 co
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
