-- table 3, chart events
SELECT *
FROM chartevents
WHERE subject_id = 10061;

---------------- list of what features have been measured 

WITH patient10061 AS 
(SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10061
ORDER BY events.itemid, charttime

)
SELECT DISTINCT itemid, label
FROM patient10061
ORDER BY label;

----------------- create events, input, output tables 

SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
INTO events10061
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10061;


SELECT subject_id, input.itemid, label, amount, amountuom, rate, rateuom, charttime
INTO input10061
FROM inputevents_cv AS input
INNER JOIN d_items AS itemscode
ON input.itemid = itemscode.itemid
WHERE subject_id = 10061;


SELECT subject_id, output.itemid, label, value, valueuom, charttime
INTO output10061
FROM outputevents AS output
INNER JOIN d_items AS itemscode
ON output.itemid = itemscode.itemid
WHERE subject_id = 10061
ORDER BY output.itemid;


----------- join them together 

SELECT events10061.subject_id, 
        events10061.itemid AS event_item, 
        events10061.charttime, 
        events10061.label AS event_label, 
        events10061.value AS event_value, 
        events10061.valuenum AS event_valuenum, 
        events10061.valueuom AS event_valueuom, 

        input10061.itemid AS input_item, 
        input10061.label AS input_label, 
        input10061.amount AS input_amount, 
        input10061.amountuom AS input_amountuom, 
        input10061.rate AS input_rate, 
        input10061.rateuom AS input_rateuom, 
        input10061.charttime AS input_charttime, 

        output10061.itemid AS output_item, 
        output10061.label AS output_label, 
        output10061.value AS output_value, 
        output10061.valueuom AS output_valueuom, 
        output10061.charttime AS output_charttime 

FROM events10061
FULL OUTER JOIN input10061  
USING (charttime)
FULL OUTER JOIN output10061
USING (charttime)
ORDER BY charttime;

