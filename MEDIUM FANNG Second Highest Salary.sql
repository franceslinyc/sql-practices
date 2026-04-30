-- Second Highest Salary
-- https://datalemur.com/questions/sql-second-highest-salary

-- Step 1 
-- Find the Highest Salary

SELECT MAX(salary) AS highest_salary
FROM employee;

-- Step 2
-- Use a CTE to create a tmp table

WITH tmp AS (
  SELECT MAX(salary) AS highest_salary
  FROM employee
)

-- Step 3
-- Find the Second Highest Salary 

WITH tmp AS (
  SELECT MAX(salary) AS highest_salary
  FROM employee
)
SELECT MAX(salary) AS second_highest_salary
FROM employee
WHERE salary < (
    -- Pull the highest salary from the CTE
    SELECT highest_salary 
    FROM tmp 
);