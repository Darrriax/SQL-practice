-- Window Ranking Function
USE SalesDB

-- ROW_NUMBER()
SELECT 
OrderID,
Sales,
ROW_NUMBER() OVER (ORDER BY Sales DESC) AS Rank
FROM Sales.Orders

-- RANK()
SELECT 
OrderID,
Sales,
RANK() OVER (ORDER BY Sales DESC) AS Rank
FROM Sales.Orders

-- DENSE_RANK()
SELECT 
OrderID,
Sales,
DENSE_RANK() OVER (ORDER BY Sales DESC) AS Rank
FROM Sales.Orders

-- USE CASES
-- Top-N analysis
SELECT
    OrderID,
    ProductID,
    Sales,
    RankByProducts
FROM (
    SELECT 
        OrderID,
        ProductID,
        Sales,
        ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY Sales DESC) RankByProducts
    FROM Sales.Orders
) AS t
WHERE RankByProducts = 1

SELECT 
    *
FROM (
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales,
        ROW_NUMBER() OVER (ORDER BY SUM(Sales)) RankCustomers
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t
WHERE RankCustomers <= 2

-- Unique IDs
SELECT 
ROW_NUMBER() OVER (ORDER BY OrderID, OrderDate) UniqueID,
*
FROM Sales.OrdersArchive

-- Identify duplicates
SELECT *
FROM (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY CreationTime DESC) AS Flag,
        *
    FROM Sales.OrdersArchive
) AS t
WHERE Flag = 1

-- CUME_DIST()
-- PERCENT_RANK()
SELECT *
FROM (
    SELECT 
        *,
        CUME_DIST() OVER (ORDER BY Price DESC) AS CumeDist
    FROM Sales.Products
) AS t
WHERE CumeDist <= 0.4

-- NTILE()
SELECT
    OrderID,
    Sales,
    NTILE(1) OVER (ORDER BY Sales DESC) OneBucket,
    NTILE(2) OVER (ORDER BY Sales DESC) TwoBuckets,
    NTILE(3) OVER (ORDER BY Sales DESC) ThreeBuckets,
    NTILE(4) OVER (ORDER BY Sales DESC) FourBuckets
FROM Sales.Orders

-- USE CASE
SELECT 
    *,
    CASE Segments
        WHEN 1 THEN 'High'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'Low'
    END
FROM (
    SELECT 
        OrderID,
        Sales,
        NTILE(3) OVER (ORDER BY Sales DESC) AS Segments
    FROM Sales.Orders
) AS t

-- EQUALIZING LOAD
SELECT 
    *,
    NTILE(2) OVER (ORDER BY OrderID) AS Buckets
FROM Sales.Orders
