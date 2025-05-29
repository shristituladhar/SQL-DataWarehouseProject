# Data Warehouse & Analytics Project

Welcome to my hands-on **Data Warehouse & Analytics Project**, designed to simulate a real-world data engineering workflow. This project follows the **Medallion Architecture** (Bronze → Silver → Gold) to transform raw CSV data into business-ready insights using **SQL Server** and **T-SQL**.

It’s part of my learning journey in data analytics and data engineering to showcase practical skills in ETL, data modeling, and analytics.

---

## Architecture Overview
This project follows the **Medallion Architecture**.
![High Level Data Architecture](https://github.com/user-attachments/assets/e11a3b8d-d0e3-49d1-8947-5cba7a81fae7)

- **Bronze Layer**: Raw source data from CRM and ERP systems, as-is.
- **Silver Layer**: Cleaned, joined, and type-corrected tables.
- **Gold Layer**: Final star schema model with `dim_customers`, `dim_products`, and `fact_sales`.
All transformations are handled with **manual SQL**,  no third-party tools.

---

## Project Goals
- Build a structured SQL-based data warehouse from scratch  
- Design a star schema for analytical querying  
- Apply data transformations using ETL pipelines  
- Generate insights into customer behavior, product performance, and sales trends  
- Document and version everything with Git and SQL scripts

---

## Tools & Stack
- **SQL Server Express + SSMS**  
- **T-SQL**  
- **Draw.io** for architecture & data flow diagrams  
- **GitHub** for version control  

---

## Repository Structure
![image](https://github.com/user-attachments/assets/ea9c61f5-b011-43ef-9ba7-29c01d44d910)

**Sample Data Sources**
- CRM data: `crm_cust_info`, `crm_sales_details`, `crm_prd_info`
- ERP data: `erp_cust_az12`, `erp_loc_a101`, `erp_px_cat_g1v2`
  
---

## Data Quality Checks
✔ Surrogate key uniqueness  
✔ No null dimension keys in `fact_sales`  
✔ Foreign key validation  
✔ Duplicate detection (pre-join)  
✔ Gender integration logic applied (`CRM` is the master, `ERP` is fallback)

---

## Documentation
- `data_catalog.md`: Field-by-field breakdown of all tables
- `naming_conventions.md`: Layered naming structure and rules
- `ddl_gold.sql`: View creation scripts for Gold Layer
- `quality_checks.sql`: Integrity & consistency tests for dimension/fact tables

---

## Quick Start
To explore this project locally:
1. Clone the repo
2. Open `init_database.sql` in SQL Server Management Studio
3. Run layer by layer: `bronze → silver → gold`
4. Explore the views: `SELECT * FROM gold.dim_customers`

---

## About This Project

This project is inspired by the **"SQL Bootcamp"** series by [Data With Baraa](https://www.youtube.com/@DataWithBaraa). While the core concepts are based on the tutorials, all implementation, structure, and documentation have been created independently to deepen my understanding and build a professional portfolio project.

---

## About Me

I'm **Shristi Tuladhar**, an IT student, passionate about data analytics, SQL, and building real-world projects. This project is part of my self-taught portfolio to break into the data industry and demonstrate that I can design and build complete solutions.

---

## License

This project is open-sourced under the [MIT License](LICENSE).  
You're welcome to explore, use, and build on it, just give credit where it's due.
