-- Subqueries
USE SalesDB

SELECT 
DISTINCT TABLE_NAME
FROM INFORMATION_SCHEMA.COLUMNS

-- TASK: find the products that have a price hogher that the average price of all products
SELECT 
    ProductID,
    Product,
    Price
FROM (
    SELECT 
        ProductID,
        Product,
        Price,
        AVG(Price) OVER () AS AvgPrice
    FROM Sales.Products
) AS t 
WHERE Price > AvgPrice

-- TASK: rank customers based on their total amount of sales
SELECT 
    *,
    RANK() OVER (ORDER BY TotalSales DESC) AS CustomerRank
FROM (  
    SELECT 
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t

-- Show the product IDs, names, prices, and the total number of orders
SELECT 
    ProductID,
    Product,
    Price,
    (SELECT COUNT (*) FROM Sales.Orders) AS TotalOrders
FROM Sales.Products

-- TASK: show all customer details and find the total orders for each customer
SELECT 
    m.*,
    t.TotalOrders
FROM Sales.Customers AS m
LEFT JOIN (
    SELECT 
        CustomerID,
        COUNT (*) AS TotalOrders
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t
ON m.CustomerID = t.CustomerID 

-- TASK: find the products that have a price higher than the avg price of all products
SELECT 
    ProductID,
    Product,
    Price
FROM Sales.Products
WHERE Price > (SELECT AVG(Price) FROM Sales.Products)

 -- TASK: show the details of orders made by customers in Geramny
 SELECT *
 FROM Sales.Orders
 WHERE CustomerID IN (SELECT CustomerID FROM Sales.Customers WHERE Country = 'Germany')

-- TASK: as previous, but not from Germany
 SELECT *
 FROM Sales.Orders
 WHERE CustomerID IN (SELECT CustomerID FROM Sales.Customers WHERE Country != 'Germany')
-- or
 SELECT *
 FROM Sales.Orders
 WHERE CustomerID NOT IN (SELECT CustomerID FROM Sales.Customers WHERE Country = 'Germany')

-- TASK: find female employees whose salaries are greater than the salaries of any male employees
SELECT *
FROM Sales.Employees
WHERE Gender = 'F' AND Salary > ANY (SELECT Salary FROM Sales.Employees WHERE Gender = 'M')

-- TASK: find female employees whose salaries are greater than the salaries of all male employees
SELECT *
FROM Sales.Employees
WHERE Gender = 'F' AND Salary > ALL (SELECT Salary FROM Sales.Employees WHERE Gender = 'M')

-- TASK: show all customer details and find the total orders for each customer
SELECT 
    *,
    (SELECT COUNT (*) FROM Sales.Orders AS o WHERE o.CustomerID = m.CustomerID) AS TotalSales
FROM Sales.Customers AS m

-- TASK: show the order details for customers in Germany
SELECT *
FROM Sales.Orders AS o
WHERE EXISTS (SELECT 1 FROM Sales.Customers AS c WHERE Country = 'Germany' AND o.CustomerID = c.CustomerID)
