{{ config(materialized='table') }}

select
  product_id,
  product_name
from {{ ref('int_product') }}
