-- ---------------------------------------------------------
-- Query 1: Customer-level revenue and order metrics
-- Grain:
--   1 row = 1 customer (customer_unique_id)
-- ---------------------------------------------------------
select 
			ocd.customer_unique_id,
			count(distinct ooid.order_id) as orders_cnt,
			sum(ooid.price)::numeric as total_revenue
	from olist.olist_orders_dataset ood
	join olist.olist_customers_dataset ocd 
		using (customer_id)
	join olist.olist_order_items_dataset ooid
		using (order_id)
	where order_status = 'delivered'
	group by ocd.customer_unique_id

  
-- ---------------------------------------------------------
-- Query 2: Customer segmentation
-- Segments customers into:
--   - one_time
--   - repeat
-- Calculates average revenue and orders per segment
-- ---------------------------------------------------------
with customer_orders as(
	select 
			ocd.customer_unique_id,
			count(distinct ooid.order_id) as orders_cnt,
			sum(ooid.price)::numeric as total_revenue
	from olist.olist_orders_dataset ood
	join olist.olist_customers_dataset ocd 
		using (customer_id)
	join olist.olist_order_items_dataset ooid
		using (order_id)
	where order_status = 'delivered'
	group by ocd.customer_unique_id
),
customer_bucket as (
	select
		customer_unique_id,
		orders_cnt,
		total_revenue,
		case
			when orders_cnt = 1 then 'one_time'
			else 'repeat'
		end as customer_type
	from customer_orders
)
select 
	customer_type,
	count(customer_unique_id) as customer_cnt,
	round(avg(total_revenue), 2) as avg_revenue_per_customer,
    round(avg(orders_cnt), 2) as avg_orders_per_customer
from customer_bucket
group by customer_type 
order by customer_type;


-- ---------------------------------------------------------
-- Query 3: Repeat customer rate
-- Calculates:
--   - total customers
--   - repeat customers
--   - repeat customer rate
-- ---------------------------------------------------------
with customer_orders as(
	select 
			ocd.customer_unique_id,
			count(distinct ooid.order_id) as orders_cnt,
			sum(ooid.price)::numeric as total_revenue
	from olist.olist_orders_dataset ood
	join olist.olist_customers_dataset ocd 
		using (customer_id)
	join olist.olist_order_items_dataset ooid
		using (order_id)
	where order_status = 'delivered'
	group by ocd.customer_unique_id
),
customer_bucket as (
	select
		customer_unique_id,
		orders_cnt,
		total_revenue,
		case
			when orders_cnt = 1 then 'one_time'
			else 'repeat'
		end as customer_type
	from customer_orders
)
select
	count(customer_unique_id) total_customers,
	sum(case when customer_type = 'repeat' then 1 else 0 end)::numeric repeat_customer,
	sum(case when customer_type = 'repeat' then 1 else 0 end)::numeric  / count(customer_unique_id) repeat_customer_rate
from customer_bucket;
