-- -----------------------------------------------------------------------------
-- MODEL: int_orders
--
-- LAYER
--   Intermediate
--
-- PURPOSE
--   Build an order header dataset (one row per order) from sales line items.
--   This model consolidates order-level attributes such as order_date and
--   order_status so downstream marts can compute order-level KPIs.
--
-- UPSTREAM
--   ref('raw_sales_data')
--
-- GRAIN
--   One row per order_id.
--
-- TRANSFORMATIONS
--   - Aggregates / deduplicates line items to order-level grain
--   - Selects deterministic order attributes (e.g., max/min order_date)
--   - Preserves order_status for filtering (Completed/Pending/Cancelled)
--
-- DOWNSTREAM USAGE
--   - Order-level marts (AOV, order counts, revenue by period)
--   - Fact tables that need a clean order header
-- -----------------------------------------------------------------------------
{{ config(materialized='view') }}

with base as (
  select
    order_id,
    order_date,
    order_status
  from {{ ref('raw_sales_data') }}
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
