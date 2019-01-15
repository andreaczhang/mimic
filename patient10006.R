# understand the records for patient 10006

# tab1, admission
q <- "
SELECT *
FROM admissions
WHERE subject_id = 10006;"  

q.res <- dbGetQuery(con, q)
q.res


q2 <- "
SELECT subject_id, icd9_code
FROM diagnoses_icd
WHERE subject_id = 10006;

"
q2.res <- dbGetQuery(con, q2); q2.res

q3 <- "
SELECT icd9_code, short_title, long_title
FROM d_icd_diagnoses
WHERE icd9_code = '99591';   
"
# 99591 is sepsis

q3.res <- dbGetQuery(con, q3); q3.res


q4 <- "
SELECT subject_id, diag.icd9_code, short_title, long_title
FROM diagnoses_icd AS diag
INNER JOIN d_icd_diagnoses AS code
ON diag.icd9_code = code.icd9_code
WHERE subject_id = 10006;

"
q4.res <- dbGetQuery(con, q4); q4.res



# --------------- with time stamp: *events 
# 1. chart events 
# note that not everything can be numerically visualised. 

q5 <- "
SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY events.itemid, charttime;
"
q5.res <- dbGetQuery(con, q5); q5.res
head(q5.res)
dim(q5.res)




# 2. input events 

q6 <- "
SELECT subject_id, input.itemid, label, amount, amountuom, rate, rateuom, charttime
FROM inputevents_cv AS input
INNER JOIN d_items AS itemscode
ON input.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY input.itemid;
"
q6.res <- dbGetQuery(con, q6); q6.res
head(q6.res)





# 3. output events 
q7 <- "
SELECT subject_id, output.itemid, label, value, valueuom, charttime
FROM outputevents AS output
INNER JOIN d_items AS itemscode
ON output.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY output.itemid;
"
q7.res <- dbGetQuery(con, q7); q7.res
head(q7.res)

# 4. lab events 
q8 <- "
SELECT subject_id, lab.itemid, label, charttime, value, valuenum, valueuom, flag
FROM labevents AS lab
INNER JOIN d_labitems AS labitemscode
ON lab.itemid = labitemscode.itemid
WHERE subject_id = 10006
ORDER BY lab.itemid, charttime;
"
q8.res <- dbGetQuery(con, q8); q8.res
head(q8.res)

# 5. microbiology events 

q9 <- "
SELECT *
FROM microbiologyevents
WHERE subject_id = 10006
ORDER BY spec_itemid, charttime;
"
q9.res <- dbGetQuery(con, q9); q9.res
head(q9.res)


