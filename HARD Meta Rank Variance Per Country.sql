-- Rank Variance Per Country 
-- https://platform.stratascratch.com/coding/2007-rank-variance-per-country?code_type=1

-- Compare the total number of comments made by users in each country during December 2019 and January 2020.

-- For each month, rank countries by their total number of comments in descending order. Countries with the 
-- same total should share the same rank, and the next rank should increase by one (without skipping numbers).

-- Return the names of the countries whose rank improved from December to January (that is, their rank number 
-- became smaller).

-- Step 1
-- For each country and month, sum up total comments made between Dec 2019 and Jan 2020

SELECT u.country,
       DATE_TRUNC('month', c.created_at)::DATE AS month_start, 
                    -- DATE_TRUNC('month'): Round a timestamp down to the first of its month, zeroing out the day and time
                    -- 2019-12-14 09:23:45  -> 2019-12-01 00:00:00
                    -- 2019-12-31 17:05:00  -> 2019-12-01 00:00:00
                    -- 2020-01-08 12:00:00  -> 2020-01-01 00:00:00
       SUM(c.number_of_comments) AS total_comments
FROM fb_comments_count AS c
JOIN fb_active_users AS u ON c.user_id = u.user_id
WHERE c.created_at >= '2019-12-01'
    AND c.created_at < '2020-02-01'
GROUP BY u.country,
         DATE_TRUNC('month', c.created_at)::DATE

-- Step 2
-- Wrap Step 1 as a CTE 
-- Filter it down to December only

WITH monthly_comments AS(
    SELECT u.country,
          DATE_TRUNC('month', c.created_at)::DATE AS month_start,
          SUM(c.number_of_comments) AS total_comments
    FROM fb_comments_count AS c
    JOIN fb_active_users AS u ON c.user_id = u.user_id
    WHERE c.created_at >= '2019-12-01'
        AND c.created_at < '2020-02-01'
    GROUP BY u.country,
             DATE_TRUNC('month', c.created_at)::DATE
)
SELECT country,
       total_comments
FROM monthly_comments
WHERE month_start = '2019-12-01'

-- Step 3 Repeat Step 2 for Jan

WITH monthly_comments AS(
    SELECT u.country,
          DATE_TRUNC('month', c.created_at)::DATE AS month_start,
          SUM(c.number_of_comments) AS total_comments
    FROM fb_comments_count AS c
    JOIN fb_active_users AS u ON c.user_id = u.user_id
    WHERE c.created_at >= '2019-12-01'
        AND c.created_at < '2020-02-01'
    GROUP BY u.country,
             DATE_TRUNC('month', c.created_at)::DATE
)
SELECT country,
        total_comments
FROM monthly_comments
WHERE month_start = '2020-01-01'

-- Step 4
-- Wrap Step 2 as a CTE 
-- Rank each country by total comments in December; ties get the same rank

WITH monthly_comments AS(
    SELECT u.country,
          DATE_TRUNC('month', c.created_at)::DATE AS month_start,
          SUM(c.number_of_comments) AS total_comments
    FROM fb_comments_count AS c
    JOIN fb_active_users AS u ON c.user_id = u.user_id
    WHERE c.created_at >= '2019-12-01'
        AND c.created_at < '2020-02-01'
    GROUP BY u.country,
             DATE_TRUNC('month', c.created_at)::DATE
), december AS (
    SELECT country,
           total_comments
    FROM monthly_comments
    WHERE month_start = '2019-12-01'
)
SELECT country,
       total_comments,
       DENSE_RANK() OVER (ORDER BY total_comments DESC) AS dec_rank
FROM december

-- Step 5 Repeat Step 4 for Jan

WITH monthly_comments AS(
    SELECT u.country,
          DATE_TRUNC('month', c.created_at)::DATE AS month_start,
          SUM(c.number_of_comments) AS total_comments
    FROM fb_comments_count AS c
    JOIN fb_active_users AS u ON c.user_id = u.user_id
    WHERE c.created_at >= '2019-12-01'
        AND c.created_at < '2020-02-01'
    GROUP BY u.country,
             DATE_TRUNC('month', c.created_at)::DATE
), january AS(
    SELECT country,
           total_comments
    FROM monthly_comments
    WHERE month_start = '2020-01-01'
)
SELECT country,
       total_comments,
       DENSE_RANK() OVER (ORDER BY total_comments DESC) AS jan_rank
FROM january

-- Step 7
-- Join December and January rankings side by side, one row per country
-- Filter countries whose rank improved from December to January

WITH monthly_comments AS(
    SELECT u.country,
          DATE_TRUNC('month', c.created_at)::DATE AS month_start,
          SUM(c.number_of_comments) AS total_comments
    FROM fb_comments_count AS c
    JOIN fb_active_users AS u ON c.user_id = u.user_id
    WHERE c.created_at >= '2019-12-01'
        AND c.created_at < '2020-02-01'
    GROUP BY u.country,
             DATE_TRUNC('month', c.created_at)::DATE
), december AS (
    SELECT country,
           total_comments
    FROM monthly_comments
    WHERE month_start = '2019-12-01'
), january AS(
    SELECT country,
           total_comments
    FROM monthly_comments
    WHERE month_start = '2020-01-01'
), december_rank AS(
    SELECT country,
           total_comments,
           DENSE_RANK() OVER (ORDER BY total_comments DESC) AS dec_rank
    FROM december
), january_rank AS(
    SELECT country,
           total_comments,
           DENSE_RANK() OVER (ORDER BY total_comments DESC) AS jan_rank
    FROM january
), rank_compare AS (
    -- Join December and January rankings side by side, one row per country
    SELECT d.country,
           d.dec_rank,
           j.jan_rank,
           d.total_comments AS dec_comments,
           j.total_comments AS jan_comments
    FROM december_rank d
    JOIN january_rank j USING (country) -- Match rows where country name is the same in both tables
)
SELECT country
FROM rank_compare
WHERE dec_rank > jan_rank               -- This means Jan rank improved
ORDER BY dec_rank;