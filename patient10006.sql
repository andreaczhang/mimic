-- table 1, admissions

SELECT *
FROM admissions
WHERE subject_id = 10006;






-- table 2, diagnosis

SELECT subject_id, icd9_code
FROM diagnoses_icd
WHERE subject_id = 10006;



-- relate diagnosis to code 
-- first try one code
SELECT icd9_code, short_title, long_title
FROM d_icd_diagnoses
WHERE icd9_code = '99591';


-- then try many codes together, using INNER JOIN 
SELECT subject_id, diag.icd9_code, short_title, long_title
FROM diagnoses_icd AS diag
INNER JOIN d_icd_diagnoses AS code
ON diag.icd9_code = code.icd9_code
WHERE subject_id = 10006;



-- table 3, chart events
SELECT *
FROM chartevents
WHERE subject_id = 10006;


SELECT subject_id, DISTINCT itemid
FROM chartevents
WHERE subject_id = 10006


SELECT subject_id, itemid, charttime, valuenum, valueuom
FROM chartevents
WHERE subject_id = 10006 AND itemid = 1703
ORDER BY charttime;


SELECT label, itemid 
FROM d_items
WHERE itemid IN (87)

-- 1703 is healthcar proxy 






SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY events.itemid, charttime;


-- now I want to find out with this new table, find only the items  (and their label names) 

WITH patient10006 AS 
(SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY events.itemid, charttime

)
SELECT DISTINCT itemid, label
FROM patient10006;






-- input and output events 
-- from cv, use charttime instead of start/end time
-- for patient 10006, from cv. 

SELECT subject_id, input.itemid, label, amount, amountuom, rate, rateuom, charttime
FROM inputevents_cv AS input
INNER JOIN d_items AS itemscode
ON input.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY input.itemid;


SELECT subject_id, input.itemid, label, value, valueuom, charttime
FROM outputevents AS output
INNER JOIN d_items AS itemscode
ON output.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY output.itemid;




-- lab events 
SELECT subject_id, lab.itemid, label, charttime, value, valuenum, valueuom, flag
FROM labevents AS lab
INNER JOIN d_labitems AS labitemscode
ON lab.itemid = labitemscode.itemid
WHERE subject_id = 10006
ORDER BY lab.itemid, charttime;


-- microbiology 
SELECT *
FROM microbiologyevents
WHERE subject_id = 10006
ORDER BY spec_itemid, charttime;



