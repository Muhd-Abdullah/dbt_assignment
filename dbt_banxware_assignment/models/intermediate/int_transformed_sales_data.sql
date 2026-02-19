{{ config(materialized='view') }}

with base as (
  select
    *,
    round(quantity * price, 2) as total_sales_amount
  from {{ ref('raw_sales_data') }}
  where quantity > 0 and price > 0
),

deduped as (
  select *
  from base
  qualify row_number() over (
    partition by sales_uuid
    order by
      -- “most complete” preference (add fields if you have more)
      (order_date is not null) desc,
      (customer_id is not null) desc,
      (product_id is not null) desc,
      total_sales_amount desc,
      order_date desc nulls last
  ) = 1
)

select * from deduped
