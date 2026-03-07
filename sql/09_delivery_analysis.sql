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
-- Delivery time per order
--
-- Metric:
-- delivery_days =
-- order_delivered_customer_date - order_purchase_ts
--
-- Only delivered orders are used
-- ---------------------------------------------------------

WITH order_delivery_days AS (
    SELECT
        order_id,
        order_purchase_ts,

        NULLIF(order_delivered_customer_date, '')::timestamp AS delivery_date,

        DATE_PART(
            'day',
            NULLIF(order_delivered_customer_date, '')::timestamp
            - order_purchase_ts
        )::numeric AS delivery_days,

        order_status

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
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        SUM(
            CASE
                WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        )::numeric
        / COUNT(order_id),
        2
    ) AS late_delivery_rate

FROM olist.olist_orders_dataset

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;



-- ---------------------------------------------------------
-- Query 9.3
-- Delay severity analysis
--
-- delay_days =
-- actual_delivery_date - estimated_delivery_date
--
-- Only late deliveries are included
-- ---------------------------------------------------------

WITH order_delay_days AS (
    SELECT
        order_id,

        NULLIF(order_delivered_customer_date, '')::timestamp AS delivery_date,

        NULLIF(order_estimated_delivery_date, '')::timestamp AS estimated_date,

        DATE_PART(
            'day',
            NULLIF(order_delivered_customer_date, '')::timestamp
            -
            NULLIF(order_estimated_delivery_date, '')::timestamp
        )::numeric AS delay_days,

        order_status

    FROM olist.olist_orders_dataset

    WHERE order_status = 'delivered'
      AND NULLIF(order_delivered_customer_date, '') IS NOT NULL
      AND NULLIF(order_estimated_delivery_date, '') IS NOT NULL
      AND order_delivered_customer_date > order_estimated_delivery_date
)

SELECT
    ROUND(AVG(delay_days), 2) AS avg_delay_days,
    MAX(delay_days) AS max_delay_days
FROM order_delay_days;
