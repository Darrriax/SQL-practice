-- Window Value Functions
USE SalesDB

-- LEAD() & LAG()
SELECT 
    Sales,
    LEAD(Sales, 2, 10) OVER (PARTITION BY ProductID ORDER BY OrderDate)
FROM Sales.Orders

-- MonthOverMonth Perfomance Analysis
-- TASK: MOM perfomance finding the percentage change in sales between cur and prev month
SELECT
    *,
    CurrentMonthSales - PreviousMonthSales AS MoM_Change,
    ROUND(CAST((CurrentMonthSales - PreviousMonthSales) AS FLOAT) / PreviousMonthSales * 100, 1) AS MoM_ChangePerc
FROM
(
    SELECT
        MONTH(OrderDate) AS OrderMonth,
        SUM(Sales) AS CurrentMonthSales,
        LAG(SUM(Sales)) OVER (ORDER BY MONTH(OrderDate)) AS PreviousMonthSales
    FROM Sales.Orders
    GROUP BY MONTH(OrderDate)
) AS t

-- Customer Retention Analysis
-- TASK: rank customers based on average number of days between orders
SELECT 
    CustomerID,
    AVG(DayDiff) AS AvgDayDiff,
    RANK() OVER (ORDER BY CASE WHEN AVG(DayDiff) IS NULL THEN 1 ELSE 0 END, AVG(DayDiff))
FROM (    
    SELECT 
        OrderID,
        CustomerID,
        DATEDIFF(DAY, OrderDate, LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate)) AS DayDiff
    FROM Sales.Orders
) AS t
GROUP BY CustomerID

-- TASK: find avg shipping duration in days for each month
SELECT 
    OrderMonth,
    AVG(DayDiff) AS AvgShippingDuration
FROM (
    SELECT 
        DATEDIFF(day, OrderDate, ShipDate) AS DayDiff,
        MONTH(OrderDate) AS OrderMonth
    FROM Sales.Orders
) AS t
GROUP BY OrderMonth

-- TASK: find number of days between each order and previous order
SELECT 
    OrderId,
    OrderDate AS CurrentOrderDate,
    LAG(OrderDate) OVER (ORDER BY OrderDate) AS PreviousOrderDate,
    DATEDIFF(day, LAG(OrderDate) OVER (ORDER BY OrderDate), OrderDate) AS NumOfDays
FROM Sales.Orders

-- FIRST_VALUE & LAST_VALUE
-- TASK: find the lowest and highest sales for each product
SELECT DISTINCT
    ProductID,
    FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales) AS LowestSales,
    FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales DESC) AS HighestSales
FROM Sales.Orders

-- TASK: find the diff between current and lowest sales
SELECT
    OrderID,
    ProductID,
    Sales,
    FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales) AS LowestSales,
    Sales - FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales) AS DiffBeetwenCurrentAndLowest
FROM Sales.Orders