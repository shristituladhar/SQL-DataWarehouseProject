/*
===============================================================
Initial Database & Schema Setup for DataWarehouse Project
===============================================================

Purpose:
    This script sets up the core structure for the SQL Data Warehouse project.
    It ensures a clean environment by removing any existing 'DataWarehouse'
    database and then creating a new one with the necessary schemas to support
    the Medallion Architecture layers: bronze, silver, and gold.

Note:
    Running this script will delete the existing 'DataWarehouse' database if present.
    Make sure to back up any critical data before executing.
*/

-- Switch to master context
USE master;
GO

-- Drop the database if it already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the new database
CREATE DATABASE DataWarehouse;
GO

-- Switch to the new database
USE DataWarehouse;
GO

-- Create schemas for layered architecture
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
