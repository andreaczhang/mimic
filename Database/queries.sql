/* Basic queries  */




/* ------------ select ------------ */
SELECT
 column_1,     -- query col 1, separate with comma
 column_2,
 ...
FROM
 table_name;   -- use semicolon to finish 
 
 
-- select all
SELECT * FROM  table_name;

-- print column names 
SELECT * FROM table_name WHERE FALSE;

-- distinct keywords
SELECT DISTINCT language FROM films;



/* ------------ filter ------------ */

SELECT column_1, column_2 … column_n FROM table_name
  WHERE conditions;  -- use =, > < and many others. unequal is <>, not !=
 
SELECT title FROM films WHERE country = 'China';
SELECT name, birthdate FROM people WHERE birthdate = '1974-11-11';

-- WHERE AND (OR). need to specify the column names in both. 

SELECT title FROM films WHERE (release_year = 1994 OR release_year = 1995)
  AND (certification = 'PG' OR certification = 'R');

-- WHERE BETWEEN. it is inclusive
SELECT title, release_year FROM films 
  WHERE release_year BETWEEN 1990 AND 2000 
  AND budget > 100000000 
  AND (language = 'Spanish' OR language = 'French');

-- WHERE IN. 
WHERE (release_year = 1994 OR release_year = 1995) -- equivalent to 
WHERE release_year IN (1994, 1995)



-- NULL and IS NULL. deal with missing values 

SELECT name FROM people WHERE deathdate IS NULL;  -- a.k.a. alive 


-- LIKE and NOT LIKE. pattern in text string
-- % matches 0, 1, many characters etc in text
-- _ matches a single character 

SELECT name FROM people WHERE name LIKE 'B%';  -- name start with B
SELECT name FROM people WHERE name LIKE '_r%';  -- name with r as 2nd letter




/* ------------ limit ------------ */
SELECT * FROM table_name LIMIT n OFFSET m;  -- print from m+1 to n+m (e.g. n=10, m=3, will give row 4-13)





/* ------------ count ------------ */
SELECT COUNT (*) FROM table_name    -- nrows of table

SELECT COUNT (column1) FROM table_name  -- nrows of non-missing value for col1
SELECT COUNT (DISTINCT column1) FROM table_name  -- unique




/* ------------ aggregations ------------ */

SELECT AVG(duration) FROM films;  -- average



/* ------------ arithmetic ------------ */
SELECT (4 * 3);
SELECT (4.0 / 3.0) AS result; -- as float



/* ------------ aliasing ------------ */
SELECT title, (gross - budget) AS net_profit FROM films;
SELECT COUNT (deathdate) * 100.0 / COUNT(*) AS percentage_dead FROM people;






/* ------------ order by ------------ */
SELECT title FROM films ORDER BY release_year DESC;  -- from new to old 

SELECT birthdate, name FROM people ORDER BY birthdate, name; -- order by multiple columns, birthdate first 


/* ------------ group by ------------ */
SELECT sex, count(*) FROM employees GROUP BY sex ORDER BY count DESC; -- ORDER BY always after GROUP BY

SELECT release_year, AVG(duration) FROM films GROUP BY release_year; -- average durations
SELECT release_year, MAX(budget) FROM films GROUP BY release_year



/* ------------ HAVING (aggregation with conditions) ------------ */
SELECT release_year FROM films GROUP BY release_year HAVING COUNT(title) > 10; -- HAVING, instead of WHERE 



SELECT release_year, AVG(budget) AS avg_budget, AVG(gross) AS avg_gross 
  FROM films WHERE release_year > 1990  
  GROUP BY release_year 
  HAVING AVG(budget)>60000000    -- here can't use avg_budget
  ORDER BY AVG(gross) DESC;


-- select country, average budget, average gross
SELECT country, AVG(budget) AS avg_budget, AVG(gross) AS avg_gross
  FROM films  -- from the films table
  GROUP BY country  -- group by country 
  HAVING COUNT(title) >10  -- where the country has more than 10 titles
  ORDER BY country  -- order by country
  LIMIT 5;  -- limit to only show 5 results



