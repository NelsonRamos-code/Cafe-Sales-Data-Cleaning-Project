/*


Data Cleaning Project
Cafe Sales Data

*/

-- 1. Handling Missing Values: Categorical Values

			-- Verified distinct values.

SELECT Item, COUNT(*)
FROM DataCleaningProject.dbo.dirty_cafe_sales
GROUP BY Item
ORDER BY COUNT(*) DESC

		   --Replace ''NULL'' and ''ERROR'' values with ''Unknown''

SELECT 
  Item, 
  CASE WHEN Item IS NULL 
  OR Item = 'ERROR' THEN 'Unknown' ELSE Item END 
FROM 
  DataCleaningProject.dbo.dirty_cafe_sales

UPDATE dirty_cafe_sales
SET Item = CASE WHEN Item IS NULL 
  OR Item = 'ERROR' THEN 'Unknown' ELSE Item END 


-- 2. Handling Missing Values: Numerical Values

SELECT *
FROM DataCleaningProject.dbo.dirty_cafe_sales

			-- Verified column ''Quantity''.

SELECT Quantity, COUNT(*) AS num
FROM DataCleaningProject.dbo.dirty_cafe_sales
GROUP BY Quantity
ORDER BY COUNT(Quantity) DESC

			-- 479 NULL Values (Reolace with Median)

WITH QuantityCounts AS (
    SELECT Quantity, COUNT(*) AS num
    FROM DataCleaningProject.dbo.dirty_cafe_sales
    WHERE Quantity IS NOT NULL
    GROUP BY Quantity
),
Cumulative AS (
    SELECT *,
           SUM(num) OVER (ORDER BY Quantity) AS cum_count,
           SUM(num) OVER () AS total_count
    FROM QuantityCounts
)
UPDATE DataCleaningProject.dbo.dirty_cafe_sales
SET Quantity = (
    SELECT TOP 1 Quantity
    FROM Cumulative
    WHERE cum_count >= total_count / 2.0
    ORDER BY cum_count
)
WHERE Quantity IS NULL;


            -- Verified column ''Quantity''.

SELECT Price_Per_Unit, COUNT(*) AS num
FROM DataCleaningProject.dbo.dirty_cafe_sales
GROUP BY Price_Per_Unit
ORDER BY COUNT(*) DESC

           -- 533 NULL Values (Replace with mean)

SELECT 
   CEILING(AVG(CAST(Price_Per_Unit AS FLOAT))) AS Mean_Price_Per_Unit
FROM 
  DataCleaningProject.dbo.dirty_cafe_sales
WHERE 
  Price_Per_Unit IS NOT NULL

UPDATE DataCleaningProject.dbo.dirty_cafe_sales
SET Price_Per_Unit = (
    SELECT CEILING(AVG(CAST(Price_Per_Unit AS FLOAT)))
    FROM DataCleaningProject.dbo.dirty_cafe_sales
    WHERE Price_Per_Unit IS NOT NULL
)
WHERE Price_Per_Unit IS NULL;


            -- Verified column ''Total_Spent''.

SELECT Total_Spent, count(*)
FROM DataCleaningProject.dbo.dirty_cafe_sales
WHERE Total_Spent IS NULL
GROUP BY Total_Spent

          -- 502 NULL VALUES Identified (Replace with mean)

SELECT CEILING(AVG(Total_Spent) ) AS avg_number
FROM DataCleaningProject.dbo.dirty_cafe_sales

UPDATE DataCleaningProject.dbo.dirty_cafe_sales
SET Total_Spent = (
        SELECT CEILING(AVG(Total_Spent) )
        FROM DataCleaningProject.dbo.dirty_cafe_sales
        WHERE Total_Spent IS NOT NULL)
WHERE Total_Spent IS NULL
  

     
            -- Verified column ''Payment_Method''.

SELECT Payment_Method, count(*)
FROM DataCleaningProject.dbo.dirty_cafe_sales
GROUP BY Payment_Method

            -- Replace invalid entries like "ERROR" and "UNKNOWN" with NaN or appropriate values.

UPDATE DataCleaningProject.dbo.dirty_cafe_sales
SET Payment_Method = NULL
WHERE Payment_Method IN ('Unknown','ERROR')

            -- Verified column ''Location''.

SELECT Location, count(*)
FROM DataCleaningProject.dbo.dirty_cafe_sales
GROUP BY Location

                -- Replace invalid entries like "ERROR" and "UNKNOWN" with NaN or appropriate values.

UPDATE DataCleaningProject.dbo.dirty_cafe_sales
SET Location = NULL
WHERE Location IN ('UNKNOWN','ERROR')

            -- Verified column ''Transaction_Date''.

SELECT *
FROM DataCleaningProject.dbo.dirty_cafe_sales
WHERE CAST(Transaction_Date AS VARCHAR(50)) IN ('ERROR', 'unknown', 'UNKNOWN')

            -- Check for NULLs
SELECT COUNT(*) 
FROM DataCleaningProject.dbo.dirty_cafe_sales
WHERE Transaction_Date IS NULL;

            -- Check date ranges
SELECT 
  MIN(Transaction_Date) AS MinDate,
  MAX(Transaction_Date) AS MaxDate
FROM DataCleaningProject.dbo.dirty_cafe_sales

            -- Fill missing dates with plausible values based on nearby records.
             -- To solve that i will find the most frequent date and then will replace null value with it

SELECT TOP 1 Transaction_Date
FROM DataCleaningProject.dbo.dirty_cafe_sales
WHERE Transaction_Date IS NOT NULL
GROUP BY Transaction_Date
ORDER BY COUNT(*) DESC;

UPDATE DataCleaningProject.dbo.dirty_cafe_sales
SET Transaction_Date = (SELECT TOP 1 Transaction_Date
FROM DataCleaningProject.dbo.dirty_cafe_sales
WHERE Transaction_Date IS NOT NULL
GROUP BY Transaction_Date
ORDER BY COUNT(*) DESC)
WHERE Transaction_Date IS NULL;

            -- Feature engineering: Create new columns, such as Day of the Week or Transaction Month, for further analysis.

SELECT
        DATENAME(MONTH, Transaction_Date) AS Month_Column
FROM DataCleaningProject.dbo.dirty_cafe_sales


SELECT
        DATENAME(WEEKDAY, Transaction_Date) AS Month_Column
FROM DataCleaningProject.dbo.dirty_cafe_sales

ALTER TABLE DataCleaningProject.dbo.dirty_cafe_sales
ADD Month_Name VARCHAR(20),
    week_day VARCHAR(20)

UPDATE DataCleaningProject.dbo.dirty_cafe_sales
SET 
        Month_Name = DATENAME(MONTH, Transaction_Date),
        week_day = DATENAME(WEEKDAY, Transaction_Date)
