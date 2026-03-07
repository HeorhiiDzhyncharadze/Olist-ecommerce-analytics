-- =========================================================
-- Cohort Retention Analysis
-- Purpose:
--   Analyze customer retention by monthly acquisition cohort
--   and measure how many customers return in subsequent months
--
-- Business question:
--   Do customers come back after their first purchase month?
--
-- Notes:
--   - Only delivered orders are included
--   - Customer-level analysis uses customer_unique_id
--   - Cohort is defined by the month of first delivered order
-- =========================================================


-- ---------------------------------------------------------
-- Query 1: Cohort retention base table
-- Returns:
--   cohort_month
--   cohort_index
--   customers_cnt
--   cohort_size
--   retention_rate
--
-- Grain:
--   1 row = 1 cohort_month x 1 cohort_index
-- ---------------------------------------------------------

WITH customer_orders AS (
    SELECT
        ocd.customer_unique_id,

        -- Purchase month of each delivered order
        DATE_TRUNC('month', ood.order_purchase_ts) AS order_month

    FROM olist.olist_orders_dataset ood
    JOIN olist.olist_customers_dataset ocd
        USING (customer_id)

    -- Keep only delivered orders
    WHERE ood.order_status = 'delivered'

    -- Deduplicate at customer-month level
    GROUP BY ocd.customer_unique_id, DATE_TRUNC('month', ood.order_purchase_ts)
),

first_orders AS (
    SELECT
        customer_unique_id,

        -- First delivered purchase month of each customer
        MIN(order_month) AS first_order_month

    FROM customer_orders
    GROUP BY customer_unique_id
),

cohort_base AS (
    SELECT
        co.customer_unique_id,
        fo.first_order_month,
        co.order_month,

        -- Number of months since the first purchase month
        (
            EXTRACT(YEAR FROM co.order_month) - EXTRACT(YEAR FROM fo.first_order_month)
        ) * 12
        +
        (
            EXTRACT(MONTH FROM co.order_month) - EXTRACT(MONTH FROM fo.first_order_month)
        ) AS cohort_index

    FROM customer_orders co
    JOIN first_orders fo
        USING (customer_unique_id)
),

cohort_table AS (
    SELECT
        -- Cohort month = first purchase month
        first_order_month AS cohort_month,
        cohort_index,

        -- Active customers in each cohort month / cohort index combination
        COUNT(DISTINCT customer_unique_id) AS customers_cnt

    FROM cohort_base
    GROUP BY first_order_month, cohort_index
),

cohort_size AS (
    SELECT
        cohort_month,

        -- Cohort size is the number of customers at month 0
        customers_cnt AS cohort_size

    FROM cohort_table
    WHERE cohort_index = 0
),

cohort_retention AS (
    SELECT
        ct.cohort_month,
        ct.cohort_index,
        ct.customers_cnt,
        cs.cohort_size,

        -- Retention rate = active customers / original cohort size
        ROUND(ct.customers_cnt::numeric / cs.cohort_size, 4) AS retention_rate

    FROM cohort_table ct
    JOIN cohort_size cs
        USING (cohort_month)
)

SELECT
    cohort_month,
    cohort_index,
    customers_cnt,
    cohort_size,
    retention_rate

FROM cohort_retention
ORDER BY cohort_month, cohort_index;



-- ---------------------------------------------------------
-- Query 2: Pivoted cohort retention matrix
-- Returns monthly retention by cohort in matrix format
--
-- Example:
--   m0 = retention in acquisition month
--   m1 = retention after 1 month
--   m2 = retention after 2 months
-- ---------------------------------------------------------

WITH customer_orders AS (
    SELECT
        ocd.customer_unique_id,
        DATE_TRUNC('month', ood.order_purchase_ts) AS order_month
    FROM olist.olist_orders_dataset ood
    JOIN olist.olist_customers_dataset ocd
        USING (customer_id)
    WHERE ood.order_status = 'delivered'
    GROUP BY ocd.customer_unique_id, DATE_TRUNC('month', ood.order_purchase_ts)
),

