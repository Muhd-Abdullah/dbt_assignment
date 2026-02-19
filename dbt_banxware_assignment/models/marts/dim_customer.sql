with base as (
  select
    customer_id,
    customer_name
  from {{ ref('raw_customer_data') }}
),

deduped as (
  select *
  from base
  qualify row_number() over (
    partition by customer_id
    order by customer_name
  ) = 1
)

select
  customer_id,
  customer_name
from deduped
