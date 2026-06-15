-- IN and LIKE operators
USE MyDatabase

-- IN and NOT IN operator
SELECT *
FROM customers
WHERE country NOT IN ('Germany', 'USA')

-- LIKE operator
SELECT *
FROM customers
WHERE first_name LIKE '__r%'