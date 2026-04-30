-- Top Three Salaries
-- https://datalemur.com/questions/sql-top-three-salaries

-- Step 1

SELECT 
  department_name, 
  name, 
  salary, 
  DENSE_RANK() OVER(
    PARTITION BY department_name ORDER BY salary DESC) AS ranking 
FROM employee 
INNER JOIN department on employee.department_id = department.department_id

-- Step 2

WITH tmp AS (
  SELECT 
    department_name, 
    name, 
    salary, 
    DENSE_RANK() OVER(
       PARTITION BY department_name ORDER BY salary DESC) AS ranking 
  FROM employee 
  INNER JOIN department on employee.department_id = department.department_id
) 

-- Step 3

WITH tmp AS (
  SELECT 
    department_name, 
    name, 
    salary, 
    DENSE_RANK() OVER(
       PARTITION BY department_name ORDER BY salary DESC) AS ranking 
  FROM employee 
  INNER JOIN department on employee.department_id = department.department_id
) 
SELECT 
    department_name, 
    name, 
    salary 
FROM tmp 
WHERE ranking <= 3 
ORDER BY department_name, salary DESC, name