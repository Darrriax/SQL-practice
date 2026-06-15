-- Date & Time
USE SalesDB

-- YEAR(), MONTH(), DAY()
SELECT 
OrderID,
CreationTime,
YEAR(CreationTime) Year,
MONTH(CreationTime) Month,
DAY(CreationTime) Day
FROM Sales.Orders

-- DATEPART(part, date) !STORED AS A INT!
SELECT 
OrderID,
CreationTime,
DATEPART(year, CreationTime) Year_DP,
DATEPART(month, CreationTime) Month_DP,
DATEPART(day, CreationTime) Day_DP,
DATEPART(hour, CreationTime) Hour_DP,
DATEPART(quarter, CreationTime) Quarter_DP,
DATEPART(weekday, CreationTime) Weekday_DP,
DATEPART(week, CreationTime) Week_DP
FROM Sales.Orders

-- DATENAME(part, date) !STORED AS A STRING!
SELECT 
OrderID,
CreationTime,
DATENAME(month, CreationTime) AS Month_DN,
DATENAME(weekday, CreationTime) AS Weekday_DN,
DATENAME(day, CreationTime) AS Day_DN,
DATENAME(year, CreationTime) AS Year_DN 
FROM Sales.Orders

-- DATETRUNC(part, date) !KEEP|RESET!
SELECT 
    OrderID,
    CreationTime,
    DATETRUNC(minute, CreationTime) AS Minute_DT,
    DATETRUNC(day, CreationTime) AS Day_DT,
    DATETRUNC(year, CreationTime) AS Year_DT
FROM Sales.Orders

SELECT 
    DATETRUNC(month, CreationTime) AS Month_DT,
    COUNT(*)
FROM Sales.Orders
GROUP BY DATETRUNC(month, CreationTime)

-- EOMONTH
SELECT 
    OrderID,
    CreationTime,
    EOMONTH(CreationTime) AS End_of_month
FROM Sales.Orders

-- CHALLANGE: FIRST OF MONTH
SELECT 
    OrderID,
    CreationTime,
    DATETRUNC(month, CreationTime) AS Start_of_month
FROM Sales.Orders

-- TASK 1: Orders per year
SELECT 
    YEAR(OrderDate) AS Year_DT,
    COUNT(*) AS Orders_quantity
FROM Sales.Orders
GROUP BY YEAR(OrderDate)
UNION 
SELECT 
    YEAR(OrderDate),
    COUNT(*)
FROM Sales.OrdersArchive
GROUP BY YEAR(OrderDate)


-- TASK 1: Orders per month
SELECT 
    DATEPART(month, OrderDate) AS Month_NUM,
    DATENAME(month, OrderDate) AS Month_DN,
    COUNT(*) AS Orders_number
FROM Sales.Orders
GROUP BY DATEPART(month, OrderDate), DATENAME(month, OrderDate)
UNION
SELECT 
    DATEPART(month, OrderDate) AS Month_NUM,
    DATENAME(month, OrderDate) AS Month_DN,
    COUNT(*)
FROM Sales.OrdersArchive
GROUP BY DATEPART(month, OrderDate), DATENAME(month, OrderDate)

-- TASK 2: Show all orders that were placed during the month of february
SELECT 
    *
FROM Sales.Orders
WHERE MONTH(OrderDate) = 2

-- FORMAT
SELECT
    OrderID,
    CreationTime,
    FORMAT(CreationTime, 'MM-dd-yyyy') USA_format,
    FORMAT(CreationTime, 'dd-MM-yyyy') EU_format,
    FORMAT(CreationTime, 'dd') Day,
    FORMAT(CreationTime, 'ddd') Day_abbr,
    FORMAT(CreationTime, 'dddd') Day_full,
    FORMAT(CreationTime, 'MM') Month,
    FORMAT(CreationTime, 'MMM') Month_abbr,
    FORMAT(CreationTime, 'MMMM') Month_full
FROM Sales.Orders

-- TASK: show as Day Wed Jan Q1 2025 12:34:56 PM
SELECT 
    CreationTime,
    'Day' + FORMAT(CreationTime, ' ddd MMM Q' + 
    DATENAME(quarter, CreationTime) + 
    ' yyyy hh:mm:ss tt') AS FormattedDate
FROM Sales.Orders

-- USE CASE
SELECT 
    FORMAT(OrderDate, 'MMM yy') AS Month_and_year,
    COUNT(*) AS Orders
FROM Sales.Orders
GROUP BY FORMAT(OrderDate, 'MMM yy')

-- CONVERT
SELECT
    CONVERT(INT, '123') AS [String to INT (CONVERT)],
    CONVERT(DATE, '2023-03-10') AS [String to DATE (CONVERT)],
    CreationTime,
    CONVERT(DATE, CreationTime) AS [DATETIME to DATE (CONVERT)],
    CONVERT(VARCHAR, CreationTime, 32) AS [DATETIME to VARCHAR (CONVERT to USA Std. Style:32)],
    CONVERT(VARCHAR, CreationTime, 34) AS [DATETIME to VARCHAR (CONVERT to EU Std. Style:34)]
FROM Sales.Orders

-- CAST
SELECT
    CAST('123' AS INT) [String to INT],
    CAST(123 AS VARCHAR) [INT to String],
    CAST('2025-03-10' AS DATE) [String to DATE],
    CAST('2025-03-10' AS DATETIME) [String to DATETIME],
    CreationTime,
    CAST(CreationTime AS DATE) [DATETIME to DATE]
FROM Sales.Orders

-- DATEADD
SELECT 
    OrderID,
    OrderDate,
    DATEADD(month, 3, OrderDate) AS ThreeMonthLater,
    DATEADD(year, 2, OrderDate) AS TwoYearsLater,
    DATEADD(day, -10, OrderDate) AS TenDaysBefore
FROM Sales.Orders

-- DATEDIFF
SELECT
    DATEDIFF(day, OrderDate, ShipDate) AS Difference
FROM Sales.Orders

-- TASK: calculate the age of emplyees
SELECT 
    FirstName,
    LastName, 
    Department,
    DATEDIFF(year, BirthDate, GETDATE()) AS Age
FROM Sales.Employees

-- TASK: avg shipping duration in days for each month
SELECT 
    FORMAT(OrderDate, 'MMMM') Month,
    AVG(DATEDIFF(day, OrderDate, ShipDate)) AVG_shipping_duration
FROM Sales.Orders
GROUP BY FORMAT(OrderDate, 'MMMM')

-- TASK: find the numbers of days between each order and previous order
SELECT 
    OrderID,
    OrderDate AS Order_date,
    LAG(OrderDate) OVER (ORDER BY OrderDate) AS Prev_order_date,
    DATEDIFF(day, LAG(OrderDate) OVER (ORDER BY OrderDate), OrderDate) AS Day_diff_between_orders
FROM Sales.Orders

--ISDATE
SELECT
    ISDATE('123') DATECHECK1,
    ISDATE('2025-08-20') DATECHECK2, -- THIS IS TRUE
    ISDATE('20-08-2025') DATECHECK3,
    ISDATE('2025') DATECHECK4, -- THIS IS TRUE
    ISDATE('08') DATECHECK5

SELECT
    OrderDate,
    CASE WHEN ISDATE(OrderDate) = 1 THEN CAST(OrderDate AS DATE)
    ELSE '9999-01-01'
    END NewOrderDate
FROM
(
    SELECT '2025-08-20' AS OrderDate UNION
    SELECT '2025-08-21' UNION
    SELECT '2025-08-22' UNION
    SELECT '2025-08'
) AS t