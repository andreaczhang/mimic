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




