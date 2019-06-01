-- TABLES NEEDED TO PRODUCE SAPSII SCORES 

DROP TABLE IF EXISTS gcsfirstday CASCADE;
CREATE TABLE gcsfirstday
(
  ROW_ID INT NOT NULL,
  SUBJECT_ID INT NOT NULL,
  HADM_ID INT NOT NULL,
  ICUSTAY_ID INT NOT NULL,
  MINGCS INT,
  gcsmotor INT,
  gcsverbal INT,
  gcseyes INT,
  endotrachflag INT
) ;

-- IN psql
\copy gcsfirstday FROM 'GCStable.csv' DELIMITER ',' CSV HEADER NULL ''






-- ventdurations

DROP TABLE IF EXISTS ventdurations CASCADE;
CREATE TABLE ventdurations
(
  ROW_ID INT NOT NULL,
  VENTNUM INT,
  ICUSTAY_ID INT NOT NULL,
  starttime TIMESTAMP(0),
  endtime TIMESTAMP(0),
  duratiton_hours DOUBLE PRECISION
) ;

\copy ventdurations FROM 'Venttable.csv' DELIMITER ',' CSV HEADER NULL ''




DROP TABLE IF EXISTS vitalsfirstday CASCADE;
CREATE TABLE vitalsfirstday
(
  ROW_ID INT NOT NULL,
  SUBJECT_ID INT NOT NULL,
  HADM_ID INT NOT NULL,
  ICUSTAY_ID INT NOT NULL,
  heartrate_min DOUBLE PRECISION, 
  heartrate_max DOUBLE PRECISION, 
  heartrate_mean DOUBLE PRECISION, 
  sysbp_min  DOUBLE PRECISION, 
  sysbp_max  DOUBLE PRECISION, 
  sysbp_mean DOUBLE PRECISION, 
  diasbp_min  DOUBLE PRECISION, 
  diasbp_max DOUBLE PRECISION,  
  diasbp_mean  DOUBLE PRECISION, 
  meanbp_min  DOUBLE PRECISION, 
  meanbp_max  DOUBLE PRECISION, 
  meanbp_mean  DOUBLE PRECISION, 
  resprate_min DOUBLE PRECISION,  
  resprate_max  DOUBLE PRECISION, 
  resprate_mean DOUBLE PRECISION, 
  tempc_min  DOUBLE PRECISION, 
  tempc_max  DOUBLE PRECISION, 
  tempc_mean  DOUBLE PRECISION, 
  spo2_min  DOUBLE PRECISION, 
  spo2_max  DOUBLE PRECISION, 
  spo2_mean  DOUBLE PRECISION, 
  glucose_min  DOUBLE PRECISION, 
  glucose_max DOUBLE PRECISION,  
  glucose_mean DOUBLE PRECISION
) ;

\copy vitalsfirstday FROM 'Vitaltable.csv' DELIMITER ',' CSV HEADER NULL ''
