-- RFM ANALYSIS
-- Project: Stratex Commerce | E-Commerce BI
-- Tool: SQLite / SQLiteStudio
-- Tables: customers, transactions


----------------- EXPLORE RECENCY DISTRIBUTION -----------------------------

-- Recency: days since last purchase, anchored to year-end
-- rather than today, ensures consistent year-over-year
-- comparison and prevents scores from shifting daily

--- Overall recency range per year

SELECT
    txn_year,
    MIN(recency_days)           AS min_recency,
    MAX(recency_days)           AS max_recency,
    ROUND(AVG(recency_days), 0) AS avg_recency
FROM (
    SELECT
        customer_id,
        strftime('%Y', MAX(transaction_date))   AS txn_year,
        CAST(
            julianday(
                (CAST(strftime('%Y', MAX(transaction_date)) AS INTEGER) + 1)
                || '-01-01'
            ) - julianday(MAX(transaction_date))
        AS INTEGER)                             AS recency_days
    FROM transactions
    WHERE status = 'completed'
    GROUP BY customer_id, strftime('%Y', transaction_date)
)
GROUP BY txn_year
ORDER BY txn_year;

--- Recency bucket breakdown
------- Decision: Thresholds at 30 / 60 / 90 / 180 days (based on natural distribution of the data)
SELECT
    txn_year,
    COUNT(CASE WHEN recency_days <= 30                          THEN 1 END) AS "0-30 days",
    COUNT(CASE WHEN recency_days > 30  AND recency_days <= 60   THEN 1 END) AS "31-60 days",
    COUNT(CASE WHEN recency_days > 60  AND recency_days <= 90   THEN 1 END) AS "61-90 days",
    COUNT(CASE WHEN recency_days > 90  AND recency_days <= 180  THEN 1 END) AS "91-180 days",
    COUNT(CASE WHEN recency_days > 180 AND recency_days <= 270  THEN 1 END) AS "181-270 days",
    COUNT(CASE WHEN recency_days > 270                          THEN 1 END) AS "270+ days"
FROM (
    SELECT
        customer_id,
        strftime('%Y', MAX(transaction_date))   AS txn_year,
        CAST(
            julianday(
                (CAST(strftime('%Y', MAX(transaction_date)) AS INTEGER) + 1)
                || '-01-01'
            ) - julianday(MAX(transaction_date))
        AS INTEGER)                             AS recency_days
    FROM transactions
    WHERE status = 'completed'
    GROUP BY customer_id, strftime('%Y', transaction_date)
)
GROUP BY txn_year
ORDER BY txn_year;


--------------------- EXPLORE FREQUENCY DISTRIBUTION -------------------------

--- Frequency bucket breakdown
------- Decision: Thresholds at 2 / 4 / 8 / 13 orders (based on natural distribution of the data)
SELECT
    COUNT(CASE WHEN frequency = 1                       THEN 1 END) AS "1 order",
    COUNT(CASE WHEN frequency >= 2  AND frequency <= 3  THEN 1 END) AS "2-3 orders",
    COUNT(CASE WHEN frequency >= 4  AND frequency <= 7  THEN 1 END) AS "4-7 orders",
    COUNT(CASE WHEN frequency >= 8  AND frequency <= 12 THEN 1 END) AS "8-12 orders",
    COUNT(CASE WHEN frequency >= 13                     THEN 1 END) AS "13+ orders"
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT transaction_id) AS frequency
    FROM transactions
    WHERE status = 'completed'
    GROUP BY customer_id
);


----------------- EXPLORE MONETARY DISTRIBUTION ---------------------------------


--- Monetary bucket breakdown
------- Decision: Thresholds at $50 / $200 / $500 / $1,000 (based on natural spend tiers in the data)

SELECT
    COUNT(CASE WHEN monetary < 50                           THEN 1 END) AS "Under $50",
    COUNT(CASE WHEN monetary >= 50   AND monetary < 200     THEN 1 END) AS "$50-199",
    COUNT(CASE WHEN monetary >= 200  AND monetary < 500     THEN 1 END) AS "$200-499",
    COUNT(CASE WHEN monetary >= 500  AND monetary < 1000    THEN 1 END) AS "$500-999",
    COUNT(CASE WHEN monetary >= 1000                        THEN 1 END) AS "$1000+"
FROM (
    SELECT
        customer_id,
        ROUND(SUM(total_amount), 2) AS monetary
    FROM transactions
    WHERE status = 'completed'
    GROUP BY customer_id
);


