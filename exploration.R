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

