-- table 3, chart events
SELECT *
FROM chartevents
WHERE subject_id = 10111;

---------------- list of what features have been measured 

WITH patient10111 AS 
(SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10111
ORDER BY events.itemid, charttime

)
SELECT DISTINCT itemid, label
FROM patient10111
ORDER BY label;

----------------- create events, input, output tables 

SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
INTO events10111
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10111;


SELECT subject_id, input.itemid, label, amount, amountuom, rate, rateuom, charttime
INTO input10111
FROM inputevents_cv AS input
INNER JOIN d_items AS itemscode
ON input.itemid = itemscode.itemid
WHERE subject_id = 10111;


SELECT subject_id, output.itemid, label, value, valueuom, charttime
INTO output10111
FROM outputevents AS output
INNER JOIN d_items AS itemscode
ON output.itemid = itemscode.itemid
WHERE subject_id = 10111
ORDER BY output.itemid;


----------- join them together 

SELECT events10111.subject_id, 
        events10111.itemid AS event_item, 
        events10111.charttime, 
        events10111.label AS event_label, 
        events10111.value AS event_value, 
        events10111.valuenum AS event_valuenum, 
        events10111.valueuom AS event_valueuom, 

        input10111.itemid AS input_item, 
        input10111.label AS input_label, 
        input10111.amount AS input_amount, 
        input10111.amountuom AS input_amountuom, 
        input10111.rate AS input_rate, 
        input10111.rateuom AS input_rateuom, 
        input10111.charttime AS input_charttime, 

        output10111.itemid AS output_item, 
        output10111.label AS output_label, 
        output10111.value AS output_value, 
        output10111.valueuom AS output_valueuom, 
        output10111.charttime AS output_charttime 

FROM events10111
FULL OUTER JOIN input10111  
USING (charttime)
FULL OUTER JOIN output10111
USING (charttime)
ORDER BY charttime;

