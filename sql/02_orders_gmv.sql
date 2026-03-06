-- =========================================================
-- Order-level GMV
-- Purpose:
--   Aggregate payment data to order level
--   to avoid duplicated revenue caused by multiple payment rows
-- =========================================================

SELECT
    order_id,
    SUM(payment_value) AS order_gmv
FROM olist.olist_order_payments_dataset
GROUP BY order_id;
