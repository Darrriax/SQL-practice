-- Window Functions Basics
USE MyDatabase;

-- TASK: find total number of orders
SELECT 
    COUNT(*) AS TotalNumberOfOrders
FROM orders

-- TASK: find total sales of orders
SELECT 
    SUM(sales) AS TotalSales
FROM orders

-- TASK: find average sales of all orders
SELECT
    AVG(sales) AS AverageSales
FROM orders

-- TASK: find highest sales of all orders
SELECT
    MAX(sales) AS HishestSales
FROM orders

-- TASK: find lowest sales of all orders
SELECT
    MIN(sales) AS LowestSales
FROM orders

-- TASK: analyze the scores in customers table
SELECT
    COUNT(*) AS NumberOfCustomers,
    SUM(score) AS TotalScore,
    AVG(score) AS AverageScore,
    MAX(score) AS HihgestScore,
    MIN(score) AS LowestScore
FROM customers

-- WINDOW vs GROUP BY
-- TASK: find total sales across all orders
USE SalesDB
SELECT 
    SUM(Sales) AS TotalSales
FROM Sales.Orders

-- TASK: find total sales for each product
SELECT 
    ProductID,
    SUM(Sales) AS TotalSales
FROM Sales.Orders
GROUP BY ProductID

-- TASK: find total sales for each product + provide order id & date
SELECT 
    OrderID, 
    ProductID,
    OrderDate,
    SUM(Sales) OVER (PARTITION BY ProductID) AS TotalSalesByProduct
FROM Sales.Orders

-- WINDOW Partition By

-- TASK: find the total sales across all orders additionally provide details such order id & date
SELECT
    OrderID,
    OrderDate,
    SUM(Sales) OVER () AS TotalSales
FROM Sales.Orders

-- TASK: find the total sales for each product + order id & date
SELECT 
    OrderID,
    OrderDate,
    Sales,
    SUM(Sales) OVER () AS TotalSales,
    SUM(Sales) OVER (PARTITION BY ProductID) AS TotalSalesOfProduct
FROM Sales.Orders

-- TASK: find the total sales for each combination of product and order status
SELECT 
    OrderStatus,
    ProductID,
    Sales,
    SUM(Sales) OVER (PARTITION BY ProductID, OrderStatus) AS SalesByProductAndStatus
FROM Sales.Orders

 -- WINDOW Order By

-- TASK: Rank each order based on their sales from highest to lowest + order id & order date
SELECT
    OrderID,
    OrderDate,
    Sales,
    RANK() OVER (ORDER BY Sales DESC) AS Ranked
FROM Sales.Orders

-- Window Frame (ROWS|  )
SELECT
    OrderStatus,
    OrderDate,
    OrderID,
    Sales,
    SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS Sum3NextOrders,
    SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate ROWS 2 PRECEDING) AS Precedings2,
    SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS AllSalesFromStatus
FROM Sales.Orders

-- TASK: Find the total sales for each order status, only for two products 101 and 102
SELECT
    OrderStatus,
    ProductID,
    Sales,
    SUM(Sales) OVER (PARTITION BY OrderStatus) AS TotalSales
FROM Sales.Orders
WHERE ProductID IN (101, 102)

-- TASK: Rank customers based on their total sales
SELECT
    CustomerID,
    SUM(Sales) AS TotalSales,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS CustomerRank
FROM Sales.Orders
GROUP BY CustomerID
