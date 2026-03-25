DROP VIEW IF EXISTS olist.vw_cohort_analysis;

CREATE VIEW olist.vw_cohort_analysis AS

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_ts)::date AS order_month
    FROM olist.olist_orders_dataset o
    JOIN olist.olist_customers_dataset c
        USING (customer_id)
    WHERE o.order_status = 'delivered'
    GROUP BY
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_ts)::date
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
            (EXTRACT(YEAR FROM co.order_month) - EXTRACT(YEAR FROM fo.first_order_month)) * 12
            +
            (EXTRACT(MONTH FROM co.order_month) - EXTRACT(MONTH FROM fo.first_order_month))
        )::int AS cohort_index
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
)

SELECT
    ct.cohort_month,
    ct.cohort_index,
    ct.customers_cnt,
    cs.cohort_size,
    ROUND(ct.customers_cnt::numeric / cs.cohort_size, 4) AS retention_rate
FROM cohort_table ct
JOIN cohort_size cs
    USING (cohort_month)
ORDER BY ct.cohort_month, ct.cohort_index;
