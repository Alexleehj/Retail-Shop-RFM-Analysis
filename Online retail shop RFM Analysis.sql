USE Portfolio;  
CREATE TABLE combined_sales (
    InvoiceNo      VARCHAR(20),
    StockCode      VARCHAR(20),
    Description    VARCHAR(255),
    Quantity       INT,
    InvoiceDate    DATETIME,
    UnitPrice      DECIMAL(10,2),
    CustomerID     VARCHAR(20),
    Country        VARCHAR(50),
);

BULK INSERT combined_sales
FROM '02_Portfolio\Dataset\online+retail+ii\Year 2009-2010.csv'
WITH (
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    FIRSTROW = 2,  
    CODEPAGE = '65001'
);


USE Portfolio;  
BULK INSERT combined_sales
FROM '02_Portfolio\Dataset\online+retail+ii\Year 2010-2011.csv'
WITH (
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,  
    CODEPAGE = '65001', 
    TABLOCK  
);


-- Check full duplicated record based on merged files
SELECT 
    InvoiceNo, StockCode, Description, Quantity, InvoiceDate, 
    UnitPrice, CustomerID, Country,COUNT(*) AS DuplicateCount
FROM 
    [Portfolio].[dbo].[combined_sales]
GROUP BY 
    InvoiceNo, StockCode, Description, Quantity, InvoiceDate, 
    UnitPrice, CustomerID, Country
HAVING 
    COUNT(*) > 1;


-- Check duplicated records based on business logic 
-- Keywords: CustomerID + InvoiceNo + StockCode + InvoiceDate
SELECT 
     CustomerID, InvoiceNo, StockCode, InvoiceDate,
    COUNT(*) AS DuplicateCount
FROM 
    [Portfolio].[dbo].[combined_sales]
GROUP BY 
    CustomerID, InvoiceNo, StockCode, InvoiceDate 
HAVING 
    COUNT(*) > 1;

-- Sort out the non-valid customer ID, due to segementation should be based on customers, we should firstly make sure the customer ID accuracy
SELECT *
FROM [Portfolio].[dbo].[combined_sales]
WHERE 
    CustomerID IS NULL 
    OR CustomerID = ''
    OR CustomerID LIKE '%[^a-zA-Z0-9]%'
    OR LEN(CustomerID) NOT BETWEEN 5 AND 10;

-- Data backup before clean and delete the non-valid data
SELECT * 
INTO [Portfolio].[dbo].[combined_sales_backup]
FROM [Portfolio].[dbo].[combined_sales];


-- Delete full duplicated records
-- Use ROW_NUMBER() to keep the 1st record from duplicated group£¨based on InvoiceDate ascending£©
WITH CTE_CompleteDuplicates AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                InvoiceNo, StockCode, Description, Quantity, 
                InvoiceDate, UnitPrice, CustomerID, Country
            ORDER BY 
                InvoiceDate  -- based on the earlist time to keep the record
        ) AS RowNum
    FROM 
        [Portfolio].[dbo].[combined_sales]
)
DELETE FROM CTE_CompleteDuplicates 
WHERE RowNum > 1;

-- Delete business logic duplication based on:CustomerID + InvoiceNo + StockCode + InvoiceDate
-- Keep the 1st record from duplicated group based on business logic£¨ InvoiceDate ascending£©
WITH CTE_BusinessDuplicates AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                CustomerID, InvoiceNo, StockCode, InvoiceDate
            ORDER BY 
                InvoiceDate  -- based on the earlist time to keep the record
        ) AS RowNum
    FROM 
        [Portfolio].[dbo].[combined_sales]
)
DELETE FROM CTE_BusinessDuplicates 
WHERE RowNum > 1;

-- Delete non-valide customer ID
DELETE FROM [Portfolio].[dbo].[combined_sales]
WHERE 
    CustomerID IS NULL 
    OR CustomerID = ''
    OR CustomerID LIKE '%[^a-zA-Z0-9]%'
    OR LEN(CustomerID) NOT BETWEEN 5 AND 10;

-- Validate remaining record
SELECT COUNT(*) AS TotalRecords 
FROM [Portfolio].[dbo].[combined_sales];


-- Ensure no duplicated record
SELECT 
    InvoiceNo, StockCode, Description, Quantity, 
    InvoiceDate, UnitPrice, CustomerID, Country,
    COUNT(*) AS DuplicateCount
FROM 
    [Portfolio].[dbo].[combined_sales]
GROUP BY 
    InvoiceNo, StockCode, Description, Quantity, 
    InvoiceDate, UnitPrice, CustomerID, Country
HAVING 
    COUNT(*) > 1;  -- expect 0 record 

-- Validate business logic duplication record
SELECT 
    CustomerID, InvoiceNo, StockCode, InvoiceDate,
    COUNT(*) AS DuplicateCount
