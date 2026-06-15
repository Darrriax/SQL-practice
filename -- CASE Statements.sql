-- CASE Statements

--TASK: display categories of total sales from highest to lowest
USE SalesDB
SELECT 
    Category,
    SUM(Sales) AS TotalSales
FROM (
    SELECT 
        Sales,
        CASE WHEN Sales > 50 THEN 'High'
        WHEN Sales > 20 THEN 'Medium'
        WHEN Sales <= 20 THEN 'Low'
        END AS Category
    FROM Sales.Orders
) AS t
GROUP By Category
ORDER BY SUM(Sales) DESC

-- TASK: retrieve employee details with gender displayed as full text
SELECT
    EmployeeID,
    FirstName,
    LastName,
    CASE 
        WHEN Gender = 'M' THEN 'Male'
        WHEN Gender = 'F' THEN 'Female'
        ELSE ''
    END AS FullGender
FROM Sales.Employees

-- TASK: retrieve customers deyails with abbreviated country code
SELECT 
    CustomerID,
    FirstName,
    LastName,
    CASE 
        WHEN Country = 'Germany' THEN 'DE'
        WHEN Country = 'USA' THEN 'US'
        ELSE 'unknown'
    END AS CountryCode,
    Score
FROM Sales.Customers

SELECT 
    CustomerID,
    FirstName,
    LastName,
    CASE Country
        WHEN 'Germany' THEN 'DE'
        WHEN 'USA' THEN 'US'
        ELSE 'unknown' 
    END AS CountryCode,
    Score
FROM Sales.Customers

-- TASK: find the average scores of customers and treat NULLs as 0
SELECT 
    t.CustomerID,
    LastName,
    AVG(t.EditedScore) OVER() AS NewScore
FROM (
    SELECT
        CustomerID,
        LastName,
        CASE WHEN Score IS NULL THEN 0 ELSE Score END AS EditedScore
    FROM Sales.Customers
) AS t

-- TASK: how many times each customer has made an order with sales greater than 30
SELECT
    CustomerID,
    COALESCE(SUM(CASE WHEN Sales > 30 THEN 1 END), 0) AS NumberOfOrders,
    COUNT(*) AllOrders
FROM Sales.Orders
GROUP BY CustomerID