------------------------- FINAL RFM QUERY -------------------------------

------- Design decisions:

----------- 1. INNER JOIN: To include customers with completed purchases only

----------- 2. year_spine + CROSS JOIN: One row per customer per year
----------- to enable year-over-year segment comparison in Power BI

----------- 3. customer_txn pre-aggregation: All calculations done once upfront
----------- to avoid repeated subsequeries

----------- 4. Year-boundary recency: 2023 row uses last 2023 purchase,
----------- 2024 row uses last ever purchase, to prevent negative values

----------- 5. Cumulative frequency & monetary: 2024 row includes all
----------- transactions (2023 + 2024) to reflect total customer value at year-end

----------- 6. Customers who have transaction history in 2023 only will appear in 2024
-----------  with high recency --> correctly categorised in At Risk or Inactive segment

----------- 7. Segment score logic driven by recency & frequency as primary signals,
----------- monetary used selectively to identify high-value customers who have gone quiet


WITH year_spine AS (
    SELECT '2023' AS txn_year
    UNION ALL
    SELECT '2024'
),

customer_txn AS (
    SELECT
        customer_id,
        MAX(CASE WHEN strftime('%Y', transaction_date) <= '2023'
            THEN transaction_date END)              AS last_txn_2023,
        MAX(transaction_date)                       AS last_txn_2024,
        COUNT(DISTINCT CASE WHEN strftime('%Y', transaction_date) <= '2023'
            THEN transaction_id END)                AS frequency_2023,
        COUNT(DISTINCT transaction_id)              AS frequency_2024,
        ROUND(SUM(CASE WHEN strftime('%Y', transaction_date) <= '2023'
            THEN total_amount ELSE 0 END), 2)       AS monetary_2023,
        ROUND(SUM(total_amount), 2)                 AS monetary_2024,
        MAX(CASE WHEN strftime('%Y', transaction_date) = '2023'
            THEN 1 ELSE 0 END)                      AS bought_2023
    FROM transactions
    WHERE status = 'completed'
    GROUP BY customer_id
),

rfm_base AS (
    SELECT
        y.txn_year,
        c.customer_id,
        c.segment,
        CAST(
            julianday((CAST(y.txn_year AS INTEGER) + 1) || '-01-01') -
            julianday(
                CASE WHEN y.txn_year = '2023'
                     THEN ct.last_txn_2023
                     ELSE ct.last_txn_2024
                END
            )
        AS INTEGER)                                 AS recency_days,
        CASE WHEN y.txn_year = '2023'
             THEN ct.frequency_2023
             ELSE ct.frequency_2024
        END                                         AS frequency,
        CASE WHEN y.txn_year = '2023'
             THEN ct.monetary_2023
             ELSE ct.monetary_2024
        END                                         AS monetary
    FROM customers c
    INNER JOIN customer_txn ct
        ON c.customer_id = ct.customer_id
    CROSS JOIN year_spine y
    WHERE (y.txn_year = '2023' AND ct.bought_2023 = 1)
       OR (y.txn_year = '2024')
),

rfm_scored AS (
    SELECT
        customer_id,
        segment,
        txn_year,
        recency_days,
        frequency,
        monetary,
        CASE
            WHEN recency_days <= 30  THEN 5
            WHEN recency_days <= 60  THEN 4
            WHEN recency_days <= 90  THEN 3
            WHEN recency_days <= 180 THEN 2
            ELSE 1
        END AS r_score,
        CASE
            WHEN frequency >= 13 THEN 5
            WHEN frequency >= 8  THEN 4
            WHEN frequency >= 4  THEN 3
            WHEN frequency >= 2  THEN 2
            ELSE 1
        END AS f_score,
        CASE
            WHEN monetary >= 1000 THEN 5
            WHEN monetary >= 500  THEN 4
            WHEN monetary >= 200  THEN 3
            WHEN monetary >= 50   THEN 2
            ELSE 1
        END AS m_score
    FROM rfm_base
),

rfm_final AS (
    SELECT
        customer_id,
        segment,
        txn_year,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        (r_score + f_score + m_score) AS rfm_total_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
                THEN 'Champion'
            WHEN r_score >= 3 AND f_score >= 3
                THEN 'Loyal'
            WHEN r_score >= 3 AND f_score = 2
                THEN 'Potential Loyalist'
            WHEN r_score >= 3 AND f_score = 1
                THEN 'Promising'
            WHEN r_score <= 2 AND f_score >= 3
                THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 4
                THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 3
                THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2
                THEN 'Inactive'
            ELSE 'Unclassified'
        END AS rfm_segment
    FROM rfm_scored
)
SELECT
    customer_id,
    segment,
    txn_year,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    rfm_total_score,
    rfm_segment
