# helper functions for extracting Johnson2017 cohort (First start with Ripoll)

# -------------- query for creating preparation tables ----------------- #

# 1. create query for each individual ce tables 

createQueryJ <- function(tablenames, charteventsindex){
  
  cat(paste0('Creating queries associated with chartevent ', charteventsindex), '\n') 
  
  ceName <- paste0('ce_', charteventsindex)
  NamesWithIndex <- paste0(tablenames, charteventsindex)   # replace: tablenames
  
  qDROP <- "DROP TABLE IF EXISTS "
  qCASCADE <- " CASCADE;"
  qCREATE <- "CREATE TABLE "
  
  # query for drop table if exist
  qDropTables <- paste0(qDROP, NamesWithIndex, qCASCADE)
  
  
  # 1. cohort 
  qCohort <- paste0(qCREATE, NamesWithIndex[1], q1a, ceName, q1b)
  # 1.2 hourly cohort
  qHourlyCohort <- paste0(qCREATE, NamesWithIndex[2], q1c, NamesWithIndex[1] , q1d) 
  # 2. bg
  qBg <- paste0(qCREATE, NamesWithIndex[3], q2a) 
  # 2.2 bg art 
  qBgart <- paste0(
    qCREATE, NamesWithIndex[4], q2b, ceName, q2c, ceName, q2d, NamesWithIndex[3], 
    q2e, NamesWithIndex[1], q2f) 
  # 3. code status
  qCodeStatus <- paste0(qCREATE, NamesWithIndex[5], q3a, ceName, q3b, NamesWithIndex[1], q3c) 
  # 4. colloid-bolus
  qColloidBolus <- paste0(
    qCREATE, NamesWithIndex[6], q4a, NamesWithIndex[1], q4b, NamesWithIndex[1], 
    q4c, NamesWithIndex[1], q4d, ceName, q4e
  ) 
  # 5. crystalloid-bolus
  qCrystBolus <- paste0(qCREATE, NamesWithIndex[7], q5a, NamesWithIndex[1], q5b, NamesWithIndex[1], q5c) 
  # 6. gcs
  qGcs <- paste0(qCREATE, NamesWithIndex[8], q6a, ceName, q6b, NamesWithIndex[1], q6c, NamesWithIndex[1], q6d) 
  
  # 7. lab
  qLab <- paste0(qCREATE, NamesWithIndex[9], q7a, NamesWithIndex[1], q7b) 
  
  # 8. uo
  qUo <- paste0(qCREATE, NamesWithIndex[10], q8a, NamesWithIndex[1], q8b) 
  
  # 9. vital
  qVital <- paste0(qCREATE, NamesWithIndex[11], q9a, NamesWithIndex[1], q9b, ceName, q9c) 
  # 10.data: hourly_cohort, vital, gcs, uo, bgart, lab
  qData <- paste0(
    qCREATE, NamesWithIndex[12], 
    q10a, NamesWithIndex[2],
    q10b, NamesWithIndex[11], 
    q10c, NamesWithIndex[8], 
    q10d, NamesWithIndex[10], 
    q10e, NamesWithIndex[4], 
    q10f, NamesWithIndex[9], 
    q10g) 
  
  # 11. intime outtime
  qIntimeOuttime <- paste0(qCREATE, NamesWithIndex[13], q11a, ceName, q11b) 
  
  # 12. service
  qService <- paste0(qCREATE, NamesWithIndex[14], q12a, ceName, q12b, ceName, q12c) 
  
  # 13. obs count
  qObscount <- paste0(qCREATE, NamesWithIndex[15], q13a, ceName, q13b, ceName, q13c) 
  
  return(list(qDropTables = qDropTables, 
              qCohort = qCohort, 
              qHourlyCohort = qHourlyCohort, 
              qBg = qBg, 
              qBgart = qBgart, 
              qCodeStatus = qCodeStatus, 
              qColloidBolus = qColloidBolus, 
              qCrystBolus = qCrystBolus, 
              qGcs = qGcs, 
              qLab = qLab, 
              qUo = qUo, 
              qVital = qVital, 
              qData = qData, 
              qIntimeOuttime = qIntimeOuttime, 
              qService = qService, 
              qObscount = qObscount))
  
}








# after every chunk, print out the message of completion

