DROP VIEW IF EXISTS olist.vw_customer_analysis;

CREATE VIEW olist.vw_customer_analysis AS

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT oi.order_id) AS orders_cnt,
        ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
    FROM olist.olist_orders_dataset o
    JOIN olist.olist_customers_dataset c
        USING (customer_id)
    JOIN olist.olist_order_items_dataset oi
        USING (order_id)
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    orders_cnt,
    total_revenue,
    ROUND((total_revenue / NULLIF(orders_cnt, 0))::numeric, 2) AS avg_revenue_per_order,
    CASE
        WHEN orders_cnt = 1 THEN 'one_time'
        ELSE 'repeat'
    END AS customer_type
FROM customer_orders
ORDER BY total_revenue DESC;
