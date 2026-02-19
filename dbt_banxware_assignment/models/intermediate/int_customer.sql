{{ config(materialized='view') }}

with deduped as (
  select *
  from {{ ref('raw_customer_data') }}
  qualify row_number() over (
    partition by customer_id
    order by created_at desc, customer_name
  ) = 1
)

select
  customer_id,
  customer_name
from deduped

