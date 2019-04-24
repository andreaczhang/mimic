install.packages('tidyverse')

# first attempt to connect to db
install.packages('RPostgreSQL')
library(RPostgreSQL)

# ================ 1. connection

# create a connection
# save the password that we can "hide" it as best as we can by collapsing it
pw <- {
  "andrea"
}


drv <- dbDriver("PostgreSQL")      # loads the PostgreSQL driver
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, 
                 dbname = "demo",
                 host = "localhost", 
                 port = 5432,
                 user = "chizhang", 
                 password = pw)
rm(pw) # removes the password

# check tables 
dbExistsTable(con, "admissions")  # this works
# TRUE



# ================ 2. load data 
que <- 'SELECT subject_id FROM admissions'  # this could also work


class(dfsports) # it's a dataframe





# ================ 3. close connection
dbDisconnect(con)
dbUnloadDriver(drv)




# ====================== # 
# for big mimic data base 


conbig <- dbConnect(drv, 
                 dbname = "mimicbig",
                 host = "localhost", 
                 port = 5432,
                 user = "chizhang", 
                 password = pw)
rm(pw) # removes the password

dbExistsTable(conbig, "admissions")  # this works




# after connection, go through the tutorial and check the outputs from DB



que <- "SELECT *
        FROM patients
        WHERE subject_id IN (10006, 10011, 10013);"  # necessary to distinguish the two quotes


que2 <- "SELECT *
FROM icustays
WHERE first_careunit LIKE '%ICU';"


# join more than 1 tables, link with subject id.

que3 <- "
SELECT * FROM icustays AS icu
INNER JOIN admissions AS adm
ON icu.hadm_id = adm.hadm_id
INNER JOIN patients AS pat
on icu.subject_id = pat.subject_id
"

que4 <- "
SELECT subject_id, hadm_id, icustay_id, los,
    CASE WHEN los < 2 THEN 'short'
WHEN los >=2 AND los < 7 THEN 'medium'
WHEN los >=7 THEN 'long'
ELSE NULL END AS los_group
FROM icustays;

"

# both 211 and 220045 are heart rate
que5 <- "
SELECT label FROM d_items WHERE itemid IN (211, 220045) ;
"

que.res2 <- dbGetQuery(con, 
                      que5)
que.res2

# retrieve maximum heart rate value for each patient, only for below 140. 
que6 <- "
SELECT MAX(valuenum) AS max_heartrate
FROM chartevents 
WHERE itemid IN (211, 220045)
GROUP BY subject_id
HAVING max(valuenum) <= 140;

"


que7 <- "
SELECT value, valuenum FROM chartevents WHERE itemid IN (211, 220045);
"

que.res <- dbGetQuery(con, 
                       que7)

dim(que.res)
que.res
head(que.res)
str(que.res)  # value is a character, and valuenum is a numeric
# class(que.res) # it's a dataframe





# ----------- length of stay 
que8 <- "
SELECT los 
FROM icustays;
"
que.res <- dbGetQuery(con, 
                      que8)

hist(que.res$los, breaks = 25)




# ========== update March 17 
# try to read from a .sql 

library(readr)
df <- dbGetQuery(con, statement = read_file('simple_query.sql'))



q <- "
SELECT *
FROM patients
WHERE subject_id IN (10006);
"

dbGetQuery(con, statement = q)

#  now I want to replace 10006 with 10011, 10013 respectively 
# empty string: " "
newval <- c(10006, 10011, 10045)

string1 <- "SELECT * FROM patients WHERE subject_id IN ("
string2 <-  ")"

patientDF <- list()
for (i in 1:length(newval)){
  qnew <- paste0(
    string1, newval[i], string2
  )
  
  patientDF[[i]] <- dbGetQuery(con, statement = qnew)
  
}


library(tidyverse)
library(reshape2)

# find a quick way to display the graphs 
dat49 <- readRDS('resultsPatientDF.RData')

length(dat49)

# how many hours in ICU? 
nHoursIn <- rep(0, 49)
for (i in 1:49){
  nHoursIn[i] <- nrow(dat49[[i]])
}



# ================ still use 10006 as example 
p10006 <- dat49[[1]]
head(p10006)

plottable <- p10006[, c(3, 5:ncol(p10006))]
head(plottable)
meltplottable <- melt(plottable, id = 'hours_in')
head(meltplottable)


# separate the time series into more reasonable scaling groups 
variableGroup1 <- c('heartrate', 'respiratoryrate', 'diastolicnbp', 
                    'systolicnbp', 'meannbp', 'temperature')
variableGroup2 <- setdiff(colnames(plottable)[-1], variableGroup1)  # -1 for time


variables1 <- plottable[, variableGroup1] %>% cbind(plottable[1], .)  # add back time 
variables2 <- plottable[, variableGroup2] %>% cbind(plottable[1], .)

melt1 <- melt(variables1, id = 'hours_in')

ggplot(melt1, aes(hours_in, value, 
                  colour = variable, group = variable)) + 
  geom_point() + 
  geom_line()


melt2 <- melt(variables2, id = 'hours_in')

ggplot(melt2, aes(hours_in, value, 
                  colour = variable, group = variable)) + 
  geom_point()+ 
  geom_line()
# p10006 has too few hours 
# try one with longer hours 


# ================ still use 10006 as example 
p10011 <- dat49[[3]]

plottable <- p10011[, c(3, 5:ncol(p10011))]
# head(plottable)
meltplottable <- melt(plottable, id = 'hours_in')
# head(meltplottable)


# separate the time series into more reasonable scaling groups 
variableGroup1 <- c('heartrate', 'respiratoryrate', 'diastolicnbp', 
                    'systolicnbp', 'meannbp', 'temperature')
variableGroup2 <- setdiff(colnames(plottable)[-1], variableGroup1)  # -1 for time


variables1 <- plottable[, variableGroup1] %>% cbind(plottable[1], .)  # add back time 
variables2 <- plottable[, variableGroup2] %>% cbind(plottable[1], .)

melt1 <- melt(variables1, id = 'hours_in')

ggplot(melt1, aes(hours_in, value, 
                  colour = variable, group = variable)) + 
  geom_point() + 
  geom_line()


melt2 <- melt(variables2, id = 'hours_in')

ggplot(melt2, aes(hours_in, value, 
                  colour = variable, group = variable)) + 
  geom_point()+ 
  geom_line()















