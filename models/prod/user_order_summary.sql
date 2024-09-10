-- models/user_order_summary.sql

WITH user_orders AS (
    SELECT 
        u.id AS user_id,
        u.first_name,
        u.last_name,
        u.age,
        u.gender,
        o.order_id,
        o.status,
        o.created_at AS order_date,
        o.returned_at,
        o.shipped_at,
        o.delivered_at,
        o.num_of_item,
        oi.sale_price
    FROM 
        {{ ref('rawUsers') }} u
    JOIN 
        {{ ref('rawOrders') }} o ON u.id = o.user_id
    LEFT JOIN 
        {{ ref('rawOrdersitems') }} oi ON o.order_id = oi.order_id
)

SELECT 
    user_id,
    first_name,
    last_name,
    age,
    gender,
    COUNT(order_id) AS total_orders,
    SUM(sale_price) AS total_revenue,
    AVG(sale_price) AS average_order_value,
    COUNT(returned_at) AS total_returns
FROM 
    user_orders
GROUP BY 
    user_id, first_name, last_name, age, gender
