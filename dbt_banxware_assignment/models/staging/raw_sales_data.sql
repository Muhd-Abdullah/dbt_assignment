-- -----------------------------------------------------------------------------
-- MODEL: raw_sales_data
--
-- PURPOSE
--   Staging model for sales line items sourced from Snowflake bronze layer.
--   This model standardizes and types raw fields, creates a stable surrogate key,
--   parses the order date
--
-- SOURCE
--   {{ source('bronze','sales') }}
--
-- GRAIN
--   One row per (order_id, product_id) — i.e., one sales line item.
--
-- KEY FIELDS
--   - sales_uuid: deterministic surrogate key derived from (order_id, product_id)
--   - order_id, customer_id, product_id: business keys
--
--   - order_date is parsed using try_to_date to avoid failing on malformed values.
-- -----------------------------------------------------------------------------
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
from src
