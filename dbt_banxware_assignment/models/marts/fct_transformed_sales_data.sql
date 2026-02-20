-- -----------------------------------------------------------------------------
-- MODEL: fct_transformed_sales_data
--
-- LAYER
--   Marts (Fact)
--
-- PURPOSE
--   Sales fact table at the sales line-item grain. Contains foreign keys to
--   dimensions and measures used for revenue analytics.
--
-- UPSTREAM
--   ref('int_transformed_sales_data')
--
-- GRAIN
--   One row per sales_uuid (i.e., unique order_id + product_id line item).
--
-- PRIMARY KEY
--   sales_uuid
--
-- FOREIGN KEYS
--   - order_id    -> dim_orders.order_id
--   - customer_id -> dim_customer.customer_id
--   - product_id  -> dim_product.product_id
--   - date_day    -> dim_date.date_day
--
-- IMPLEMENTATION NOTES
--   - date_day is derived from s.order_date to match dim_date grain.
-- -----------------------------------------------------------------------------
{{ config(materialized='table') }}

select
  s.sales_uuid,

  -- FKs
  s.order_id,
  s.customer_id,
  s.product_id,
  s.order_date as date_day,
  -- Measures
  s.quantity,
  s.price,
  s.total_sales_amount as total_sales_amount

from {{ ref('int_transformed_sales_data') }} s
join {{ ref('dim_orders') }}   o on s.order_id = o.order_id
join {{ ref('dim_customer') }} c on s.customer_id = c.customer_id
join {{ ref('dim_product') }}  p on s.product_id = p.product_id
join {{ ref('dim_date') }}     d on s.order_date = d.date_day

