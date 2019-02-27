-- table 3, chart events
SELECT *
FROM chartevents
WHERE subject_id = 42135;

---------------- list of what features have been measured 

WITH patient42135 AS 
(SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 42135
ORDER BY events.itemid, charttime

)
SELECT DISTINCT itemid, label
FROM patient42135
ORDER BY label;

----------------- create events, input, output tables 

SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
INTO events42135
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 42135;


SELECT subject_id, input.itemid, label, amount, amountuom, rate, rateuom, charttime
INTO input42135
FROM inputevents_cv AS input
INNER JOIN d_items AS itemscode
ON input.itemid = itemscode.itemid
WHERE subject_id = 42135;


SELECT subject_id, output.itemid, label, value, valueuom, charttime
INTO output42135
FROM outputevents AS output
INNER JOIN d_items AS itemscode
ON output.itemid = itemscode.itemid
WHERE subject_id = 42135
ORDER BY output.itemid;


----------- join them together 

SELECT events42135.subject_id, 
        events42135.itemid AS event_item, 
        events42135.charttime, 
        events42135.label AS event_label, 
        events42135.value AS event_value, 
        events42135.valuenum AS event_valuenum, 
        events42135.valueuom AS event_valueuom, 

        input42135.itemid AS input_item, 
        input42135.label AS input_label, 
        input42135.amount AS input_amount, 
        input42135.amountuom AS input_amountuom, 
        input42135.rate AS input_rate, 
        input42135.rateuom AS input_rateuom, 
        input42135.charttime AS input_charttime, 

        output42135.itemid AS output_item, 
        output42135.label AS output_label, 
        output42135.value AS output_value, 
        output42135.valueuom AS output_valueuom, 
        output42135.charttime AS output_charttime 

FROM events42135
FULL OUTER JOIN input42135  
USING (charttime)
FULL OUTER JOIN output42135
USING (charttime)
ORDER BY charttime;

