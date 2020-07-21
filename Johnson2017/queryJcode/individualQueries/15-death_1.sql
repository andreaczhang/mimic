-- ############# DEATH INFORMATION, CE_1 ##############
-- REQUIRES MP_COHORT_1


select 
    co.subject_id, co.hadm_id, co.icustay_id
    , ceil(extract(epoch from (co.outtime - co.intime))/60.0/60.0) as dischtime_hours
    , ceil(extract(epoch from (adm.deathtime - co.intime))/60.0/60.0) as deathtime_hours
    , case when adm.deathtime is null then 0 else 1 end as death
    from MP_COHORT_1 co
    inner join admissions adm
    on co.hadm_id = adm.hadm_id
    where co.excluded = 0;

