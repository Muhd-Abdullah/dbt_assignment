{{ config(materialized='view') }}

with src as (
  select *
  from {{ source('bronze','customers') }}
)

select
  id::number as customer_id,
  name::string as customer_name,

  current_timestamp() as created_at,
  'customers.csv' as source_file

from src
