--------------------------------------------------------
-- Load data directly from gzip files. 
-- This is NOT ALL tables, since I don't need all of them
--------------------------------------------------------

\copy ADMISSIONS FROM PROGRAM 'gzip -dc ADMISSIONS.csv.gz' DELIMITER ',' CSV HEADER NULL ''

\copy CHARTEVENTS from PROGRAM 'gzip -dc CHARTEVENTS.csv.gz' delimiter ',' csv header NULL ''

\copy DATETIMEEVENTS from PROGRAM 'gzip -dc DATETIMEEVENTS.csv.gz' delimiter ',' csv header NULL ''

\copy DIAGNOSES_ICD from PROGRAM 'gzip -dc DIAGNOSES_ICD.csv.gz' delimiter ',' csv header NULL ''

\copy DRGCODES from PROGRAM 'gzip -dc DRGCODES.csv.gz' delimiter ',' csv header NULL ''

\copy D_ICD_DIAGNOSES from PROGRAM 'gzip -dc D_ICD_DIAGNOSES.csv.gz' delimiter ',' csv header NULL ''

\copy D_ICD_PROCEDURES from PROGRAM 'gzip -dc D_ICD_PROCEDURES.csv.gz' delimiter ',' csv header NULL ''

\copy D_ITEMS from PROGRAM 'gzip -dc D_ITEMS.csv.gz' delimiter ',' csv header NULL ''


\copy D_LABITEMS from PROGRAM 'gzip -dc D_LABITEMS.csv.gz' delimiter ',' csv header NULL ''


\copy ICUSTAYS from PROGRAM 'gzip -dc ICUSTAYS.csv.gz' delimiter ',' csv header NULL ''


\copy INPUTEVENTS_CV from PROGRAM 'gzip -dc INPUTEVENTS_CV.csv.gz' delimiter ',' csv header NULL ''

\copy INPUTEVENTS_MV from PROGRAM 'gzip -dc INPUTEVENTS_MV.csv.gz' delimiter ',' csv header NULL ''


\copy LABEVENTS from PROGRAM 'gzip -dc LABEVENTS.csv.gz' delimiter ',' csv header NULL ''

\copy MICROBIOLOGYEVENTS from PROGRAM 'gzip -dc MICROBIOLOGYEVENTS.csv.gz' delimiter ',' csv header NULL ''

\copy NOTEEVENTS from PROGRAM 'gzip -dc NOTEEVENTS.csv.gz' delimiter ',' csv header NULL ''


\copy OUTPUTEVENTS from PROGRAM 'gzip -dc OUTPUTEVENTS.csv.gz' delimiter ',' csv header NULL ''


\copy PATIENTS from PROGRAM 'gzip -dc PATIENTS.csv.gz' delimiter ',' csv header NULL ''

\copy PRESCRIPTIONS from PROGRAM 'gzip -dc PRESCRIPTIONS.csv.gz' delimiter ',' csv header NULL ''


\copy PROCEDUREEVENTS_MV from PROGRAM 'gzip -dc PROCEDUREEVENTS_MV.csv.gz' delimiter ',' csv header NULL ''


\copy PROCEDURES_ICD from PROGRAM 'gzip -dc PROCEDURES_ICD.csv.gz' delimiter ',' csv header NULL ''

-- \copy CALLOUT from 'CALLOUT.csv' delimiter ',' csv header NULL ''
-- \copy CAREGIVERS from 'CAREGIVERS.csv' delimiter ',' csv header NULL ''
-- \copy CPTEVENTS from 'CPTEVENTS.csv' delimiter ',' csv header NULL ''
-- \copy D_CPT from 'D_CPT.csv' delimiter ',' csv header NULL ''
\copy SERVICES from PROGRAM 'gzip -dc SERVICES.csv.gz' delimiter ',' csv header NULL ''
-- \copy TRANSFERS from 'TRANSFERS.csv' delimiter ',' csv header NULL ''
