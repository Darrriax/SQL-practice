/*
=====================================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)

Script Purpose:
    This stored procedure loads data into the 'silver' schema from the 'bronze' schema tables.
    It performs the following actions:
    - Truncates the silver tables before loading data.
    - Uses the 'FROM' command to load data from bronze tables to silver tables.
Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.
Usage Example:
    EXEC silver.load_silver;
=====================================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @start_batch_time DATETIME, @end_batch_time DATETIME
    BEGIN TRY
        PRINT '==================================================================================';
        PRINT '                             Loading Silver Layer';
        PRINT '==================================================================================';

        PRINT '-------------------------------------------------------------';
        PRINT '                     Loading CRM Tables';
        PRINT '-------------------------------------------------------------';

        SET @start_batch_time = GETDATE();
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> Inserting data into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname, 
            TRIM(cst_lastname) AS cst_lastname, -- Remove unwanted spaces
            CASE   
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' 
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' 
                ELSE 'Unknown'
            END AS cst_marital_status, -- Normalize marital status values to readable format
            CASE   
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' 
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' 
                ELSE 'Unknown'
            END AS cst_gndr, -- Normalize gender values to readable format
            cst_create_date
        FROM (
            SELECT 
                *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rank
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) AS t
        WHERE rank = 1; -- Select the most recent record per customer
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + 'ms';
        PRINT '-------------------------------------------------';

        ----------------------------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>> Inserting data into: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
            prd_id,
            prd_cat,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT 
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat, -- Extract category id
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- Extract product key
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'Unknown'
            END AS prd_line, -- Map product line codes to descriptive values
            CAST(prd_start_dt AS DATE) prd_start_dt,
            CAST (
                LEAD(prd_start_dt, 1) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
                AS DATE
            ) AS prd_end_dt -- Calcilate end date as one day before the next start date
        FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + 'ms';
        PRINT '-------------------------------------------------';

        ----------------------------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> Inserting data into: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE WHEN LEN(sls_order_dt) != 8 
                OR sls_order_dt > 20500101 
                OR sls_order_dt < 19000101
                THEN NULL
                ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
            END AS sls_order_dt,
            CASE WHEN LEN(sls_ship_dt) != 8 
                OR sls_ship_dt > 20500101 
                OR sls_ship_dt < 19000101
                THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE)
            END AS sls_ship_dt,
            CASE WHEN LEN(sls_due_dt) != 8 
                OR sls_due_dt > 20500101 
                OR sls_due_dt < 19000101
                THEN NULL
                ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
            END AS sls_due_dt,
            CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_price) * sls_quantity 
                THEN ABS(sls_price) * sls_quantity
                ELSE sls_sales 
            END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
            sls_quantity,
            CASE WHEN sls_price <= 0 OR sls_price IS NULL
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price -- Recalculate price if original value is incorrect
        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + 'ms';
        PRINT '-------------------------------------------------';

        ----------------------------------------------------------------------------------------
        PRINT '-------------------------------------------------------------';
        PRINT '                     Loading ERP Tables';
        PRINT '-------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> Inserting data into: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT 
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,
            CASE WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END AS bdate, -- Set future birthdates to NULL
            CASE WHEN TRIM(UPPER(REPLACE(gen, CHAR(13), ''))) IN ('F', 'FEMALE') THEN 'Female'
                WHEN TRIM(UPPER(REPLACE(gen, CHAR(13), ''))) IN ('M', 'MALE') THEN 'Male'
                ELSE 'Unknown'
            END AS gen -- Normalize gender values and handle unknown cases
        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + 'ms';
        PRINT '-------------------------------------------------';

        ----------------------------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> Inserting data into: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT 
            REPLACE(cid, '-', '') AS cid,
            CASE
                WHEN TRIM(REPLACE(cntry, CHAR(13), '')) = 'DE' THEN 'Germany'
                WHEN TRIM(REPLACE(cntry, CHAR(13), '')) IN ('USA', 'US') THEN 'United States'
                WHEN TRIM(REPLACE(cntry, CHAR(13), '')) = '' OR TRIM(REPLACE(cntry, CHAR(13), '')) IS NULL THEN 'Unknown'
                ELSE TRIM(REPLACE(cntry, CHAR(13), ''))
            END AS cntry -- Normalize and handle missing or blank country codes
        FROM bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + 'ms';
        PRINT '-------------------------------------------------';

        ----------------------------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> Inserting data into: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT 
            id,
            cat,
            subcat,
            REPLACE(maintenance, CHAR(13), '') AS maintenance
        FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + 'ms';
        PRINT '-------------------------------------------------';

        ----------------------------------------------------------------------------------------
        SET @end_batch_time = GETDATE();
        PRINT '==================================================================================';
        PRINT '                        Loading Silver Layer is completed';
        PRINT '                        Total load duration: ' + CAST(DATEDIFF(MILLISECOND, @start_batch_time, @end_batch_time) AS NVARCHAR) + 'ms';
        PRINT '==================================================================================';
    END TRY
    BEGIN CATCH
        PRINT '======================================================';
        PRINT 'AN ERROR OCCURED DURING LOADING SILVER LAYER';
        PRINT 'Error message' + ERROR_MESSAGE();
        PRINT 'Error number' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error state' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '======================================================';
    END CATCH
END;