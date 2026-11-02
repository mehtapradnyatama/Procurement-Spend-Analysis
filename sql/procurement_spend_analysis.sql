-- Procurement Spend Analysis
-- SQL dialect: DuckDB
-- Source: Company Purchasing Dataset by Shahriar Kabir (synthetic data, 2024).
-- https://www.kaggle.com/datasets/shahriarkabir/company-purchasing-dataset
-- Currency is unspecified; amounts are not labelled USD or IDR.
--
-- Run this file from the project root using DuckDB.
-- In the Web Shell, register spend_analysis_dataset.csv with Import first,
-- then replace the path below with 'spend_analysis_dataset.csv'.
-- The current CSV uses semicolons, decimal commas, and DD/MM/YY dates.
-- Later sections use the purchases table created in section 01.

-- 01. Create the purchases table using the verified CSV parsing settings.
CREATE OR REPLACE TEMP TABLE purchases AS
SELECT *
FROM read_csv(
    'dataset_alternative/spend_analysis_dataset.csv',
    delim = ';',
    header = true,
    decimal_separator = ',',
    dateformat = '%d/%m/%y'
);

-- 02. Check the row count and total spend against Excel.
SELECT
    COUNT(*) AS transaction_count,
    ROUND(SUM(TotalCost), 2) AS total_spend
FROM purchases;

-- 03. Rank categories by total spend.
SELECT
    Category,
    ROUND(SUM(TotalCost), 2) AS total_spend
FROM purchases
GROUP BY Category
ORDER BY total_spend DESC;

-- 04. Compare supplier spend and transaction counts.
SELECT
    Supplier,
    ROUND(SUM(TotalCost), 2) AS total_spend,
    COUNT(*) AS transaction_count
FROM purchases
GROUP BY Supplier
ORDER BY total_spend DESC;

-- 05. Examine Electronics spend, quantities, and weighted average unit prices.
-- Weighted average unit price = total spend / total quantity.
SELECT
    ItemName,
    ROUND(SUM(TotalCost), 2) AS total_spend,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(TotalCost) / SUM(Quantity), 2) AS weighted_avg_unit_price
FROM purchases
WHERE Category = 'Electronics'
GROUP BY ItemName
ORDER BY total_spend DESC;

-- 06. Summarize monthly spend in chronological order.
SELECT
    DATE_TRUNC('month', PurchaseDate) AS month,
    ROUND(SUM(TotalCost), 2) AS total_spend
FROM purchases
GROUP BY month
ORDER BY month ASC;

-- 07. Compare category spend in August and September.
-- Inclusive lower bound and exclusive upper bound include both complete months.
SELECT
    DATE_TRUNC('month', PurchaseDate) AS month,
    Category,
    ROUND(SUM(TotalCost), 2) AS total_spend
FROM purchases
WHERE PurchaseDate >= DATE '2024-08-01'
  AND PurchaseDate < DATE '2024-10-01'
GROUP BY month, Category
ORDER BY month ASC, total_spend DESC;
