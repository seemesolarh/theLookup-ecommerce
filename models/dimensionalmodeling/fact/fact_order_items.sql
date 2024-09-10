-- models/fact_order_items.sql

with order_items as (
    select
        id,
        order_id,
        user_id,
        product_id,
        inventory_item_id,
        status,
        created_at,
        shipped_at,
        delivered_at,
        returned_at,
        sale_price
    from {{ ref('rawOrdersitems') }}
)

select * from order_items
