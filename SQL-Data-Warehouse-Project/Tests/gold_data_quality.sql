USE DataWarehouse;

-- Check for uniqueness of customer key in gold.dim_customers
-- Expectation: No results 
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-------------------------------------------------------------------------------
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-------------------------------------------------------------------------------
-- Check the data model connectivity between fact and dimensions
-- 1. Find sales missing a valid customer
SELECT 
    'Missing Customer' AS issue,
    fs.* FROM gold.fact_sales AS fs
WHERE NOT EXISTS (
    SELECT 1 
    FROM gold.dim_customers dc 
    WHERE dc.customer_key = fs.customer_key
)

UNION ALL

-- 2. Find sales missing a valid product
SELECT 
    'Missing Product' AS issue,
    fs.* FROM gold.fact_sales AS fs
WHERE NOT EXISTS (
    SELECT 1 
    FROM gold.dim_products dp 
    WHERE dp.product_key = fs.product_key
);