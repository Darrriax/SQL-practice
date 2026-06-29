-- String & Number functions
USE MyDatabase

-- CONCAT
SELECT 
    first_name,
    country,
    CONCAT(first_name, ' ', country) AS name_country
FROM customers 

-- UPPER & LOWER
SELECT
    first_name,
    LOWER(first_name) AS lowercase_name
FROM customers

SELECT
    first_name,
    UPPER(first_name) AS uppercase_name
FROM customers

-- TRIM
SELECT 
    first_name
FROM customers
EXCEPT
SELECT 
    TRIM(first_name)
FROM customers
-- -- --
SELECT 
    first_name
FROM customers
WHERE first_name != TRIM(first_name)

-- REPLACE
SELECT
    '096-188-38-24' AS phone,
    REPLACE('096-188-38-24', '-', '') AS clean_phone

SELECT
    'txt.txt' AS old_filename,
    REPLACE('txt.txt', '.txt', '.csv') AS new_filename

-- LEN
SELECT 
    first_name,
    LEN(first_name) AS char_count
FROM customers

-- LEFT & RIGHT
SELECT 
    first_name,
    LEFT(TRIM(first_name), 2) AS first_2_char_of_name
FROM customers

SELECT 
    first_name,
    RIGHT(first_name, 2) AS last_2_char_of_name
FROM customers

-- SUBSTRING
SELECT 
    first_name,
    SUBSTRING(TRIM(first_name), 2, LEN(first_name) - 1) AS name_without_first_char
FROM customers

-- ROUND
SELECT 
3.516 AS number,
ROUND(3.516, 0) AS round_0,
ROUND(3.516, 1) AS round_1,
ROUND(3.516, 2) AS round_2

-- ABS
SELECT
-10 AS num_1,
5 AS num_2,
ABS(-10) AS abs_num_1,
ABS(5) AS abs_num_2