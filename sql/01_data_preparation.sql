-- =========================================================
-- Data Preparation
--
-- Purpose:
-- Prepare core tables for analysis:
-- - validate schema and column types
-- - convert raw purchase datetime text into timestamp format
-- - perform basic data quality checks
-- - validate table grain before joins
-- =========================================================


-- ---------------------------------------------------------
-- Query 1
-- Check source and cleaned purchase timestamp columns
-- ---------------------------------------------------------
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'olist'
  AND table_name = 'olist_orders_dataset'
  AND column_name IN ('order_purchase_timestamp', 'order_purchase_ts');


-- ---------------------------------------------------------
-- Query 2
-- Add a clean timestamp column for purchase datetime
-- ---------------------------------------------------------
ALTER TABLE olist.olist_orders_dataset
ADD COLUMN IF NOT EXISTS order_purchase_ts timestamp without time zone;


-- ---------------------------------------------------------
-- Query 3
-- Populate the cleaned timestamp column from the raw text field
-- ---------------------------------------------------------
UPDATE olist.olist_orders_dataset
SET order_purchase_ts = NULLIF(order_purchase_timestamp, '')::timestamp
WHERE order_purchase_ts IS NULL;


-- ---------------------------------------------------------
-- Query 4
-- Validate that timestamp conversion was successful
-- ---------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    COUNT(order_purchase_ts) AS parsed_rows,
    COUNT(*) - COUNT(order_purchase_ts) AS null_ts_rows
FROM olist.olist_orders_dataset;


-- ---------------------------------------------------------
-- Query 5
-- Grain check: orders table
--
-- Expected grain:
-- 1 row = 1 order
-- ---------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders_cnt
FROM olist.olist_orders_dataset;


-- ---------------------------------------------------------
-- Query 6
-- Grain check: order_items table
--
-- Expected grain:
-- 1 row = 1 order item
-- Multiple rows per order_id are expected
-- ---------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders_cnt
FROM olist.olist_order_items_dataset;


-- ---------------------------------------------------------
-- Query 7
-- Grain check: order_payments table
--
-- Expected grain:
-- 1 row = 1 payment record or installment
-- Multiple rows per order_id are expected
-- ---------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders_cnt
FROM olist.olist_order_payments_dataset;
