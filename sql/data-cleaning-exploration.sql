-- DATA CLEANING & EXPLORATION
-- Project: Stratex Commerce | Customer Behaviour & RFM Segmentation Analysis
-- Tool: SQLite / SQLiteStudio
-- Tables: customers, products, transactions


---------------- ROW COUNTS -----------------------

SELECT 'customers'      AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products'       AS table_name, COUNT(*) AS row_count FROM products
UNION ALL
SELECT 'transactions'   AS table_name, COUNT(*) AS row_count FROM transactions;


----------- DUPLICATE CHECKS -----------------

--- Customers
SELECT customer_id, COUNT(*) AS duplicate
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

--- Products
SELECT product_id, COUNT(*) AS duplicate
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

--- Transactions
SELECT transaction_id, COUNT(*) AS duplicate
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


--------------- NULL CHECKS -------------------

--- Customers
SELECT
    COUNT(*) - COUNT(customer_id)       AS null_customer_id,
    COUNT(*) - COUNT(signup_date)       AS null_signup_date,
    COUNT(*) - COUNT(age)               AS null_age,
    COUNT(*) - COUNT(gender)            AS null_gender,
    COUNT(*) - COUNT(country)           AS null_country,
    COUNT(*) - COUNT(segment)           AS null_segment,
    COUNT(*) - COUNT(is_churned)        AS null_is_churned,
    COUNT(*) - COUNT(lifetime_value)    AS null_lifetime_value,
    COUNT(*) - COUNT(email_opt_in)      AS null_email_opt_in,
    COUNT(*) - COUNT(has_app)           AS null_has_app
FROM customers;

--- Products
SELECT
    COUNT(*) - COUNT(product_id)        AS null_product_id,
    COUNT(*) - COUNT(product_name)      AS null_product_name,
    COUNT(*) - COUNT(category)          AS null_category,
    COUNT(*) - COUNT(brand)             AS null_brand,
    COUNT(*) - COUNT(price)             AS null_price,
    COUNT(*) - COUNT(avg_rating)        AS null_avg_rating,
    COUNT(*) - COUNT(num_ratings)       AS null_num_ratings,
    COUNT(*) - COUNT(stock_quantity)    AS null_stock_quantity,
    COUNT(*) - COUNT(discount_pct)      AS null_discount_pct,
    COUNT(*) - COUNT(is_featured)       AS null_is_featured,
    COUNT(*) - COUNT(weight_kg)         AS null_weight_kg
FROM products;

--- Transactions
SELECT
    COUNT(*) - COUNT(transaction_id)    AS null_transaction_id,
    COUNT(*) - COUNT(customer_id)       AS null_customer_id,
    COUNT(*) - COUNT(product_id)        AS null_product_id,
    COUNT(*) - COUNT(transaction_date)  AS null_transaction_date,
    COUNT(*) - COUNT(quantity)          AS null_quantity,
    COUNT(*) - COUNT(unit_price)        AS null_unit_price,
    COUNT(*) - COUNT(total_amount)      AS null_total_amount,
    COUNT(*) - COUNT(discount_applied)  AS null_discount_applied,
    COUNT(*) - COUNT(status)            AS null_status,
    COUNT(*) - COUNT(payment_method)    AS null_payment_method,
    COUNT(*) - COUNT(shipping_cost)     AS null_shipping_cost
FROM transactions;


----------------- DATE RANGES EXPLORATION ----------------------------

--- Transactions date
SELECT
    MIN(transaction_date)                               AS first_txn,
    MAX(transaction_date)                               AS last_txn,
    CAST(julianday(MAX(transaction_date)) -
        julianday(MIN(transaction_date)) AS INTEGER)    AS days_covered
FROM transactions;

--- Customer signups date
SELECT
    MIN(signup_date)    AS first_signup,
    MAX(signup_date)    AS latest_signup
FROM customers;


----------- CUSTOMER EXPLORATION -----------------------

