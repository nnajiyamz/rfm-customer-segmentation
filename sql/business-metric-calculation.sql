-- BUSINESS METRIC CALCULATIONS
-- Project: Stratex Commerce | Customer Behaviour & RFM Segmentation Analysis
-- Tool: SQLite / SQLiteStudio
-- Tables: customers, transactions


--- Total Revenue, Orders, Customers, AOV, Revenue per Customer
SELECT
    ROUND(SUM(total_amount), 2)                     AS total_revenue,
    COUNT(DISTINCT transaction_id)                  AS total_orders,
    COUNT(DISTINCT customer_id)                     AS total_customers,
    ROUND(SUM(total_amount) / 
        COUNT(DISTINCT transaction_id), 2)          AS avg_order_value,
    ROUND(SUM(total_amount) / 
        COUNT(DISTINCT customer_id), 2)             AS revenue_per_customer
FROM transactions
WHERE status = 'completed';

--- Revenue & AOV by Country 
SELECT
    c.country,
    ROUND(SUM(t.total_amount), 2)                   AS total_revenue,
    COUNT(DISTINCT t.transaction_id)                AS total_orders,
    ROUND(SUM(t.total_amount) /
        COUNT(DISTINCT t.transaction_id), 2)        AS aov,
    COUNT(DISTINCT t.customer_id)                   AS total_customers,
    ROUND(SUM(t.total_amount) /
        COUNT(DISTINCT t.customer_id), 2)           AS revenue_per_customer
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
WHERE t.status = 'completed'
GROUP BY c.country
ORDER BY total_revenue DESC;

--- Customer Count by Country & Customer Tier
SELECT
    c.country,
    c.segment                                       AS customer_tier,
    COUNT(DISTINCT c.customer_id)                   AS customer_count
FROM customers c
GROUP BY c.country, c.segment
ORDER BY c.country, customer_count DESC;

--- Revenue by Age Group
SELECT
    CASE
        WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN c.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN c.age BETWEEN 36 AND 45 THEN '36-45'
        WHEN c.age BETWEEN 46 AND 55 THEN '46-55'
        WHEN c.age BETWEEN 56 AND 65 THEN '56-65'
        ELSE '66-75'
    END                                             AS age_group,
    ROUND(SUM(t.total_amount), 2)                   AS total_revenue,
    COUNT(DISTINCT t.transaction_id)                AS total_orders,
    ROUND(SUM(t.total_amount) /
        COUNT(DISTINCT t.transaction_id), 2)        AS aov,
    COUNT(DISTINCT t.customer_id)                   AS total_customers,
        ROUND(SUM(t.total_amount) * 100.0 /
        (SELECT SUM(total_amount) 
         FROM transactions 
         WHERE status = 'completed'), 2)            AS pct_revenue
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
WHERE t.status = 'completed'
GROUP BY age_group
ORDER BY age_group;

--- Revenue by Customer Tier
SELECT
    c.segment                                       AS customer_tier,
    ROUND(SUM(t.total_amount), 2)                   AS total_revenue,
    COUNT(DISTINCT t.transaction_id)                AS total_orders,
    COUNT(DISTINCT t.customer_id)                   AS total_customers,
    ROUND(SUM(t.total_amount) /
        COUNT(DISTINCT t.transaction_id), 2)        AS aov,
        ROUND(SUM(t.total_amount) * 100.0 /
        (SELECT SUM(total_amount) 
         FROM transactions 
         WHERE status = 'completed'), 2)            AS pct_revenue
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
WHERE t.status = 'completed'
GROUP BY c.segment
ORDER BY c.segment, total_revenue DESC;

--- Revenue by Gender
SELECT
    c.gender,
    ROUND(SUM(t.total_amount), 2)                   AS total_revenue,
    ROUND(SUM(t.total_amount) * 100.0 /
        (SELECT SUM(total_amount) 
         FROM transactions 
         WHERE status = 'completed'), 2)            AS pct_revenue
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
WHERE t.status = 'completed'
GROUP BY c.gender
ORDER BY total_revenue DESC;
