# Example: patient 10006



### Diagnose_icd (d_icd_diagnoses )

99591, ..., 2874, ... ,E8791, ... ,V090, ... etc. total 21 diagnosis. They all relate to harm_id = 142345. Using query 

```sql
SELECT subject_id, diag.icd9_code, short_title, long_title
FROM diagnoses_icd AS diag
INNER JOIN d_icd_diagnoses AS code
ON diag.icd9_code = code.icd9_code
WHERE subject_id = 10006;
```

can print out the diagnosis descriptions. 



### chart event (d_items)

```sql
SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY events.itemid, charttime;

```

for instance, ` itemid = 677` is the body temperature, `211` is heart rate, `618` is respiratory rate 

### input events (d_items)

this depends on whether CV or MV used, the column names can be slightly different 

```sql
SELECT subject_id, input.itemid, label, amount, amountuom, rate, rateuom, charttime
FROM inputevents_cv AS input
INNER JOIN d_items AS itemscode
ON input.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY input.itemid;

```



### output events (d_items)

```sql

SELECT subject_id, output.itemid, label, value, valueuom, charttime
FROM outputevents AS output
INNER JOIN d_items AS itemscode
ON output.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY output.itemid;

```

### lab events (d_labitems)

```sql
SELECT subject_id, lab.itemid, label, charttime, value, valuenum, valueuom, flag
FROM labevents AS lab
INNER JOIN d_labitems AS labitemscode
ON lab.itemid = labitemscode.itemid
WHERE subject_id = 10006
ORDER BY lab.itemid, charttime;

```

### microbiology events 

```sql
SELECT *
FROM microbiologyevents
WHERE subject_id = 10006
ORDER BY spec_itemid, charttime;

```



## Plot one table

start with body temperature from table chartevent. 

```R
temp <- q5.res[which(q5.res$itemid == 677), ]
hr <- q5.res[which(q5.res$itemid == 211), ]
respr <- q5.res[which(q5.res$itemid == 618), ]
### this should be easy to do with purrr.

. 
tab.new <- (rbind(temp, hr, respr))[, c(3, 4, 6)] # in the same table, with 3 columns
ggplot(tab.new, aes(x = charttime, y = valuenum, 
                    group = label, colour = label)) + 
  geom_line()

```





![Screenshot 2019-01-15 at 11.23.26](/Users/andrea/Desktop/Screenshot 2019-01-15 at 11.23.26.png)

But with this plot we can't see the sampling frequency. instead use `geom_point()`, it becomes obvious that temperature is sampled less. 

![Screenshot 2019-01-15 at 11.41.46](/Users/andrea/Desktop/Screenshot 2019-01-15 at 11.41.46.png)

## Aggregate everything and plot together 

it is useful to aggregate, but is it also useful to plot everything together? many fields are not numeric values. 

```sql
-- only aggregate chartevents, input, output 

-- save 10006's event into table events10006, 920 rows
SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
INTO events10006
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10006;

-- save 10006's input, 6 rows
SELECT subject_id, input.itemid, label, amount, amountuom, rate, rateuom, charttime
INTO input10006
FROM inputevents_cv AS input
INNER JOIN d_items AS itemscode
ON input.itemid = itemscode.itemid
WHERE subject_id = 10006;

-- save 10006's output, 3 rows
SELECT subject_id, output.itemid, label, value, valueuom, charttime
INTO output10006
FROM outputevents AS output
INNER JOIN d_items AS itemscode
ON output.itemid = itemscode.itemid
WHERE subject_id = 10006
ORDER BY output.itemid;



-- select relevant columns (with unique names) from 3 tables, using FULL OUTER JOIN. match time 

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
USING (charttime);

```

Issue: some input and outputs are replicated, because the left table has many rows recorded at the same time point. This needs to be solved, but I don't think now. 