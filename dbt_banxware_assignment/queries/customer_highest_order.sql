select
  customer_name,
  count(distinct order_id) as order_volume
from {{ref('agg_completed_orders')}}
where year = 2023
  and month = 10
group by customer_name
order by order_volume desc
limit 1
