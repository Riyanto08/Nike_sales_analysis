--Check 10 head rows--
SELECT * FROM nike_sales LIMIT 10

--Check number of rows--
SELECT COUNT(*) AS number_of_rows FROM nike_sales 

--Check number of columns--
SELECT COUNT(*) AS number_of_columns 
FROM information_schema.columns
WHERE table_name = 'nike_sales'

--Check Column name and type column--
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'nike_sales'

--Describe the data--
SELECT
  COUNT(total_sales) AS number_of_data,
  AVG(CAST(total_sales AS numeric)) AS mean,
  STDDEV(CAST(total_sales AS numeric)) AS standard_deviation,
  MIN(CAST(total_sales AS numeric)) AS minimum,
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CAST(total_sales AS numeric)) AS q1,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY CAST(total_sales AS numeric)) AS median,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CAST(total_sales AS numeric)) AS q3,
  MAX(CAST(total_sales AS numeric)) AS maksimum
FROM nike_sales;

--Check missing value--
SELECT 
  SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) AS null_invoice_date,
  SUM(CASE WHEN product IS NULL THEN 1 ELSE 0 END) AS null_product,
  SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS null_region,
  SUM(CASE WHEN retailer IS NULL THEN 1 ELSE 0 END) AS null_retailer,
  SUM(CASE WHEN sales_method IS NULL THEN 1 ELSE 0 END) AS null_sales_method,
  SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
  SUM(CASE WHEN price_per_unit IS NULL THEN 1 ELSE 0 END) AS null_price_per_unit,
  SUM(CASE WHEN total_sales IS NULL THEN 1 ELSE 0 END) AS null_total_sales,
  SUM(CASE WHEN units_sold IS NULL THEN 1 ELSE 0 END) AS null_units_sold
FROM nike_sales;

--Check data duplicated--
SELECT 
  invoice_date, product, region, retailer, sales_method, state,
  price_per_unit, total_sales, units_sold,
  COUNT(*) AS jumlah
FROM nike_sales
GROUP BY 
  invoice_date, product, region, retailer, sales_method, state,
  price_per_unit, total_sales, units_sold
HAVING COUNT(*) > 1
ORDER BY jumlah DESC;

--Total sales by state--
SELECT 
  state,
  SUM(CAST(total_sales AS INTEGER)) AS total_sales
FROM nike_sales
GROUP BY state
ORDER BY total_sales DESC;

--Unit sold by state--
SELECT 
  state,
  SUM(CAST(units_sold AS INTEGER)) AS units_sold
FROM nike_sales
GROUP BY state
ORDER BY units_sold DESC;

--Total sales by product--
SELECT 
  product,
  SUM (CAST(total_sales AS INTEGER)) AS total_sales
FROM nike_sales
GROUP BY product
ORDER BY total_sales DESC;

--Unit sold by product--
SELECT 
  product,
  SUM (CAST(units_sold AS INTEGER)) AS total_units_sold
FROM nike_sales
GROUP BY product
ORDER BY total_units_sold DESC;

-- Total sales by region--
SELECT 
  region,
  SUM(CAST(total_sales AS INTEGER)) AS total_sales
FROM nike_sales
GROUP BY region
ORDER BY total_sales DESC;

--Unit sold by region--
SELECT 
  region,
  SUM(CAST(units_sold AS INTEGER)) AS units_sold
FROM nike_sales
GROUP BY region
ORDER BY units_sold DESC;

--Total sales by sales method--
SELECT 
  sales_method,
  SUM(CAST(total_sales AS INTEGER)) AS total_sales
FROM nike_sales
GROUP BY sales_method
ORDER BY total_sales DESC;

--Unit sold by sales method--
SELECT 
  sales_method,
  SUM(CAST(units_sold AS INTEGER)) AS units_sold
FROM nike_sales
GROUP BY sales_method
ORDER BY units_sold DESC;

--Total sales by retailer--
SELECT 
  retailer,
  SUM(CAST(total_sales AS INTEGER)) AS total_sales
FROM nike_sales
GROUP BY retailer
ORDER BY total_sales DESC;

--Unit sold by sales retailer--
SELECT 
  retailer,
  SUM(CAST(units_sold AS INTEGER)) AS units_sold
FROM nike_sales
GROUP BY retailer
ORDER BY units_sold DESC;

--Total sales by monthly--
SELECT 
  TO_CHAR(TO_DATE(invoice_date, 'DD/MM/YYYY'), 'YYYY-MM') AS month,
  SUM(total_sales::numeric) AS total_sales
FROM nike_sales
GROUP BY TO_CHAR(TO_DATE(invoice_date, 'DD/MM/YYYY'), 'YYYY-MM')
ORDER BY month;

--Unit sold by monthly--
SELECT 
  TO_CHAR(TO_DATE(invoice_date, 'DD/MM/YYYY'), 'YYYY-MM') AS month,
  SUM(units_sold::numeric) AS total_units_sold
FROM nike_sales
GROUP BY TO_CHAR(TO_DATE(invoice_date, 'DD/MM/YYYY'), 'YYYY-MM')
ORDER BY month;

--Monthly increase/decrease in total sales--
WITH monthly_sales AS (
  SELECT 
    TO_CHAR(TO_DATE(invoice_date, 'DD-MM-YYYY'), 'YYYY-MM') AS month,
    SUM(total_sales::numeric) AS total_sales
  FROM nike_sales
  WHERE invoice_date LIKE '__-__-____'
  GROUP BY TO_CHAR(TO_DATE(invoice_date, 'DD-MM-YYYY'), 'YYYY-MM')
),
sales_with_changes AS (
  SELECT 
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS previos_sales,
    total_sales - LAG(total_sales) OVER (ORDER BY month) AS difference,
    CASE 
      WHEN total_sales > LAG(total_sales) OVER (ORDER BY month) THEN 'increased'
      WHEN total_sales < LAG(total_sales) OVER (ORDER BY month) THEN 'decreased'
      ELSE 'same'
    END AS change_status
  FROM monthly_sales
)
SELECT * FROM sales_with_changes;

--Monthly increase/decrease in unit sold--
WITH monthly_unit_sold AS (
  SELECT 
    TO_CHAR(TO_DATE(invoice_date, 'DD-MM-YYYY'), 'YYYY-MM') AS month,
    SUM(units_sold::numeric) AS total_unit_sold
  FROM nike_sales
  WHERE invoice_date LIKE '__-__-____'
  GROUP BY TO_CHAR(TO_DATE(invoice_date, 'DD-MM-YYYY'), 'YYYY-MM')
),
unit_sold_with_changes AS (
  SELECT 
    month,
    total_unit_sold,
    LAG(total_unit_sold) OVER (ORDER BY month) AS previos_unit_sold,
    total_unit_sold - LAG(total_unit_sold) OVER (ORDER BY month) AS difference,
    CASE 
      WHEN total_unit_sold > LAG(total_unit_sold) OVER (ORDER BY month) THEN 'increased'
      WHEN total_unit_sold < LAG(total_unit_sold) OVER (ORDER BY month) THEN 'decreased'
      ELSE 'same'
    END AS change_status
  FROM monthly_unit_sold
)
SELECT * FROM unit_sold_with_changes;

--Relationship between unit price and units sold--
SELECT 
  CAST(price_per_unit AS INTEGER) AS price_per_unit,
  AVG(CAST(units_sold AS INTEGER)) AS average_units
FROM nike_sales
GROUP BY price_per_unit
ORDER BY price_per_unit;