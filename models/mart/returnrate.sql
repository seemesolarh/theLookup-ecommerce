-- models/return_rate_analysis.sql
{{ config(
    materialized='table'
) }}
WITH product_returns AS (
    SELECT 
        p.product_id,
        p.name AS product_name,
        p.category AS product_category,
        COUNT(oi.id) AS total_sales,
        SUM(CASE WHEN oi.status = 'Returned' THEN 1 ELSE 0 END) AS total_returns,
        CASE 
            WHEN COUNT(oi.id) > 0 THEN (SUM(CASE WHEN oi.status = 'Returned' THEN 1 ELSE 0 END) / COUNT(oi.id)) * 100 
            ELSE 0
        END AS return_rate_percentage
    FROM 
       {{ ref('dim_products') }}  p
    LEFT JOIN 
        {{ ref('fact_order_items') }}  oi ON p.product_id = oi.product_id
    GROUP BY 
        product_id, product_name, product_category
)

SELECT 
    product_id,
    product_name,
    product_category,
    total_sales,
    total_returns,
    return_rate_percentage
FROM 
    product_returns
ORDER BY 
    return_rate_percentage DESC
