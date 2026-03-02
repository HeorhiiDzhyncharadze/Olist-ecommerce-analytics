-- =========================================================
-- Monthly KPI Analysis (Delivered Orders Only)
-- Metrics:
--   1. Orders Count
--   2. GMV (Gross Merchandise Value)
--   3. AOV (Average Order Value)
-- =========================================================

-- CTE 1: Select only delivered orders
-- Grain: 1 row = 1 order
-- We prepare the base dataset of completed transactions
with delivered_orders as (
	select 
		order_id,

    -- Truncate purchase timestamp to month level
    -- This allows monthly aggregation
		date_trunc('month', order_purchase_ts) as month
	from olist.olist_orders_dataset ood

  -- Include only successfully delivered orders
	where order_status = 'delivered'
),

-- CTE 2: Aggregate payments at the order level
-- Grain: 1 row = 1 order
-- Important: an order may contain multiple payment rows (installments)
-- Therefore, we aggregate payments before joining
payments_by_order as (
	select 
		order_id,

    -- Total payment amount per order (Order-level GMV)
		sum(payment_value) as order_gmv
	from olist.olist_order_payments_dataset oopd

  -- Group by order to avoid revenue duplication
	group by order_id
)

-- Final aggregation at the month level
-- Grain of result: 1 row = 1 month
select 
	d.month,
  
  -- Number of unique delivered orders in the month
	count(distinct d.order_id) as order_cnt,
  
  -- Number of unique delivered orders in the month
	sum(p.order_gmv) as gmv,

  -- Average Order Value
  -- AOV = Total GMV / Number of Orders
	sum(p.order_gmv)::numeric / nullif (count(distinct d.order_id), 0) as aov
from delivered_orders d

-- Join aggregated payments to delivered orders
-- INNER JOIN ensures we only include paid orders
join payments_by_order p
	on d.order_id = p.order_id

-- Aggregate results by month
group by d.month

-- Sort chronologically
order by d.month;
