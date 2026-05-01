-- Finding Purchases 
-- https://platform.stratascratch.com/coding/10553-finding-purchases?code_type=1

-- Identify returning active users by finding users who made a repeat purchase within 
-- 7 days or less of their previous transaction, excluding same-day purchases. Output 
-- a list of these user_id.

-- Step 1

SELECT user_id,
        created_at::DATE AS tx_date,
        LAG(created_at::DATE) OVER (PARTITION BY user_id --  Reset and calculate separately for each user
                                    ORDER BY created_at) AS prev_tx_date
FROM amazon_transactions

-- Step 2

WITH tmp AS (
    SELECT user_id,
           created_at::DATE AS tx_date,
           LAG(created_at::DATE) OVER (PARTITION BY user_id 
                                       ORDER BY created_at) AS prev_tx_date
    FROM amazon_transactions
)

-- Step 3

WITH tmp AS (
    SELECT user_id,
           created_at::DATE AS tx_date,
           LAG(created_at::DATE) OVER (PARTITION BY user_id 
                                       ORDER BY created_at) AS prev_tx_date
    FROM amazon_transactions
)
SELECT DISTINCT user_id  -- Careful! Use DISTINCT 
FROM tmp
WHERE prev_tx_date IS NOT NULL
    AND (tx_date - prev_tx_date) > 0
    AND (tx_date - prev_tx_date) <= 7; 

---- Alternative solution BUT MAY BE INEFFICIENT ---- 

WITH tmp AS (
    SELECT user_id,
           created_at::DATE AS tx_date,
           LAG(created_at::DATE) OVER (PARTITION BY user_id 
                                       ORDER BY created_at) AS prev_tx_date
    FROM amazon_transactions
),
tmp2 AS (
    SELECT user_id,
           tx_date - prev_tx_date AS day
    FROM tmp
    WHERE prev_tx_date IS NOT NULL
)
SELECT DISTINCT user_id
FROM tmp2
WHERE day > 0 AND day <= 7;