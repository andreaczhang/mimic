# examine the tables created by johnson 2017 code
library(magrittr)
library(dplyr)
library(purrr)



dataPath_ts <- '~/Documents/Data/MIMICJohnson/TimeSeries/'
dataPath_fc <- '~/Documents/Data/MIMICJohnson/FinalCohort/'

ts1 <- read.csv(paste0(dataPath_ts, 'TS_1.csv'))
glimpse(ts1)


fc1 <- read.csv(paste0(dataPath_fc, 'FC_1.csv'))
glimpse(fc1)
# 1266

# how are these two linked? 
ts1$icustay_id %>% unique %>% length
ts1$subject_id %>% unique %>% length
ts1$hadm_id %>% unique %>% length


fc1$icustay_id %>% unique %>% length
fc1$subject_id %>% unique %>% length
fc1$hadm_id %>% unique %>% length
# seems to be a bit unmatched


