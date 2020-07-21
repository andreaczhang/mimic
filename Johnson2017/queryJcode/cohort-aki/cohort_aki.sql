-- CELI AKI
-- inclusion_only_mimicii
-- inclusion_over_18
-- inclusion_aki_icd9
-- hospital_expire_flag


SELECT 
    co.subject_id, co.hadm_id, co.icustay_id
    , ceil(extract(epoch FROM (co.outtime - co.intime))/60.0/60.0) as dischtime_hours
    , ceil(extract(epoch FROM (adm.deathtime - co.intime))/60.0/60.0) as deathtime_hours
    , CASE WHEN adm.deathtime is null then 0 else 1 end as death
    FROM 
    mp_cohort_1 -- REPLACE
    
     co
    INNER JOIN admissions adm
    on co.hadm_id = adm.hadm_id
    WHERE co.excluded = 0
    and icustay_id IN (
        SELECT icustay_id FROM 
       final_cohort_1 AS fc  -- REPLACE 
        
  WHERE fc.inclusion_only_mimicii = 1
    AND fc.inclusion_over_18 =1
    AND fc.inclusion_aki_icd9 = 1
    AND fc.hospital_expire_flag = 1
) ORDER BY icustay_id
;      