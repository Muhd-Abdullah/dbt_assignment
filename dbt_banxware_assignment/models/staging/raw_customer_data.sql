{{ config(materialized='table') }}

with src as (
  select *
  from {{ source('bronze','customers') }}
)

select
  id::number as customer_id,
  name::string as customer_name,
from src
