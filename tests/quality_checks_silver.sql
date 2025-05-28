/*
===============================================================================
Silver Layer - Data Quality Checks
===============================================================================
Purpose:
    This script performs data validation and quality checks on the 'silver' 
    layer after applying transformations from bronze. It covers:
    - Primary key nulls or duplicates
    - Unwanted whitespace
    - Data standardization
    - Invalid or inconsistent values (dates, IDs, prices, etc.)

Usage:
    Run this script after loading data into the Silver Layer.
    Fix any issues before proceeding to the Gold Layer or reporting.
===============================================================================
*/

-- ============================================================================
-- crm_cust_info
-- ============================================================================

-- Nulls or duplicates in Primary Key
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Unwanted spaces
SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Data standardization
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;


-- ============================================================================
-- crm_prd_info
-- ============================================================================

-- Nulls or duplicates in Primary Key
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Unwanted spaces
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Invalid or missing costs
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Standardization
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Invalid date orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ============================================================================
-- crm_sales_details
-- ============================================================================

-- Invalid date ranges
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Sales mismatch
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_price IS NULL
   OR sls_quantity IS NULL
   OR sls_sales <= 0
   OR sls_price <= 0
   OR sls_quantity <= 0;


-- ============================================================================
-- erp_cust_az12
-- ============================================================================

-- Out-of-range or future birthdates
SELECT *
FROM silver.erp_cust_az12
WHERE bdate > GETDATE()
   OR bdate < '1924-01-01';

-- Standardize gender
SELECT DISTINCT gen
FROM silver.erp_cust_az12;


-- ============================================================================
-- erp_loc_a101
-- ============================================================================

-- Clean and standardized country names
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ============================================================================
-- erp_px_cat_g1v2
-- ============================================================================

-- Unwanted spaces
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Maintenance standardization check
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;
