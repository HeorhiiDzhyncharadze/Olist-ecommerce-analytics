-- =========================================================
-- Revenue by Product Category
-- Purpose:
--   Analyze total item-level revenue by product category
-- Grain of source data:
--   1 row = 1 order item
-- Notes:
--   Revenue is calculated using item price, not payment_value,
--   to avoid duplication caused by multiple payment rows per order.
-- =========================================================

WITH order_items_enriched AS (
    SELECT
        oi.order_id,
        oi.product_id,
        oi.price,

        -- Original category name in Portuguese
        p.product_category_name,

        -- English category name for reporting
        t.product_category_name_english

    FROM olist.olist_order_items_dataset oi

    -- Join products to get category information
    JOIN olist.olist_products_dataset p
        ON oi.product_id = p.product_id

    -- Join translation table to make categories readable in English
    LEFT JOIN olist.product_category_name_translation t
        ON p.product_category_name = t.product_category_name
)

SELECT
    -- Replace NULL category names with 'unknown' for reporting clarity
    COALESCE(product_category_name_english, 'unknown') AS category,

    -- Total item-level revenue by category
    SUM(price) AS total_revenue

FROM order_items_enriched

GROUP BY COALESCE(product_category_name_english, 'unknown')
ORDER BY total_revenue DESC;
