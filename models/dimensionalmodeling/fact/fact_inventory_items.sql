-- models/fact_inventory_items.sql

with inventory_items as (
    select
        id,
        product_id,
        created_at,
        sold_at,
        cost,
        product_category,
        product_name,
        product_retail_price,
        product_department,
        product_sku,
        product_distribution_center_id
    from {{ ref('rawInventoryItems') }}
)

select * from inventory_items
