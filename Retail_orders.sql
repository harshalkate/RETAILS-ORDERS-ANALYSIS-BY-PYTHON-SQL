select * from retail_data;

SELECT 
    ship_mode, 
    CONCAT('', IFNULL(ship_mode, 'Null')) AS ship_mode
FROM 
    retail_data;

update retail_data
set ship_mode = ifnull(ship_mode,'Null');

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'retail_data' ;

SELECT STR_TO_DATE(order_date, '%d-%m-%Y') AS order_date FROM retail_data;

UPDATE retail_data
SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y');

select * from retail_data;
-- find top 10 highest reveue generating products 
SELECT product_id, SUM(sale_price) AS sales
FROM retail_data
GROUP BY product_id
ORDER BY sales DESC limit 10;

-- find top 5 highest selling products in each region
with cte as(
SELECT region,product_id, SUM(sale_price) AS sales
FROM retail_data
GROUP BY region,product_id)
select * from (
select * 
, row_number() over(partition by region order by sales desc) as rn
from cte) a
where rn<=5;

-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM retail_data
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- for each category which month had highest sales 
with cte as (
select category,format(order_date,'yyyyMM') as order_year_month
, sum(sale_price) as sales
from retail_data
group by category,format(order_date,'yyyyMM')
)
select * from(
select *
,row_number() over(partition by category order by sales) as rn
from cte) a
where rn=1;

-- which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM retail_data
    GROUP BY sub_category, YEAR(order_date)
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte
    GROUP BY sub_category
)
SELECT 
    cte2.*,
    (sales_2022 - sales_2023) AS sales_difference
FROM cte2
ORDER BY sales_difference DESC
LIMIT 1;
