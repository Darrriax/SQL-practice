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

-- View create & drop
IF OBJECT_ID ('Sales.V_Monthly_Summary', 'V') IS NOT NULL
    DROP VIEW Sales.V_Monthly_Summary
GO
CREATE VIEW Sales.V_Monthly_Summary AS
(
    SELECT 
        DATETRUNC(month, OrderDate) AS OrderMonth,
        SUM(Sales) AS TotalSales,
        COUNT(OrderID) AS TotalOrders,
        SUM(Quantity) AS TotalQuantities
    FROM Sales.Orders
    GROUP BY DATETRUNC(month, OrderDate)
)

SELECT *
FROM Sales.V_Monthly_Summary

DROP VIEW Sales.V_Monthly_Summary

-- TASK: provide a view that combines details from orders, products, customers, and employees
IF OBJECT_ID('Sales.V_Combined_Tables', 'V') IS NOT NULL
    DROP VIEW Sales.V_Combined_Tables
GO
CREATE VIEW Sales.V_Combined_Tables AS 
(
    SELECT 
        o.OrderID,
        o.OrderDate,
        COALESCE(c.FirstName, '') + ' ' + COALESCE(c.LastName, '') AS CustomerName,
        c.Country AS CustomerCountry,
        COALESCE(e.FirstName, '') + ' ' + COALESCE(e.LastName, '') AS EmployeeName,
        e.Department,
        p.Product,
        p.Category,
        p.Price
    FROM Sales.Orders AS o
    LEFT JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID
    LEFT JOIN Sales.Products AS p
    ON o.ProductID = p.ProductID
    LEFT JOIN Sales.Employees AS e
    ON o.SalesPersonID = e.EmployeeID
)

SELECT *
FROM Sales.V_Combined_Tables

-- TASK: provide a view for the EU Sales team that combines details from all tables and exclides data related to the USA
CREATE VIEW Sales.V_EU_Order_Details AS (    
    SELECT 
        o.OrderID,
        o.OrderDate,
        p.Product,
        p.Category,
        p.Price,
        o.Sales,
        o.OrderStatus,
        o.Quantity,
        COALESCE(c.FirstName, '') + ' ' + COALESCE(c.LastName, '') AS CustomerName,
        c.Country AS CustomerCountry,
        COALESCE(e.FirstName, '') + ' ' + COALESCE(e.LastName, '') AS EmployeeName,
        e.Department
    FROM Sales.Orders AS o
    LEFT JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID
    LEFT JOIN Sales.Products AS p
    ON o.ProductID = p.ProductID
    LEFT JOIN Sales.Employees AS e
    ON o.SalesPersonID = e.EmployeeID
    WHERE c.Country != 'USA'
)

SELECT *
FROM Sales.V_EU_Order_Details

