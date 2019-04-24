# mimic
Here stores code for understanding MIMIC data. 

## Folders

### mimic101

`mimic101.md` gives detailed documentations on how MIMIC database (not demo) is created, in addition to some exploratory understandings on the tables. 

`mimic101.sql `  gives some initial attemps using sql. 

`mimic101.R` connects the database with R, try to query from R, and does some exploratory plots. 

### createMimicDb

`postgres_create_tables.sql` creates tables in postgresql database. 

`postgres_load_data.sql` loads data (unzipped) into postgresql tables created by above. 

`postgres_load_data_mycode.sql` loads data (zipped) into tables created by above. This is useful when I don't want to unzip or it's too time consuming to unzip. 

`cohortPartitionT.sql` (not used) attempts to partition tables. This method is not used because it requires partitions by heritance to be set up before loading data. 

`cohortPartititonM.R` creates 50 quantiles for patient ID (subject_id). Used for partitioning large chartevents for performance.

`cohortPartitionM.sql` partitions table **chartevents** into 50 intervals into materialized views, with names **ce_1, …, ce_50**.



### tableInfo

`table information`: A list of variables and data types for tables in MIMIC database.

`variable_index_carevue`: as the name suggests. 

The other csvs: more detailed indices related to some variables. 



### Project2Sepsis

Subject_id, hadm_id, icustay_id tables for a selected cohort, for project 2. Detailed information see Project 2. 

- `sepsisDeadApr18.csv` for patients who are eventually dead. 

- `sepsisUndeadApr18.csv`



### Project1

Not used for now. 



### someData (not uploaded)

## Others



#### Signal data.md

Information related to signal data in MIMIC database. 

#### Cups_ccs_2015_definitions.yaml

Definition of diagnosis, used by Harutyunyan 2018 paper. 

#### Benchmark.md

Information related to Harutyunyan 2018 benchmark paper. This paper is useful for comparing methods used on MIMIC dataset. 

#### Angus.sql

Angus criteria of sepsis. 