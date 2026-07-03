CREATE DATABASE walmart_db;
USE walmart_db;

SELECT *
FROM Walmart_Sales
LIMIT 5;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Store) AS Total_Stores,
    MIN(Date) AS Start_Date,
    MAX(Date) AS End_Date
FROM Walmart_Sales;

# Total Revenue
SELECT
    ROUND(SUM(Weekly_Sales),2) AS Total_Revenue
FROM Walmart_Sales;

# Average Weekly Sales
SELECT
    ROUND(AVG(Weekly_Sales),2) AS Avg_Weekly_Sales
FROM Walmart_Sales;

# Top 10 Stores
SELECT
    Store,
    ROUND(SUM(Weekly_Sales),2) AS Revenue
FROM Walmart_Sales
GROUP BY Store
ORDER BY Revenue DESC
LIMIT 10;

#Bottom 10 Stores
SELECT
    Store,
    ROUND(SUM(Weekly_Sales),2) AS Revenue
FROM Walmart_Sales
GROUP BY Store
ORDER BY Revenue
LIMIT 10;

# Holiday vs Non-Holiday Sales
SELECT
    Holiday_Flag,
    ROUND(SUM(Weekly_Sales),2) AS Revenue,
    ROUND(AVG(Weekly_Sales),2) AS Avg_Sales
FROM Walmart_Sales
GROUP BY Holiday_Flag;

# Best Sales Month
SELECT
    MONTH(STR_TO_DATE(Date,'%d-%m-%Y')) AS Month_No,
    MONTHNAME(STR_TO_DATE(Date,'%d-%m-%Y')) AS Month_Name,
    ROUND(SUM(Weekly_Sales),2) AS Revenue
FROM Walmart_Sales
GROUP BY Month_No, Month_Name
ORDER BY Revenue DESC;

# Monthly Sales Trend
SELECT
    YEAR(STR_TO_DATE(Date,'%d-%m-%Y')) AS Year,
    MONTH(STR_TO_DATE(Date,'%d-%m-%Y')) AS Month,
    ROUND(SUM(Weekly_Sales),2) AS Revenue
FROM Walmart_Sales
GROUP BY Year, Month
ORDER BY Year, Month;

# Yearly Revenue
SELECT
    YEAR(STR_TO_DATE(Date,'%d-%m-%Y')) AS Year,
    ROUND(SUM(Weekly_Sales),2) AS Revenue
FROM Walmart_Sales
GROUP BY Year;

# Top 5 Holiday Weeks
SELECT
    Store,
    Date,
    Weekly_Sales
FROM Walmart_Sales
WHERE Holiday_Flag = 1
ORDER BY Weekly_Sales DESC
LIMIT 5;

# Average Sales by Store
SELECT Store,
    ROUND(AVG(Weekly_Sales),2) AS Avg_Sales
FROM Walmart_Sales
GROUP BY Store
ORDER BY Avg_Sales DESC;

# Temperature Impact
SELECT
    ROUND(AVG(Temperature),2) AS Avg_Temp,
    ROUND(AVG(Weekly_Sales),2) AS Avg_Sales
FROM Walmart_Sales;

SELECT
CASE
WHEN Temperature < 40 THEN 'Cold'
WHEN Temperature BETWEEN 40 AND 70 THEN 'Moderate'
ELSE 'Hot'
END AS Weather,

ROUND(AVG(Weekly_Sales),2) AS Avg_Sales

FROM Walmart_Sales

GROUP BY Weather;

# Fuel Price Impact
SELECT
CASE
WHEN Fuel_Price < 3 THEN 'Low'
ELSE 'High'
END AS Fuel_Level,

ROUND(AVG(Weekly_Sales),2) AS Avg_Sales

FROM Walmart_Sales

GROUP BY Fuel_Level;

# Unemployment Impact
SELECT
ROUND(Unemployment,1) AS Rate,
ROUND(AVG(Weekly_Sales),2) AS Avg_Sales

FROM Walmart_Sales

GROUP BY Rate

ORDER BY Rate;

# CPI Impact
SELECT
ROUND(CPI) AS CPI_Level,

ROUND(AVG(Weekly_Sales),2) AS Avg_Sales

FROM Walmart_Sales

GROUP BY CPI_Level

ORDER BY CPI_Level;

# Rank Stores by Revenue
SELECT
    Store,
    ROUND(SUM(Weekly_Sales),2) AS Revenue,
    RANK() OVER(ORDER BY SUM(Weekly_Sales) DESC) AS Store_Rank
FROM Walmart_Sales
GROUP BY Store;

# Dense Rank
SELECT
    Store,
    ROUND(SUM(Weekly_Sales),2) AS Revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(Weekly_Sales) DESC
    ) AS StoreRank
FROM Walmart_Sales
GROUP BY Store;

# Top Store of Each Year
WITH StoreRevenue AS
(
SELECT
Store,
YEAR(STR_TO_DATE(Date,'%d-%m-%Y')) AS Sales_Year,
SUM(Weekly_Sales) Revenue
FROM Walmart_Sales
GROUP BY Store,Sales_Year
)

SELECT *
FROM
(
SELECT *,
RANK() OVER(PARTITION BY Sales_Year ORDER BY Revenue DESC) rnk
FROM StoreRevenue
)t
WHERE rnk=1;

# Running Total
SELECT
STR_TO_DATE(Date,'%d-%m-%Y') AS Sales_Date,

SUM(Weekly_Sales) AS Daily_Sales,

SUM(SUM(Weekly_Sales))
OVER(ORDER BY STR_TO_DATE(Date,'%d-%m-%Y'))
AS Running_Total

FROM Walmart_Sales

GROUP BY Sales_Date;

# 4-Week Moving Average
SELECT

STR_TO_DATE(Date,'%d-%m-%Y') AS Sales_Date,

SUM(Weekly_Sales) AS Sales,

AVG(SUM(Weekly_Sales))
OVER(
ORDER BY STR_TO_DATE(Date,'%d-%m-%Y')
ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
)
AS Moving_Average

FROM Walmart_Sales

GROUP BY Sales_Date;

CREATE VIEW Store_Revenue AS

SELECT
Store,
ROUND(SUM(Weekly_Sales),2) Revenue
FROM Walmart_Sales
GROUP BY Store;

SELECT *
FROM Store_Revenue;

DELIMITER //

CREATE PROCEDURE GetStoreSales(IN StoreID INT)

BEGIN

SELECT *
FROM Walmart_Sales
WHERE Store = StoreID;

END //

DELIMITER ;

CALL GetStoreSales(20);

# Top 3 Stores Each Year
WITH Revenue AS
(
SELECT
Store,
YEAR(STR_TO_DATE(Date,'%d-%m-%Y')) AS Sales_Year,
SUM(Weekly_Sales) Revenue
FROM Walmart_Sales
GROUP BY Store,Sales_Year
)

SELECT *

FROM
(
SELECT *,
DENSE_RANK()
OVER(PARTITION BY Sales_Year ORDER BY Revenue DESC) rnk
FROM Revenue
)x

WHERE rnk<=3;