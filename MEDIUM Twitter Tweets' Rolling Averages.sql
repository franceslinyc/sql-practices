-- Tweets' Rolling Averages
-- https://datalemur.com/questions/rolling-average-tweets

-- Step 1 WRONG 
-- Calculate the cumulative average tweet count for the cumulative number of days

SELECT
  user_id,
  tweet_date,
  AVG(tweet_count) OVER (
    PARTITION BY user_id
    ORDER BY tweet_date) AS rolling_avg_3d 
    -- Default frame: ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
FROM tweets;


-- Step 1 
-- Calculate the rolling average tweet count for each user over a 3-day period

SELECT    
  user_id,    
  tweet_date,
  tweet_count,
  AVG(tweet_count) OVER (
    PARTITION BY user_id     
    ORDER BY tweet_date
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg
FROM tweets;

-- Step 2
-- Round the rolling average tweet count to 2 decimal points

SELECT    
  user_id,    
  tweet_date,   
  ROUND(AVG(tweet_count) OVER (
    PARTITION BY user_id     
    ORDER BY tweet_date     
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
  ,2) AS rolling_avg_3d
FROM tweets;