{{ config(
  materialized = 'table'
) }}

WITH fct_orders AS (
  SELECT * FROM {{ ref('fct_orders') }}
),
src_order_items AS (
  SELECT * FROM {{ ref('src_order_items') }}
),
src_reviews AS (
  SELECT * FROM {{ ref('src_reviews') }}
),
dim_sellers AS (
  SELECT * FROM {{ ref('dim_sellers') }}
),
order_reviews AS (
  SELECT
    order_id,
    AVG(review_score) AS avg_review_score
  FROM src_reviews
  GROUP BY order_id
),
seller_orders AS (
  SELECT
    oi.seller_id,
    oi.order_id,
    oi.price,
    oi.freight_value,
    o.order_status,
    o.delivery_delay_days,
    o.order_delivered_customer_date
  FROM src_order_items oi
  LEFT JOIN fct_orders o ON oi.order_id = o.order_id
)
SELECT
  s.seller_id,
  s.seller_city,
  s.seller_state,
  COUNT(DISTINCT so.order_id) AS total_orders,
  SUM(so.price) AS total_revenue,
  AVG(so.price) AS avg_order_value,
  SUM(so.freight_value) AS total_freight,
  AVG(r.avg_review_score) AS avg_review_score,
  AVG(CASE WHEN so.delivery_delay_days > 0 THEN so.delivery_delay_days END) AS avg_delay_days,
  SUM(CASE WHEN so.delivery_delay_days > 0 THEN 1 ELSE 0 END)::FLOAT
    / NULLIF(SUM(CASE WHEN so.order_delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END), 0)
    AS late_delivery_rate
FROM dim_sellers s
LEFT JOIN seller_orders so ON s.seller_id = so.seller_id
LEFT JOIN order_reviews r ON so.order_id = r.order_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
