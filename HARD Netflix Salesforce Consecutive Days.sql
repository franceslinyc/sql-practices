-- Consecutive Days
-- https://platform.stratascratch.com/coding/2054-consecutive-days?code_type=1

-- Find all the users who were active for 3 consecutive days or more.

-- Step 1
-- Create data one row per (user, date) and drop duplicate events

SELECT DISTINCT
    user_id,
    record_date
FROM sf_events
ORDER BY user_id ASC, record_date ASC

-- e.g., 
-- user_id, record_date
-- A        2021-01-01 
-- A        2021-01-02 
-- A        2021-01-03 
-- A        2021-01-05 

-- Step 2
-- Wrap Step 1 in a CTE
-- Create the anchor_date column, where anchor_date = record_date - row_number 

WITH distinct_days AS (
    SELECT DISTINCT
        user_id,
        record_date
    FROM sf_events
    ORDER BY user_id ASC, record_date ASC
)
SELECT
    user_id,
    record_date - ROW_NUMBER() OVER (PARTITION BY user_id
                                     ORDER BY record_date)::INTEGER AS anchor_date
                                     -- ::INTEGER or else PostgreSQL won't subtract an integer directly from a date 
FROM distinct_days

-- e.g., 
-- user_id, record_date, row_number, anchor_date = record_date - row_number
-- A        2021-01-01   1           2020-12-31
-- A        2021-01-02   2           2020-12-31
-- A        2021-01-03   3           2020-12-31
-- A        2021-01-05   4           2021-01-01

-- e.g., 
-- user_id, anchor_date = record_date - row_number
-- A        2020-12-31
-- A        2020-12-31
-- A        2020-12-31
-- A        2021-01-01

-- Step 3
-- Create TWO CTEs

WITH distinct_days AS (
    SELECT DISTINCT
        user_id,
        record_date
    FROM sf_events
    ORDER BY user_id ASC, record_date ASC
),
consecutive_days AS (
    SELECT
        user_id,
        record_date - ROW_NUMBER() OVER (PARTITION BY user_id
                                         ORDER BY record_date)::INTEGER AS anchor_date
    FROM distinct_days
)

-- Step 4 
-- Count how many days fall into each (user, anchor date) group 

WITH distinct_days AS (
    SELECT DISTINCT
        user_id,
        record_date
    FROM sf_events
    ORDER BY user_id ASC, record_date ASC
),
consecutive_days AS (
    SELECT
        user_id,
        record_date - ROW_NUMBER() OVER (PARTITION BY user_id
                                         ORDER BY record_date)::INTEGER AS anchor_date
    FROM distinct_days
)
SELECT DISTINCT user_id
FROM consecutive_days
GROUP BY user_id, anchor_date
HAVING COUNT(*) >= 3 -- at least 3 days share the same anchor
ORDER BY user_id;

-- e.g., 
-- user_id, record_date
-- A        2021-01-01 
-- A        2021-01-02 
-- A        2021-01-03 
-- A        2021-01-05 

-- user_id, record_date, row_number, anchor_date = record_date - row_number
-- A        2021-01-01   1           2020-12-31
-- A        2021-01-02   2           2020-12-31
-- A        2021-01-03   3           2020-12-31
-- A        2021-01-05   4           2021-01-01

-- user_id, anchor_date = record_date - row_number
-- A        2020-12-31
-- A        2020-12-31
-- A        2020-12-31
-- A        2021-01-01

-- user_id, anchor_date, count
-- A        2020-12-31     3
-- A        2021-01-01     1