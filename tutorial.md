# MIMIC tutorial

## SQL for this dataset 

https://github.com/MIT-LCP/mimic-code/blob/master/tutorials/sql-intro.md

This should help me getting started, at least more tuned for this specific dataset. https://mimic.physionet.org/mimictables/admissions/ for the description of each table



### 1. admissions 

`hadm_id` is the unique admission, corresponding to a patient using `subject_id`. Possible to have multiple `subject_id` with different `hadm_id` for several visits. 

links to <u>patients</u> table. 



### 2. chartevents

`value` is a string, and `valuenum` is a numeric. When querying aggregated value must use `MAX(valuenum)`, for example. 



it is important to notice that there can be multiple ICU stays: we need to decide which one we want to keep. 





It is possible to cerate materialised view of the output. 



### diagnose_icd

Subject (patient) corresponds to his diagnosis, each of them have multiple diagnosis codes (icd9_code). Then icd9_code relate to <u>d_icd_diagnoses table</u>. 



principal and other diagnosis codes: 6 digits, decimal point between 3 and 4

V codes: decimal point between 2 and 3



### icustays

http://data.patientcarelink.org/staffing2017/units.cfm?ID=12&Name=Beth%20Israel%20Deaconess%20Medical%20Center

```sql
SELECT DISTINCT first_careunit FROM icustays;
```

icu types include surgical (SICU), medical (MICU), coronary (CCU), trauma (TSICU), cardiac surgery recovery (CSRU).  



## Example: patient 10006



### Diagnose_icd

99591, ..., 2874, ... ,E8791, ... ,V090, ... etc. total 21 diagnosis. They all relate to harm_id = 142345. Using query 

```sql
SELECT subject_id, diag.icd9_code, short_title, long_title
FROM diagnoses_icd AS diag
INNER JOIN d_icd_diagnoses AS code
ON diag.icd9_code = code.icd9_code
WHERE subject_id = 10006;
```

can print out the diagnosis descriptions. 











## Angus paper 

### infections 

examine how they link the substrings with ICD9 code. 

In appendix 1, they identify the bacterial or fungal infection. By using `substring()` it specifies the first 3, 4, or 5 digits, which corresponds to the main group of the diagnosis.

```sql
SELECT subject_id, hadm_id,
    CASE WHEN SUBSTRING(icd9_code,1,3) IN ('001','002','003','004','005','008','009','010','011',
'012','013','014','015','016','017','018','020','021','022','023','024','025','026','027','030','031','032','033','034','035','036','037','038','039','040','041','090','091','092','093','094','095','096','097','098','100','101','102','103','104','110','111','112','114','115','116','117','118','320','322','324','325','420','421','451','461','462','463','464','465','481','482','485','486','494','510','513','540','541','542','566','567','590','597','601','614','615','616','681','682','683','686','730') THEN 1
        WHEN SUBSTRING(icd9_code,1,4) IN ('5695','5720','5721','5750','5990','7110','7907','9966','9985','9993') THEN 1
        WHEN SUBSTRING(icd9_code,1,5) IN ('49121','56201','56203','56211','56213','56983') THEN 1
        ELSE 0 END AS infection
    FROM diagnoses_icd
```

Examine closely, 

```sql
SELECT icd9_code, short_title, long_title 
FROM d_icd_diagnoses
WHERE SUBSTRING(icd9_code,1,3) IN ('001');
```

will print similar results (actually less, since there are other codes related with cholera too)

```sql
SELECT icd9_code, short_title
FROM d_icd_diagnoses
WHERE short_title LIKE ('%holera%');
```



Just to pick some more, 

- 010: primary tubeculousis, which has 28 sub-diagnosis. 
- 033: whooping cough, 4 sub-diagnosis based on different causes (organism)
- 465: acute upper respiratory infections 

For more than 3 digits, the 4 and 5 digits are used to specify the sub-category. For example we only want 

- 562.01: diverticulitis of small intestine 

and not the others belonging to 562 groups. 



### organ dysfunction

still from diagnoses_icd table 

```sql
SELECT subject_id, hadm_id,
        CASE
        -- Acute Organ Dysfunction Diagnosis Codes
        WHEN substring(icd9_code,1,3) IN ('458','293','570','584') THEN 1
        WHEN substring(icd9_code,1,4) IN ('7855','3483','3481','2874','2875','2869','2866','5734')  THEN 1
        ELSE 0 END AS organ_dysfunction,
        -- Explicit diagnosis of severe sepsis or septic shock
        CASE
        WHEN substring(icd9_code,1,5) IN ('99592','78552')  THEN 1
        ELSE 0 END AS explicit_sepsis
    FROM diagnoses_icd
```



- 458: hypotention (of 6 kinds)
- 99592: severe sepsis. (99591 is sepsis, and many other 995 have nothing to do with sepsis)
- 785.5: cardiovascular shocks 

and so on. 



### Procedures

from procedures, 

```sql
SELECT subject_id, hadm_id,
        CASE
        WHEN substring(icd9_code,1,4) IN ('9670','9671','9672') THEN 1
        ELSE 0 END AS mech_vent
    FROM procedures_icd

```

Using the following code can easily retrieve the names of procedure 

```sql
SELECT icd9_code, short_title, long_title
FROM d_icd_procedures
WHERE substring(icd9_code,1,4) IN ('9670');  --,'9671','9672'
-- WHERE substring(icd9_code,1,3) IN ('967')
```

- 967: continuous invasive mechanical ventilation of (unspecified, less than 96, more than 96) durations. 



