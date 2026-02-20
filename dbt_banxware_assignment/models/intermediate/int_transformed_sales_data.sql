-- -----------------------------------------------------------------------------
-- MODEL: int_transformed_sales_data
--
-- LAYER
--   Intermediate
--
-- PURPOSE
--   Clean, validate, and standardize sales line-item data for downstream
--   dimensional modeling.
--
-- UPSTREAM
--   ref('raw_sales_data')
--
-- GRAIN
--   One row per sales line item (sales_uuid).
--
-- TRANSFORMATIONS
--   - Enforces basic data quality: quantity > 0, price > 0
--   - Deduplicates at sales_uuid level (if duplicates exist)
--   - Adds derived metric(s), e.g. total_sales_amount = quantity * price
--
-- DOWNSTREAM USAGE
--   - ref('int_orders') for order header attributes
--   - ref('int_product') for product attributes
--   - Fact models / marts for revenue, order KPIs, customer KPIs
-- -----------------------------------------------------------------------------

{{ config(materialized='view') }}

with base as (
  select
    sales_uuid,
    order_id,
    order_date,
    customer_id,
    product_id,
    quantity,
    price,
    round(quantity * price, 2) as total_sales_amount
  from {{ ref('raw_sales_data') }}
  where quantity > 0 and price > 0
),

deduped as (
  select *
  from base
  qualify row_number() over (
    partition by sales_uuid
    order by
      -- “most complete” preference (add fields if you have more)
      (order_date is not null) desc,
      (customer_id is not null) desc,
      (product_id is not null) desc,
      total_sales_amount desc,
      order_date desc nulls last
  ) = 1
)

select * from deduped
