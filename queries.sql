-- Question 11: Last transaction for each day
SELECT id, created_at, transaction_value
FROM (
    SELECT id, created_at, transaction_value,
           ROW_NUMBER() OVER (PARTITION BY DATE(created_at) ORDER BY created_at DESC) AS rn
    FROM transactions
) t
WHERE rn = 1
ORDER BY created_at;

-- Question 15: CTR vs Search Result Rating Analysis
-- This query groups search results by rating and calculates CTR for each rating bucket
-- to determine if there's a correlation between search result rating and clickthrough rate
SELECT 
    rating,
    COUNT(*) AS total_results,
    SUM(clicks) AS total_clicks,
    SUM(impressions) AS total_impressions,
    ROUND(SUM(clicks) * 100.0 / SUM(impressions), 2) AS ctr_percentage
FROM search_results
GROUP BY rating
ORDER BY rating DESC;

-- Alternative approach: Using rating buckets for clearer visualization
-- Useful if ratings are continuous and you want to see CTR trends across rating ranges
SELECT 
    CASE 
        WHEN rating >= 4.5 THEN '4.5 - 5.0 (Excellent)'
        WHEN rating >= 4.0 THEN '4.0 - 4.5 (Very Good)'
        WHEN rating >= 3.0 THEN '3.0 - 4.0 (Good)'
        WHEN rating >= 2.0 THEN '2.0 - 3.0 (Fair)'
        ELSE '0 - 2.0 (Poor)'
    END AS rating_bucket,
    COUNT(*) AS total_results,
    SUM(clicks) AS total_clicks,
    SUM(impressions) AS total_impressions,
    ROUND(SUM(clicks) * 100.0 / SUM(impressions), 2) AS ctr_percentage
FROM search_results
GROUP BY 
    CASE 
        WHEN rating >= 4.5 THEN '4.5 - 5.0 (Excellent)'
        WHEN rating >= 4.0 THEN '4.0 - 4.5 (Very Good)'
        WHEN rating >= 3.0 THEN '3.0 - 4.0 (Good)'
        WHEN rating >= 2.0 THEN '2.0 - 3.0 (Fair)'
        ELSE '0 - 2.0 (Poor)'
    END
ORDER BY 
    CASE 
        WHEN rating_bucket = '4.5 - 5.0 (Excellent)' THEN 1
        WHEN rating_bucket = '4.0 - 4.5 (Very Good)' THEN 2
        WHEN rating_bucket = '3.0 - 4.0 (Good)' THEN 3
        WHEN rating_bucket = '2.0 - 3.0 (Fair)' THEN 4
        ELSE 5
    END;

-- Setup: Create tables and insert data
CREATE TABLE your_dataset.account (
    account_id INTEGER,
    first_seen TIMESTAMP,
    registration_timestamp TIMESTAMP
);

INSERT INTO your_dataset.account VALUES
    (123, '2020-01-01 01:01:01', '2020-01-02 02:02:02'),
    (125, '2020-05-01 01:01:01', NULL);

CREATE TABLE your_dataset.transactions (
    transaction_id STRING,
    account_id INTEGER,
    usd FLOAT64,
    transaction_time TIMESTAMP
);

INSERT INTO your_dataset.transactions VALUES
    ('aaa', 123, 99.99, '2021-01-01 01:01:01'),
    ('aab', 123, 9.99, '2021-01-02 01:01:01'),
    ('aac', 125, 0.99, '2021-01-03 01:01:01');

-- Question 1: Find Date of the very first transaction per user
SELECT 
    account_id,
    MIN(transaction_time) AS first_transaction_date
FROM your_dataset.transactions
GROUP BY account_id
ORDER BY account_id;

-- Question 2: Find How many users made their first purchase at 2021-01-01
WITH cte_first_transaction AS (
    SELECT 
        account_id,
        MIN(transaction_time) AS first_transactions
    FROM your_dataset.transactions
    GROUP BY account_id
),
purchases_on_2021_01_01 AS (
    SELECT 
        account_id
    FROM first_purchase
    WHERE DATE(first_transaction_date) = '2021-01-01'
)
SELECT 
    COUNT(DISTINCT account_id) AS user_with_first_purchase
FROM cte_first_transaction
WHERE DATE(first_transactions) = '2021-01-01';

-- Question 3: Find How much revenue (sum of usd) did users bring within first 7 days after registration
SELECT 
    a.account_id,
    SUM(t.usd) AS revenue_within_7_days
FROM your_dataset.account a
LEFT JOIN your_dataset.transactions t 
    ON a.account_id = t.account_id
    AND t.transaction_time <= TIMESTAMP_ADD(a.registration_timestamp, INTERVAL 7 DAY)
    AND a.registration_timestamp IS NOT NULL
GROUP BY a.account_id
ORDER BY a.account_id;

-- Alternative: Total revenue across all users within 7 days of registration
SELECT 
    SUM(t.usd) AS total_revenue_7_days_post_registration
FROM your_dataset.account a
INNER JOIN your_dataset.transactions t 
    ON a.account_id = t.account_id
WHERE a.registration_timestamp IS NOT NULL
    AND t.transaction_time <= TIMESTAMP_ADD(a.registration_timestamp, INTERVAL 7 DAY);

-- Question 4: Suggested Metrics to Calculate
-- 1. User Activation Rate: % of registered users who make at least one transaction
-- 2. Time to First Purchase: Days between registration and first transaction
-- 3. Customer Lifetime Value (CLV): Total revenue per user
-- 4. Average Order Value (AOV): Average transaction amount per user
-- 5. Purchase Frequency: Number of transactions per user
-- 6. Revenue Within 7/30/90 days: Revenue generated in critical time windows
-- 7. Churn Rate: Users who never made a purchase vs. registered users

-- Implementation of suggested metrics:
SELECT 
    a.account_id,
    CASE WHEN t.account_id IS NOT NULL THEN 1 ELSE 0 END AS is_active,
    TIMESTAMP_DIFF(MIN(t.transaction_time), a.registration_timestamp, DAY) AS days_to_first_purchase,
    COUNT(DISTINCT t.transaction_id) AS purchase_frequency,
    ROUND(SUM(t.usd), 2) AS customer_lifetime_value,
    ROUND(AVG(t.usd), 2) AS average_order_value
FROM your_dataset.account a
LEFT JOIN your_dataset.transactions t ON a.account_id = t.account_id
WHERE a.registration_timestamp IS NOT NULL
GROUP BY a.account_id
ORDER BY a.account_id;
