with base as (
  select
    order_id,
    customer_id,
    order_date,
    order_status
  from {{ ref('int_transformed_sales_data') }}
),

deduped as (
  select
    order_id,
    customer_id,
    order_date,
    order_status
  from base
  qualify row_number() over (
    partition by order_id
    order by order_date desc
  ) = 1
)

select * from deduped
