-- Swapped Food Delivery
-- https://datalemur.com/questions/sql-swapped-food-delivery

-- Step 1
-- Count Total Number of Orders

SELECT COUNT(order_id) AS total_orders 
FROM orders;

-- Step 2
-- Use a CTE to create a tmp table
-- Perform a Cartesian join, i.e., every row in orders table is paired with a single row from the tmp table

WITH tmp AS (
  SELECT COUNT(order_id) AS total_orders 
  FROM orders
)
SELECT *          -- order_id, item
FROM orders
CROSS JOIN tmp;   -- Combine every row from the first table with every row from the second table
                  -- Unlike LEFT JOIN, RIGHT JOIN, order does not matter, 
                  -- e.g., 
                  -- orders = 7 rows
                  -- tmp = 1 rows
                  -- result = 7 x 1 rows

-- Step 3
-- Apply Swapped Order Logic with CASE Statement

WITH tmp AS (
  SELECT COUNT(order_id) AS total_orders 
  FROM orders
)
SELECT
  ------------------------------------
  order_id,
  CASE
    WHEN order_id % 2 != 0 AND order_id != total_orders THEN order_id + 1 -- If odd order AND not the last order, swap with the next item.
    WHEN order_id % 2 != 0 AND order_id = total_orders THEN order_id      -- If odd order AND the last order, remain as the last item. 
    ELSE order_id - 1 -- If even order, swap with the previous item. 
  END AS corrected_order_id,
  item
  ------------------------------------
FROM orders
CROSS JOIN tmp;

-- Step 4
-- sort the table based on the corrected order IDs 

WITH tmp AS (
  SELECT COUNT(order_id) AS total_orders 
  FROM orders
)
SELECT
  -- order_id, -- Remove old order id
  CASE
    WHEN order_id % 2 != 0 AND order_id != total_orders THEN order_id + 1 
    WHEN order_id % 2 != 0 AND order_id = total_orders THEN order_id 
    ELSE order_id - 1 
  END AS corrected_order_id,
  item
FROM orders
CROSS JOIN tmp
ORDER BY corrected_order_id; -- Sort based on corrected order id 