-- FAANG Stock Min-Max (Part 1)
-- https://datalemur.com/questions/sql-bloomberg-stock-min-max-1

-- Step 1
-- Retrieve highest open price

SELECT 
  ticker,
  TO_CHAR(date, 'Mon-YYYY') AS highest_mth,
  MAX(open) AS highest_open,   -- Name is a bit misleadning here. No aggregation at all. 
  ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open DESC) AS row_num
FROM stock_prices
GROUP BY ticker, TO_CHAR(date, 'Mon-YYYY'), open; 
         -- GROUP BY open otherwise ORDER BY open in ROW_NUMBER() OVER (...) won't work

-- Step 2
-- Retrieve lowest open price

SELECT 
  ticker,
  TO_CHAR(date, 'Mon-YYYY') AS lowest_mth,
  MIN(open) AS lowest_open,   -- Name is a bit misleadning here. No aggregation at all. 
  ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open) AS row_num
FROM stock_prices
GROUP BY ticker, TO_CHAR(date, 'Mon-YYYY'), open;


-- Step 3 
-- Create TWO CTEs: highest and lowest

WITH highest AS (
  SELECT 
    ticker,
    TO_CHAR(date, 'Mon-YYYY') AS highest_mth,
    MAX(open) AS highest_open,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open DESC) AS row_num
  FROM stock_prices
  GROUP BY ticker, TO_CHAR(date, 'Mon-YYYY'), open
),
lowest AS (
  SELECT 
    ticker,
    TO_CHAR(date, 'Mon-YYYY') AS lowest_mth,
    MIN(open) AS lowest_open,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open) AS row_num
  FROM stock_prices
  GROUP BY ticker, TO_CHAR(date, 'Mon-YYYY'), open
)

-- Step 4
-- Join CTEs 
-- Filter the results to include only rows where the row number in both CTEs is equal to 1

WITH highest AS (
  SELECT 
    ticker,
    TO_CHAR(date, 'Mon-YYYY') AS highest_mth,
    MAX(open) AS highest_open,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open DESC) AS row_num
  FROM stock_prices
  GROUP BY ticker, TO_CHAR(date, 'Mon-YYYY'), open
),
lowest AS (
  SELECT 
    ticker,
    TO_CHAR(date, 'Mon-YYYY') AS lowest_mth,
    MIN(open) AS lowest_open,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open) AS row_num
  FROM stock_prices
  GROUP BY ticker, TO_CHAR(date, 'Mon-YYYY'), open
)
SELECT
  highest.ticker,
  highest.highest_mth,
  highest.highest_open,
  lowest.lowest_mth,
  lowest.lowest_open
FROM highest
INNER JOIN lowest
  ON highest.ticker = lowest.ticker
  AND highest.row_num = 1 -- Highest open price
  AND lowest.row_num = 1  -- Lowest open price
ORDER BY highest.ticker;

-- Step 4
-- Join CTEs 
-- Filter the results to include only rows where the row number in both CTEs is equal to 1

WITH highest AS (SELECT 
    ticker,
    TO_CHAR(date, 'Mon-YYYY') AS highest_mth,
    --MAX(open) AS highest_open,
    open AS highest_open,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open DESC) AS row_num
  FROM stock_prices
  GROUP BY ticker, TO_CHAR(date, 'Mon-YYYY'), open
), 
lowest AS (SELECT 
    ticker,
    TO_CHAR(date, 'Mon-YYYY') AS lowest_mth, 
    --MIN(open) AS lowest_open,
    open AS lowest_open,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open) AS row_num
  FROM stock_prices
  GROUP BY ticker, TO_CHAR(date, 'Mon-YYYY'), open
) 
SELECT
  highest.ticker,
  highest.highest_mth,
  highest.highest_open,
  lowest.lowest_mth,
  lowest.lowest_open
FROM highest
INNER JOIN lowest
  ON highest.ticker = lowest.ticker
  AND highest.row_num = 1 -- Highest open price
  AND lowest.row_num = 1  -- Lowest open price
ORDER BY highest.ticker;




---- Alternative solution ----

WITH monthly_prices AS (
  SELECT
    ticker,
    TO_CHAR(date, 'Mon-YYYY') AS month,
    MAX(open) AS max_open,
    MIN(open) AS min_open
  FROM stock_prices
  GROUP BY ticker, TO_CHAR(date, 'Mon-YYYY')
),
ranked AS (
  SELECT
    ticker,
    month,
    max_open,
    min_open,
    RANK() OVER (PARTITION BY ticker ORDER BY max_open DESC) AS high_rank,
    RANK() OVER (PARTITION BY ticker ORDER BY min_open ASC) AS low_rank
  FROM monthly_prices
)
SELECT
  ticker,
  MAX(CASE WHEN high_rank = 1 THEN month END) AS highest_mth,
  MAX(CASE WHEN high_rank = 1 THEN max_open END) AS highest_open,
  MAX(CASE WHEN low_rank  = 1 THEN month END) AS lowest_mth,
  MAX(CASE WHEN low_rank  = 1 THEN min_open END) AS lowest_open
FROM ranked
WHERE high_rank = 1 OR low_rank = 1
GROUP BY ticker
ORDER BY ticker;