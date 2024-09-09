-- models/product_profitability_analysis.sql

{{ config(
    materialized='table'
) }}
WITH product_profitability AS (
    SELECT 
        p.product_id,
        p.name AS product_name,
        p.category AS product_category,
        SUM(oi.sale_price) AS total_revenue,
        SUM(p.cost) AS total_cost,
        (SUM(oi.sale_price) - SUM(p.cost)) AS total_profit,
        ((SUM(oi.sale_price) - SUM(p.cost)) / SUM(oi.sale_price)) * 100 AS profit_margin_percentage
    FROM 
      {{ ref('dim_products') }} p
    JOIN 
        {{ ref('fact_order_items') }} oi ON p.product_id = oi.product_id
    GROUP BY 
        product_id, product_name, product_category
)

SELECT 
    product_id,
    product_name,
    product_category,
    total_revenue,
    total_cost,
    total_profit,
    profit_margin_percentage
FROM 
    product_profitability
ORDER BY 
    total_profit