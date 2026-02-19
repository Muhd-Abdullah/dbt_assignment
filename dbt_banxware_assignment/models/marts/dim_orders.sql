{{ config(materialized='table') }}

select
  order_id,
  order_date,
  order_status
from {{ ref('int_orders') }}
