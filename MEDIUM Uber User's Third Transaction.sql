-- User's Third Transaction
-- https://datalemur.com/questions/sql-third-transaction

-- Step 1 
-- Obtain the order of transaction numbers for each user

SELECT 
  user_id, 
  spend, 
  transaction_date, 
  ROW_NUMBER() OVER (
    PARTITION BY user_id ORDER BY transaction_date) AS row_num
FROM transactions;


-- Step 2
-- Use a CTE to create a tmp table

WITH tmp AS (
  SELECT 
    user_id, 
    spend, 
    transaction_date, 
    ROW_NUMBER() OVER (
      PARTITION BY user_id ORDER BY transaction_date) AS row_num 
  FROM transactions)

-- Step 3
-- Filter for the users' third transaction 

WITH tmp AS (
  SELECT 
    user_id, 
    spend, 
    transaction_date, 
    ROW_NUMBER() OVER (
      PARTITION BY user_id ORDER BY transaction_date) AS row_num 
  FROM transactions)
SELECT 
  user_id, 
  spend, 
  transaction_date 
FROM tmp 
WHERE row_num = 3;