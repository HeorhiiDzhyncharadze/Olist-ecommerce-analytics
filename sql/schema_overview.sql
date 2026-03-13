-- =========================================================
-- Schema Overview
--
-- Purpose:
-- Document the structure of the main tables used in the
-- Olist e-commerce analysis and validate table grain.
--
-- This file helps understand how the dataset is organized
-- before performing analytical queries.
-- =========================================================



-- ---------------------------------------------------------
-- Orders table
--
-- Expected grain:
-- 1 row = 1 order
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders
FROM olist.olist_orders_dataset;



-- ---------------------------------------------------------
-- Order items table
--
-- Expected grain:
-- 1 row = 1 product inside an order
-- Multiple rows per order_id are expected
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders
FROM olist.olist_order_items_dataset;



-- ---------------------------------------------------------
-- Customers table
--
-- Expected grain:
-- 1 row = 1 customer record
-- Multiple customer_id values may map to the same
-- customer_unique_id (same person placing multiple orders)
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS distinct_customers
FROM olist.olist_customers_dataset;



-- ---------------------------------------------------------
-- Products table
--
-- Expected grain:
-- 1 row = 1 product
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS distinct_products
FROM olist.olist_products_dataset;



-- ---------------------------------------------------------
-- Product category translation table
--
-- Maps Portuguese category names to English
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_category_name) AS distinct_categories
FROM olist.product_category_name_translation;
