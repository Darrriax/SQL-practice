-- Window Aggregate Functions
USE SalesDB

-- COUNT()
-- TASK: total num of orders
SELECT 
    COUNT(*) AS TotalOrders
FROM Sales.Orders


-- TASK: total num of orders + OrderID & OrderDate
SELECT 
    OrderID,
    OrderDate,
    COUNT(*) OVER () AS TotalOrders
FROM Sales.Orders

-- TASK: total num of orders for each customer
SELECT DISTINCT
    CustomerID,
    COUNT(*) OVER (PARTITION BY CustomerID) AS NumOfOrders
FROM Sales.Orders

-- TASK: find the total number of customers, additionally provide all customer's details
SELECT 
    *,
    COUNT(*) OVER () AS TotalCustomers
FROM Sales.Customers

-- TASK: find the total number of scores for the customers
SELECT
    Score,
    COUNT(Score) OVER () AS TotalScore
FROM Sales.Customers

-- TASK: Check if 'Orders' contains any duplicate rows
SELECT
*
FROM (
    SELECT
    OrderID,
    COUNT(*) OVER (PARTITION BY OrderID) AS CheckPK
    FROM Sales.OrdersArchive
) AS t
WHERE CheckPK > 1

-- SUM()
-- TASK: find the total sales across all orders and the ts for each product
SELECT 
    ProductID,
    OrderId,
    OrderDate,
    SUM(Sales) OVER () AS TotalSales,
    SUM(Sales) OVER (PARTITION BY ProductID) AS SalesByProduct
FROM Sales.Orders
 
-- TASK: find the % contribution of each product's sales to the total sales
SELECT
    CAST(SalesByProduct/CAST(TotalSales AS FLOAT)*100 AS VARCHAR) + '%' AS PercentConrtibution
FROM (
    SELECT DISTINCT
        ProductID,
        SUM(Sales) OVER (PARTITION BY ProductID) AS SalesByProduct,
        SUM(Sales) OVER () AS TotalSales
    FROM Sales.Orders
) AS t

-- AVG()
-- TASK: avg across all orders, avg sales for each product
SELECT 
    ProductID,
    OrderId,
    OrderDate,
    AVG(Sales) OVER () AS AVGSales,
    AVG(Sales) OVER (PARTITION BY ProductID) AS AVGByProduct
FROM Sales.Orders

-- TASK: avg scores of customers
SELECT
CustomerID,
LastName,
AVG(COALESCE(Score, 0)) OVER () AS AvgScore
FROM Sales.Customers

-- TASK: find all orders where sales are higher that the average sales across all orders
SELECT 
    OrderID,
    ProductID,
    Sales,
    AVGSales
FROM (
    SELECT 
        *,
        AVG(Sales) OVER () AS AVGSales
    FROM Sales.Orders
) AS t
WHERE Sales > AVGSales

-- MIN() & MAX()
SELECT 
    OrderID, 
    OrderDate, 
    ProductID,
    Sales,
    MAX(Sales) OVER () AS HighestSale,
    MIN(Sales) OVER () AS LowestSale,
    MAX(Sales) OVER (PARTITION BY ProductID) AS HighestSalePerProduct,
    MIN(Sales) OVER (PARTITION BY ProductID) AS LowestSalePerProduct
FROM Sales.Orders

SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Department,
    Salary
FROM (
    SELECT 
        *,
        MAX(Salary) OVER () AS MaxSalary
    FROM Sales.Employees
) AS t
WHERE Salary = MaxSalary

SELECT 
    OrderID,
    ProductID,
    OrderDate,
    Sales,
    Sales - MIN(Sales) OVER () AS DeviationFromMin,
    MAX(Sales) OVER () - Sales AS DeviationFromMax
FROM Sales.Orders

SELECT
    ProductID,
    OrderID,
    OrderDate,
    Sales,
    AVG(Sales) OVER (PARTITION BY ProductID ORDER BY OrderDate) AS MovingAVG
FROM Sales.Orders

SELECT
    ProductID,
    OrderID,
    OrderDate,
    Sales,
    AVG(Sales) OVER (PARTITION BY ProductID ORDER BY OrderDate ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS MovingAVG
FROM Sales.Orders