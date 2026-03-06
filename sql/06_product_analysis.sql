-- =========================================================
-- Product / Basket Analysis
-- Purpose:
--   Analyze order composition and basket size structure
--   to understand how revenue changes with number of items per order
-- =========================================================


-- ---------------------------------------------------------
-- Query 1: Order-level basket metrics
-- Builds a base table with:
--   - number of items per order
--   - revenue per order
-- Grain:
--   1 row = 1 order
-- ---------------------------------------------------------

WITH order_info AS (
    SELECT
        ood.order_id,

        -- Number of items in the order
        COUNT(ooid.order_item_id) AS items_per_order,

        -- Total item-level revenue per order
        SUM(ooid.price)::numeric AS order_revenue

    FROM olist.olist_orders_dataset ood
    JOIN olist.olist_order_items_dataset ooid
        USING (order_id)

    -- Keep only delivered orders
    WHERE ood.order_status = 'delivered'

    GROUP BY ood.order_id
)

SELECT
    order_id,
    items_per_order,
    order_revenue
FROM order_info
ORDER BY items_per_order DESC;



-- ---------------------------------------------------------
-- Query 2: Basket size bucket analysis
-- Groups orders into:
--   - 1 item
--   - 2 items
--   - 3+ items
--
-- Metrics:
--   - number of orders
--   - average order revenue
--   - average items per order
-- ---------------------------------------------------------

WITH order_info AS (
    SELECT
        ood.order_id,
        COUNT(ooid.order_item_id) AS items_per_order,
        SUM(ooid.price)::numeric AS order_revenue
    FROM olist.olist_orders_dataset ood
    JOIN olist.olist_order_items_dataset ooid
        USING (order_id)
    WHERE ood.order_status = 'delivered'
    GROUP BY ood.order_id
),

bucket_info AS (
    SELECT
        order_id,
        order_revenue,
        items_per_order,

        -- Create basket size buckets
        CASE
            WHEN items_per_order = 1 THEN '1 item'
            WHEN items_per_order = 2 THEN '2 items'
            ELSE '3+ items'
        END AS items_bucket

    FROM order_info
)

SELECT
    items_bucket,

    -- Number of orders in each basket bucket
    COUNT(order_id) AS order_cnt,

    -- Average revenue per order in each bucket
    ROUND(AVG(order_revenue), 2) AS avg_order_revenue,

    -- Average number of items in each bucket
    ROUND(AVG(items_per_order), 2) AS avg_items_per_order

FROM bucket_info
GROUP BY items_bucket

-- Custom sort order for readability
ORDER BY
    CASE
        WHEN items_bucket = '1 item' THEN 1
        WHEN items_bucket = '2 items' THEN 2
        ELSE 3
    END;