runQueryJ <- function(queryList, tablenames, charteventsindex){
  
  NamesWithIndex <- paste0(tablenames, charteventsindex) 
  
  # first drop tables if exist. necessary to collapse vector into one string 
  cat(paste0('Dropping tables if exist for chartevent ', charteventsindex), '\n')
  dbGetQuery(con, statement = paste(c(queryList$qDropTables), collapse = ""))
  
  
  
  # next create tables 
  cat(paste0('Start creating tables for chartevent ', charteventsindex), '\n')
  
  # 1. cohort
  cat(paste0('Creating ', NamesWithIndex[1]), '\n')
  dbGetQuery(con, statement = queryList$qCohort)
  
  # 1.2 hourly cohort 
  cat(paste0('Creating ', NamesWithIndex[2]), '\n')
  dbGetQuery(con, statement = queryList$qHourlyCohort)
  
  # 2. bg
  cat(paste0('Creating ', NamesWithIndex[3]), '\n')
  dbGetQuery(con, statement = queryList$qBg)
  
  # 2.2 bg art 
  cat(paste0('Creating ', NamesWithIndex[4]), '\n')
  dbGetQuery(con, statement = queryList$qBgart)
  
  # 3. code status
  cat(paste0('Creating ', NamesWithIndex[5]), '\n')
  dbGetQuery(con, statement = queryList$qCodeStatus)
  
  # 4. colloid-bolus
  cat(paste0('Creating ', NamesWithIndex[6]), '\n')
  dbGetQuery(con, statement = queryList$qColloidBolus)
  
  # 5. crystalloid-bolus
  cat(paste0('Creating ', NamesWithIndex[7]), '\n')
  dbGetQuery(con, statement = queryList$qCrystBolus)
  
  # 6. gcs
  cat(paste0('Creating ', NamesWithIndex[8]), '\n')
  dbGetQuery(con, statement = queryList$qGcs)
  
  # 7. lab
  cat(paste0('Creating ', NamesWithIndex[9]), '\n')
  dbGetQuery(con, statement = queryList$qLab)
  
  # 8. uo
  cat(paste0('Creating ', NamesWithIndex[10]), '\n')
  dbGetQuery(con, statement = queryList$qUo)
  
  # 9. vital
  cat(paste0('Creating ', NamesWithIndex[11]), '\n')
  dbGetQuery(con, statement = queryList$qVital)
  
  # 10.data: vital, gcs, uo, bgart, lab
  cat(paste0('Creating ', NamesWithIndex[12]), '\n')
  dbGetQuery(con, statement = queryList$qData)
  
  # 11. intime outtime
  cat(paste0('Creating ', NamesWithIndex[13]), '\n')
  dbGetQuery(con, statement = queryList$qIntimeOuttime)
  
  # 12. service
  cat(paste0('Creating ', NamesWithIndex[14]), '\n')
  dbGetQuery(con, statement = queryList$qService)
  
  # 13. obs count
  cat(paste0('Creating ', NamesWithIndex[15]), '\n')
  dbGetQuery(con, statement = queryList$qObscount)
  
  
}



# --------------- create final cohort ---------------- #

createQueryFinalCohort <- function(charteventsindex){
  
  cat(paste0('Creating queries final cohort ', charteventsindex), '\n') 
  namesNeeded <- c('final_cohort_', 'mp_cohort_', 'mp_bg_art_', 'mp_code_status_', 
                   'mp_intime_outtime_', 'mp_service_', 'mp_obs_count_')
  namesWithIndexShort <- paste0(namesNeeded, charteventsindex)   
  
  # final cohort
  qFinalCohort <- paste0(
    qCREATE, namesWithIndexShort[1], 
    q14a, namesWithIndexShort[4],  # code status
    q14b, namesWithIndexShort[5],  # intime outtime
    q14c, namesWithIndexShort[3],  # bgart
    q14d, namesWithIndexShort[3],  # bgart
    q14e, namesWithIndexShort[3],  # bgart
    q14f, namesWithIndexShort[3],  # bgart
    q14g, namesWithIndexShort[5],  # intime outtime
    q14h, namesWithIndexShort[4],  # code status
    q14i, namesWithIndexShort[5],  # intime outtime
    q14j, namesWithIndexShort[7],  # obscount
    q14k, namesWithIndexShort[6],  # service
    q14l, namesWithIndexShort[2],  # cohort 
    q14m
  )
  return(qFinalCohort = qFinalCohort)
}


runQueryFinalCohort <- function(qFinalCohort, charteventsindex){
  # next create tables 
  cat(paste0('Creating final cohort ', charteventsindex), '\n')
  
  # final cohort 
  dbGetQuery(con, statement = qFinalCohort)
  
}








# -------------- export into csv/list ---------------- #

# 1. time series
exportTScsv <- function(charteventsindex){
  
  cat(paste0('Exporting time series data for cohort ', charteventsindex), '\n')
  
  queryTS <- paste0("SELECT * FROM mp_data_", charteventsindex, ';')
  resultTS <- dbGetQuery(con, statement = queryTS)
  
  # save 
  dataPath <- '~/Documents/Data/MIMICJohnson/TimeSeries/'
  write.csv(resultTS, file = paste0(dataPath, 'TS_', charteventsindex, '.csv'))
}


# 2. final cohort 
exportFCcsv <- function(charteventsindex){
  
  cat(paste0('Exporting final cohort data for cohort ', charteventsindex), '\n')
  
  queryFC <- paste0("SELECT * FROM final_cohort_", charteventsindex, ';')
  resultFC <- dbGetQuery(con, statement = queryFC)
  
  # save 
  dataPath <- '~/Documents/Data/MIMICJohnson/FinalCohort/'
  write.csv(resultFC, file = paste0(dataPath, 'FC_', charteventsindex, '.csv'))
}





