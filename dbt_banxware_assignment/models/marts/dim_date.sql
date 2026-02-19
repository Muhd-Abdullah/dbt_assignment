with bounds as (
  select
    min(order_date) as min_date,
    max(order_date) as max_date
  from {{ ref('int_transformed_sales_data') }}
),

date_raw as (

  {{ dbt_utils.date_spine(
      datepart="day",
      start_date="(select min_date from bounds)",
      end_date="(select max_date from bounds)"
  ) }}

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
order by date_day;
