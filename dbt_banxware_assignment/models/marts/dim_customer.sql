-- -----------------------------------------------------------------------------
-- MODEL: dim_customer
--
-- LAYER
--   Marts (Dimensional)
--
-- PURPOSE
--   Customer dimension table used for slicing facts by customer attributes.
--   This model is a thin wrapper over the intermediate customer model.
--
-- UPSTREAM
--   ref('int_customer')
--
-- GRAIN
--   One row per customer_id.
--
-- PRIMARY KEY
--   customer_id
--
-- DOWNSTREAM USAGE
--   - Joined from facts (e.g., fct_transformed_sales_data)
--   - Customer reporting (revenue by customer, repeat customers, etc.)
-- -----------------------------------------------------------------------------
{{ config(materialized='table') }}

select
  customer_id,
  customer_name
from {{ ref('int_customer') }}