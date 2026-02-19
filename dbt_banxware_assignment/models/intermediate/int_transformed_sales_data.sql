{{ config(
    materialized='incremental',
    unique_key='sales_uuid',
    incremental_strategy='merge'
) }}

with base as (
  select *
  from {{ ref('raw_sales_data') }}
),

-- apply business rules + transformations
transformed as (
  select
    sales_uuid,
    order_id,
    customer_id,
    product_id,
    product_name,
    quantity,
    price,
    order_status,
    order_date,

    year(order_date)  as order_year,
    month(order_date) as order_month,
    day(order_date)   as order_day,

    (quantity * price) as total_sales_amount,

    created_at,
    source_file
  from base
  where quantity > 0
    and price > 0
),

-- dedupe by keeping latest record per sales_uuid (QUALIFY)
deduped as (
  select *
  from transformed
  qualify row_number() over (
    partition by sales_uuid
    order by created_at desc
  ) = 1
)

select * from deduped
