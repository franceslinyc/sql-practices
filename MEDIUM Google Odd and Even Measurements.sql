-- Odd and Even Measurements
-- https://datalemur.com/questions/odd-even-measurements

-- Step 1
-- Create measurement day
-- Create measurement num

SELECT 
  CAST(measurement_time AS DATE) AS measurement_day,   -- CAST() turn TIMESTAMP to DATE
  measurement_value, 
  ---- Rank but with unique rank -----
  ROW_NUMBER() OVER (                                  -- ROW_NUMBER(), unlike RANK(), assign a unique sequential number to each row within a window
    PARTITION BY CAST(measurement_time AS DATE)        -- Again! ROW_NUMBER cannot use measurement_day yet
    ORDER BY measurement_time) AS measurement_num 
  ------------------------------------
FROM measurements; 

-- Step 2
-- Use a CTE to create a tmp table

WITH cte AS(
  SELECT 
    CAST(measurement_time AS DATE) AS measurement_day, 
    measurement_value, 
    ROW_NUMBER() OVER (
      PARTITION BY CAST(measurement_time AS DATE) 
      ORDER BY measurement_time) AS measurement_num 
  FROM measurements 
) 

-- Step 3
-- Filter and sum 

WITH cte AS (
  SELECT 
    CAST(measurement_time AS DATE) AS measurement_day, 
    measurement_value, 
    ROW_NUMBER() OVER (
      PARTITION BY CAST(measurement_time AS DATE) 
      ORDER BY measurement_time) AS measurement_num 
  FROM measurements
) 
SELECT 
  measurement_day, 
  SUM(measurement_value) FILTER (WHERE measurement_num % 2 != 0) AS odd_sum, 
  SUM(measurement_value) FILTER (WHERE measurement_num % 2 = 0) AS even_sum 
  ---- This works too ---- 
  -- SUM(CASE WHEN measurement_num % 2 != 0 THEN measurement_value ELSE 0 END) AS odd_sum,
  -- SUM(CASE WHEN measurement_num % 2 = 0 THEN measurement_value ELSE 0 END) AS even_sum
FROM cte
GROUP BY measurement_day; 