--- Segment
SELECT
    segment,
    COUNT(*)                                            AS count,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM customers), 2)            AS percentage
FROM customers
GROUP BY segment
ORDER BY count DESC;

--- Churn rate
SELECT
    CASE WHEN is_churned = 1
        THEN 'Churned'
        ELSE 'Active' END                               AS status,
    COUNT(*)                                            AS count,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM customers), 2)            AS percentage
FROM customers
GROUP BY is_churned;

--- Gender
SELECT
    gender,
    COUNT(*)                                            AS count,
    ROUND(AVG(age), 1)                                  AS avg_age,
    ROUND(AVG(lifetime_value), 2)                       AS avg_ltv
FROM customers
GROUP BY gender;

--- Range age
SELECT
    MIN(age)            AS min_age,
    MAX(age)            AS max_age,
    ROUND(AVG(age), 1)  AS avg_age
FROM customers;

--- Country & customer count
SELECT
    country,
    COUNT(*)                                            AS customer_count,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM customers), 2)            AS percentage
FROM customers
GROUP BY country
ORDER BY customer_count DESC;

--- Email opt-in & has app
SELECT
    email_opt_in,
    has_app,
    COUNT(*)                                            AS count,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM customers), 2)            AS percentage
FROM customers
GROUP BY email_opt_in, has_app;


------------- LIFETIME VALUE DATA VALIDATION -------------------------

--- Lifetime value vs actual transaction total
------- Results: The lifetime_value column does not match actual transaction totals
------- It could be because of pre assigned synthetic field, not related to actual purchase behaviour

SELECT
    c.customer_id,
    c.signup_date,
    c.lifetime_value,
    ROUND(SUM(t.total_amount), 2)                       AS actual_total_spent,
    ROUND(c.lifetime_value - SUM(t.total_amount), 2)    AS difference
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
    AND t.status = 'completed'
GROUP BY c.customer_id
LIMIT 10;

--- Customers with LTV but no completed transaction
------- Results: 1. Customers who signed up before 2023 with no transaction history
------- may have purchased outside the dataset coverage period (pre-2023)
------- 2. However, customers who signed up in 2023 or later with no transaction
------- history but have LTV data confirm that the column is synthetic 
------- and cannot be used for revenue analysis

SELECT
    c.customer_id,
    c.signup_date,
    c.lifetime_value,
    ROUND(SUM(t.total_amount), 2)                       AS actual_total_spent,
    ROUND(c.lifetime_value - SUM(t.total_amount), 2)    AS difference
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
    AND t.status = 'completed'
WHERE c.lifetime_value > 1
GROUP BY c.customer_id
HAVING SUM(t.total_amount) IS NULL;

--- Data sanity check: Customers with no completed transactions
---- Validates whether zero total spent means truly no transaction history
---- or only because of unsuccessful orders (pending, cancelled, refunded)
---- Also checks correlation with is_churned flag

------- Results: 1. zero total spent means zero transaction history / unsuccessful orders
------- 2. is_churned definition is unclear:
------- Some customers with zero purchase history since 2020 are not flagged as churned,
------- but some customers with only pending orders are flagged as churned

SELECT
    c.customer_id,
    c.signup_date,
    c.segment,
    c.lifetime_value,
    c.is_churned,
    COUNT(t.transaction_id)                             AS total_orders,
    SUM(CASE WHEN t.status = 'completed'
        THEN 1 ELSE 0 END)                              AS completed,
    SUM(CASE WHEN t.status = 'pending'
        THEN 1 ELSE 0 END)                              AS pending,
    SUM(CASE WHEN t.status = 'cancelled'
        THEN 1 ELSE 0 END)                              AS cancelled,
    SUM(CASE WHEN t.status = 'refunded'
        THEN 1 ELSE 0 END)                              AS refunded,
    CASE
        WHEN COUNT(t.transaction_id) = 0
            THEN 'Zero Transaction History'
        ELSE 'Has Transactions But Not Completed'
    END                                                 AS status
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
WHERE c.customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM transactions
    WHERE status = 'completed'
)
AND c.lifetime_value > 0
GROUP BY c.customer_id
ORDER BY c.signup_date, c.lifetime_value DESC;


