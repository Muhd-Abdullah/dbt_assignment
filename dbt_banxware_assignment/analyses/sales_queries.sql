with base as (
    select *
    from {{ source('bronze','sales') }}
),

profile as (
    select
        count(*) as row_count,
        count(distinct order_id) as distinct_orders,
        count(distinct customer_id) as distinct_customers,
        count(distinct product_id) as distinct_products,

        min(quantity) as min_quantity,
        max(quantity) as max_quantity,

        min(price) as min_price,
        max(price) as max_price,

        min(try_to_date(order_date,'MM/DD/YYYY')) as min_order_date,
        max(try_to_date(order_date,'MM/DD/YYYY')) as max_order_date
    from base
),

nulls as (
    select
        count_if(order_id is null) +
        count_if(order_date is null) +
        count_if(customer_id is null) +
        count_if(product_id is null) +
        count_if(quantity is null) +
        count_if(price is null)
        as null_count
    from base
),

invalid_dates as (
    select count(*) as invalid_date_rows
    from base
    where try_to_date(order_date,'MM/DD/YYYY') is null
),

duplicate_business_key as (
    select count(*) as dup_count
    from (
        select order_id, product_id
        from base
        group by 1,2
        having count(*) > 1
    )
),

invalid_numeric as (
    select count(*) as invalid_rows
    from base
    where quantity <= 0 or price <= 0
),

ref_integrity as (
    select count(*) as missing_customers
    from {{ source('bronze','sales') }} s
    left join {{ source('bronze','customers') }} c
      on s.customer_id = c.id
    where c.id is null
)

select
    'sales_row_count' as check_name,
    row_count as metric,
    'INFO' as status
from profile

union all

select
    'sales_distinct_orders',
    distinct_orders,
    'INFO'
from profile

union all

select
    'sales_null_check',
    null_count,
    case when null_count = 0 then 'PASS' else 'FAIL' end
from nulls

union all

select
    'sales_invalid_date_format',
    invalid_date_rows,
    case when invalid_date_rows = 0 then 'PASS' else 'FAIL' end
from invalid_dates

union all

select
    'sales_duplicate_business_key',
    dup_count,
    case when dup_count = 0 then 'PASS' else 'FAIL' end
from duplicate_business_key

union all

select
    'sales_invalid_quantity_or_price',
    invalid_rows,
    case when invalid_rows = 0 then 'PASS' else 'FAIL' end
from invalid_numeric

union all

select
    'sales_missing_customers_fk',
    missing_customers,
    case when missing_customers = 0 then 'PASS' else 'FAIL' end
from ref_integrity
;
