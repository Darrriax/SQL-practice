-- Views
USE SalesDB;

-- TASK:find the running total of sales for each month
WITH CTE_Monthly_Summary AS 
(
    SELECT 
        DATETRUNC(month, OrderDate) AS OrderMonth,
        SUM(Sales) AS TotalSales,
        COUNT(OrderID) AS TotalOrders,
        SUM(Quantity) AS TotalQuantities
    FROM Sales.Orders
    GROUP BY DATETRUNC(month, OrderDate)
)

SELECT
    OrderMonth,
    SUM(TotalSales) OVER (ORDER BY OrderMonth) AS RunningTotal
FROM CTE_Monthly_Summary;

SELECT *
FROM Sales.V_Monthly_Summary

DROP VIEW Sales.V_Monthly_Summary

SELECT *
FROM Sales.V_Combined_Tables

SELECT *
FROM Sales.V_EU_Order_Details

