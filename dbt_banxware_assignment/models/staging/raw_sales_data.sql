{{ config(materialized='table') }}

with src as (
  select *
  from {{ source('bronze','sales') }}
)

select
  -- single stable fact grain key
  {{stable_uuid(['order_id','product_id'])}} as sales_uuid,

  -- business keys (typed)
  order_id::number as order_id,
  customer_id::number as customer_id,
  product_id::number as product_id,

  -- attributes
  product_name::string as product_name,
  quantity::number as quantity,
  price::float as price,
  order_status::string as order_status,

  -- parsed date
  try_to_date(order_date, 'MM/DD/YYYY') as order_date,

  -- metadata
  current_timestamp() as created_at,
  'sales.csv' as source_file

from src
