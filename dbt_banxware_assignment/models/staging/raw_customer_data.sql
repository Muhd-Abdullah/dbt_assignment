-- -----------------------------------------------------------------------------
-- MODEL: raw_customer_data
--
-- PURPOSE
--   Staging model for customers sourced from Snowflake bronze layer.
--   This model standardizes column names, casts types
--
-- SOURCE
--   {{ source('bronze','customers') }}
--
-- GRAIN
--   One row per customer_id.
--
-- KEY FIELDS
--   - customer_id: business key (cast from source column id)
--
-- -----------------------------------------------------------------------------

{{ config(materialized='table') }}

with src as (
  select *
  from {{ source('bronze','customers') }}
)

select
  id::number as customer_id,
  name::string as customer_name,
from src
