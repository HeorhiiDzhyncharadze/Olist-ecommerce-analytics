-- =========================================================
-- Monthly Business KPIs
--
-- Purpose:
-- Analyze core business performance metrics by month.
--
-- Metrics calculated:
-- - total orders
-- - total revenue (GMV)
-- - average order value (AOV)
--
-- Grain of source data:
-- orders table = 1 row per order
-- order_items table = 1 row per order item
-- =========================================================


-- ---------------------------------------------------------
-- Step 1: Prepare delivered orders
-- ---------------------------------------------------------
WITH delivered_orders AS (

    SELECT
        order_id,
        date_trunc('month', order_purchase_ts) AS order_month

    FROM olist.olist_orders_dataset

    WHERE order_status = 'delivered'
),


-- ---------------------------------------------------------
-- Step 2: Calculate revenue per order
-- ---------------------------------------------------------
order_revenue AS (

    SELECT
        order_id,
        SUM(price) AS order_revenue

    FROM olist.olist_order_items_dataset

    GROUP BY order_id
)


-- ---------------------------------------------------------
-- Step 3: Monthly KPI aggregation
-- ---------------------------------------------------------
SELECT
    d.order_month,

    -- Number of delivered orders
    COUNT(DISTINCT d.order_id) AS orders_cnt,

    -- Total revenue
    SUM(r.order_revenue) AS total_revenue,

    -- Average order value
    ROUND(SUM(r.order_revenue) / COUNT(DISTINCT d.order_id), 2) AS avg_order_value

FROM delivered_orders d

JOIN order_revenue r
    USING (order_id)

GROUP BY d.order_month
ORDER BY d.order_month;
