library(magrittr)
library(data.table)
source('./CohortCode/queryGeneral/DBconnect.R')
source('./Johnson2017/queryJcode/cohort-aki/helpers-subcohort-aki.R')

# cohort 1 

# coh1 <- selectCohort_aki(charteventsindex = 1)
# 
# coh1$resSelect$icustay_id
# 
# 
# unique(coh1$resSelect$icustay_id) # %>% sort(decreasing = F)
# coh1$resSelectDeathInfo$icustay_id # %>% sort(decreasing = F)




# do it for 1 to 50
cohortTS_akiList <- list()
cohortInfo_akiList <- list()

for (i in 1:50){
  cohortSelected <- selectCohort_aki(charteventsindex = i)
  cohortTS_akiList[[i]] <- cohortSelected$resSelect
  cohortInfo_akiList[[i]] <- cohortSelected$resSelectDeathInfo
  cat(paste0('Subcohort ', i, ' done \n'))
}

# bind
cohortTS_akiAll <- rbindlist(l = cohortTS_akiList)
cohortInfo_akiAll <- rbindlist(l = cohortInfo_akiList)



cohortTS_akiAll %>% dim   # 762422, 56
cohortInfo_akiAll %>% dim # 4739 patients, 6

cohortInfo_akiAll$dischtime_hours %>% summary

cohortInfo_akiAll$death %>% sum/4739
# 811


write.csv(cohortTS_akiAll, paste0('~/Documents/Data/AKI/', 'cohortTS_akiAll.csv'))
write.csv(cohortInfo_akiAll, paste0('~/Documents/Data/AKI/', 'cohortInfo_akiAll.csv'))






# ----- make the time series data more workable ---- # 
# drop the first few columns, use icustay id as the index 

ts <- cohortTS_akiAll
length(unique(ts$subject_id))  # 3759 unique patients
length(unique(ts$hadm_id))     # 4271

colnames(ts)
head(ts)
ts2 <- ts[, 3:ncol(ts)]
colnames(ts2)

icustayIDs <- unique(ts2$icustay_id)

patientList <- function(allDF, unqIcustay){
  
  individualPatient <- list()
  for (i in 1:length(unqIcustay)){
    
    rowindex <- which(allDF$icustay_id == unqIcustay[i])
    individualPatient[[i]] <- allDF[rowindex, ]
    
  }
  names(individualPatient) <- paste0('icustay_', unqIcustay)
  return(individualPatient = individualPatient)
}

pList <- patientList(allDF = ts2, unqIcustay = icustayIDs)
pList$icustay_200066
saveRDS(pList, file = paste0('~/Documents/Data/AKI/patientList.RData'))
# static$icustay_id %>% head





