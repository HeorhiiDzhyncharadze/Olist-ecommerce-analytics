-- =========================================================
-- Monthly Revenue Trend for Top 5 Categories
--
-- Purpose:
-- Analyze monthly revenue dynamics for the top 5 product
-- categories by overall delivered revenue.
--
-- Notes:
-- - Revenue is calculated at item level using item price
-- - Only delivered orders are included
-- - Top 5 categories are selected based on total revenue
--   across the full dataset
-- =========================================================

WITH order_items_enriched AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_ts) AS order_month,
        oi.price,
        p.product_category_name,
        t.product_category_name_english

    FROM olist.olist_order_items_dataset oi

    JOIN olist.olist_products_dataset p
        USING (product_id)

    JOIN olist.olist_orders_dataset o
        USING (order_id)

    LEFT JOIN olist.product_category_name_translation t
        USING (product_category_name)

    -- Keep only completed (delivered) orders
    WHERE o.order_status = 'delivered'
),

monthly_category_revenue AS (
    SELECT
        order_month,

        -- Replace missing category names with 'unknown'
        COALESCE(product_category_name_english, 'unknown') AS category,

        -- Monthly item-level revenue by category
        SUM(price)::numeric AS total_revenue

    FROM order_items_enriched

    GROUP BY
        order_month,
        COALESCE(product_category_name_english, 'unknown')
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
    mcr.order_month,
    mcr.category,
    mcr.total_revenue

FROM monthly_category_revenue mcr

JOIN top_5_categories t5
    USING (category)

ORDER BY
    mcr.order_month,
    mcr.total_revenue DESC;