first_orders AS (
    SELECT
        customer_unique_id,
        MIN(order_month) AS first_order_month
    FROM customer_orders
    GROUP BY customer_unique_id
),

cohort_base AS (
    SELECT
        co.customer_unique_id,
        fo.first_order_month,
        co.order_month,
        (
            EXTRACT(YEAR FROM co.order_month) - EXTRACT(YEAR FROM fo.first_order_month)
        ) * 12
        +
        (
            EXTRACT(MONTH FROM co.order_month) - EXTRACT(MONTH FROM fo.first_order_month)
        ) AS cohort_index
    FROM customer_orders co
    JOIN first_orders fo
        USING (customer_unique_id)
),

cohort_table AS (
    SELECT
        first_order_month AS cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_unique_id) AS customers_cnt
    FROM cohort_base
    GROUP BY first_order_month, cohort_index
),

cohort_size AS (
    SELECT
        cohort_month,
        customers_cnt AS cohort_size
    FROM cohort_table
    WHERE cohort_index = 0
),

cohort_retention AS (
    SELECT
        ct.cohort_month,
        ct.cohort_index,
        ct.customers_cnt,
        cs.cohort_size,
        ROUND(ct.customers_cnt::numeric / cs.cohort_size, 4) AS retention_rate
    FROM cohort_table ct
    JOIN cohort_size cs
        USING (cohort_month)
)

SELECT
    cohort_month,

    COALESCE(MAX(CASE WHEN cohort_index = 0 THEN retention_rate END), 0) AS m0,
    COALESCE(MAX(CASE WHEN cohort_index = 1 THEN retention_rate END), 0) AS m1,
    COALESCE(MAX(CASE WHEN cohort_index = 2 THEN retention_rate END), 0) AS m2,
    COALESCE(MAX(CASE WHEN cohort_index = 3 THEN retention_rate END), 0) AS m3,
    COALESCE(MAX(CASE WHEN cohort_index = 4 THEN retention_rate END), 0) AS m4,
    COALESCE(MAX(CASE WHEN cohort_index = 5 THEN retention_rate END), 0) AS m5,
    COALESCE(MAX(CASE WHEN cohort_index = 6 THEN retention_rate END), 0) AS m6,
    COALESCE(MAX(CASE WHEN cohort_index = 7 THEN retention_rate END), 0) AS m7,
    COALESCE(MAX(CASE WHEN cohort_index = 8 THEN retention_rate END), 0) AS m8,
    COALESCE(MAX(CASE WHEN cohort_index = 9 THEN retention_rate END), 0) AS m9,
    COALESCE(MAX(CASE WHEN cohort_index = 10 THEN retention_rate END), 0) AS m10,
    COALESCE(MAX(CASE WHEN cohort_index = 11 THEN retention_rate END), 0) AS m11,
    COALESCE(MAX(CASE WHEN cohort_index = 12 THEN retention_rate END), 0) AS m12,
    COALESCE(MAX(CASE WHEN cohort_index = 13 THEN retention_rate END), 0) AS m13,
    COALESCE(MAX(CASE WHEN cohort_index = 14 THEN retention_rate END), 0) AS m14,
    COALESCE(MAX(CASE WHEN cohort_index = 15 THEN retention_rate END), 0) AS m15,
    COALESCE(MAX(CASE WHEN cohort_index = 16 THEN retention_rate END), 0) AS m16,
    COALESCE(MAX(CASE WHEN cohort_index = 17 THEN retention_rate END), 0) AS m17,
    COALESCE(MAX(CASE WHEN cohort_index = 18 THEN retention_rate END), 0) AS m18,
    COALESCE(MAX(CASE WHEN cohort_index = 19 THEN retention_rate END), 0) AS m19,
    COALESCE(MAX(CASE WHEN cohort_index = 20 THEN retention_rate END), 0) AS m20

FROM cohort_retention
GROUP BY cohort_month
ORDER BY cohort_month;
