USE DataWarehouse;

-- Check for nulls, duplicates in PK
-- Expectations: No result
SELECT 
    cst_id,
    COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Check for unwanted spaces
-- Expectations: No result
SELECT 
    cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT 
    cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

-- Check data consistency
SELECT DISTINCT
    cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT
    cst_marital_status
FROM bronze.crm_cust_info

SELECT *
FROM bronze.crm_cust_info

-------------------------------------------------------------------------------
-- Check for nulls, duplicates in PK
-- Expectations: No result
SELECT 
    prd_id,
    COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- Expectations: No result
SELECT 
    prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check data consistency
SELECT DISTINCT
    prd_line
FROM bronze.crm_prd_info

-- Check cost values
SELECT 
    prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

SELECT *
FROM bronze.crm_prd_info

-------------------------------------------------------------------------------
-- Check for invalid date
SELECT 
    sls_order_dt
FROM bronze.crm_sales_details
WHERE LEN(sls_order_dt) != 8 OR sls_order_dt > 20500101 OR sls_order_dt < 19000101

-- Check for invalid date orders
SELECT * 
FROM bronze.crm_sales_details
WHERE  sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check the values (sales = quantity * price)
SELECT 
    CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_price) * sls_quantity 
        THEN ABS(sls_price) * sls_quantity
        ELSE sls_sales 
    END AS sls_sales,
    sls_quantity,
    CASE WHEN sls_price <= 0 OR sls_price IS NULL
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL

SELECT * 
FROM bronze.crm_sales_details

-------------------------------------------------------------------------------
-- Check for correct cid
SELECT 
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid
FROM bronze.erp_cust_az12
WHERE (CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END) NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-- Check date
SELECT
    bdate
FROM bronze.erp_cust_az12
WHERE LEN(bdate) != 10 OR bdate < '1926-01-01' OR bdate > GETDATE()

-- Check for unique gender values
SELECT DISTINCT
    gen
FROM bronze.erp_cust_az12

SELECT DISTINCT
    CASE WHEN TRIM(UPPER(REPLACE(gen, CHAR(13), ''))) IN ('F', 'FEMALE') THEN 'Female'
        WHEN TRIM(UPPER(REPLACE(gen, CHAR(13), ''))) IN ('M', 'MALE') THEN 'Male'
        ELSE 'Unknown'
    END AS gen
FROM bronze.erp_cust_az12

-------------------------------------------------------------------------------
-- Check cid value
SELECT 
    REPLACE(cid, '-', '')
FROM bronze.erp_loc_a101
WHERE LEN(REPLACE(cid, '-', '')) != 10

-- Check data consistency & standardization
SELECT DISTINCT
    CASE
        WHEN TRIM(REPLACE(cntry, CHAR(13), '')) = 'DE' THEN 'Germany'
        WHEN TRIM(REPLACE(cntry, CHAR(13), '')) IN ('USA', 'US') THEN 'United States'
        WHEN TRIM(REPLACE(cntry, CHAR(13), '')) = '' OR TRIM(REPLACE(cntry, CHAR(13), '')) IS NULL THEN 'Unknown'
        ELSE TRIM(REPLACE(cntry, CHAR(13), ''))
    END AS cntry
FROM bronze.erp_loc_a101

-------------------------------------------------------------------------------
-- Check for unwanted spaces
SELECT 
    REPLACE(cat, CHAR(13), '')
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)

-- Check data consistency & standardization
SELECT DISTINCT
    maintenance
FROM bronze.erp_px_cat_g1v2

SELECT 
    *
FROM bronze.erp_px_cat_g1v2