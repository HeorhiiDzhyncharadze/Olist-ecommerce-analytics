DROP VIEW IF EXISTS olist.vw_monthly_kpis;

CREATE VIEW olist.vw_monthly_kpis AS

WITH delivered_orders AS (

    SELECT
        order_id,
        customer_id,
        date_trunc('month', order_purchase_ts)::date AS order_month
    FROM olist.olist_orders_dataset
    WHERE order_status = 'delivered'
),

order_revenue AS (

    SELECT
        order_id,
        SUM(price) AS order_revenue
    FROM olist.olist_order_items_dataset
    GROUP BY order_id
)

SELECT
    d.order_month,
    COUNT(DISTINCT d.order_id) AS orders_cnt,
    COUNT(DISTINCT d.customer_id) AS customers_cnt,
    ROUND(SUM(r.order_revenue)::numeric, 2) AS total_revenue,
    ROUND((SUM(r.order_revenue) / NULLIF(COUNT(DISTINCT d.order_id), 0))::numeric, 2) AS avg_order_value
FROM delivered_orders d
JOIN order_revenue r
    USING (order_id)
GROUP BY d.order_month
ORDER BY d.order_month;
