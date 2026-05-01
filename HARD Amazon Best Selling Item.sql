-- Best Selling Item
-- https://platform.stratascratch.com/coding/10172-best-selling-item?code_type=1

-- Find the best-selling item for each month (no need to separate months by year). 
-- The best-selling item is determined by the highest total sales amount, calculated 
-- as: total_paid = unitprice * quantity. A negative quantity indicates a return or 
-- cancellation (the invoice number begins with 'C'. To calculate sales, ignore returns 
-- and cancellations. Output the month, description of the item, and the total amount paid.

-- Step 1

SELECT
    EXTRACT(MONTH FROM invoicedate) AS month, 
    description,
    SUM(unitprice * quantity) AS total_paid,
    RANK() OVER (PARTITION BY EXTRACT(MONTH FROM invoicedate)
                    ORDER BY SUM(unitprice * quantity) DESC
                ) AS ranking
FROM online_retail
WHERE quantity > 0
GROUP BY EXTRACT(MONTH FROM invoicedate), description

-- Step 2

WITH monthly_sales AS (
    SELECT
        EXTRACT(MONTH FROM invoicedate) AS month, 
        description,
        SUM(unitprice * quantity) AS total_paid,
        RANK() OVER (PARTITION BY EXTRACT(MONTH FROM invoicedate)
                     ORDER BY SUM(unitprice * quantity) DESC
                    ) AS ranking
    FROM online_retail
    WHERE quantity > 0
    GROUP BY EXTRACT(MONTH FROM invoicedate), description
)

-- Step 3

WITH monthly_sales AS (
    SELECT
        EXTRACT(MONTH FROM invoicedate) AS month, 
        description,
        SUM(unitprice * quantity) AS total_paid,
        RANK() OVER (PARTITION BY EXTRACT(MONTH FROM invoicedate)
                     ORDER BY SUM(unitprice * quantity) DESC
                    ) AS ranking
    FROM online_retail
    WHERE quantity > 0
    GROUP BY EXTRACT(MONTH FROM invoicedate), description
)
SELECT
    month,
    description,
    total_paid
FROM monthly_sales
WHERE ranking = 1;