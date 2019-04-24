-- get range

SELECT MIN(subject_id), MAX(subject_id) FROM chartevents;

-- get id for the first partition, 35

SELECT DISTINCT subject_id FROM chartevents 
WHERE subject_id BETWEEN 10000 AND 10100;

-- ===================== table partition via inherit 
-- ===================== also the one recommended
-- ===================== however it seems to be needed BEFORE import data


CREATE TABLE ce0 () INHERITS (chartevents); 
--FOR subject_id FROM 10000 TO 10100;

CREATE TABLE ce0 (
    CHECK ( subject_id >= 10000 AND subject_id < 10100 )
) INHERITS (chartevents);

-- create index
CREATE INDEX ce0_subject_id 
ON ce0 (subject_id);

-- create triger function
CREATE OR REPLACE FUNCTION chartevents_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO ce0 VALUES (NEW.*);  -- for now only ce0
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

-- calls triger function 
CREATE TRIGGER chartevents_trigger
    BEFORE INSERT ON chartevents
    FOR EACH ROW EXECUTE PROCEDURE chartevents_insert_trigger();





