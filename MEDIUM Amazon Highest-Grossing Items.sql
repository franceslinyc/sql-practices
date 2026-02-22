-- Highest-Grossing Items
-- link: https://datalemur.com/questions/sql-highest-grossing

-- Step 1 
-- Calculate total spend per product within each category
-- Rank product by total spending within each category from highest to lowest

SELECT 
  category, 
  product, 
  SUM(spend) AS total_spend, 
  ---- Rank --------------------------
  RANK() OVER (                          -- RANK() -> Assign ranks 1, 2, 3, ...; OVER() -> Make RANK() a window function 
  PARTITION BY category                  -- PARTITION BY  -> Decide how rows are divided into windows
  ORDER BY SUM(spend) DESC) AS ranking   -- ORDER BY      -> Define how rows are sorted before ranking 
  ------------------------------------
FROM product_spend
WHERE EXTRACT(YEAR FROM transaction_date) = 2022
GROUP BY category, product;

-- Step 2 Create a tmp table using CTE 

WITH ranked_spending_cte AS (
  SELECT 
    category, 
    product, 
    SUM(spend) AS total_spend,
    RANK() OVER (
      PARTITION BY category 
      ORDER BY SUM(spend) DESC) AS ranking 
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product
)

-- Step 3 Return only the top 2 highest-grossing products per category 

WITH ranked_spending_cte AS (
  SELECT 
    category, 
    product, 
    SUM(spend) AS total_spend,
    RANK() OVER (
      PARTITION BY category 
      ORDER BY SUM(spend) DESC) AS ranking 
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product
)
SELECT 
  category, 
  product, 
  total_spend 
FROM ranked_spending_cte 
WHERE ranking <= 2         -- Filter to top 2 per category
ORDER BY category, ranking;