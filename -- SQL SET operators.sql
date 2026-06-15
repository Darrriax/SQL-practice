-- SQL SET operators
USE SalesDB

-- UNION (No duplicates)
SELECT 
    FirstName,
    LastName
FROM Sales.Customers
UNION
SELECT 
    FirstName,
    LastName
FROM Sales.Employees

-- UNION ALL (Contain all rows)
SELECT 
    FirstName,
    LastName
FROM Sales.Customers
UNION ALL
SELECT 
    FirstName,
    LastName
FROM Sales.Employees

-- EXCEPT
SELECT 
    FirstName,
    LastName
FROM Sales.Employees
EXCEPT
SELECT 
    FirstName,
    LastName
FROM Sales.Customers

-- INTERSECT
SELECT 
    FirstName,
    LastName
FROM Sales.Employees
INTERSECT
SELECT 
    FirstName,
    LastName
FROM Sales.Customers

-- USECASES
-- Combine information
SELECT 
    'Orders' AS Source
    ,[OrderID]
    ,[ProductID]
    ,[CustomerID]
    ,[SalesPersonID]
    ,[OrderDate]
    ,[ShipDate]
    ,[OrderStatus]
    ,[ShipAddress]
    ,[BillAddress]
    ,[Quantity]
    ,[Sales]
    ,[CreationTime]
FROM Sales.Orders
UNION
SELECT 
    'OrdersArchive' AS Source
    ,[OrderID]
    ,[ProductID]
    ,[CustomerID]
    ,[SalesPersonID]
    ,[OrderDate]
    ,[ShipDate]
    ,[OrderStatus]
    ,[ShipAddress]
    ,[BillAddress]
    ,[Quantity]
    ,[Sales]
    ,[CreationTime]
FROM Sales.OrdersArchive
ORDER BY OrderID

-- Delta detection
/*We can use EXCEPT operator to check data completeness (moving from one table to another). Use twice, replacing order of tables*/



