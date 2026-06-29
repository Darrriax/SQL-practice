-- CTE
USE SalesDB;

-- TASK: find the total sales per customer
WITH CTE_Total_Sales AS 
(
    SELECT 
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
)
-- TASK: find the last order date for each customer
, CTE_Last_Order_Date AS 
(
    SELECT 
        CustomerID,
        MAX(OrderDate) AS LastOrderDate
    FROM Sales.Orders
    GROUP BY CustomerID
)
-- Nested CTE
-- TASK: rank customers based on total sales per customer
, CTE_Customer_Rank AS 
(
    SELECT 
        *,
        RANK() OVER (ORDER BY TotalSales DESC) AS CustomerRank
    FROM CTE_Total_Sales
)
-- TASK: segment customers based on their total sales
, CTE_Customer_Segments AS
(
    SELECT 
        *,
        CASE 
            WHEN TotalSales > 100 THEN 'High' 
            WHEN TotalSales > 50 THEN 'Medium'
            ELSE 'Low'
        END AS CustomerSegments
    FROM CTE_Total_Sales
)

SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    cts.TotalSales,
    clod.LastOrderDate,
    ccr.CustomerRank,
    ccs.CustomerSegments
FROM Sales.Customers AS c
LEFT JOIN CTE_Total_Sales AS cts
ON cts.CustomerID = c.CustomerID
LEFT JOIN CTE_Last_Order_Date AS clod
ON clod.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Rank AS ccr
ON ccr.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Segments AS ccs
ON ccs.CustomerID = c.CustomerID;

-- Recursive CTE
-- TASK: generate a sequence of numbers from 1 to 20
WITH CTE_Range_1to20 AS
(
    -- Anchor
    SELECT 1 AS num
    UNION ALL
    -- Recursive
    SELECT 
        num + 1
    FROM CTE_Range_1to20
    WHERE num < 20
)
SELECT * FROM CTE_Range_1to20;
-- OPTION (MAXRECURSION 10)

-- TASK: show the employee hierarchy by displaying each employee level within the organization
WITH CTE_Employee_Hierarcy AS (
    SELECT 
        1 AS EmployeeLevel,
        EmployeeID,
        FirstName,
        LastName,
        ManagerID
    FROM Sales.Employees
    WHERE ManagerID IS NULL

    UNION ALL

    SELECT 
        EmployeeLevel + 1,
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.ManagerID
    FROM Sales.Employees AS e
    INNER JOIN CTE_Employee_Hierarcy as ceh
    ON e.ManagerID = ceh.EmployeeID
)

SELECT * FROM CTE_Employee_Hierarcy