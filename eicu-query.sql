-- it is for eicu, but as I don't have a separate project, let's do it here for now

-- first check how many patients there are, and how many unique stays
SELECT DISTINCT patienthealthsystemstayid FROM patient;   -- 1242
SELECT DISTINCT patientunitstayid FROM patient; -- 1447



-- different hospitals 
select distinct hospitalid from patient




-- many fields are empty

SELECT distinct patientunitstayid from nurseassessment;

