-- =========================================================
-- Delivery Performance Analysis
--
-- Purpose:
-- Analyze delivery performance and logistics efficiency.
--
-- Business questions:
-- 1. How long does delivery take on average?
-- 2. What share of deliveries are late?
-- 3. How severe are delivery delays?
-- =========================================================


-- ---------------------------------------------------------
-- Query 9.1
-- Delivery time analysis
--
-- Metric:
-- delivery_days =
-- actual_delivery_date - purchase_date
--
-- Only delivered orders are included
-- ---------------------------------------------------------

WITH order_delivery_days AS (
    SELECT
        DATE_PART(
            'day',
            NULLIF(order_delivered_customer_date, '')::timestamp
            - order_purchase_ts
        )::numeric AS delivery_days

    FROM olist.olist_orders_dataset

    WHERE order_status = 'delivered'
      AND NULLIF(order_delivered_customer_date, '') IS NOT NULL
)

SELECT
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    MIN(delivery_days) AS min_delivery_days,
    MAX(delivery_days) AS max_delivery_days
FROM order_delivery_days;



-- ---------------------------------------------------------
-- Query 9.2
-- Late delivery rate
--
-- Late delivery =
-- actual_delivery_date > estimated_delivery_date
-- ---------------------------------------------------------

SELECT
    COUNT(order_id) AS total_orders,

    SUM(
        CASE
            WHEN NULLIF(order_delivered_customer_date, '')::timestamp
               > NULLIF(order_estimated_delivery_date, '')::timestamp
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        SUM(
            CASE
                WHEN NULLIF(order_delivered_customer_date, '')::timestamp
                   > NULLIF(order_estimated_delivery_date, '')::timestamp
                THEN 1
                ELSE 0
            END
        )::numeric
        / COUNT(order_id),
        4
    ) AS late_delivery_rate

FROM olist.olist_orders_dataset

WHERE order_status = 'delivered'
  AND NULLIF(order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(order_estimated_delivery_date, '') IS NOT NULL;



-- ---------------------------------------------------------
-- Query 9.3
-- Delay severity analysis
--
-- Metric:
-- delay_days =
-- actual_delivery_date - estimated_delivery_date
--
-- Only late deliveries are included
-- ---------------------------------------------------------

WITH order_delay_days AS (
    SELECT
        DATE_PART(
            'day',
            NULLIF(order_delivered_customer_date, '')::timestamp
            - NULLIF(order_estimated_delivery_date, '')::timestamp
        )::numeric AS delay_days

    FROM olist.olist_orders_dataset

    WHERE order_status = 'delivered'
      AND NULLIF(order_delivered_customer_date, '') IS NOT NULL
      AND NULLIF(order_estimated_delivery_date, '') IS NOT NULL
      AND NULLIF(order_delivered_customer_date, '')::timestamp
          > NULLIF(order_estimated_delivery_date, '')::timestamp
)

SELECT
    ROUND(AVG(delay_days), 2) AS avg_delay_days,
    MAX(delay_days) AS max_delay_days
FROM order_delay_days;
