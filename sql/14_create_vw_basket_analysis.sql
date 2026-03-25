DROP VIEW IF EXISTS olist.vw_basket_analysis;

CREATE VIEW olist.vw_basket_analysis AS

WITH order_info AS (
    SELECT
        ood.order_id,
        COUNT(ooid.order_item_id) AS items_per_order,
        ROUND(SUM(ooid.price)::numeric, 2) AS order_revenue
    FROM olist.olist_orders_dataset ood
    JOIN olist.olist_order_items_dataset ooid
        USING (order_id)
    WHERE ood.order_status = 'delivered'
    GROUP BY ood.order_id
)

SELECT
    order_id,
    items_per_order,
    order_revenue,
    CASE
        WHEN items_per_order = 1 THEN '1 item'
        WHEN items_per_order = 2 THEN '2 items'
        ELSE '3+ items'
    END AS items_bucket
FROM order_info
ORDER BY items_per_order DESC, order_revenue DESC;
