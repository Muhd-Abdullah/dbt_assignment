select
    p.product_name,
    ROUND(sum(f.total_sales_amount),2) as total_sales
from {{ ref('fct_transformed_sales_data') }} f
join {{ref('dim_product')}} p
    on f.product_id = p.product_id
join {{ref('dim_date')}} d
    on f.date_day = d.date_day
where d.year = 2023
group by p.product_name
order by total_sales desc
limit 5