-------------- CUSTOMER PURCHASE COVERAGE ------------------------
--- Brief overview of customers who never completed a transaction (excluded from RFM analysis)

--- Count of how many customers have no completed transaction= 270
SELECT COUNT(*) AS no_completed_customers
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM transactions
    WHERE status = 'completed'
);

--- Count of Never Attempted vs Attempted But Unsuccessful customers
------- Results: 59 Never Attempted, 211 Attempted But Unsuccessful

SELECT
    customer_type,
    COUNT(*)                                            AS total_customers
FROM (
    SELECT
        c.customer_id,
        CASE
            WHEN COUNT(t.transaction_id) = 0
                THEN 'Never Attempted'
            ELSE 'Attempted But Unsuccessful'
        END                                             AS customer_type
    FROM customers c
    LEFT JOIN transactions t ON c.customer_id = t.customer_id
    WHERE c.customer_id NOT IN (
        SELECT DISTINCT customer_id
        FROM transactions
        WHERE status = 'completed'
    )
    GROUP BY c.customer_id
)
GROUP BY customer_type;

--- Never attempted signup trend by month
------- Results: trend spike from mid-2023 onwards

SELECT
    strftime('%Y-%m', signup_date)                      AS signup_month,
    COUNT(*)                                            AS never_attempted_count
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM transactions
)
GROUP BY signup_month
ORDER BY signup_month;

--- Individual breakdown of excluded customers
--- (full detail per customer: signup date, segment, order attempts & failure type)

SELECT
    c.customer_id,
    c.signup_date,
    c.segment,
    c.is_churned,
    COUNT(t.transaction_id)                             AS total_order_attempts,
    SUM(CASE WHEN t.status = 'pending'
        THEN 1 ELSE 0 END)                              AS pending_count,
    SUM(CASE WHEN t.status = 'cancelled'
        THEN 1 ELSE 0 END)                              AS cancelled_count,
    SUM(CASE WHEN t.status = 'refunded'
        THEN 1 ELSE 0 END)                              AS refunded_count,
    CASE
        WHEN COUNT(t.transaction_id) = 0
            THEN 'Never Attempted'
        ELSE 'Attempted But Unsuccessful'
    END                                                 AS customer_type
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
WHERE c.customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM transactions
    WHERE status = 'completed'
)
GROUP BY c.customer_id, c.signup_date, c.segment
ORDER BY signup_date, total_order_attempts DESC;


----------- PRODUCT EXPLORATION -------------------

--- Products by category
SELECT
    category,
    COUNT(*)                        AS product_count,
    ROUND(AVG(price), 2)            AS avg_price,
    ROUND(AVG(avg_rating), 2)       AS avg_rating,
    SUM(stock_quantity)             AS total_stock
FROM products
GROUP BY category
ORDER BY product_count DESC;

--- Price range
SELECT
    MIN(price)              AS min_price,
    MAX(price)              AS max_price,
    ROUND(AVG(price), 2)    AS avg_price
FROM products;

--- Distinct discount rate
SELECT DISTINCT discount_pct FROM products
ORDER BY discount_pct DESC;

--- Product count by discount
SELECT
    COUNT(CASE WHEN discount_pct = 0
        THEN 1 END)                 AS no_discount,
    COUNT(CASE WHEN discount_pct > 0
        AND discount_pct <= 10
        THEN 1 END)                 AS discount_1_10pct,
    COUNT(CASE WHEN discount_pct > 10
        AND discount_pct <= 25
        THEN 1 END)                 AS discount_11_25pct,
    COUNT(CASE WHEN discount_pct > 25
        THEN 1 END)                 AS discount_over_25pct
FROM products;

