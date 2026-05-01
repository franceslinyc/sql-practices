-- Monthly Percentage Difference
-- https://platform.stratascratch.com/coding/10319-monthly-percentage-difference?code_type=1


-- Step 1
-- Aggregate revenue by month

SELECT 
  TO_CHAR(created_at::DATE, 'YYYY-MM') AS year_month,
            -- TO_CHAR See below 
            -- ::DATE: Convert to datetime 
            -- ::DATE is the same as CAST(... AS DATE)   
  SUM(value) AS revenue
FROM sf_transactions
GROUP BY year_month

-- Step 2
-- Wrap it as a CTE

WITH monthly AS (
  SELECT 
    TO_CHAR(created_at::DATE, 'YYYY-MM') AS year_month,
    SUM(value) AS revenue
  FROM sf_transactions
  GROUP BY year_month
)

-- Step 3
-- Calculate month-over-month revenue change

WITH monthly AS (
  SELECT 
    TO_CHAR(created_at::DATE, 'YYYY-MM') AS year_month,
    SUM(value) AS revenue
  FROM sf_transactions
  GROUP BY year_month
)
SELECT 
    year_month,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY year_month)) / LAG(revenue) OVER (ORDER BY year_month)
        * 100, 2) AS revenue_diff_pct
                     --  LAG(column, offset, default) OVER (
                     --         PARTITION BY ...   -- optional: reset window per group
                     --         ORDER BY ...)      -- required: defines row order
FROM monthly
ORDER BY year_month; -- Careful! Stilll need this since ORDER BY in LAG() OVER() is local to the window function

-- Step 4
-- Refactor with a window 

WITH monthly AS (
  SELECT 
    TO_CHAR(created_at::DATE, 'YYYY-MM') AS year_month,
    SUM(value) AS revenue
  FROM sf_transactions
  GROUP BY year_month
)
SELECT 
    year_month,
    ROUND((revenue - LAG(revenue) OVER w) / LAG(revenue) OVER w
        * 100, 2) AS revenue_diff_pct
FROM monthly
WINDOW w AS (ORDER BY year_month) -- So that we can use w with LAG() OVER() 
ORDER BY year_month;

---- Alternative solution ----

WITH monthly AS (
  SELECT 
    TO_CHAR(created_at::DATE, 'YYYY-MM') AS year_month,
    SUM(value) AS revenue
  FROM sf_transactions
  GROUP BY year_month
),
monthly_with_lag AS (
  SELECT
    year_month,
    revenue,
    LAG(revenue) OVER (ORDER BY year_month) AS prev_revenue  -- Computed once, reused below
  FROM monthly
)
SELECT
    year_month,
    ROUND((revenue - prev_revenue) / prev_revenue * 100, 2) AS revenue_diff_pct
FROM monthly_with_lag
ORDER BY year_month;


-- -- Dates
-- TO_CHAR(column, 'YYYY-MM-DD')         -- '2023-07-15'
-- TO_CHAR(column, 'YYYY-MM')            -- '2023-07'
-- TO_CHAR(column, 'Month YYYY')         -- 'July      2023'
-- TO_CHAR(column, 'FMMonth YYYY')       -- 'July 2023'  (FM removes padding)
-- TO_CHAR(column, 'DD Mon YYYY')        -- '15 Jul 2023'
-- TO_CHAR(column, 'YYYY "Q"Q')          -- '2023 Q3'
-- TO_CHAR(ccolumn, 'YYYY-WW')            -- '2023-28'