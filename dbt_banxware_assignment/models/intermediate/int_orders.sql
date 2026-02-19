{{ config(materialized='view') }}

with base as (
  select
    order_id,
    order_date,
    order_status,
    created_at,
    source_file
  from {{ ref('int_transformed_sales_data') }}
  where order_id is not null
),

deduped as (
  select *
  from base
  qualify row_number() over (
    partition by order_id
    order by order_date desc, created_at desc
  ) = 1
)

select
  order_id,
  order_date,
  order_status
from deduped
