-- Titanic Survivors and Non-Survivors
-- https://platform.stratascratch.com/coding/9881-make-a-report-showing-the-number-of-survivors-and-non-survivors-by-passenger-class?code_type=1

SELECT
    survived,
    COUNT(*) FILTER (WHERE pclass = 1) AS first_class,
    COUNT(*) FILTER (WHERE pclass = 2) AS second_class,
    COUNT(*) FILTER (WHERE pclass = 3) AS third_class
    -- SUM(CASE WHEN pclass = 1 THEN 1 ELSE 0 END) AS first_class,
    -- SUM(CASE WHEN pclass = 2 THEN 1 ELSE 0 END) AS second_class,
    -- SUM(CASE WHEN pclass = 3 THEN 1 ELSE 0 END) AS third_class
FROM titanic
GROUP BY survived;