--- Featured vs non featured
SELECT
    CASE WHEN is_featured = 1
        THEN 'Featured'
        ELSE 'Not Featured' END     AS featured_status,
    COUNT(*)                        AS product_count,
    ROUND(AVG(price), 2)            AS avg_price,
    ROUND(AVG(avg_rating), 2)       AS avg_rating
FROM products
GROUP BY is_featured;

--- Top 10 products by rating
SELECT
    product_name,
    category,
    avg_rating,
    num_ratings,
    price
FROM products
WHERE num_ratings > 10
ORDER BY avg_rating DESC
LIMIT 10;


-------------- TRANSACTION EXPLORATION ------------------------

--- Distinct status values
SELECT DISTINCT status
FROM transactions
ORDER BY status;

--- Transaction status breakdown
SELECT
    status,
    COUNT(*)                                            AS count,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions), 2)         AS percentage
FROM transactions
GROUP BY status
ORDER BY count DESC;

--- Revenue summary (completed only)
SELECT
    MIN(total_amount)               AS min_order_value,
    MAX(total_amount)               AS max_order_value,
    ROUND(AVG(total_amount), 2)     AS avg_order_value,
    ROUND(SUM(total_amount), 2)     AS total_revenue,
    COUNT(*)                        AS total_orders
FROM transactions
WHERE status = 'completed';

--- Payment method breakdown
SELECT
    payment_method,
    COUNT(*)                                            AS count,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions), 2)         AS percentage
FROM transactions
GROUP BY payment_method
ORDER BY count DESC;

--- Revenue summary by quarter
SELECT
    strftime('%Y', transaction_date)                    AS year,
    CASE
        WHEN CAST(strftime('%m', transaction_date)
            AS INTEGER) <= 3  THEN 'Q1'
        WHEN CAST(strftime('%m', transaction_date)
            AS INTEGER) <= 6  THEN 'Q2'
        WHEN CAST(strftime('%m', transaction_date)
            AS INTEGER) <= 9  THEN 'Q3'
        ELSE 'Q4'
    END                                                 AS quarter,
    ROUND(SUM(total_amount), 2)                         AS total_revenue,
    COUNT(DISTINCT transaction_id)                      AS total_orders
FROM transactions
WHERE status = 'completed'
GROUP BY year, quarter
ORDER BY year, quarter;

--- Shipping cost
SELECT
    MIN(shipping_cost)                                  AS min_shipping,
    MAX(shipping_cost)                                  AS max_shipping,
    ROUND(AVG(shipping_cost), 2)                        AS avg_shipping,
    COUNT(CASE WHEN shipping_cost = 0
        THEN 1 END)                                     AS free_shipping_count,
    ROUND(COUNT(CASE WHEN shipping_cost = 0
        THEN 1 END) * 100.0 /
        COUNT(*), 2)                                    AS free_shipping_pct
FROM transactions;

--- Discount analysis
SELECT
    COUNT(CASE WHEN discount_applied > 0
        THEN 1 END)                                     AS discounted_orders,
    COUNT(CASE WHEN discount_applied = 0
        THEN 1 END)                                     AS full_price_orders,
    ROUND(AVG(CASE WHEN discount_applied > 0
        THEN discount_applied END), 2)                  AS avg_discount_amount,
    ROUND(COUNT(CASE WHEN discount_applied > 0
        THEN 1 END) * 100.0 /
        COUNT(*), 2)                                    AS pct_discounted
FROM transactions;

--- Quantity per order
SELECT
    MIN(quantity)               AS min_qty,
    MAX(quantity)               AS max_qty,
    ROUND(AVG(quantity), 1)     AS avg_qty
FROM transactions;


--------------- VALIDATE TABLE JOINS --------------------

--- Transactions --> customers
SELECT COUNT(*) AS orphan_transactions
FROM transactions t
LEFT JOIN customers c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

--- Transactions --> products
SELECT COUNT(*) AS orphan_transactions
FROM transactions t
LEFT JOIN products p ON t.product_id = p.product_id
WHERE p.product_id IS NULL;
