-- -----------------------------------------------------------------------------
-- MODEL: agg_completed_orders
--
-- LAYER
--   Marts (Aggregate)
--
-- PURPOSE
--   Order-level aggregate mart for reporting on Completed orders only.
--   Computes total order revenue by summing line-item revenue per order and
--   enriches with customer name and date attributes (year/month).
--
-- UPSTREAM
--   ref('fct_transformed_sales_data')  (order totals)
--   ref('dim_orders')                 (order_status filtering)
--   ref('dim_customer')               (customer_name)
--   ref('dim_date')                   (year/month)
--
-- GRAIN
--   One row per order_id.
--
-- METRICS
--   - order_total_sales_amount: SUM(total_sales_amount) per order, rounded to 2 decimals
--
-- FILTERING
--   - Only includes orders where dim_orders.order_status = 'Completed'
-- -----------------------------------------------------------------------------
{{ config(materialized='table') }}

with orders as (

  select
    f.order_id,
    f.customer_id,
    f.date_day,
    ROUND(SUM(f.total_sales_amount), 2) AS order_total_sales_amount
  from {{ ref('fct_transformed_sales_data') }} f
  group by
    f.order_id,
    f.customer_id,
    f.date_day
)

select
  d.year,
  d.month,
  o.order_id,
  o.customer_id,
  c.customer_name,
  ord.order_status,
  o.order_total_sales_amount

from orders o
join {{ ref('dim_date') }} d
  on o.date_day = d.date_day
join {{ ref('dim_customer') }} c
  on o.customer_id = c.customer_id
join {{ ref('dim_orders') }} ord
  on o.order_id = ord.order_id
where ord.order_status = 'Completed'