-- Y-on-Y Growth Rate
-- https://datalemur.com/questions/yoy-growth-rate

-- Step 1
-- Summarize Yearly Spend

SELECT 
  EXTRACT(YEAR FROM transaction_date) AS year, 
  product_id,
  spend AS curr_year_spend 
FROM user_transactions;

-- Step 2
-- Calculate Prior Year's Spend

SELECT 
    EXTRACT(YEAR FROM transaction_date) AS year,
    product_id,
    spend AS curr_year_spend,
    ---- Lag --------------------------
    LAG(spend) OVER (
      PARTITION BY product_id 
      ORDER BY 
        product_id, 
        EXTRACT(YEAR FROM transaction_date)) AS prev_year_spend 
    ------------------------------------
  FROM user_transactions;


-- Step 3 
-- Use a CTE to create a tmp table

WITH tmp AS (
  SELECT 
    EXTRACT(YEAR FROM transaction_date) AS year,
    product_id,
    spend AS curr_year_spend,
    LAG(spend) OVER (
      PARTITION BY product_id 
      ORDER BY 
        product_id, 
        EXTRACT(YEAR FROM transaction_date)) AS prev_year_spend 
  FROM user_transactions
)


-- Step 4
-- Calculate Year-on-Year Growth Rate

WITH tmp AS (
  SELECT 
    EXTRACT(YEAR FROM transaction_date) AS year,
    product_id,
    spend AS curr_year_spend,
    LAG(spend) OVER (
      PARTITION BY product_id 
      ORDER BY 
        product_id, 
        EXTRACT(YEAR FROM transaction_date)) AS prev_year_spend 
  FROM user_transactions
)

SELECT 
  year,
  product_id, 
  curr_year_spend, 
  prev_year_spend, 
  ROUND(100 *                             -- Year-on-Year Growth Rate = ((Current Year's Spend - Previous Year’s Spend) / Previous Year’s Spend) x 100
    (curr_year_spend - prev_year_spend)
    / prev_year_spend
  , 2) AS yoy_rate 
FROM tmp;