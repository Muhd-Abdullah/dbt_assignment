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