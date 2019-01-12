# Postgresql using bash 

my credentials: chizhang. password: andrea

## installation

https://www.postgresql.org/download/macosx/

```bash
# install homebrew

brew install postgresql
brew services stop postgresql  
brew services start postgresql  # necessary
```

check version

```bash
postgres -V  
```



### install a graphical user interface

I choose postico







## Getting started

Start

```bash
psql postgres
```



### Create user

create with psql (`CREATE ROLE`) and give it permission `ALTER ROLE`.

```bash
postgres=# CREATE ROLE chizhang WITH LOGIN PASSWORD 'mypassword'; (andrea is my password)
postgres=# ALTER ROLE chizhang CREATEDB;
```

both show some information of the database

```bash
postgres=# \du
postgres=> \list
```



to quit

```bash
postgres=# \q 
```



### connect to a default database

change user, then create database. The prompt  `>` indicate now it's not a super user account (andrea). 

```bash
andrea$ psql postgres -U chizhang
CREATE DATABASE mimicdata;
postgres=> GRANT ALL PRIVILEGES ON DATABASE mimicdata TO chizhang;


-------- updated 12.2

CREATE DATABASE demo;
postgres=> GRANT ALL PRIVILEGES ON DATABASE demo TO chizhang;
postgres=> \connect demo 
demo=> \dt 

-------- updated 18.1.10

# in postico, let user chizhang connect to database demo. 

```

`\dt` lists the tables in currently connected db





### create and drop table, and import csv

```sql
CREATE TABLE fav_sports3 (

   name char(20),
   age integer,
   sport char(20),
   gender char(20)
);

COPY fav_sports3 FROM '/Users/andrea/Documents/PhdProjects/Project-Paper2/Database/trialdata.csv' DELIMITER ',' CSV HEADER;
SELECT * FROM fav_sports;
```

It's necessary to create table first. 

Must be a super user to copy via command line. Lemme try to get over this by setting chizhang as the superuser

```bash
postgres=# ALTER USER chizhang WITH SUPERUSER;
\du

-- revoke
postgres=# ALTER USER chizhang WITH NOSUPERUSER;

```





Columns must be **consistent with the csv file**. 



to drop table, 

```sql
DROP TABLE tablename
```

change table name, 

```sql
ALTER TABLE table_name RENAME TO new_name;
```







### Data type 

When creating a table, it is necessary to specify the data types. 

```sql
DROP TABLE IF EXISTS ADMISSIONS CASCADE;  -- and all other objects that depends on it
CREATE TABLE ADMISSIONS
(
  ROW_ID INT NOT NULL,   -- not null constraint enforces a column must not accept NULL values
  SUBJECT_ID INT NOT NULL,
  HADM_ID INT NOT NULL,
  ADMITTIME TIMESTAMP(0) NOT NULL,   -- 0 is precision
  DISCHTIME TIMESTAMP(0) NOT NULL,
  DEATHTIME TIMESTAMP(0),
  ADMISSION_TYPE VARCHAR(50) NOT NULL,    -- character varying = variable-length with limit, stores up to n characters
  ADMISSION_LOCATION VARCHAR(50) NOT NULL,
  DISCHARGE_LOCATION VARCHAR(50) NOT NULL,
  INSURANCE VARCHAR(255) NOT NULL,
  LANGUAGE VARCHAR(10),
  RELIGION VARCHAR(50),
  MARITAL_STATUS VARCHAR(50),
  ETHNICITY VARCHAR(200) NOT NULL,
  EDREGTIME TIMESTAMP(0),
  EDOUTTIME TIMESTAMP(0),
  DIAGNOSIS VARCHAR(255),
  HOSPITAL_EXPIRE_FLAG SMALLINT,  -- numeric type, +-32768
  HAS_CHARTEVENTS_DATA SMALLINT NOT NULL,
  CONSTRAINT adm_rowid_pk PRIMARY KEY (ROW_ID),  -- == unique not null
  CONSTRAINT adm_hadm_unique UNIQUE (HADM_ID)  -- unique constraint for all rows
) ;
```



Date and time needs special attention. 

```sql
SET datestyle = dmy;
COPY ADMISSIONS FROM '/Users/andrea/Desktop/Database/DataDemo/ADMISSIONS.csv' DELIMITER ',' CSV HEADER NULL '';

SELECT * FROM ADMISSIONS;
```





# MIMIC dataset (provided, not mine)



### these need to be run everytime

```bash
postgres=> \c mimicdata;
mimicdata=> CREATE SCHEMA mimicdemo;
mimicdata=> set search_path to mimicdemo;
```

In the future need to run these

```bash
Data andrea$ psql 'dbname=mimicdata user=chizhang options=--search_path=mimicdemo'
```





## some exploratories

After having the database, start with the mimic demo datasets. (these are in terminal)

```bash
andrea$ psql postgres -U chizhang
postgres=> \c mimicdata;
mimicdata=> set search_path to mimicdemo;
```

print all table names in mimicdemo

```sql
\dt  -- this is after mimicdemo=>
```

print column names in a table

```sql
SELECT 
 *            
FROM 
 table_name
WHERE        -- filter
 FALSE;
```

count patients

```sql
SELECT COUNT(subject_id) FROM patients;

SELECT COUNT(row_id) FROM  CHARTEVENTS WHERE subject_id = 10065 -- returns how many rows 
```

print 10 rows. better to use order_by

```sql
SELECT * FROM D_CPT LIMIT 10;  -- first 10 rows
SELECT * FROM D_CPT LIMIT 10 OFFSET 3;  -- row 4 to 13

SELECT * FROM D_CPT FETCH FIRST 10 ROW ONLY;   -- same result as the first
SELECT * FROM D_CPT OFFSET 3 ROWS FETCH FIRST 10 ROW ONLY;  -- same as the second
```

select information for one patient 

```sql
SELECT * FROM CHARTEVENTS WHERE subject_id = 10065;
```



SELECT * FROM patients WHERE subject_id = 10065

chartevents

cptevents

datetimeevents

diagnoses_icd

icustays

inputevents_cv

outputevents

labevents

microbiologyevents

noteevents

prescriptions

procedures_icd

services



```sql
-- find all the tables that have the column
SELECT * FROM  INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%subject_id%' LIMIT 3
```