/* ================== JOIN (multiple tables) ==================  
-- if column names are same in different tables, use table_name.col_name 

INNER JOIN: fields in both tables

OUTER JOIN 
  LEFT JOIN: key fields in right table are missing if not appeared in left table 
  RIGHT JOIN
  FULL JOIN
  
CROSS JOIN: all combinations. doesn't use ON or USING

SEMI JOIN: join based on conditions set in the second table 
ANTI JOIN: conditions NOT met. 

*/

SELECT title, imdb_score
FROM films
JOIN reviews
ON films.id = reviews.film_id
WHERE title = 'To Kill a Mockingbird';



/* ------------ LEFT JOIN: 
use the first table's keys, possible that the second one doesn't
have the same key are left out. for example, left.table (1,2,3,4), right.table (1,2,5,6), 
by left joining them (1,2) will have both columns filled, (3,4) have left column filled and right 
column empty.
------------ */ 

SELECT c1.name AS city, code, c2.name AS country,   -- note that this 'code' is from countries table. we didn't 
                                                    -- country_code from c1(cities), only use c1_country_code as key
       region, city_proper_pop
FROM cities AS c1             -- specify left table
INNER JOIN countries AS c2    -- specify right table and type of join   
ON c1.country_code = c2.code  -- match
ORDER BY code DESC;



SELECT COUNT(*)FROM  -- count how many rows 
    (SELECT DISTINCT c1.name AS city, code, c2.name AS country,   
       region, city_proper_pop 
    FROM cities AS c1   
    INNER JOIN countries AS c2
    ON c1.country_code = c2.code 
    ORDER BY code DESC) mytab   -- name table as mytab. this has to be here otherwise count doesnt work



SELECT name, region, gdp_percapita
FROM countries AS c
LEFT JOIN economies AS e
ON c.code = e.code
WHERE year = 2010;


-- use AVG
SELECT region, AVG(gdp_percapita) AS avg_gdp
FROM countries AS c
LEFT JOIN economies AS e
ON c.code = e.code
WHERE year = 2010
GROUP BY region
ORDER BY avg_gdp DESC;  -- Order by avg_gdp, descending



/* ------------ FULL JOIN: 
all index kept, those missign keep missing. 
------------ */ 

SELECT left_table.id AS L_id, 
  right_table.id AS R_id, 
  left_table.value AS L_val, 
  right_table.value AS R_val 
  FROM left_table
  FULL JOIN right_table
  USING (id);    -- USING needs bracket! 



SELECT name AS country, code, region, basic_unit
FROM countries
FULL JOIN currencies
USING (code)
WHERE region = 'North America' OR region IS NULL
ORDER BY region;


/* ------------ CROSS JOIN: 
tab1 index (1, 2, 3), tab2 index (a,b,c), with cross join the index becomes (1a, 1b, 1c, ..., 3c). 
do not use ON. 
------------ */ 


SELECT c.name AS city, l.name AS language
FROM cities AS c        
CROSS JOIN languages AS l
WHERE c.name LIKE 'Hyder%';






/* ------------ UNION and UNION ALL 
stack tables on top, different from JOINs
------------ */ 
  
  
  SELECT *            -- all columns
FROM economies2010  -- 2010 table will be on top
UNION 
SELECT *            -- select again
FROM economies2015  -- 2015 table on the bottom
ORDER BY code, year;



SELECT code, year
FROM economies
UNION ALL
SELECT country_code, year
FROM populations
ORDER BY code, year;


/* ------------ INTERSECT
just change UNION to intersect 
------------ */
  
  SELECT countries.name -- as country 
FROM countries
INTERSECT 
SELECT cities.name -- as city
FROM cities

-- this will show the cities that have the same name as country 




/* ------------ EXCEPT
appear in the left table, but not in the right table
tab1 index (1, 2, 3, 4), tab2 index (1, 4, 5, 6), EXCEPT will return (2,3)
------------ */
  SELECT name      -- select city names
FROM cities
EXCEPT
SELECT capital   -- that are not capitals
FROM countries
ORDER BY name;

-- select capitals that are not listed in city lists (which are populous )
SELECT capital 
FROM countries
EXCEPT 
SELECT name 
FROM cities
ORDER BY capital;




