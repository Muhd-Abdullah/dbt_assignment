-- -----------------------------------------------------------------------------
-- MODEL: int_customer
--
-- LAYER
--   Intermediate
--
-- PURPOSE
--   Prepare a clean customer dimension dataset (one row per customer_id).
--   Applies deterministic deduplication/standardization rules so downstream
--   marts can rely on consistent customer attributes.
--
-- UPSTREAM
--   ref('raw_customer_data')
--
-- GRAIN
--   One row per customer_id.
--
-- TRANSFORMATIONS (TYPICAL)
--   - Deduplicates customers to the latest/best record per customer_id
--
-- DOWNSTREAM USAGE
--   - dim_customer in the mart layer
--   - Customer analytics (repeat rate, revenue by customer, etc.)
-- -----------------------------------------------------------------------------
{{ config(materialized='view') }}

with deduped as (
  select
    customer_id,
    customer_name
  from {{ ref('raw_customer_data') }}
  qualify row_number() over (
    partition by customer_id
    order by
      (customer_name is not null) desc,
      length(customer_name) desc,
      customer_name
  ) = 1
)

select
  customer_id,
  customer_name
from deduped