FROM rfm_final
ORDER BY txn_year, rfm_total_score DESC; -- Exported as rfm_segments.csv for Power BI


--------------------- SEGMENT SUMMARY -----------------------------

--- Data sanity check:
---- 1. No customers in Unclassified
---- 2. Segment sizes are reasonable
---- 3. Average metrics align with segment expectations


WITH year_spine AS (
    SELECT '2023' AS txn_year UNION ALL SELECT '2024'
),
customer_txn AS (
    SELECT
        customer_id,
        MAX(CASE WHEN strftime('%Y', transaction_date) <= '2023'
            THEN transaction_date END)              AS last_txn_2023,
        MAX(transaction_date)                       AS last_txn_2024,
        COUNT(DISTINCT CASE WHEN strftime('%Y', transaction_date) <= '2023'
            THEN transaction_id END)                AS frequency_2023,
        COUNT(DISTINCT transaction_id)              AS frequency_2024,
        ROUND(SUM(CASE WHEN strftime('%Y', transaction_date) <= '2023'
            THEN total_amount ELSE 0 END), 2)       AS monetary_2023,
        ROUND(SUM(total_amount), 2)                 AS monetary_2024,
        MAX(CASE WHEN strftime('%Y', transaction_date) = '2023'
            THEN 1 ELSE 0 END)                      AS bought_2023
    FROM transactions
    WHERE status = 'completed'
    GROUP BY customer_id
),
rfm_base AS (
    SELECT
        y.txn_year, c.customer_id, c.segment,
        CAST(julianday((CAST(y.txn_year AS INTEGER) + 1) || '-01-01') -
             julianday(CASE WHEN y.txn_year = '2023' THEN ct.last_txn_2023
                            ELSE ct.last_txn_2024 END)
        AS INTEGER)                                 AS recency_days,
        CASE WHEN y.txn_year = '2023' THEN ct.frequency_2023
             ELSE ct.frequency_2024 END             AS frequency,
        CASE WHEN y.txn_year = '2023' THEN ct.monetary_2023
             ELSE ct.monetary_2024 END              AS monetary
    FROM customers c
    INNER JOIN customer_txn ct ON c.customer_id = ct.customer_id
    CROSS JOIN year_spine y
    WHERE (y.txn_year = '2023' AND ct.bought_2023 = 1)
       OR (y.txn_year = '2024')
),
rfm_scored AS (
    SELECT *,
        CASE WHEN recency_days <= 30  THEN 5
             WHEN recency_days <= 60  THEN 4
             WHEN recency_days <= 90  THEN 3
             WHEN recency_days <= 180 THEN 2
             ELSE 1 END                             AS r_score,
        CASE WHEN frequency >= 13 THEN 5
             WHEN frequency >= 8  THEN 4
             WHEN frequency >= 4  THEN 3
             WHEN frequency >= 2  THEN 2
             ELSE 1 END                             AS f_score,
        CASE WHEN monetary >= 1000 THEN 5
             WHEN monetary >= 500  THEN 4
             WHEN monetary >= 200  THEN 3
             WHEN monetary >= 50   THEN 2
             ELSE 1 END                             AS m_score
    FROM rfm_base
),
rfm_final AS (
    SELECT *,
        (r_score + f_score + m_score)               AS rfm_total_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champion'
            WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal'
            WHEN r_score >= 3 AND f_score = 2                   THEN 'Potential Loyalist'
            WHEN r_score >= 3 AND f_score = 1                   THEN 'Promising'
            WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 4 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2                  THEN 'Inactive'
            ELSE 'Unclassified'
        END                                         AS rfm_segment
    FROM rfm_scored
)
SELECT
    txn_year,
    rfm_segment,
    COUNT(*)                        AS customer_count,
    ROUND(AVG(monetary), 2)         AS avg_monetary,
    ROUND(AVG(frequency), 1)        AS avg_frequency,
    ROUND(AVG(recency_days), 0)     AS avg_recency_days
FROM rfm_final
GROUP BY txn_year, rfm_segment
ORDER BY txn_year, customer_count DESC;