FROM 
   [Portfolio].[dbo].[combined_sales]
GROUP BY 
    CustomerID, InvoiceNo, StockCode, InvoiceDate
HAVING 
    COUNT(*) > 1;  -- expect 0 record 

-- Ensure non-valid customer ID is removed
SELECT *
FROM [Portfolio].[dbo].[combined_sales]
WHERE 
    CustomerID IS NULL 
    OR CustomerID = ''
    OR CustomerID LIKE '%[^a-zA-Z0-9]%'
    OR LEN(CustomerID) NOT BETWEEN 5 AND 10;  -- expect 0 record 

	ALTER INDEX ALL ON [Portfolio].[dbo].[combined_sales] REBUILD;


-- Create temp view for the cleaned transaction record for RFM analysis
USE [Portfolio]; 
GO

CREATE VIEW [dbo].[v_valid_sales] AS
SELECT *
FROM [Portfolio].[dbo].[combined_sales]
WHERE LEFT(InvoiceNo, 1) <> 'C';  -- eliminate canceled orders



-- Validate cleaned view
SELECT * FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_NAME = 'v_valid_sales';

SELECT TOP 10 * FROM [dbo].[v_valid_sales];


-- Create RFM base table
CREATE TABLE [Portfolio].[dbo].[RFM_Base] (
    CustomerID VARCHAR(20) PRIMARY KEY,
    Recency INT,
    Frequency INT,
    Monetary DECIMAL(18,2)
);


-- Calculate RFM value, due to the source data is from long time ago, I use the lastest date in the record as basetime to calculate the Recency.
DECLARE @baseline_date DATE = (SELECT MAX(InvoiceDate) FROM [Portfolio].[dbo].[v_valid_sales]);

INSERT INTO [Portfolio].[dbo].[RFM_Base]
SELECT
    CustomerID,
    DATEDIFF(DAY, MAX(InvoiceDate), @baseline_date) AS Recency,
    COUNT(DISTINCT InvoiceNo) AS Frequency,
    SUM(Quantity * UnitPrice) AS Monetary
FROM 
    [Portfolio].[dbo].[v_valid_sales]
GROUP BY 
    CustomerID;


-- Validation RFM value if reasonable
SELECT TOP 10 * 
FROM [Portfolio].[dbo].[RFM_Base]
ORDER BY Monetary DESC;

-- Recency£¨should >= 0£©
SELECT 
    MIN(Recency) AS MinRecency,
    MAX(Recency) AS MaxRecency
FROM 
    [Portfolio].[dbo].[RFM_Base];


-- Create RFM result table
CREATE TABLE [Portfolio].[dbo].[RFM_Result] (
    CustomerID VARCHAR(20) PRIMARY KEY,
    Recency INT,
    Frequency INT,
    Monetary DECIMAL(18,2),
    R_Score INT,
    F_Score INT,
    M_Score INT,
    RFM_Group VARCHAR(10)
);


-- Asign RFM scores (from 1-5)
WITH RFM_Scoring AS (
    SELECT
        CustomerID,
        Recency,
        Frequency,
        Monetary,
        -- the lower Recency value, the higher R_score
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score, 
        -- the higher Frequency value, the higher F_score
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score, 
        -- the higher Monetary value, the higher M_score
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score   
    FROM 
        [Portfolio].[dbo].[RFM_Base]
)
INSERT INTO [Portfolio].[dbo].[RFM_Result]
SELECT 
    CustomerID,
    Recency,
    Frequency,
    Monetary,
    R_Score,
    F_Score,
    M_Score,
    CONCAT(R_Score, '-', F_Score, '-', M_Score) AS RFM_Group
FROM 
    RFM_Scoring;


-- Validate R_Score patten
SELECT 
    R_Score,
    MIN(Recency) AS MinRecency,
    MAX(Recency) AS MaxRecency,
    COUNT(*) AS CustomerCount
FROM 
    [Portfolio].[dbo].[RFM_Result]
GROUP BY 
    R_Score
ORDER BY 
    R_Score DESC;


-- Validate F_Score patten
SELECT 
    F_Score,
    MIN(Frequency) AS MinFrequency,
    MAX(Frequency) AS MaxFrequency,
    COUNT(*) AS CustomerCount
FROM 
    [Portfolio].[dbo].[RFM_Result]
GROUP BY 
    F_Score
ORDER BY 
    F_Score DESC;

-- Validate M_Score pattern
SELECT 
    M_Score,
    MIN(Monetary) AS MinMonetary,
    MAX(Monetary) AS MaxMonetary,
    COUNT(*) AS CustomerCount
FROM 
    [Portfolio].[dbo].[RFM_Result]
GROUP BY 
    M_Score
ORDER BY 
    M_Score DESC;




