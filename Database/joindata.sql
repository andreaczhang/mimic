/* ----------------- INNER JOIN ------------------- */

SELECT *
FROM left_table
INNER JOIN right_table
ON left_table.id = right_table.id
-- INNER JOIN another_table
-- ON left_table.id = another_table.id;


SELECT cities.name AS city, countries.name AS country, region -- table1.val, table2.val
  FROM cities
  INNER JOIN countries
  ON cities.country_code = countries.code;   -- table1.key, table2.key
  

SELECT c1.name AS city, c2.name AS country
FROM cities AS c1   -- alternatively, already alias here 
INNER JOIN countries AS c2
ON c1.country_code = c2.code;  


/* ----------------- USING (when ON key is the same) ------------------- */
SELECT *
FROM countries
INNER JOIN economies
USING(code)
  
  
/* ----------------- self joining ------------------- */  
  
SELECT p1.country_code, 
       p1.size AS size2010,   -- basically makes the same column replicate
       p2.size AS size2015
FROM populations AS p1
INNER JOIN populations AS p2
ON p1.country_code = p2.country_code
    AND p1.year = p2.year - 5;

  
SELECT p1.country_code, 
       p1.size AS size2010,
       p2.size AS size2015,
       ((p2.size - p1.size)/p1.size * 100.0) AS growth_perc
FROM populations AS p1
INNER JOIN populations AS p2
ON p1.country_code = p2.country_code
    AND p1.year = p2.year - 5;



/* ----------------- CASE WHEN ------------------- */  
SELECT name, continent, code, surface_area,
    CASE WHEN surface_area > 2000000 THEN 'large'   -- first case
        WHEN surface_area > 350000 THEN 'medium'   -- second case
        ELSE 'small' END   -- else clause + end
        AS geosize_group
FROM countries;


/* ----------------- INTO ------------------- */  
 
 SELECT country_code, size,
    CASE WHEN size > 50000000 THEN 'large'
        WHEN size > 1000000 THEN 'medium'
        ELSE 'small' END
        AS popsize_group
INTO pop_plus    -- into a new table 
FROM populations
WHERE year = 2015;


SELECT name, continent, geosize_group, popsize_group
FROM countries_plus AS c
INNER JOIN pop_plus AS p
ON c.code = p.country_code
ORDER BY geosize_group;

 
 
 
 
 
 
 
 
  