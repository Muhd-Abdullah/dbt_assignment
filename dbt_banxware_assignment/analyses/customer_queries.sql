with base as (
    select *
    from {{ source('bronze','customers') }}
),

profile as (
    select
        count(*) as row_count,
        count(distinct id) as distinct_customer_ids,
        count_if(id is null) as null_customer_id,
        count_if(name is null) as null_customer_name
    from base
),

duplicate_ids as (
    select id
    from base
    group by id
    having count(*) > 1
),

name_inconsistency as (
    select id
    from base
    group by id
    having count(distinct name) > 1
)

select
    'customers_row_count' as check_name,
    row_count as metric,
    'INFO' as status
from profile

union all

select
    'customers_distinct_customer_ids',
    distinct_customer_ids,
    'INFO'
from profile

union all

select
    'customers_null_check',
    null_customer_id + null_customer_name,
    case when null_customer_id + null_customer_name = 0 then 'PASS' else 'FAIL' end
from profile

union all

select
    'customers_duplicate_ids',
    count(*),
    case when count(*) = 0 then 'PASS' else 'FAIL' end
from duplicate_ids

union all

select
    'customers_name_inconsistency',
    count(*),
    case when count(*) = 0 then 'PASS' else 'FAIL' end
from name_inconsistency
;
