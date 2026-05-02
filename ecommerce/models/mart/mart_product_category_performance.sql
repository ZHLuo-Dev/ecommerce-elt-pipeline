{{ config(
  materialized = 'table'
) }}

WITH src_order_items AS (
  SELECT * FROM {{ ref('src_order_items') }}
),
dim_products AS (
  SELECT * FROM {{ ref('dim_products') }}
),
src_orders AS (
  SELECT * FROM {{ ref('src_orders') }}
),
src_reviews AS (
  SELECT * FROM {{ ref('src_reviews') }}
),
order_reviews AS (
  SELECT
    order_id,
    AVG(review_score) AS avg_review_score
  FROM src_reviews
  GROUP BY order_id
),
order_category AS (
  SELECT
    oi.order_id,
    oi.order_item_id,
    oi.price,
    oi.freight_value,
    p.product_category,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATEDIFF('day', o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_days
  FROM src_order_items oi
  LEFT JOIN dim_products p ON oi.product_id = p.product_id
  LEFT JOIN src_orders o ON oi.order_id = o.order_id
)
SELECT
  oc.product_category,
  COUNT(DISTINCT oc.order_id) AS total_orders,
  COUNT(oc.order_item_id) AS total_items_sold,
  ROUND(SUM(oc.price), 2) AS total_revenue,
  ROUND(SUM(oc.price) / NULLIF(COUNT(DISTINCT oc.order_id), 0), 2) AS avg_order_value,
  ROUND(COUNT(oc.order_item_id)::FLOAT / NULLIF(COUNT(DISTINCT oc.order_id), 0), 2) AS items_per_order,
  ROUND(AVG(r.avg_review_score), 2) AS avg_review_score,
  ROUND(SUM(oc.freight_value), 2) AS total_freight,
  ROUND(AVG(oc.delivery_days), 1) AS avg_delivery_days,
  ROUND(
    SUM(CASE WHEN oc.order_status = 'canceled' THEN 1 ELSE 0 END)::FLOAT
    / NULLIF(COUNT(DISTINCT oc.order_id), 0), 4
  ) AS cancel_rate
FROM order_category oc
LEFT JOIN order_reviews r ON oc.order_id = r.order_id
GROUP BY oc.product_category
ORDER BY total_revenue DESC