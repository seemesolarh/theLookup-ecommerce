-- models/dim_distribution_centers.sql

with distribution_centers as (
    select
        id,
        name,
        latitude,
        longitude
    from {{ ref('rawDistributioncentre') }}
)
select * from distribution_centers
