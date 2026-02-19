select
  customer_name,
  ROUND(sum(order_total_sales_amount),2) as total_sales
from {{ref('agg_completed_orders')}}
where year = 2023
group by customer_name
order by total_sales desc
limit 5
