-- models/product_sales_performance.sql

WITH product_sales AS (
    SELECT 
        p.id AS product_id,
        p.name AS product_name,
        p.brand AS product_brand,
        p.category AS product_category,
        p.retail_price,
        p.department,
        SUM(oi.sale_price) AS total_sales,
        COUNT(oi.id) AS units_sold
    FROM 
        {{ ref('rawProducts') }} p
    JOIN 
        {{ ref('rawOrdersitems') }} oi ON p.id = oi.product_id
    WHERE 
        oi.status = 'Delivered'
    GROUP BY 
        product_id, product_name, product_brand, product_category, retail_price, department
)

SELECT 
    product_id,
    product_name,
    product_brand,
    product_category,
    retail_price,
    department,
    total_sales,
    units_sold,
    total_sales / units_sold AS avg_price_per_unit
FROM 
    product_sales
ORDER BY 
    total_sales DESC
