-- use materialised views
-- =========== first 10 
/* 
0%    2%    4%    6%    8%   10%    12%   14%   16%   18%   20%   
2     987   1968  2952  3940  4909  5894  6887  7870  8849   9835

*/


CREATE MATERIALIZED VIEW ce_1 AS 
SELECT * FROM chartevents WHERE subject_id >= 0 AND subject_id < 987 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_2 AS 
SELECT * FROM chartevents WHERE subject_id >= 987 AND subject_id < 1968 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_3 AS 
SELECT * FROM chartevents WHERE subject_id >= 1968 AND subject_id < 2952 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_4 AS 
SELECT * FROM chartevents WHERE subject_id >= 2952 AND subject_id < 3940 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_5 AS 
SELECT * FROM chartevents WHERE subject_id >= 3940 AND subject_id < 4909 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_6 AS 
SELECT * FROM chartevents WHERE subject_id >= 4909 AND subject_id < 5894 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_7 AS 
SELECT * FROM chartevents WHERE subject_id >= 5894 AND subject_id < 6887 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_8 AS 
SELECT * FROM chartevents WHERE subject_id >= 6887 AND subject_id < 7870 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_9 AS 
SELECT * FROM chartevents WHERE subject_id >= 7870 AND subject_id < 8849 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_10 AS 
SELECT * FROM chartevents WHERE subject_id >= 8849 AND subject_id < 9835 ORDER BY subject_id; 


- ============== 11-20
/* 
22%   24%   26%   28%   30%   32%   34%   36%   38%   40%
10821 11802 12783 13776 14758 15747 16717 17712 18709 19711

*/

CREATE MATERIALIZED VIEW ce_11 AS 
SELECT * FROM chartevents WHERE subject_id >= 9835 AND subject_id < 10821 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_12 AS 
SELECT * FROM chartevents WHERE subject_id >= 10821 AND subject_id < 11802 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_13 AS 
SELECT * FROM chartevents WHERE subject_id >= 11802 AND subject_id < 12783 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_14 AS 
SELECT * FROM chartevents WHERE subject_id >= 12783 AND subject_id < 13776 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_15 AS 
SELECT * FROM chartevents WHERE subject_id >= 13776 AND subject_id < 14758 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_16 AS 
SELECT * FROM chartevents WHERE subject_id >= 14758 AND subject_id < 15747 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_17 AS 
SELECT * FROM chartevents WHERE subject_id >= 15747 AND subject_id < 16717 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_18 AS 
SELECT * FROM chartevents WHERE subject_id >= 16717 AND subject_id < 17712 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_19 AS 
SELECT * FROM chartevents WHERE subject_id >= 17712 AND subject_id < 18709 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_20 AS 
SELECT * FROM chartevents WHERE subject_id >= 18709 AND subject_id < 19711 ORDER BY subject_id; 

-- ================ 21-30

/* 
42%   44%   46%   48%   50%   52%   54%   56%   58%   60%   
20705 21688 22673 23657 24650 25630 26616 27617 28643 29662

*/

CREATE MATERIALIZED VIEW ce_21 AS 
SELECT * FROM chartevents WHERE subject_id >= 19711 AND subject_id < 20705 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_22 AS 
SELECT * FROM chartevents WHERE subject_id >= 20705 AND subject_id < 21688 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_23 AS 
SELECT * FROM chartevents WHERE subject_id >= 21688 AND subject_id < 22673 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_24 AS 
SELECT * FROM chartevents WHERE subject_id >= 22673 AND subject_id < 23657 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_25 AS 
SELECT * FROM chartevents WHERE subject_id >= 23657 AND subject_id < 24650 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_26 AS 
SELECT * FROM chartevents WHERE subject_id >= 24650 AND subject_id < 25630 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_27 AS 
SELECT * FROM chartevents WHERE subject_id >= 25630 AND subject_id < 26616 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_28 AS 
SELECT * FROM chartevents WHERE subject_id >= 26616 AND subject_id < 27617 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_29 AS 
SELECT * FROM chartevents WHERE subject_id >= 27617 AND subject_id < 28643 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_30 AS 
SELECT * FROM chartevents WHERE subject_id >= 28643 AND subject_id < 29662 ORDER BY subject_id; 

-- ============== 31-40

/* 
62%   64%   66%   68%   70%   72%   74%   76%   78%   80%
30686 31708 32700 43195 46746 50332 53763 57255 60696 64230 

*/

CREATE MATERIALIZED VIEW ce_31 AS 
SELECT * FROM chartevents WHERE subject_id >= 29662 AND subject_id < 30686 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_32 AS 
SELECT * FROM chartevents WHERE subject_id >= 30686 AND subject_id < 31708 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_33 AS 
SELECT * FROM chartevents WHERE subject_id >= 31708 AND subject_id < 32700 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_34 AS 
SELECT * FROM chartevents WHERE subject_id >= 32700 AND subject_id < 43195 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_35 AS 
SELECT * FROM chartevents WHERE subject_id >= 43195 AND subject_id < 46746 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_36 AS 
SELECT * FROM chartevents WHERE subject_id >= 46746 AND subject_id < 50332 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_37 AS 
SELECT * FROM chartevents WHERE subject_id >= 50332 AND subject_id < 53763 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_38 AS 
SELECT * FROM chartevents WHERE subject_id >= 53763 AND subject_id < 57255 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_39 AS 
SELECT * FROM chartevents WHERE subject_id >= 57255 AND subject_id < 60696 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_40 AS 
SELECT * FROM chartevents WHERE subject_id >= 60696 AND subject_id < 64230 ORDER BY subject_id; 

-- ============= 41-50
/* 
82%   84%   86%   88%   90%   92%   94%   96%   98%  100% 
67753 71232 74993 78546 82100 85701 89328 92865 96442 99999 

*/


CREATE MATERIALIZED VIEW ce_41 AS 
SELECT * FROM chartevents WHERE subject_id >= 64230 AND subject_id < 67753 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_42 AS 
SELECT * FROM chartevents WHERE subject_id >= 67753 AND subject_id < 71232 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_43 AS 
SELECT * FROM chartevents WHERE subject_id >= 71232 AND subject_id < 74993 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_44 AS 
SELECT * FROM chartevents WHERE subject_id >= 74993 AND subject_id < 78546 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_45 AS 
SELECT * FROM chartevents WHERE subject_id >= 78546 AND subject_id < 82100 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_46 AS 
SELECT * FROM chartevents WHERE subject_id >= 82100 AND subject_id < 85701 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_47 AS 
SELECT * FROM chartevents WHERE subject_id >= 85701 AND subject_id < 89328 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_48 AS 
SELECT * FROM chartevents WHERE subject_id >= 89328 AND subject_id < 92865 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_49 AS 
SELECT * FROM chartevents WHERE subject_id >= 92865 AND subject_id < 96442 ORDER BY subject_id; 

CREATE MATERIALIZED VIEW ce_50 AS 
SELECT * FROM chartevents WHERE subject_id >= 96442 AND subject_id <= 99999 ORDER BY subject_id; 

