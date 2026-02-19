{{ config(materialized='view') }}

with base as (
  select
    product_id,
    product_name
  from {{ ref('int_transformed_sales_data') }}
  where product_id is not null
),

deduped as (
  select *
  from base
  qualify row_number() over (
    partition by product_id
    order by
      (product_name is not null) desc,
      length(product_name) desc,
      product_name asc          
  ) = 1
)

select
  product_id,
  product_name
from deduped

