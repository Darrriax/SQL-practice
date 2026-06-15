-- NULLs
USE SalesDB
-- ISNULL (columnToCheck, replacement)
-- COALESCE (columnToCheck, replacement1, replacement2)

-- TASK: get average score of customers
SELECT
    AVG(COALESCE(Score, 0)) AS Average_score
FROM Sales.Customers

-- TASK: display a full name in a single field
SELECT 
    CustomerID,
    COALESCE(FirstName, '') + ' ' + COALESCE(LastName, '') AS full_name,
    COALESCE(score, 0) + 10 AS current_score
FROM Sales.Customers

-- TASK: sort customers from lowest to highest scores with NULLs appearing last
SELECT 
    CustomerID,
    Score
    -- CASE WHEN Score IS NULL THEN 1 ELSE 0 END
FROM Sales.Customers
ORDER BY CASE WHEN Score IS NULL THEN 1 ELSE 0 END, Score ASC

-- NULLIF (value1, value2)

-- TASK: find the sales price for each order by deviding the sales by its quantity
SELECT 
    OrderID,
    Quantity,
    Sales,
    Sales/NULLIF(Quantity, 0) AS SalesPrice
FROM Sales.Orders

-- TASK: identify the customers who have no scores
SELECT *
FROM Sales.Customers
WHERE Score IS NULL

-- TASK: identify the customers who have scores
SELECT *
FROM Sales.Customers
WHERE Score IS NOT NULL

-- TASK: list all details for customers who have not placed any orders
SELECT *
FROM Sales.Customers as c
LEFT JOIN Sales.Orders as o
ON c.CustomerID = o.CustomerID
WHERE OrderDate IS NULL

-- USECASE: separate types
WITH Orders AS (
SELECT 1 Id, 'A' Category UNION 
SELECT 2, NULL UNION
SELECT 3, '' UNION
SELECT 4, ' '
)
SELECT
*,
DATALENGTH(Category) CategoryLen
FROM Orders