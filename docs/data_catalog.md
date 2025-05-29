# Data Catalog for Gold Layer (Star Schema)

## Overview
The Gold Layer is the final business-ready data mart, modeled using a Star Schema.
It supports reporting and analytics by exposing clean, integrated views of customers, products, and sales.

It includes:
- `gold.dim_customers`
- `gold.dim_products`
- `gold.fact_sales`

---

## 1. gold.dim_customers

| Column Name       | Data Type     | Description                                                                 |
|-------------------|---------------|-----------------------------------------------------------------------------|
| `customer_key`    | INT           | Surrogate key generated via `ROW_NUMBER()`                                 |
| `customer_id`     | INT           | Unique customer ID from CRM                                                |
| `customer_number` | NVARCHAR(50)  | CRM key used to track the customer                                         |
| `first_name`      | NVARCHAR(50)  | Customer’s first name                                                      |
| `last_name`       | NVARCHAR(50)  | Customer’s last name                                                       |
| `country`         | NVARCHAR(50)  | Country (from ERP)                                                         |
| `marital_status`  | NVARCHAR(50)  | Cleaned marital status (Married, Single, etc.)                             |
| `gender`          | NVARCHAR(50)  | Final gender value (CRM is primary, ERP is fallback)                       |
| `birthdate`       | DATE          | Date of birth (from ERP)                                                   |
| `create_date`     | DATE          | Customer creation date (from CRM)                                          |

---

## 2. gold.dim_products

| Column Name       | Data Type     | Description                                                                 |
|-------------------|---------------|-----------------------------------------------------------------------------|
| `product_key`     | INT           | Surrogate key generated via `ROW_NUMBER()`                                 |
| `product_id`      | INT           | CRM product ID                                                              |
| `product_number`  | NVARCHAR(50)  | Unique product code (e.g., 'AC-HE-HL-U509')                                 |
| `product_name`    | NVARCHAR(50)  | Descriptive name of the product                                             |
| `category_id`     | NVARCHAR(50)  | Extracted from product key prefix                                           |
| `category`        | NVARCHAR(50)  | Product category (from ERP)                                                 |
| `subcategory`     | NVARCHAR(50)  | Product subcategory (e.g., ‘Helmets’)                                       |
| `maintenance`     | NVARCHAR(50)  | Maintenance requirement (‘Yes’, ‘No’, or ‘N/A’)                             |
| `cost`            | INT           | Cost of the product                                                         |
| `product_line`    | NVARCHAR(50)  | Cleaned product line label (e.g., ‘Mountain’, ‘Road’)                       |
| `start_date`      | DATE          | Date product became available                                               |

---

## 3. gold.fact_sales

| Column Name       | Data Type     | Description                                                                 |
|-------------------|---------------|-----------------------------------------------------------------------------|
| `order_number`    | NVARCHAR(50)  | Unique order identifier (e.g., 'SO54496')                                   |
| `product_key`     | INT           | Foreign key linking to `dim_products.product_key`                           |
| `customer_key`    | INT           | Foreign key linking to `dim_customers.customer_key`                         |
| `order_date`      | DATE          | Date the order was placed                                                   |
| `shipping_date`   | DATE          | Date the product was shipped                                                |
| `due_date`        | DATE          | Payment due date                                                            |
| `sales_amount`    | INT           | Final sales value (or derived from quantity × price)                        |
| `quantity`        | INT           | Number of units sold                                                        |
| `price`           | INT           | Unit price of the product                                                   |

---

## Relationships

- `fact_sales.customer_key` → `dim_customers.customer_key`
- `fact_sales.product_key` → `dim_products.product_key`

All views were created from the Silver Layer using LEFT JOINs to preserve master data even when enrichment was missing. Surrogate keys were generated using `ROW_NUMBER()` to support dimensional modeling.
