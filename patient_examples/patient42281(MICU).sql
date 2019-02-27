-- table 3, chart events
SELECT *
FROM chartevents
WHERE subject_id = 42281;

---------------- list of what features have been measured 

WITH patient42281 AS 
(SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 42281
ORDER BY events.itemid, charttime

)
SELECT DISTINCT itemid, label
FROM patient42281
ORDER BY label;

----------------- create events, input, output tables 

SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
INTO events42281
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 42281;


SELECT subject_id, input.itemid, label, amount, amountuom, rate, rateuom, charttime
INTO input42281
FROM inputevents_cv AS input
INNER JOIN d_items AS itemscode
ON input.itemid = itemscode.itemid
WHERE subject_id = 42281;


SELECT subject_id, output.itemid, label, value, valueuom, charttime
INTO output42281
FROM outputevents AS output
INNER JOIN d_items AS itemscode
ON output.itemid = itemscode.itemid
WHERE subject_id = 42281
ORDER BY output.itemid;


----------- join them together 

SELECT events42281.subject_id, 
        events42281.itemid AS event_item, 
        events42281.charttime, 
        events42281.label AS event_label, 
        events42281.value AS event_value, 
        events42281.valuenum AS event_valuenum, 
        events42281.valueuom AS event_valueuom, 

        input42281.itemid AS input_item, 
        input42281.label AS input_label, 
        input42281.amount AS input_amount, 
        input42281.amountuom AS input_amountuom, 
        input42281.rate AS input_rate, 
        input42281.rateuom AS input_rateuom, 
        input42281.charttime AS input_charttime, 

        output42281.itemid AS output_item, 
        output42281.label AS output_label, 
        output42281.value AS output_value, 
        output42281.valueuom AS output_valueuom, 
        output42281.charttime AS output_charttime 

FROM events42281
FULL OUTER JOIN input42281  
USING (charttime)
FULL OUTER JOIN output42281
USING (charttime)
ORDER BY charttime;