/* ------------ SEMI JOIN (subqueries) and ANTI JOIN 

------------ */
  
  SELECT president, country, continent
FROM presidents
WHERE country IN            -------- condition on table 2 are matched: semi join
(SELECT name
  FROM states
  WHERE indep_year < 1800);
-- semi join is like inner join with a condiion 




-- ----------------------- example 
-- query 1: select the countries within middle east, record the country code
SELECT code 
FROM countries
WHERE region = 'Middle East';

-- query 2: selecte the unique languages
SELECT DISTINCT name
FROM languages
ORDER BY name;

-- combine the above 2 by adding a WHERE .. IN ()
SELECT DISTINCT name
FROM languages
WHERE languages.code IN   -- here actually don't need to add language.
(SELECT code 
FROM countries
WHERE region = 'Middle East')
ORDER BY name

-- ----------------------- example 



-- ANTI join can be used to identify bugs, such as which items are NOT included 
SELECT president, country, continent
FROM presidents
WHERE continent LIKE '%America'
AND country NOT IN             -------- condition on table 2 are not matched: anti join
(SELECT name
FROM states
WHERE indep_year < 1800);  
-- anti join feels more like except 


SELECT c1.code, c1.name
FROM countries AS c1

WHERE continent = 'Oceania'
AND c1.code NOT IN 
(SELECT code FROM currencies)



-- example: identify the country codes included in either economies, currencies but not in populations. 

SELECT name       -- select the city name
FROM cities AS c1
-- choose only records matching the result of multiple set theory clauses
WHERE c1.country_code IN
(
  
  SELECT e.code    -- select appropriate field from economies AS e
  FROM economies AS e
  -- get all additional (unique) values of the field from currencies AS c2  
  UNION
  SELECT c2.code
  FROM currencies AS c2
  -- exclude those appearing in populations AS p
  EXCEPT
  SELECT p.country_code
  FROM populations AS p
);
  



/* ------------ subquery --------------
1. inside WHERE
 */
  
SELECT *
FROM populations
WHERE life_expectancy > 1.15*(
        SELECT AVG(life_expectancy) 
        FROM populations 
        WHERE year = 2015
        ) 
AND year = 2015;

  
  
/* ------------ subquery --------------
2. inside SELECT
*/
  
-- counts how many countries, in each continent, that has 
SELECT DISTINCT continent,     -- first element, selected from prime_ministers
  (SELECT COUNT(*)             -- second element, as a number 
  FROM states
  WHERE prime_ministers.continent = states.continent) AS countries_num
FROM prime_ministers;





SELECT countries.name AS country, COUNT(*) AS cities_num
FROM cities
INNER JOIN countries
ON countries.code = cities.country_code
GROUP BY country
ORDER BY cities_num DESC, country
LIMIT 9;

-- is the same as 
SELECT name AS country,
  (SELECT COUNT(*)
   FROM cities
   WHERE countries.code = cities.country_code) AS cities_num
FROM countries
ORDER BY cities_num DESC, country
LIMIT 9;


/* ------------ subquery --------------
3. inside FROM
*/


SELECT DISTINCT monarchs.continent, subquery.max_perc
FROM monarchs, 
  (SELECT continent, MAX(women_parli_perc) AS max_perc
  FROM states
  GROUP BY continent) AS subquery  -- temporary table 
WHERE monarchs.continent = subquery.continent
ORDER BY continent;




SELECT MAX(inflation_rate) AS max_inf    ------- this one doesn't show the name, continent. 
FROM 
    (SELECT name, continent, inflation_rate
    FROM countries
    INNER JOIN economies
    USING (code)
    WHERE year = 2015
    ) AS subquery
GROUP BY continent


SELECT name, continent, inflation_rate
FROM countries
INNER JOIN economies
ON countries.code = economies.code
WHERE year = 2015
    AND inflation_rate IN (
        SELECT MAX(inflation_rate) AS max_inf
        FROM (
             SELECT name, continent, inflation_rate
             FROM countries
             INNER JOIN economies
             ON countries.code = economies.code
             WHERE year = 2015) AS subquery
        GROUP BY continent);

