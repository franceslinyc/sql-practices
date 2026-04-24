-- Supercloud Customer 
-- https://datalemur.com/questions/supercloud-customer

-- Step 1
-- Join the customer_contracts and products tables 
-- Count the distinct product categories each customer has purchased from

SELECT 
  customers.customer_id, 
  COUNT(DISTINCT products.product_category) AS product_count
FROM customer_contracts AS customers
INNER JOIN products 
  ON customers.product_id = products.product_id
GROUP BY customers.customer_id;

-- Step 2
-- Use a CTE to create a tmp table

WITH tmp AS (
  SELECT 
    customers.customer_id, 
    COUNT(DISTINCT products.product_category) AS product_count
  FROM customer_contracts AS customers
  INNER JOIN products 
    ON customers.product_id = products.product_id
  GROUP BY customers.customer_id
)

-- Step 3
-- Filter

WITH tmp AS (
  SELECT 
    customers.customer_id, 
    COUNT(DISTINCT products.product_category) AS product_count
  FROM customer_contracts AS customers
  INNER JOIN products 
    ON customers.product_id = products.product_id
  GROUP BY customers.customer_id
)
SELECT customer_id
FROM tmp
WHERE product_count = (
  SELECT COUNT(DISTINCT product_category) 
  FROM products
);

-- Usually we do
-- WHERE product_count = 5, for example
-- but here, we want it 
-- WHERE product_count that matches count of all distinct product category