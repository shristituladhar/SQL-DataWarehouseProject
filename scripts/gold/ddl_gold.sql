/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Purpose:
    This script builds the final Gold Layer views in the data warehouse 
    using a star schema design (fact + dimension). It pulls data from 
    the Silver Layer, applies final transformations, and shapes it 
    for analytics and reporting.

Usage:
    Run this script after the Silver Layer is built and tested.
===============================================================================
*/


-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,  -- Surrogate key
    a.cst_id AS customer_id,
    a.cst_key AS customer_number,
    a.cst_firstname AS first_name,
    a.cst_lastname AS last_name,
    c.cntry AS country,
    a.cst_marital_status AS marital_status,
    CASE 
        WHEN a.cst_gndr != 'N/A' THEN a.cst_gndr   -- CRM is main gender source
        ELSE COALESCE(b.gen, 'N/A')                -- fallback from ERP
    END AS gender,
    b.bdate AS birthdate,
    a.cst_create_date AS create_date
FROM silver.crm_cust_info a
LEFT JOIN silver.erp_cust_az12 b ON a.cst_key = b.cid
LEFT JOIN silver.erp_loc_a101 c ON a.cst_key = c.cid;
GO


-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY a.prd_start_dt, a.prd_key) AS product_key, -- Surrogate key
    a.prd_id AS product_id,
    a.prd_key AS product_number,
    a.prd_nm AS product_name,
    a.cat_id AS category_id,
    b.cat AS category,
    b.subcat AS subcategory,
    b.maintenance,
    a.prd_cost AS cost,
    a.prd_line AS product_line,
    a.prd_start_dt AS start_date
FROM silver.crm_prd_info a
LEFT JOIN silver.erp_px_cat_g1v2 b ON a.cat_id = b.id
WHERE a.prd_end_dt IS NULL; -- Exclude old/historical records
GO


-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    a.sls_ord_num AS order_number,
    b.product_key,
    c.customer_key,
    a.sls_order_dt AS order_date,
    a.sls_ship_dt AS shipping_date,
    a.sls_due_dt AS due_date,
    a.sls_sales AS sales_amount,
    a.sls_quantity AS quantity,
    a.sls_price AS price
FROM silver.crm_sales_details a
LEFT JOIN gold.dim_products b ON a.sls_prd_key = b.product_number
LEFT JOIN gold.dim_customers c ON a.sls_cust_id = c.customer_id;
GO
