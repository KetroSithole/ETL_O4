/*
=============================================================
 Script   : init_database.sql
 Purpose  : Create databases, schemas and bronze tables for a
            Medallion Architecture data warehouse (SQL Server).
-------------------------------------------------------------
 Layout:
   stg_Db  -> bronze  (raw data, loaded as-is via SSIS)
   dwh_db  -> silver  (cleaned / conformed data)
           -> gold    (business-ready facts & dimensions)
-------------------------------------------------------------
 Notes:
   - Safe to re-run: every object is created only if it
     does not already exist. Nothing is dropped.
   - Bronze columns are VARCHAR(50) and nullable on purpose;
     type casting happens in the silver layer.
=============================================================
*/

USE master;
GO

/* =============================================
   1. DATABASES
   ============================================= */
IF DB_ID('stg_Db') IS NULL
BEGIN
    CREATE DATABASE stg_Db;
    PRINT 'Created database stg_Db';
END
ELSE
    PRINT 'Database stg_Db already exists - skipped';
GO

IF DB_ID('dwh_db') IS NULL
BEGIN
    CREATE DATABASE dwh_db;
    PRINT 'Created database dwh_db';
END
ELSE
    PRINT 'Database dwh_db already exists - skipped';
GO

/* =============================================
   2. SCHEMAS
   ============================================= */
USE stg_Db;
GO

IF SCHEMA_ID('bronze') IS NULL
BEGIN
    EXEC('CREATE SCHEMA bronze');
    PRINT 'Created schema stg_Db.bronze';
END
GO

USE dwh_db;
GO

IF SCHEMA_ID('silver') IS NULL
BEGIN
    EXEC('CREATE SCHEMA silver');
    PRINT 'Created schema dwh_db.silver';
END
GO

IF SCHEMA_ID('gold') IS NULL
BEGIN
    EXEC('CREATE SCHEMA gold');
    PRINT 'Created schema dwh_db.gold';
END
GO

/* =============================================
   3. BRONZE TABLES
   ============================================= */
IF NOT EXISTS (
    SELECT 1
    FROM stg_Db.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_CATALOG = 'stg_Db'
      AND TABLE_SCHEMA  = 'bronze'
      AND TABLE_NAME    = 'retail_sales_dataset'
)
BEGIN
    CREATE TABLE stg_Db.bronze.retail_sales_dataset (
        [Transaction ID]   VARCHAR(50),
        [Date]             VARCHAR(50),
        [Customer ID]      VARCHAR(50),
        [Gender]           VARCHAR(50),
        [Age]              VARCHAR(50),
        [Product Category] VARCHAR(50),
        [Quantity]         VARCHAR(50),
        [Price per Unit]   VARCHAR(50),
        [Total Amount]     VARCHAR(50)
    );
    PRINT 'Created table stg_Db.bronze.retail_sales_dataset';
END
ELSE
    PRINT 'Table stg_Db.bronze.retail_sales_dataset already exists - skipped';
GO

/* =============================================
   4. VERIFY
   ============================================= */
SELECT 'stg_Db' AS database_name, s.name AS schema_name, t.name AS table_name
FROM stg_Db.sys.schemas s
LEFT JOIN stg_Db.sys.tables t ON t.schema_id = s.schema_id
WHERE s.name = 'bronze'
UNION ALL
SELECT 'dwh_db', s.name, t.name
FROM dwh_db.sys.schemas s
LEFT JOIN dwh_db.sys.tables t ON t.schema_id = s.schema_id
WHERE s.name IN ('silver', 'gold');
GO
