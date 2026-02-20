-- -----------------------------------------------------------------------------
-- MODEL: dim_orders
--
-- LAYER
--   Marts (Dimensional)
--
-- PURPOSE
--   Order header dimension that stores order-level attributes such as order_date
--   and order_status. Enables filtering and grouping at the order grain.
--
-- UPSTREAM
--   ref('int_orders')
--
-- GRAIN
--   One row per order_id.
--
-- PRIMARY KEY
--   order_id
--
-- DOWNSTREAM USAGE
--   - Joined from facts (fct_transformed_sales_data)
--   - Used by aggregates (agg_completed_orders) to filter Completed orders
-- -----------------------------------------------------------------------------
{{ config(materialized='table') }}

select
  order_id,
  order_date,
  order_status
from {{ ref('int_orders') }}
