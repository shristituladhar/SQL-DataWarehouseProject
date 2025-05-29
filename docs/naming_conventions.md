# Naming Conventions

This document explains the naming conventions followed in this SQL Data Warehouse project. The goal is to keep everything consistent, easy to understand, and ready for business-level analytics.

---

## General Principles

- Use `snake_case` (all lowercase, words separated by underscores)
- Stick to **English** for all names
- Be descriptive and clear — avoid vague short forms
- **Do not** use SQL reserved words (like `select`, `table`, `order`) as object names

---

## Table Naming Conventions by Layer

### Bronze Layer
Raw source tables, named as: <source_system>_<original_table_name>
- Example: `crm_cust_info`, `erp_sales_data`
No renaming. Keep the original structure for traceability.

---

### Silver Layer
Cleaned and transformed data, but still named after the source system: <source_system>_<entity>
- Example: `crm_cust_info`, `erp_loc_a101`
These still reflect the system they came from, even after light cleaning.

---

### Gold Layer
Final, business-ready tables (Star Schema): <category>_<entity>
Where `<category>` is one of:
- `dim_` → Dimension table
- `fact_` → Fact table
Examples:
- `dim_customers`
- `dim_products`
- `fact_sales`

---

## Column Naming Conventions

### Surrogate Keys
Every dimension table uses a surrogate key (generated with `ROW_NUMBER()`): <entity>_key
Examples:
- `customer_key` in `dim_customers`
- `product_key` in `dim_products`

These keys are not from the source — they’re created for internal joins.

---

### Technical Columns
Used for tracking and auditing: dwh_<column_name>
Examples:
- `dwh_load_date` → when the row was loaded
- `dwh_updated_by` → which ETL process updated it

---

## Stored Procedures

If used, stored procedures for ETL follow the naming convention, like the following examples:
- `load_bronze`
- `load_silver`
- `load_gold`

They clearly show which layer they're responsible for.

---

## Final Thoughts

These naming rules help keep things:
- Easy to maintain
- Simple to debug
- Clear for anyone joining the project

Stick to them, and everything stays clean, consistent, and professional.
