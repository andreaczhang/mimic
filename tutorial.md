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

`itemid` identifies a single measurement type (relate to <u>d_items</u>)

`charttime` is when the observation is made

`cgid` is the care giver id 

It is possible to create materialised view of the output. 



### 3. diagnose_icd

Subject (patient) corresponds to his diagnosis, each of them have multiple diagnosis codes (icd9_code). Then icd9_code relate to <u>d_icd_diagnoses table</u>. 



principal and other diagnosis codes: 6 digits, decimal point between 3 and 4

V codes: decimal point between 2 and 3

### 4. icustays

http://data.patientcarelink.org/staffing2017/units.cfm?ID=12&Name=Beth%20Israel%20Deaconess%20Medical%20Center

```sql
SELECT DISTINCT first_careunit FROM icustays;
```

icu types include surgical (SICU), medical (MICU), coronary (CCU), trauma (TSICU), cardiac surgery recovery (CSRU).  



### 5. input (mv, cv) / output events 

probably it's either mv or cv, not both? link to d_items 





### 6. lab events

relate to d_labitems

`spec_itemid, spec_type_desc` are the specimen being tested, such as blood culture, urine etc

`isolate_num` is the isolated colony for organism 

`ab` antibiotic 

`interpretation` S is sensitive, R is resistant, I is intermediate, P is pending 



### 7. microbiology events 



### 8. procedures 

no time stamps 





## aggregate materialised views 



```sql
CREATE MATERIALIZED VIEW angus_sepsis as

-- source 1
WITH infection_group AS
(
    SELECT subject_id, hadm_id
    FROM diagnoses_icd
),
-- source 2
organ_diag_group as
(
    SELECT subject_id, hadm_id
    FROM diagnoses_icd
),
-- source 3
organ_proc_group as
(
    SELECT subject_id, hadm_id
    FROM procedures_icd
),


-- Aggregate above views together
aggregate as
(
    SELECT subject_id, hadm_id
    FROM admissions
)

-- aggregation ends 

-- Output component flags (explicit sepsis, organ dysfunction) and final flag (angus)
SELECT subject_id, hadm_id, infection,
   explicit_sepsis, organ_dysfunction, mech_vent
FROM aggregate;
```











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



## Arterial line study

https://github.com/MIT-LCP/mimic-code/blob/master/notebooks/aline/aline.ipynb

**Conclusion**: in hemodynamically stable patients who are mechanically ventilated, IAC is not associated with a difference in 28-day mortality. 

Presence of IAC: place an invasive arterial catheter at any point in time after initiation of mechanical ventilation

Cohort: 

- adult patients, 
- require mechanical ventilation
- within first 24 h 
- Medical / surgical ICU admission
- first ICU admission, for those who have multiple
- last for at least 24 h
- **no** sepsis diagnosis according to Angus criteria 
- **exclude** those require vasopressor while in ICU
- **exclude** those IAC placed before endotracheal intubation and intiation of mechanical ventilation (hence excluding all cardiac surgery ICU)

Primary outcome: 28-days mortality

Secondary outcome: length of stay, duration of ventilation, blood gas measurements.

propensity score model 

### Covariates: (select via genetic algorithm, final 29 out of 53)

**demographics**: Admission age, gender, race, daytime admission (7am to 7pm), day of admission and
service unit (medical or surgical ICU), and admission Sequential Organ Failure Assessment (SOFA) score

**comorbidities**: 

Congestive Heart Failure 398.91 428.0 428.1 428.20 428.21 428.22 428.23
428.30 428.31 428.32 428.33 428.40 428.41 428.42, 428, 428.2, 428.3, 428.4, 428.43, 428.9; 

Atrial fibrillation 427.3; 

Chronic renal disease 585.; 

Chronic liver disease 571; 

Chronic Obstructive Pulmonary Disease 490-496; 

Coronary Artery Disease 414.; 

Stroke 440-434; 

Malignancy 140-239; 

non-COPD lung disease (including acute respiratory distress syndrome) 518, and Pneumonia 482.

**vital signs**: Data include weight, mean arterial pressure (MAP), temperature, heart
rate, oxygen saturation (SpO2) and central venous pressure (CVP). 

**preintervention lab results**: White blood cell (WBC) count, hemoglobin, platelet count, sodium, potassium,
bicarbonate, chloride, blood urea nitrogen (BUN), creatinine, glucose, calcium, magnesium, phosphate,
aspartate Aminotransferase (AST), alanine Aminotransferase (ALT), lactic acid dehydrogenase (LDH), total
bilirubin, alkaline phosphatase, albumin, troponin T, creatinine kinase, brain natriuretic peptide (BNP),lactate, pH, central venous oxygen saturation (ScVO2), arterial partial pressure of oxygen (PaO2) and
arterial partial pressure of carbon dioxide (PCO2).

**Sedative medication use**: including midazolam, fentanyl, and propofol.



### Queries

`angus.sql, HeightWeightQuery.sql, aline_vaso_flag.sql`

`aline_cohort.sql`

then `bmi.sql, vitals.sql, sedatives.sql, icd.sql, labs.sql, sofa.sql`



