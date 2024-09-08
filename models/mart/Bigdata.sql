{{ config(
    materialized='table'
) }}
WITH user_data AS (
    -- Select relevant user data
    SELECT
        u.user_id,
        CONCAT(u.first_name, ' ', u.last_name) AS full_name,
        u.age,
        u.gender,
        u.state AS user_state,
        u.city AS user_city,
        u.created_at AS user_created_at,
        u.traffic_source
    FROM
        {{ ref('dimusers') }} u
),
order_data AS (
    -- Select relevant order data and join with users
    SELECT
        o.order_id,
        o.user_id,
        o.status AS order_status,
        o.created_at AS order_created_at,
        o.returned_at,
        o.shipped_at,
        o.delivered_at,
        o.num_of_item,
        u.full_name,
        u.age,
        u.gender,
        u.user_state,
        u.user_city
    FROM
       {{ ref('fact_orders') }} o
    JOIN
        user_data u ON o.user_id = u.user_id
),
order_items_data AS (
    -- Select relevant order item data and join with orders and users
    SELECT
        oi.id AS order_item_id,
        oi.order_id,
        oi.user_id,
        oi.product_id,
        oi.status AS item_status,
        oi.created_at AS item_created_at,
        oi.shipped_at,
        oi.delivered_at,
        oi.returned_at,
        oi.sale_price,
        o.full_name,
        o.age,
        o.gender,
        o.user_state,
        o.user_city,
        o.num_of_item
    FROM
        {{ ref('fact_order_items') }} oi
    JOIN
        order_data o ON oi.order_id = o.order_id
),
product_data AS (
    -- Select relevant product data and join with order items
    SELECT
        p.product_id,
        p.cost AS product_cost,
        p.category AS product_category,
        p.name AS product_name,
        p.brand AS product_brand,
        p.retail_price AS product_retail_price,
        p.department AS product_department,
        p.sku AS product_sku,
        p.distribution_center_id,
        oi.order_item_id,
        oi.sale_price
    FROM
        {{ ref('dim_products') }} p
    JOIN
        order_items_data oi ON p.product_id = oi.product_id
),
distribution_center_data AS (
    -- Join product data with distribution center details
    SELECT
        dc.id AS distribution_center_id,
        dc.name AS distribution_center_name,
        dc.latitude,
        dc.longitude,
        p.product_id AS product_id,
        p.product_name,
        p.product_brand,
        p.product_category,
        p.sale_price
    FROM
        {{ ref('dim_distribution_centers') }} dc
    JOIN
        product_data p ON dc.id = p.distribution_center_id
),
event_data AS (
    -- Select relevant event data and join with users
    SELECT
        e.id AS event_id,
        e.user_id,
        e.session_id,
        e.event_type,
        e.uri AS event_uri,
        e.city AS event_city,
        e.state AS event_state,
        e.created_at AS event_created_at,
        e.traffic_source
    FROM
        {{ ref('dim_events') }} e
    JOIN
        user_data u ON e.user_id = u.user_id
),
inventory_data AS (
    -- Select relevant inventory data and join with products
    SELECT
        inv.id AS inventory_id,
        inv.product_id,
        inv.created_at AS inventory_created_at,
        inv.sold_at,
        inv.cost AS inventory_cost,
        inv.product_category AS inventory_category,
        inv.product_name AS inventory_name,
        inv.product_sku AS inventory_sku,
        inv.product_distribution_center_id,
        p.product_name,
        p.product_brand
    FROM
        {{ ref('fact_inventory_items') }} inv
    JOIN
        product_data p ON inv.product_id = p.product_id
)

-- Final query: joining all the datasets into one result set with key business insights
SELECT 
    -- User Information
    u.user_id,
    u.full_name,
    u.age,
    u.gender,
    u.user_state,
    u.user_city,
    u.traffic_source,
    
    -- Order Information
    o.order_id,
    o.order_status,
    o.num_of_item,
    o.order_created_at,

    -- Order Item Information
    oi.order_item_id,
    oi.item_status,
    oi.sale_price,

    -- Product Information with conditional logic
    p.product_id,
    p.product_name,
    p.product_brand,
    p.product_category,
    p.product_cost,
    p.product_retail_price,

    -- Categorize products based on cost
    CASE
        WHEN p.product_cost < 5 THEN 'Cheap'
        WHEN p.product_cost BETWEEN 5 AND 20 THEN 'Moderate'
        ELSE 'Expensive'
    END AS product_price_category,

    -- Distribution Center Information
    dc.distribution_center_name,
    dc.latitude,
    dc.longitude,

    -- Event Information
    e.event_type,
    e.event_uri,
    e.event_city,
    e.event_state,

    -- Inventory Information
    inv.inventory_cost,
    inv.sold_at,
    
    -- Flag for whether the inventory item is sold
    CASE
        WHEN inv.sold_at IS NOT NULL THEN 'Sold'
        ELSE 'Available'
    END AS inventory_status,

    -- Calculate total sale price of the order items
    SUM(oi.sale_price) OVER (PARTITION BY o.order_id) AS total_order_value
    
FROM 
    user_data u
LEFT JOIN
    order_data o ON u.user_id = o.user_id
LEFT JOIN
    order_items_data oi ON o.order_id = oi.order_id
LEFT JOIN
    product_data p ON oi.product_id = p.product_id
LEFT JOIN
    distribution_center_data dc ON p.distribution_center_id = dc.distribution_center_id
LEFT JOIN
    event_data e ON u.user_id = e.user_id
LEFT JOIN
    inventory_data inv ON p.product_id = inv.product_id



