with base as (
  select
    product_id,
    product_name,
    order_date
  from {{ ref('int_transformed_sales_data') }}
),

deduped as (
  select
    product_id,
    product_name
  from base
  qualify row_number() over (
    partition by product_id
    order by order_date desc, product_name desc
  ) = 1
)

select * from deduped
