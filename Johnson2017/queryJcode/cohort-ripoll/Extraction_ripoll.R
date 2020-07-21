
# =========== 3. filtered cohort (time series) and death info =========== #
# COMMENT:
# only ripoll 2014 study, 2250 patients 
# the following data is in csv, relatively large. It has to be segmented into 
# individual patient lists. 




# try cohort 1
# coh1 <- selectCohortRipoll2014(charteventsindex = 1)
# 
# coh1$resSelect %>% dim
# coh1$resSelectDeathInfo

# try cohort 10
# coh10 <- selectCohortRipoll2014(charteventsindex = 10)
# coh10$resSelectDeathInfo
# dim(coh10$resSelect)

# try bind them together into one
# all.equal(colnames(coh1$resSelect), colnames(coh10$resSelect))
# head(coh1$resSelect)
# new <- rbindlist(l = list(coh1$resSelect, coh10$resSelect))




# ------- select and merge --------- # 
cohortTSList <- list()
cohortInfoList <- list()

for (i in 1:50){
  cohortSelected <- selectCohortRipoll2014(charteventsindex = i)
  cohortTSList[[i]] <- cohortSelected$resSelect
  cohortInfoList[[i]] <- cohortSelected$resSelectDeathInfo
  cat(paste0('Subcohort ', i, ' done \n'))
}

# bind
cohortTSAll <- rbindlist(l = cohortTSList)
cohortInfoAll <- rbindlist(l = cohortInfoList)



cohortTSAll %>% dim   # 533918, 56
cohortInfoAll %>% dim # 2250 patients, 6

write.csv(cohortTSAll, paste0('~/Documents/Data/MIMIC-Ripoll2014/', 'cohortTSAll.csv'))
write.csv(cohortInfoAll, paste0('~/Documents/Data/MIMIC-Ripoll2014/', 'cohortInfoAll.csv'))



