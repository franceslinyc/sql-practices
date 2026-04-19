-- Highest-Grossing Items
-- link: https://datalemur.com/questions/sql-highest-grossing

-- Step 1
-- Calculate total spend by category, product and filter the transactions to only include those from the year 2022 

SELECT 
  category, 
  product, 
  SUM(spend) AS total_spend
FROM product_spend
WHERE EXTRACT(YEAR FROM transaction_date) = 2022 -- Filter to the year of 2022
GROUP BY category, product;

-- Step 2 
-- Rank product by total spend within each category from highest to lowest

SELECT 
  category, 
  product, 
  SUM(spend) AS total_spend, 
  ---- Rank --------------------------
  RANK() OVER (                            -- RANK() -> Assign ranks 1, 2, 3, ...; OVER() -> Make RANK() a window function 
    PARTITION BY category                  -- PARTITION BY  -> Decide how rows are divided into windows
    ORDER BY SUM(spend) DESC) AS ranking   -- ORDER BY      -> Define how rows are sorted before ranking 
                                           -- Careful! ORDER BY Cannot use total_spend yet because SQL evaluate all SELECT expressions together
  ------------------------------------
FROM product_spend
WHERE EXTRACT(YEAR FROM transaction_date) = 2022
GROUP BY category, product;

-- Step 3 Use a CTE to create a tmp table

WITH tmp AS (
  SELECT 
    category, 
    product, 
    SUM(spend) AS total_spend,
    RANK() OVER (PARTITION BY category ORDER BY SUM(spend) DESC) AS ranking 
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product
)

-- Step 4 
-- Return only the top 2 highest-grossing products per category, rank 

WITH tmp AS (
  SELECT 
    category, 
    product, 
    SUM(spend) AS total_spend,
    RANK() OVER (PARTITION BY category ORDER BY SUM(spend) DESC) AS ranking 
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product
)
SELECT                      -- Run SELECT on CTE
  category, 
  product, 
  total_spend 
FROM tmp 
WHERE ranking <= 2          -- Filter to top 2 per category
ORDER BY category, ranking; -- Careful! 


-- Pattern recognition:
-- “Top N per group” -> window function: RANK() OVER (PARTITION BY ...)
-- Need ranking -> RANK() / ROW_NUMBER()
--      RANK(): ties get same rank (1, 1, 3)
--      ROW_NUMBER(): ties are unique (1, 2, 3)
-- Need filtering -> wrap in CTE

-- Steps: 
-- GROUP BY -> WINDOW FUNCTION: RANK() -> CTE -> FILTER -> ORDER