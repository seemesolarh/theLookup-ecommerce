{{ config(
    materialized='table'
) }}
select
    p.name as product_name,
    dc.name as distribution_center,
    sum(i.cost) as total_cost,
    sum(i.product_retail_price) as potential_revenue,
    count(i.id) as total_units_sold
from
    {{ ref('fact_inventory_items') }} i
    join {{ ref('dim_products') }} p on i.product_id = p.product_id
    join {{ ref('dim_distribution_centers') }} dc on i.product_distribution_center_id = dc.id
where
    i.sold_at is not null
group by
    p.name, dc.name
order by
    total_units_sold desc
