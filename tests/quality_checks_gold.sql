/*
===============================================================================
Gold Layer - Data Quality Checks
===============================================================================
Purpose:
    This script performs quality checks on the final 'gold' layer after
    building views from Silver. It verifies:
    - Surrogate key uniqueness in dimensions
    - Referential integrity between fact and dimensions
    - Nulls or unexpected data in critical fields
    - Clean business-ready data for reporting

Usage:
    Run this script after creating Gold views.
    Make sure no issues exist before consuming the data in reports/dashboards.
===============================================================================
*/

-- =======================================
-- DIMENSION TABLE: gold.dim_customers
-- =======================================

-- check for duplicate customer keys
SELECT customer_key, COUNT(*) AS total
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- check if any customer in CRM table duplicates after joining with ERP
SELECT cst_id, COUNT(*) AS cnt
FROM (
	SELECT a.cst_id
	FROM silver.crm_cust_info a
	LEFT JOIN silver.erp_cust_az12 b ON a.cst_key = b.cid
	LEFT JOIN silver.erp_loc_a101 c ON a.cst_key = c.cid
) t
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- check gender integration logic
SELECT DISTINCT 
	a.cst_gndr,
	b.gen,
	CASE 
		WHEN a.cst_gndr != 'N/A' THEN a.cst_gndr
		ELSE COALESCE(b.gen, 'N/A')
	END AS final_gender
FROM silver.crm_cust_info a
LEFT JOIN silver.erp_cust_az12 b ON a.cst_key = b.cid
ORDER BY 1, 2;



-- =======================================
-- DIMENSION TABLE: dim_products
-- =======================================

-- check for duplicate product keys
SELECT product_key, COUNT(*) AS total
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- check uniqueness of product_number after joining and filtering
SELECT prd_key, COUNT(*) AS cnt
FROM (
	SELECT a.prd_key
	FROM silver.crm_prd_info a
	LEFT JOIN silver.erp_px_cat_g1v2 b ON a.cat_id = b.id
	WHERE a.prd_end_dt IS NULL
) t
GROUP BY prd_key
HAVING COUNT(*) > 1;



-- =======================================
-- FACT TABLE: fact_sales
-- =======================================

-- check if any customer_key or product_key is missing in fact table
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;
