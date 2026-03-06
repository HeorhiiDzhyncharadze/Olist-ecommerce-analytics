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

with order_items_enriched as (
    select
        oi.order_id,
        oi.product_id,
        oi.price,

        -- Original category name in Portuguese
        p.product_category_name,

        -- English category name for reporting
        t.product_category_name_english

    from olist.olist_order_items_dataset oi

    -- Join products to get category information
    join olist.olist_products_dataset p
        on oi.product_id = p.product_id

    -- Join translation table to make categories readable in English
    left join olist.product_category_name_translation t
        on p.product_category_name = t.product_category_name
)

select
    -- Replace NULL category names with 'unknown' for reporting clarity
    COALESCE(product_category_name_english, 'unknown') as category,

    -- Total item-level revenue by category
    SUM(price) as total_revenue

from order_items_enriched

group by COALESCE(product_category_name_english, 'unknown')
order by total_revenue desc;
