DROP VIEW IF EXISTS olist.vw_revenue_by_category;

CREATE VIEW olist.vw_revenue_by_category AS

WITH order_items_enriched AS (
    SELECT
        oi.order_id,
        oi.product_id,
        oi.price,
        p.product_category_name,
        t.product_category_name_english
    FROM olist.olist_order_items_dataset oi
    JOIN olist.olist_products_dataset p
        USING (product_id)
    LEFT JOIN olist.product_category_name_translation t
        USING (product_category_name)
)

SELECT
    COALESCE(product_category_name_english, 'unknown') AS category,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT order_id) AS orders_cnt,
    ROUND(SUM(price)::numeric, 2) AS total_revenue,
    ROUND(AVG(price)::numeric, 2) AS avg_item_price
FROM order_items_enriched
GROUP BY COALESCE(product_category_name_english, 'unknown')
ORDER BY total_revenue DESC;
