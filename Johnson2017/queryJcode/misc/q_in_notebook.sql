
-- ######### produce the additional data for cohort ########## 


-- dead information 
-- requires dm_cohort

select 
    co.subject_id, co.hadm_id, co.icustay_id
    , ceil(extract(epoch from (co.outtime - co.intime))/60.0/60.0) as dischtime_hours
    , ceil(extract(epoch from (adm.deathtime - co.intime))/60.0/60.0) as deathtime_hours
    , case when adm.deathtime is null then 0 else 1 end as death
    from dm_cohort co
    inner join admissions adm
    on co.hadm_id = adm.hadm_id
    where co.excluded = 0;
-- 



-- censoring information
select co.icustay_id, min(cs.charttime) as censortime
    , ceil(extract(epoch from min(cs.charttime-co.intime) )/60.0/60.0) as censortime_hours
    from dm_cohort co 
    inner join mp_code_status cs
    on co.icustay_id = cs.icustay_id
    where cmo+dnr+dni+dncpr>0  -- remove cmo_notes
    and co.excluded = 0
    group by co.icustay_id ;   