-- JOINs
USE MyDatabase

-- No JOIN
SELECT *
FROM orders;

SELECT *
FROM customers;

--INNER JOIN (ø|ø)
SELECT  
    c.id, 
    c.first_name, 
    c.country,
    o.order_id, 
    o.order_date, 
    o.sales
FROM customers AS c
INNER JOIN orders AS o
ON c.id = o.customer_id;

-- LEFT JOIN (o|ø)
SELECT 
    c.id, 
    c.first_name, 
    c.country,
    o.order_id, 
    o.order_date, 
    o.sales
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.customer_id

-- RIGHT JOIN (ø|o)
SELECT 
    c.id, 
    c.first_name, 
    c.country,
    o.order_id, 
    o.order_date, 
    o.sales
FROM customers AS c
RIGHT JOIN orders AS o
ON o.customer_id = c.id

SELECT 
    c.id, 
    c.first_name, 
    c.country,
    o.order_id, 
    o.order_date, 
    o.sales  
FROM orders AS o
LEFT JOIN customers as c
ON o.customer_id = c.id

-- FULL JOIN [oo]
SELECT *
FROM customers AS c
FULL JOIN orders AS o
ON o.customer_id = c.id

-- ANTI JOINs
SELECT * 
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.customer_id
WHERE o.customer_id IS NULL

SELECT * 
FROM customers AS c
RIGHT JOIN orders AS o
ON c.id = o.customer_id
WHERE c.id IS NULL

SELECT * 
FROM orders AS o
LEFT JOIN customers AS c
ON c.id = o.customer_id
WHERE c.id IS NULL

SELECT *
FROM customers AS c
FULL JOIN orders AS o
ON c.id = o.customer_id
WHERE c.id IS NULL OR o.customer_id IS NULL

-- CHALLANGE
SELECT *
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.customer_id
WHERE o.customer_id IS NOT NULL

-- CROSS JOIN
SELECT *
FROM customers AS c
CROSS JOIN orders AS o

--CHALLANGE Sales.db
USE SalesDB
SELECT 
    o.OrderID AS 'Order iD', 
    c.FirstName AS 'Customer''s first name', 
    c.LastName AS 'Customer''s last name', 
    p.Product AS 'Product name', 
    o.Sales AS 'Sales amount', 
    p.Price AS 'Product price', 
    e.FirstName AS 'Salesperson''s first name',
    e.LastName AS 'Salesperson''s last name'
FROM Sales.Orders AS o
LEFT JOIN Sales.Products as p
ON o.ProductID = p.ProductID
LEFT JOIN Sales.Customers as c
ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Employees as e
ON o.SalesPersonID = e.EmployeeID