select
  year,
  month,
  Round(avg(order_total_sales_amount),2) as avg_order_value
from {{ref('agg_completed_orders')}}
where year = 2023
group by year, month
order by year, month
