USE DataWarehouse;

-- Check for nulls, duplicates in PK
-- Expectations: No result
SELECT 
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Check for unwanted spaces
-- Expectations: No result
SELECT 
    cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT 
    cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

-- Check data consistency
SELECT DISTINCT
    cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info

SELECT *
FROM silver.crm_cust_info

-------------------------------------------------------------------------------
-- Check for nulls, duplicates in PK
-- Expectations: No result
SELECT 
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- Expectations: No result
SELECT 
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check data consistency
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info

-- Check cost values
SELECT 
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT *
FROM silver.crm_prd_info

-------------------------------------------------------------------------------
-- Check for invalid date
SELECT 
    sls_order_dt
FROM silver.crm_sales_details
WHERE LEN(sls_order_dt) != 10 OR sls_order_dt > CAST('2050-01-01' AS DATE) OR sls_order_dt < CAST('1900-01-01' AS DATE)

-- Check for invalid date orders
SELECT * 
FROM silver.crm_sales_details
WHERE  sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check the values (sales = quantity * price)
SELECT 
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL

SELECT * 
FROM silver.crm_sales_details

-------------------------------------------------------------------------------
-- Check for correct cid
SELECT 
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid
FROM silver.erp_cust_az12
WHERE (CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END) NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-- Check date
SELECT
    bdate
FROM silver.erp_cust_az12
WHERE LEN(bdate) != 10 OR bdate < '1926-01-01' OR bdate > GETDATE()

-- Check for unique gender values
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12

SELECT * 
FROM silver.erp_cust_az12

-------------------------------------------------------------------------------
-- Check cid value
SELECT 
    cid
FROM silver.erp_loc_a101
WHERE LEN(cid) != 10

-- Check data consistency & standardization
SELECT DISTINCT
    CASE
        WHEN cntry = 'DE' THEN 'Germany'
        WHEN cntry IN ('USA', 'US') THEN 'United States'
        WHEN cntry = '' OR cntry IS NULL THEN 'Unknown'
        ELSE cntry
    END AS cntry
FROM silver.erp_loc_a101

SELECT *
FROM silver.erp_loc_a101

-------------------------------------------------------------------------------
-- Check for unwanted spaces
SELECT 
    cat
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)

-- Check data consistency & standardization
SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2

SELECT *
FROM silver.erp_px_cat_g1v2