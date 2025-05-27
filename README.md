# Data Warehouse & Analytics Project

Welcome to my hands-on **Data Warehouse & Analytics Project** - designed to simulate a real-world data engineering workflow. This project follows the **Medallion Architecture** (Bronze → Silver → Gold) to transform raw CSV data into business-ready insights using **SQL Server** and **T-SQL**.

It’s part of my learning journey in data analytics and data engineering to build to showcase practical skills in ETL, data modeling, and analytics.

---

## Architecture Overview

The project uses a **layered data warehouse architecture**:

- **Bronze Layer**: Raw data ingestion from CRM & ERP CSV files  
- **Silver Layer**: Cleaned and standardized data  
- **Gold Layer**: Star schema with fact and dimension tables for reporting

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
- Optional: **Power BI** for visualizations

---

## 📂 Repository Structure
SQL-DataWarehouseProject/
├── datasets/ → Source CSV files (ERP, CRM)
├── docs/ → Diagrams, catalog, naming conventions
├── scripts/ → SQL ETL scripts (bronze, silver, gold)
├── tests/ → Validation and data quality checks
├── LICENSE
└── README.md

---

## Naming Conventions

| Element              | Format               | Example                |
|----------------------|----------------------|------------------------|
| Bronze/Silver Tables | `<source>_<entity>`  | `crm_customer_info`    |
| Gold Tables          | `<type>_<entity>`    | `dim_customers`        |
| Surrogate Keys       | `<table>_key`        | `customer_key`         |
| Technical Columns    | `dwh_<column>`       | `dwh_load_date`        |
| Stored Procedures    | `load_<layer>`       | `load_bronze`          |

---

## Getting Started

To explore or run the project:
- Install SQL Server + SSMS
- Optional: Use Power BI or another BI tool to visualize Gold layer outputs

---

## About This Project

This project is inspired by the **"SQL Bootcamp"** series by [Data With Baraa](https://www.youtube.com/@DataWithBaraa). While the core concepts are based on the tutorials, all implementation, structure, and documentation have been created independently to deepen my understanding and build a professional portfolio project.

---

## About Me

I'm **Shristi Tuladhar**, an IT student, passionate about data analytics, SQL, and building real-world projects. This project is part of my self-taught portfolio to break into the data industry and demonstrate that I can design and build complete solutions.

---

## License

This project is open-sourced under the [MIT License](LICENSE).  
You're welcome to explore, use, and build on it - just give credit where it's due.
