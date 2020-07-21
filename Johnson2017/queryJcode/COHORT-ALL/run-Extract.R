# run the actual extraction 


# probably first create all the necessary dependencies (until 13)
# for the first 10 CE
# then extract the collective cohort and time series data 

tableNames <- c('mp_cohort_', 'mp_hourly_cohort_', 'mp_bg_', 'mp_bg_art_', 
                'mp_code_status_', 'mp_colloid_bolus_',                    # 1-4
                'mp_crystalloid_bolus_', 'mp_gcs_', 'mp_lab_', 'mp_uo_',   # 5-8
                'mp_vital_', 'mp_data_', 'mp_intime_outtime_', 'mp_service_', 
                'mp_obs_count_'         # 9-13
                )  
ceName <- 'ce_'

source('./DBconnect.R')
source('./Johnson2017/queryJcode/JqueryStrings1-4.R')
source('./Johnson2017/queryJcode/JqueryStrings5-8.R')
source('./Johnson2017/queryJcode/JqueryStrings9-13.R')
source('./Johnson2017/queryJcode/JqueryStringsFinalCoh(14).R')
source('./Johnson2017/queryJcode/JqueryStringSelect.R')
source('./Johnson2017/queryJcode/helpers-1-RqueryR.R')




# ceIndex <- 1  # up to 50 eventually
# NamesWithIndex[1]
# --------- 1. create query and run for the preparation tables -------- # 
queries1 <- createQueryJ(tablenames = tableNames, 
                         charteventsindex = 1)

# time it: circa 2.3 min 
Start <- Sys.time()
runQueryJ(queryList = queries1, 
            tablenames = tableNames, 
            charteventsindex = 1)
print(Sys.time() - Start)






# --------- 1.2. create 2-10 preparation tables -------- # 

queries1 <- createQueryJ(tablenames = tableNames, 
                        charteventsindex = 1)


# function to create more preparation tables 
createMoreJ <- function(indexStart, indexEnd){
  for (i in indexStart:indexEnd){
    queries <- createQueryJ(tablenames = tableNames, 
                            charteventsindex = i)
    runQueryJ(queryList = queries, 
              tablenames = tableNames, 
              charteventsindex = i)

  }
  
}
Start <- Sys.time()
createMoreJ(indexStart = 2, indexEnd = 10)
print(Sys.time() - Start)


# repeat for all other 40 tables 
Start <- Sys.time()
createMoreJ(indexStart = 11, indexEnd = 20)
print(Sys.time() - Start)

Start <- Sys.time()
createMoreJ(indexStart = 21, indexEnd = 30)
print(Sys.time() - Start)

Start <- Sys.time()
createMoreJ(indexStart = 31, indexEnd = 40)
print(Sys.time() - Start)

Start <- Sys.time()
createMoreJ(indexStart = 41, indexEnd = 50)
print(Sys.time() - Start)



# -- export patient time series data -- # 
# the function exportTScsv already has the path specified. 
exportTScsv(charteventsindex = 1)
test <- read.csv('~/Documents/Data/MIMICJohnson/TimeSeries/TS_1.csv')
head(test)


for (i in 2:50){
  exportTScsv(charteventsindex = i)
}







# =============== 2. final cohort information ============= # 

finalcohortMoreJ <- function(indexStart, indexEnd){
  for (i in indexStart:indexEnd){
    queryFinalCohort <- createQueryFinalCohort(charteventsinde = i)
    runQueryFinalCohort(qFinalCohort = queryFinalCohort,
                        charteventsindex = i)
    
  }
  
}
Start <- Sys.time()
finalcohortMoreJ(indexStart = 4, indexEnd = 10)
print(Sys.time() - Start)


Start <- Sys.time()
finalcohortMoreJ(indexStart = 11, indexEnd = 50)
print(Sys.time() - Start)



# -- export patient static data -- # 

exportFCcsv(charteventsindex = 1)
test <- read.csv('~/Documents/Data/MIMICJohnson/FinalCohort/FC_1.csv')
head(test)


for (i in 2:50){
  exportFCcsv(charteventsindex = i)
}



