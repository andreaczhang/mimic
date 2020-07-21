-- ################ CE_1 ##################
-- SELECT THE SUBCOHORT THAT MAKES RIPOLL2014
-- REQUIRES MP_DATA_1, FINAL_COHORT_1 



SELECT * FROM mp_data_1 
WHERE icustay_id IN (
    SELECT icustay_id FROM final_cohort_1
    WHERE inclusion_only_mimicii = 1
    AND inclusion_has_saps = 1
    AND inclusion_not_explicit_sepsis = 1
    AND inclusion_over_18 =1
)ORDER BY icustay_id
; 



-- DEATH INFO 

SELECT 
    co.subject_id, co.hadm_id, co.icustay_id
    , ceil(extract(epoch FROM (co.outtime - co.intime))/60.0/60.0) as dischtime_hours
    , ceil(extract(epoch FROM (adm.deathtime - co.intime))/60.0/60.0) as deathtime_hours
    , CASE WHEN adm.deathtime is null then 0 else 1 end as death
    FROM MP_COHORT_1 co
    INNER JOIN admissions adm
    on co.hadm_id = adm.hadm_id
    WHERE co.excluded = 0
    and icustay_id IN (
        SELECT icustay_id FROM final_cohort_1
        WHERE inclusion_only_mimicii = 1
        AND inclusion_has_saps = 1
        AND inclusion_not_explicit_sepsis = 1
        AND inclusion_over_18 =1
)ORDER BY icustay_id
;


-- CABALLERO, RANDOM SUBSAMPLE (HENCE MUCH MORE INCLUDED )

/*
SELECT * FROM final_cohort_1
WHERE inclusion_only_mimicii = 1
AND inclusion_over_18 =1; 

*/
