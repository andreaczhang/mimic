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


SELECT subject_id, output.itemid, label, value, valueuom, charttime
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


-- ================= try to aggregate chartevents with input 
-- use full outer join to solve 
----- inner join isn't appropriate: those not in both time points will be lost 

SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
INTO events10006
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10006;


SELECT subject_id, input.itemid, label, amount, amountuom, rate, rateuom, charttime
INTO input10006
FROM inputevents_cv AS input
INNER JOIN d_items AS itemscode
ON input.itemid = itemscode.itemid
WHERE subject_id = 10006;


SELECT subject_id, output.itemid, label, value, valueuom, charttime
INTO output10006
FROM outputevents AS output
INNER JOIN d_items AS itemscode
ON output.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY output.itemid;




SELECT events10006.subject_id, 
        events10006.itemid AS event_item, 
        events10006.charttime, 
        events10006.label AS event_label, 
        events10006.value AS event_value, 
        events10006.valuenum AS event_valuenum, 
        events10006.valueuom AS event_valueuom, 

        input10006.itemid AS input_item, 
        input10006.label AS input_label, 
        input10006.amount AS input_amount, 
        input10006.amountuom AS input_amountuom, 
        input10006.rate AS input_rate, 
        input10006.rateuom AS input_rateuom, 
        input10006.charttime AS input_charttime, 

        output10006.itemid AS output_item, 
        output10006.label AS output_label, 
        output10006.value AS output_value, 
        output10006.valueuom AS output_valueuom, 
        output10006.charttime AS output_charttime 

FROM events10006
FULL OUTER JOIN input10006  
USING (charttime)
FULL OUTER JOIN output10006
USING (charttime)
ORDER BY charttime;




