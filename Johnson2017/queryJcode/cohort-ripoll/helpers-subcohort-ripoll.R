# contains strings for selecting the final cohort 
# to start with, use sepsis definitions 
# ------------- select data from sepsis cohort  ------------------ # 


qSelecta <- "SELECT * FROM "

############ mp_data_1 


qSelectb <- " WHERE icustay_id IN (
    SELECT icustay_id FROM "

############ final_cohort_1

qSelectc <- " WHERE inclusion_only_mimicii = 1
    AND inclusion_has_saps = 1
    AND inclusion_not_explicit_sepsis = 1
    AND inclusion_over_18 =1
) ORDER BY icustay_id
; "






# ------------- death info ------------------ # 
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

qSelectDeathInfoc <-  " WHERE inclusion_only_mimicii = 1
        AND inclusion_has_saps = 1
        AND inclusion_not_explicit_sepsis = 1
        AND inclusion_over_18 =1
) ORDER BY icustay_id
;"


# -------------- final cohort time series and death info ----------------- #

selectCohortRipoll2014 <- function(charteventsindex){
  
  
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

