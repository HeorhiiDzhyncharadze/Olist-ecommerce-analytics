-- =========================================================
-- Monthly Revenue Trend for Top 5 Categories
-- Purpose:
--   Analyze monthly revenue dynamics for the top 5 product
--   categories by overall delivered revenue
--
-- Notes:
--   - Revenue is calculated at item level using item price
--   - Only delivered orders are included
--   - Top 5 categories are selected based on total revenue
--     across the full dataset
-- =========================================================

WITH order_items_enriched AS (
    SELECT
        DATE_TRUNC('month', order_purchase_ts) AS month,
        ooid.order_id,
        ooid.product_id,
        ooid.price,
        opd.product_category_name,
        pcnt.product_category_name_english
    FROM olist.olist_order_items_dataset ooid
    JOIN olist.olist_products_dataset opd
        USING (product_id)
    JOIN olist.olist_orders_dataset ood
        USING (order_id)
    LEFT JOIN olist.product_category_name_translation pcnt
        USING (product_category_name)

    -- Keep only completed (delivered) orders
    WHERE ood.order_status = 'delivered'
),

monthly_category_revenue AS (
    SELECT
        month,

        -- Replace missing category names with 'unknown'
        COALESCE(product_category_name_english, 'unknown') AS category,

        -- Monthly item-level revenue by category
        SUM(price)::numeric AS total_revenue
    FROM order_items_enriched
    GROUP BY month, COALESCE(product_category_name_english, 'unknown')
),

top_5_categories AS (
    SELECT
        category,
        SUM(total_revenue) AS overall_revenue
    FROM monthly_category_revenue
    GROUP BY category
    ORDER BY overall_revenue DESC
    LIMIT 5
)

SELECT
    mcr.month,
    mcr.category,
    mcr.total_revenue
FROM monthly_category_revenue mcr
JOIN top_5_categories top5
    USING (category)
ORDER BY mcr.month, mcr.total_revenue DESC;
