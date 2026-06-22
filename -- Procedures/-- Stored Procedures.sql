-- Stored Procedures

-- TASK: For US Customers find the total number of customers and average score 
CREATE PROCEDURE GetUSACustomerSummary AS
BEGIN
    SELECT 
        COUNT(*) AS TotalUSCustomers,
        AVG(Score) AS AvgUSScore
    FROM Sales.Customers
    WHERE Country = 'USA'
END

EXEC GetUSACustomerSummary

DROP PROCEDURE GetUSACustomerSummary
