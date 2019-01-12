/* ---------------- record what I can query from MIMIC dataset ----------- */

-- start with a single table 
SELECT subject_id, dob, gender FROM patients;

SELECT * FROM patients WHERE subject_id = 109;

SELECT *
FROM patients
WHERE subject_id IN (10006, 10011, 10013);


SELECT *
FROM icustays
WHERE first_careunit LIKE '%ICU';

-- JOIN different tables

SELECT p.subject_id, p.dob, a.hadm_id, a.admittime, icu.los
FROM patients AS p
INNER JOIN admissions AS a
ON p.subject_id = a.subject_id
INNER JOIN icustays AS icu
ON p.subject_id = i.subject_id
ORDER BY subject_id, hadm_id;

-- Use if/else logic to categorise length of stay
-- into 'short', 'medium', and 'long'

SELECT subject_id, hadm_id, icustay_id, los,
    CASE WHEN los < 2 THEN 'short'
         WHEN los >=2 AND los < 7 THEN 'medium'
         WHEN los >=7 THEN 'long'
         ELSE NULL END AS los_group      -- create a new column in the table 
FROM icustays;


SELECT subject_id, -- gender, CASE WHEN will add a new column as a selected column. 
    CASE WHEN gender = 'F' THEN 0
         WHEN gender = 'M' THEN 1
         ELSE NULL END AS gender 
         FROM patients;



SELECT label FROM d_items WHERE itemid = 211;

SELECT * FROM chartevents WHERE itemid = 211;
SELECT valuenum, valuenum FROM chartevents WHERE itemid IN (211, 220045);

SELECT MAX(valuenum) AS max_heartrate
FROM chartevents 
WHERE itemid IN (211, 220045)
GROUP BY subject_id
HAVING max(valuenum) <= 140;



-- find the order of admissions to the ICU for a patient
-- for some patients, the rows will be more than 1
-- by ordering intime gives the first visit 
-- RANK will create a column 'rank' with the orders. 
SELECT subject_id, icustay_id, intime,
    RANK() OVER (PARTITION BY subject_id ORDER BY intime)
FROM icustays;

-- select only the first ICU stay of each patient 
WITH icustayorder AS (
SELECT subject_id, icustay_id, intime,
  RANK() OVER (PARTITION BY subject_id ORDER BY intime)
FROM icustays
)
SELECT *
FROM icustayorder
WHERE rank = 1;

-- WITH firststay AS (
    WITH stayorder AS (
        SELECT subject_id, intime, los,
        RANK() OVER (PARTITION BY subject_id 
                    ORDER BY intime)
        FROM icustays
    )
    SELECT subject_id, los 
    FROM stayorder
    WHERE rank = 1)
-- SELECT subject_id, los
-- FROM firststay;



/* --------------- multiple temporary views (WITH) ----------- */

WITH serv as (
  SELECT subject_id, hadm_id, transfertime, prev_service, curr_service,
    RANK() OVER (PARTITION BY hadm_id ORDER BY transfertime) as rank
  FROM services
)
, icu as
(
  SELECT subject_id, hadm_id, icustay_id, intime, outtime
  FROM icustays
)
SELECT COUNT(*)
FROM icu
INNER JOIN serv
ON icu.hadm_id = serv.hadm_id
AND serv.rank = 1;


