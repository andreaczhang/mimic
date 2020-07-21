# ---------- select patients with acute kidney failure  ----------- # 

# ---- start with time series ---- # 

qSelecta <- "SELECT * FROM "

############ mp_data_1 


qSelectb <- " WHERE icustay_id IN (
    SELECT icustay_id FROM "

############ final_cohort_1

qSelectc <- " AS fc -- REPLACE
 WHERE fc.inclusion_only_mimicii = 1
    AND fc.inclusion_over_18 =1
    AND fc.inclusion_aki_icd9 = 1
   -- AND fc.hospital_expire_flag = 1
) ORDER BY icustay_id, hr
; "


# ---- static ----- # 


qSelectDeathInfoa <- "
SELECT 
    co.subject_id, co.hadm_id, co.icustay_id
    , ceil(extract(epoch FROM (co.outtime - co.intime))/60.0/60.0) as dischtime_hours
    , ceil(extract(epoch FROM (adm.deathtime - co.intime))/60.0/60.0) as deathtime_hours
    , CASE WHEN adm.deathtime is null then 0 else 1 end as death
    FROM "

############ MP_COHORT_1

qSelectDeathInfob <-   " co
    INNER JOIN admissions adm
    on co.hadm_id = adm.hadm_id
    WHERE co.excluded = 0
    and icustay_id IN (
        SELECT icustay_id FROM "

############ final_cohort_1

qSelectDeathInfoc <-  " AS fc
 
 WHERE fc.inclusion_only_mimicii = 1
    AND fc.inclusion_over_18 =1
    AND fc.inclusion_aki_icd9 = 1
   -- AND fc.hospital_expire_flag = 1
) ORDER BY icustay_id
;"



# -------------- extract ----------- # 


selectCohort_aki <- function(charteventsindex){
  
  
  qSelect <- paste0(
    qSelecta,  paste0('mp_data_', charteventsindex), # mp_data_1 
    qSelectb,  paste0('final_cohort_', charteventsindex), # final_cohort_1
    qSelectc)
  
  qSelectDeathInfo <- paste0(
    qSelectDeathInfoa, paste0('mp_cohort_', charteventsindex), # MP_COHORT_1
    qSelectDeathInfob, paste0('final_cohort_', charteventsindex),# final_cohort
    qSelectDeathInfoc
    
  )
  
  resSelect <- dbGetQuery(con, statement = qSelect)
  resSelectDeathInfo <- dbGetQuery(con, statement = qSelectDeathInfo)
  return(list(resSelect = resSelect, 
              resSelectDeathInfo = resSelectDeathInfo))
}











