-- -----------------------------------------------------------------------------
-- MODEL: int_product
--
-- LAYER
--   Intermediate
--
-- PURPOSE
--   Prepare a clean product dimension dataset (one row per product_id) from
--   sales line items. Ensures consistent product naming and deterministic
--   deduplication.
--
-- UPSTREAM
--   ref('raw_sales_data')
--
-- GRAIN
--   One row per product_id.
--
-- TRANSFORMATIONS
--   - Deduplicates products derived from sales records
--   - Selects a deterministic product_name for each product_id
--
-- DOWNSTREAM USAGE
--   - dim_product in the mart layer
--   - Product analytics (top products, revenue by product, etc.)
-- -----------------------------------------------------------------------------
{{ config(materialized='view') }}

with base as (
  select
    product_id,
    product_name
  from {{ ref('raw_sales_data') }}
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

