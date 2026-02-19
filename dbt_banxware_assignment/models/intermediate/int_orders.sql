{{ config(materialized='view') }}

with base as (
  select
    order_id,
    order_date,
    order_status
  from {{ ref('int_transformed_sales_data') }}
  where order_id is not null
),

deduped as (
  select *
  from base
  qualify row_number() over (
    partition by order_id
    order by
      (order_status is not null) desc,
      (order_date is not null) desc,
      order_status asc,
      order_date desc nulls last, 
      order_id asc 
  ) = 1
)

select
  order_id,
  order_date,
  order_status
from deduped
