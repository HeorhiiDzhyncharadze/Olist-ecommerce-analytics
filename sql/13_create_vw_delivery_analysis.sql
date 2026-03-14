DROP VIEW IF EXISTS olist.vw_delivery_analysis;

CREATE VIEW olist.vw_delivery_analysis AS

SELECT
    order_id,
    customer_id,
    order_purchase_ts::date AS purchase_date,
    order_delivered_customer_date::date AS delivered_date,
    order_estimated_delivery_date::date AS estimated_delivery_date,

    ROUND(
        DATE_PART(
            'day',
            order_delivered_customer_date - order_purchase_ts
        )::numeric,
        2
    ) AS delivery_days,

    ROUND(
        DATE_PART(
            'day',
            order_delivered_customer_date - order_estimated_delivery_date
        )::numeric,
        2
    ) AS delay_days,

    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
        ELSE 0
    END AS is_late

FROM olist.olist_orders_dataset

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
