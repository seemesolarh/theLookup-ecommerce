-- models/traffic_source_performance.sql

WITH traffic_performance AS (
    SELECT 
        e.traffic_source,
        COUNT(DISTINCT e.user_id) AS total_users,
        COUNT(e.id) AS total_events,
        COUNT(DISTINCT CASE WHEN oi.status = 'Delivered' THEN o.order_id END) AS total_orders,
        SUM(CASE WHEN oi.status = 'Delivered' THEN oi.sale_price ELSE 0 END) AS total_revenue
    FROM 
     {{ ref('dim_events') }}  e
    LEFT JOIN 
       {{ ref('fact_orders') }}  o ON e.user_id = o.user_id
    LEFT JOIN 
        {{ ref('fact_order_items') }}  oi ON o.order_id = oi.order_id
    GROUP BY 
        e.traffic_source
)

SELECT 
    traffic_source,
    total_users,
    total_events,
    total_orders,
    total_revenue
FROM 
    traffic_performance
ORDER BY 
    total_revenue DESC
 