with bounds as (
  select
    dateadd(month, -1, min(order_date)) as start_date,
    dateadd(month,  1, max(order_date)) as end_date
  from {{ ref('int_transformed_sales_data') }}
),

date_raw as (
  select
    dateadd(day, seq4(), b.start_date) as date_day,
    b.end_date
  from bounds b,
       table(generator(rowcount => 10000))
)

select
  date_day,
  year(date_day) as year,
  month(date_day) as month,
  day(date_day) as day,
  dayofweek(date_day) as day_of_week,
  weekofyear(date_day) as week_of_year,
  quarter(date_day) as quarter
from date_raw
where date_day <= end_date
order by date_day
