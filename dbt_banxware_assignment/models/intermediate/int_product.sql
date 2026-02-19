{{ config(materialized='view') }}

with base as (
  select
    product_id,
    product_name,
    created_at,
    source_file
  from {{ ref('int_transformed_sales_data') }}
  where product_id is not null
),

deduped as (
  select *
  from base
  qualify row_number() over (
    partition by product_id
    order by created_at desc, product_name
  ) = 1
)

select
  product_id,
  product_name
from deduped

