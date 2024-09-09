{{ config(
    materialized='table'
) }}
with customer_events as (
    select
        u.user_id as user_id,  -- Specify the alias 'u' here
        CONCAT(u.first_name, ' ', u.last_name) AS full_name,  
        e.event_type,
        e.created_at as event_time,
        row_number() over (partition by u.user_id order by e.created_at) as event_sequence
    from {{ ref('dimusers') }} u
    inner join {{ ref('dim_events') }} e 
        on u.user_id = e.user_id  -- Specify the alias 'u' here
)

select
    user_id,
   full_name,
    event_type,
    event_time,
    event_sequence
from customer_events
order by user_id, event_sequence


