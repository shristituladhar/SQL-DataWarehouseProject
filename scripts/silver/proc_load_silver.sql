/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze → Silver)
===============================================================================
Purpose:
    This procedure performs the cleansing, normalization, and transformation 
    of data from the Bronze Layer and loads it into the Silver Layer tables.

    It includes:
    - Truncating each silver table to allow repeatable batch runs
    - Data cleaning, enrichment, and formatting logic per business rules
    - Metadata tracking for load durations and error handling

    Applies transformations such as:
    - Handling NULLs, zero dates, and incorrect values
    - Standardizing codes (e.g., gender, marital status, product lines)
    - Deriving surrogate values (e.g., product end dates using LEAD)
    - Removing prefix text and invalid data
    - Ensuring consistent format across datasets

Execution:
    Run this to execute the procedure: 
        EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '===========================================================================================';
        PRINT '>> Loading Silver Layer';
        PRINT '===========================================================================================';

        -- CRM Customer Info
        PRINT '-------------------------------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-------------------------------------------------------------------------------------------';
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> Inserting into silver.crm_cust_info';
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
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                 ELSE 'N/A' END,
            CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                 ELSE 'N/A' END,
            cst_create_date
        FROM (
            SELECT *, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- CRM Product Info
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>> Inserting into silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT 
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LEN(prd_key)),
            prd_nm,
            ISNULL(prd_cost, 0),
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'N/A' END,
            CAST(prd_start_dt AS DATE),
            CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE)
        FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- CRM Sales Details
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> Inserting into silver.crm_sales_details';
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
            CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE) END,
            CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE) END,
            CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE) END,
            CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                 THEN sls_quantity * ABS(sls_price)
                 ELSE sls_sales END,
            sls_quantity,
            CASE WHEN sls_price IS NULL OR sls_price <= 0 
                 THEN sls_sales / NULLIF(sls_quantity, 0)
                 ELSE sls_price END
        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- ERP Customer Info
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> Inserting into silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
        SELECT 
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END,
            CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END,
            CASE WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                 WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                 ELSE 'N/A' END
        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- ERP Location Info
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> Inserting into silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (cid, cntry)
        SELECT 
            REPLACE(cid, '-', ''),
            CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
                 ELSE TRIM(cntry) END
        FROM bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- ERP Product Category
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> Inserting into silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT id, cat, subcat, maintenance
        FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        SET @batch_end_time = GETDATE();
        PRINT '===========================================================================================';
        PRINT 'Loading Silver Layer is Completed';
        PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '===========================================================================================';

    END TRY
    BEGIN CATCH
        PRINT '===========================================================================================';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '===========================================================================================';
    END CATCH
END;

