-- models/dim_users.sql

with users as (
    select
        id as user_id,
        first_name,
        last_name,
        email,
        age,
        gender,
        state,
        street_address,
        postal_code,
        city,
        country,
        latitude,
        longitude,
        traffic_source,
        created_at
    from {{ ref('rawUsers') }}
)

select * from users
