-- =========================================================
-- Category Revenue Share and Pareto Analysis
-- Purpose:
--   1. Measure revenue contribution by product category
--   2. Calculate cumulative revenue share
--   3. Identify how many top categories generate ~80% of total revenue
--
-- Notes:
--   - Revenue is calculated at item level using item price
--   - NULL category names are replaced with 'unknown'
--   - Window functions are used for revenue share and cumulative share
-- =========================================================


-- ---------------------------------------------------------
-- Query 1: Categories contributing to the first ~80% of revenue
-- This query returns all categories included before cumulative
-- revenue share exceeds 80%.
-- ---------------------------------------------------------

WITH order_items_enriched AS (
    SELECT
        oi.order_id,
        oi.product_id,
        oi.price,

        -- Original product category name (Portuguese)
        p.product_category_name,

        -- English translation for reporting
        t.product_category_name_english

    FROM olist.olist_order_items_dataset oi

    -- Join products table to retrieve category information
    JOIN olist.olist_products_dataset p
        ON oi.product_id = p.product_id

    -- Join translation table to convert category names into English
    LEFT JOIN olist.product_category_name_translation t
        ON p.product_category_name = t.product_category_name
),

category_revenue AS (
    SELECT
        -- Replace missing category names with 'unknown'
        COALESCE(product_category_name_english, 'unknown') AS category,

        -- Total item-level revenue by category
        SUM(price)::numeric AS total_revenue

    FROM order_items_enriched
    GROUP BY COALESCE(product_category_name_english, 'unknown')
),

category_share AS (
    SELECT
        category,
        total_revenue,

        -- Revenue share of each category in total revenue
        ROUND(
            total_revenue / NULLIF(SUM(total_revenue) OVER (), 0),
            6
        ) AS revenue_share,

        -- Running cumulative revenue share sorted from largest to smallest category
        ROUND(
            SUM(total_revenue) OVER (ORDER BY total_revenue DESC)
            / NULLIF(SUM(total_revenue) OVER (), 0),
            6
        ) AS cumulative_share

    FROM category_revenue
)

SELECT
    category,
    total_revenue,
    revenue_share,
    cumulative_share,

    -- Rank categories by revenue contribution
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS category_rank

FROM category_share

-- Keep only categories included before cumulative share exceeds 80%
WHERE cumulative_share <= 0.8

ORDER BY total_revenue DESC;



-- ---------------------------------------------------------
-- Query 2: Minimum number of categories needed to reach 80% revenue
-- This query returns the first category where cumulative revenue
-- share reaches or exceeds 80%.
-- ---------------------------------------------------------

WITH order_items_enriched AS (
    SELECT
        oi.order_id,
        oi.product_id,
        oi.price,
        p.product_category_name,
        t.product_category_name_english
    FROM olist.olist_order_items_dataset oi
    JOIN olist.olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN olist.product_category_name_translation t
        ON p.product_category_name = t.product_category_name
),

category_revenue AS (
    SELECT
        COALESCE(product_category_name_english, 'unknown') AS category,
        SUM(price)::numeric AS total_revenue
    FROM order_items_enriched
    GROUP BY COALESCE(product_category_name_english, 'unknown')
),

category_share AS (
    SELECT
        category,
        total_revenue,

        -- Revenue share of each category
        ROUND(
            total_revenue / NULLIF(SUM(total_revenue) OVER (), 0),
            6
        ) AS revenue_share,

        -- Cumulative revenue share sorted by category revenue descending
        ROUND(
            SUM(total_revenue) OVER (ORDER BY total_revenue DESC)
            / NULLIF(SUM(total_revenue) OVER (), 0),
            6
        ) AS cumulative_share,

        -- Revenue rank of category
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS category_rank

    FROM category_revenue
)

SELECT *
FROM category_share

-- Return the first row where cumulative revenue reaches 80%
WHERE cumulative_share >= 0.8

ORDER BY category_rank
LIMIT 1;
