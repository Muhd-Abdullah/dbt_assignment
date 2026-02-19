{{ config(materialized='view') }}

with deduped as (
  select *
  from {{ ref('raw_customer_data') }}
  qualify row_number() over (
    partition by customer_id
    order by
      (customer_name is not null) desc,
      length(customer_name) desc,
      customer_name
  ) = 1
)

select
  customer_id,
  customer_name
from deduped

