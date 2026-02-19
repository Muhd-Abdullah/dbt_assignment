select
    p.product_name,
    round(sum(f.total_sales_amount), 2) as total_sales
from {{ ref('fct_transformed_sales_data') }} f
join {{ ref('dim_product') }} p
  on f.product_id = p.product_id
join {{ ref('dim_date') }} d
  on f.date_day = d.date_day
join {{ref('dim_orders')}} o
  on f.order_id = o.order_id
where d.year = 2023
  and o.order_status = 'Completed'
group by p.product_name
order by total_sales desc
limit 5
