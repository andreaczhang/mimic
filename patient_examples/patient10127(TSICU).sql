-- table 3, chart events
SELECT *
FROM chartevents
WHERE subject_id = 10127;

---------------- list of what features have been measured 

WITH patient10127 AS 
(SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10127
ORDER BY events.itemid, charttime

)
SELECT DISTINCT itemid, label
FROM patient10127
ORDER BY label;

----------------- create events, input, output tables 

SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
INTO events10127
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10127;


SELECT subject_id, input.itemid, label, amount, amountuom, rate, rateuom, charttime
INTO input10127
FROM inputevents_cv AS input
INNER JOIN d_items AS itemscode
ON input.itemid = itemscode.itemid
WHERE subject_id = 10127;


SELECT subject_id, output.itemid, label, value, valueuom, charttime
INTO output10127
FROM outputevents AS output
INNER JOIN d_items AS itemscode
ON output.itemid = itemscode.itemid
WHERE subject_id = 10127
ORDER BY output.itemid;


----------- join them together 

SELECT events10127.subject_id, 
        events10127.itemid AS event_item, 
        events10127.charttime, 
        events10127.label AS event_label, 
        events10127.value AS event_value, 
        events10127.valuenum AS event_valuenum, 
        events10127.valueuom AS event_valueuom, 

        input10127.itemid AS input_item, 
        input10127.label AS input_label, 
        input10127.amount AS input_amount, 
        input10127.amountuom AS input_amountuom, 
        input10127.rate AS input_rate, 
        input10127.rateuom AS input_rateuom, 
        input10127.charttime AS input_charttime, 

        output10127.itemid AS output_item, 
        output10127.label AS output_label, 
        output10127.value AS output_value, 
        output10127.valueuom AS output_valueuom, 
        output10127.charttime AS output_charttime 

FROM events10127
FULL OUTER JOIN input10127  
USING (charttime)
FULL OUTER JOIN output10127
USING (charttime)
ORDER BY charttime;

