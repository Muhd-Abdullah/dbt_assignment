-- -----------------------------------------------------------------------------
-- MODEL: dim_product
--
-- LAYER
--   Marts (Dimensional)
--
-- PURPOSE
--   Product dimension table used for slicing facts by product attributes.
--   This model is a thin wrapper over the intermediate product model.
--
-- UPSTREAM
--   ref('int_product')
--
-- GRAIN
--   One row per product_id.
--
-- PRIMARY KEY
--   product_id
--
-- DOWNSTREAM USAGE
--   - Joined from facts (e.g., fct_transformed_sales_data)
--   - Product reporting (top products, revenue by product, etc.)
-- -----------------------------------------------------------------------------
{{ config(materialized='table') }}

select
  product_id,
  product_name
from {{ ref('int_product') }}
