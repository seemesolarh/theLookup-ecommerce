{{ config(
    materialized='table'
) }}
select
    p.category,
    sum(oi.sale_price) as total_sales,
    count(oi.id) as total_items_sold,
    dc.name as distribution_center,
    u.gender,
    u.age
from
    {{ ref('fact_order_items') }} oi
    join {{ ref('dim_products') }} p on oi.product_id = p.product_id
    join {{ ref('dimusers') }} u on oi.user_id = u.user_id
    join {{ ref('dim_distribution_centers') }} dc on p.distribution_center_id = dc.id
group by
    p.category, dc.name, u.gender, u.age
order by
    total_sales desc
