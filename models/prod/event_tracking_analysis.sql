-- models/event_tracking_analysis.sql

SELECT 
    e.user_id,
    e.event_type,
    COUNT(e.id) AS event_count,
    e.traffic_source,
    e.city,
    e.state
FROM 
    {{ ref('rawEvents') }} e
GROUP BY 
    e.user_id, e.event_type, e.traffic_source, e.city, e.state
ORDER BY 
    event_count DESC
