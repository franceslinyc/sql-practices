-- Sending vs. Opening Snaps
-- https://datalemur.com/questions/time-spent-snaps


-- Step 1
-- Join tables and filter for 'send' and 'open' snaps 

SELECT *
FROM activities
INNER JOIN age_breakdown AS age 
ON activities.user_id = age.user_id 
WHERE activities.activity_type IN ('send', 'open') 
    ---- This works too ----
    -- WHERE activities.activity_type = 'send' OR activities.activity_type = 'open'

-- Step 2
-- Obtain total time spent on sending and opening snaps, along with overall total time
-- Group by age bucket

SELECT 
  age.age_bucket, 
  SUM(CASE WHEN activities.activity_type = 'send' 
    THEN activities.time_spent ELSE 0 END) AS send_timespent, 
  SUM(CASE WHEN activities.activity_type = 'open' 
    THEN activities.time_spent ELSE 0 END) AS open_timespent, 
  SUM(activities.time_spent) AS total_timespent 
FROM activities
INNER JOIN age_breakdown AS age 
ON activities.user_id = age.user_id 
WHERE activities.activity_type IN ('send', 'open') 
GROUP BY age.age_bucket

-- Step 3
-- Use a CTE to create a tmp table

WITH tmp AS (
  SELECT 
    age.age_bucket, 
    SUM(CASE WHEN activities.activity_type = 'send' 
      THEN activities.time_spent ELSE 0 END) AS send_timespent, 
    SUM(CASE WHEN activities.activity_type = 'open' 
      THEN activities.time_spent ELSE 0 END) AS open_timespent, 
    SUM(activities.time_spent) AS total_timespent 
  FROM activities
  INNER JOIN age_breakdown AS age 
    ON activities.user_id = age.user_id 
  WHERE activities.activity_type IN ('send', 'open') 
  GROUP BY age.age_bucket
) 

-- Step 4
-- Calculate and round the percentages using CASE WHEN ... THEN ... ELSE ... END

WITH tmp AS (
  SELECT 
    age.age_bucket, 
    SUM(CASE WHEN activities.activity_type = 'send' 
      THEN activities.time_spent ELSE 0 END) AS send_timespent, 
    SUM(CASE WHEN activities.activity_type = 'open' 
      THEN activities.time_spent ELSE 0 END) AS open_timespent, 
    SUM(activities.time_spent) AS total_timespent 
  FROM activities
  INNER JOIN age_breakdown AS age 
    ON activities.user_id = age.user_id 
  WHERE activities.activity_type IN ('send', 'open') 
    ---- This works too ----
    -- WHERE activities.activity_type = 'send' OR activities.activity_type = 'open'
  GROUP BY age.age_bucket
) 
SELECT 
  age_bucket, 
  ROUND(100.0 * send_timespent / total_timespent, 2) AS send_perc, 
  ROUND(100.0 * open_timespent / total_timespent, 2) AS open_perc 
FROM tmp;

-- Step 4
-- Calculate and round the percentages using SUM(...) FILTER (WHERE ...)

WITH tmp AS (
  SELECT 
    age.age_bucket, 
    SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'send') AS send_timespent, 
    SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'open') AS open_timespent, 
    SUM(activities.time_spent) AS total_timespent 
  FROM activities
  INNER JOIN age_breakdown AS age 
    ON activities.user_id = age.user_id 
  WHERE activities.activity_type IN ('send', 'open') 
    ---- This works too ----
    -- WHERE activities.activity_type = 'send' OR activities.activity_type = 'open'
  GROUP BY age.age_bucket
) 
SELECT 
  age_bucket, 
  ROUND(100.0 * send_timespent / total_timespent, 2) AS send_perc, 
  ROUND(100.0 * open_timespent / total_timespent, 2) AS open_perc 
FROM tmp;




-- Step 1
-- Join tables and filter for 'send' and 'open' snaps 

SELECT *
FROM activities
INNER JOIN age_breakdown AS age 
  ON activities.user_id = age.user_id 
WHERE activities.activity_type IN ('send', 'open') 
    ---- This works too ----
    -- WHERE activities.activity_type = 'send' OR activities.activity_type = 'open'

-- Step 2
-- Obtain total time spent on sending and opening snaps
-- Group by age bucket

SELECT 
  age.age_bucket, 
  SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'send') AS send_perc, 
  SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'open') AS open_perc
FROM activities
INNER JOIN age_breakdown AS age 
  ON activities.user_id = age.user_id 
WHERE activities.activity_type IN ('send', 'open') 
GROUP BY age.age_bucket;

-- Step 3
-- Calculate the percentages

SELECT 
  age.age_bucket, 
  SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'send') /
    SUM(activities.time_spent) AS send_perc, 
  SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'open') /
    SUM(activities.time_spent) AS open_perc
FROM activities
INNER JOIN age_breakdown AS age 
  ON activities.user_id = age.user_id 
WHERE activities.activity_type IN ('send', 'open') 
GROUP BY age.age_bucket;

-- Step 4
-- Round the percentages

SELECT 
  age.age_bucket, 
  ROUND(100.0 * 
    SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'send')/
    SUM(activities.time_spent),2) AS send_perc, 
  ROUND(100.0 * 
    SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'open')/
    SUM(activities.time_spent),2) AS open_perc
FROM activities
INNER JOIN age_breakdown AS age 
  ON activities.user_id = age.user_id 
WHERE activities.activity_type IN ('send', 'open') 
    ---- This works too ----
    -- WHERE activities.activity_type = 'send' OR activities.activity_type = 'open'
GROUP BY age.age_bucket;

