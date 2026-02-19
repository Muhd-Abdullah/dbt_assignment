select
  -- PK
  sales_uuid,

  -- FKs (business keys)
  order_id,
  customer_id,
  product_id,

  -- date FK
  order_date,

  -- measures & attributes
  order_year,
  order_month,
  order_day,
  quantity,
  price,
  total_sales_amount,
  order_status,

  -- metadata from upstream
  created_at,
  source_file
from {{ ref('int_transformed_sales_data') }}
