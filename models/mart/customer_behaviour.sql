SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,  
    e.event_type,
    e.created_at AS event_time,
    o.status AS order_status
FROM 
    {{ ref('dimusers') }} u
JOIN 
    {{ ref('dim_events') }} e ON u.user_id = e.user_id
LEFT JOIN 
    {{ ref('fact_orders') }} o ON u.user_id = o.user_id
ORDER BY 
    u.user_id, e.created_at

