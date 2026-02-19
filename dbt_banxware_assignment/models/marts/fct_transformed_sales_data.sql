{{ config(materialized='table') }}

select
  s.sales_uuid,

  -- FKs
  s.order_id,
  s.customer_id,
  s.product_id,
  s.order_date as date_day,

  -- Date attributes from dim_date
  d.year,
  d.month,
  d.day,

  -- Measures
  s.quantity,
  s.price,
  s.total_sales_amount as total_sales_amount

from {{ ref('int_transformed_sales_data') }} s
inner join {{ ref('dim_orders') }}   o on s.order_id = o.order_id
inner join {{ ref('dim_customer') }} c on s.customer_id = c.customer_id
inner join {{ ref('dim_product') }}  p on s.product_id = p.product_id
inner join {{ ref('dim_date') }}     d on s.order_date = d.date_day

