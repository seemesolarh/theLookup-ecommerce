-- models/dim_products.sql

with products as (
    select
        id as product_id,
        cost,
        category,
        name,
        brand,
        retail_price,
        department,
        sku,
        distribution_center_id
    from {{ ref('rawProducts') }}
)

select * from products
