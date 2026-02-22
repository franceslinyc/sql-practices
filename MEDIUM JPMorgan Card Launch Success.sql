-- Card Launch Success
-- https://datalemur.com/questions/card-launch-success

-- Step 1
-- Create issue date

SELECT     
  card_name,
  issued_amount,
  MAKE_DATE(issue_year, issue_month, 1) AS issue_date
FROM monthly_cards_issued;

-- Step 2
-- Obtain launch date

SELECT 
  card_name,
  issued_amount,
  MAKE_DATE(issue_year, issue_month, 1) AS issue_date,
  ---- Min --------------------------
  MIN(MAKE_DATE(issue_year, issue_month, 1)) OVER (  -- OVER() -> Make MIN() a window function 
    PARTITION BY card_name) AS launch_date           -- PARTITION BY  -> Decide how rows are divided into window
                                                     -- Careful! MIN() Cannot use issue_date yet because SQL evaluate all SELECT expressions together
  ------------------------------------
FROM monthly_cards_issued;

-- Step 3
-- Use a CTE to create a tmp table

WITH card_launch AS (
  SELECT 
    card_name,
    issued_amount,
    MAKE_DATE(issue_year, issue_month, 1) AS issue_date,
    MIN(MAKE_DATE(issue_year, issue_month, 1)) OVER (PARTITION BY card_name) AS launch_date
  FROM monthly_cards_issued
)

-- Step 4
-- Select records 
-- Order result from highest to lowest

WITH card_launch AS (
  SELECT 
    card_name,
    issued_amount,
    MAKE_DATE(issue_year, issue_month, 1) AS issue_date,
    MIN(MAKE_DATE(issue_year, issue_month, 1)) OVER (PARTITION BY card_name) AS launch_date
  FROM monthly_cards_issued
)
SELECT 
  card_name, 
  issued_amount
FROM card_launch
WHERE issue_date = launch_date
ORDER BY issued_amount DESC;

