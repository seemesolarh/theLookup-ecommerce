-- models/fact_orders.sql

with orders as (
    select
        order_id,
        user_id,
        status,
        created_at,
        returned_at,
        shipped_at,
        delivered_at,
        num_of_item
    from {{ ref('rawOrders') }}
)

select * from orders
