{{ config(
    materialized='incremental',
    unique_key='sales_uuid',
    incremental_strategy='merge'
) }}

with base as (
  select *,
  ROUND(quantity * price, 2) as total_sales_amount,
  from {{ ref('raw_sales_data') }}
  where quantity > 0 and price > 0
),

-- dedupe by keeping latest record per sales_uuid (QUALIFY)
deduped as (
  select *
  from base
  qualify row_number() over (
    partition by sales_uuid
    order by created_at desc
  ) = 1
)

select * from deduped
